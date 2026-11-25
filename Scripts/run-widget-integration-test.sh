#!/usr/bin/env bash
# A fresh simulator keeps widget and team fixtures isolated between runs.
set -euo pipefail

# Optional build roots let task verification reuse its pinned package checkout.
if [[ "$#" -lt 1 || "$#" -gt 3 ]]; then
    echo "Usage: $0 <new-evidence-directory> [derived-data-directory] [cloned-package-directory]" >&2
    exit 64
fi

evidence_root=$1
if [[ -z "$evidence_root" || -e "$evidence_root" || -L "$evidence_root" ]]; then
    echo "Evidence directory must be a new, non-root path." >&2
    exit 73
fi
evidence_root=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve())' "$evidence_root")
if [[ "$evidence_root" == "/" || -e "$evidence_root" || -L "$evidence_root" ]]; then
    echo "Evidence directory must be a new, non-root path." >&2
    exit 73
fi

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
repo_root=$(cd "$script_dir/.." && pwd -P)

paths_overlap() {
    local left=$1
    local right=$2
    [[ "$left" == "$right" || "$left" == "$right/"* || "$right" == "$left/"* ]]
}

validate_external_root() {
    local description=$1
    local path=$2
    local resolved

    if [[ -z "$path" || "$path" == *$'\n'* || "$path" == *$'\r'* || -L "$path" ]]; then
        echo "$description must be a safe directory path." >&2
        return 73
    fi

    resolved=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).expanduser().resolve())' "$path")
    if [[ "$resolved" == "/" || ( -e "$resolved" && ! -d "$resolved" ) ]]; then
        echo "$description must be a non-root directory." >&2
        return 73
    fi
    if paths_overlap "$resolved" "$repo_root" || paths_overlap "$resolved" "$evidence_root"; then
        echo "$description must not overlap the repository or evidence directory." >&2
        return 73
    fi

    printf '%s' "$resolved"
}

# Validate Xcode's default package subdirectory before using it for pinned verification.
validate_derived_source_packages_root() {
    local path="$derived_data_root/SourcePackages"
    local resolved

    if [[ -L "$path" ]]; then
        echo "Cloned package checkout must not be a symbolic link." >&2
        return 73
    fi

    resolved=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).expanduser().resolve())' "$path")
    if [[ "$resolved" != "$path" || "$resolved" == "/" || ( -e "$resolved" && ! -d "$resolved" ) ]]; then
        echo "Cloned package checkout must stay within DerivedData and name a directory." >&2
        return 73
    fi
    if [[ "$resolved" != "$derived_data_root/"* ]] || paths_overlap "$resolved" "$repo_root" || paths_overlap "$resolved" "$evidence_root"; then
        echo "Cloned package checkout must not overlap the repository or evidence directory." >&2
        return 73
    fi

    printf '%s' "$resolved"
}

# Keep one-argument calls on Xcode's default package resolution. Explicit roots select pinned verification.
derived_data_root="$evidence_root/DerivedData"
cloned_packages_root="$derived_data_root/SourcePackages"
explicit_verification=0
if [[ "$#" -ge 2 ]]; then
    explicit_verification=1
    derived_data_root=$(validate_external_root "DerivedData" "$2")
    cloned_packages_root="$derived_data_root/SourcePackages"
fi
if [[ "$#" -ge 3 ]]; then
    cloned_packages_root=$(validate_external_root "Cloned package checkout" "$3")
    if paths_overlap "$derived_data_root" "$cloned_packages_root"; then
        echo "DerivedData and cloned package directories must not overlap." >&2
        exit 73
    fi
elif [[ "$explicit_verification" -eq 1 ]]; then
    cloned_packages_root=$(validate_derived_source_packages_root)
fi

database_build_setting=
if [[ "$explicit_verification" -eq 1 ]]; then
    if [[ ${PIKADEX_GENERATED_DATABASE_PATH+x} != x ]]; then
        echo "PIKADEX_GENERATED_DATABASE_PATH is required for explicit verification." >&2
        exit 73
    fi
    database_path=$PIKADEX_GENERATED_DATABASE_PATH
    if [[ "$database_path" == *$'\n'* || "$database_path" == *$'\r'* || "$database_path" != /* || ! -f "$database_path" || -L "$database_path" || ! -s "$database_path" ]]; then
        echo "PIKADEX_GENERATED_DATABASE_PATH must name an existing, non-empty database file by an absolute path." >&2
        exit 73
    fi
    database_path=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).resolve())' "$database_path")
    if paths_overlap "$derived_data_root" "$database_path"; then
        echo "DerivedData must not overlap the database input." >&2
        exit 73
    fi
    if paths_overlap "$cloned_packages_root" "$database_path"; then
        echo "Cloned package directory must not overlap the database input." >&2
        exit 73
    fi
    database_build_setting="PIKADEX_GENERATED_DATABASE_PATH=$database_path"
fi

mkdir -p "$(dirname "$evidence_root")"
mkdir "$evidence_root"
cd "$repo_root"

simulator_name="PikaDex Widget Integration Disposable $(uuidgen)"
simulator_id=$(xcrun simctl create \
    "$simulator_name" \
    com.apple.CoreSimulator.SimDeviceType.iPhone-17 \
    com.apple.CoreSimulator.SimRuntime.iOS-27-2)

cleanup_simulator() {
    local exit_status=$?
    trap - EXIT
    if [[ "$simulator_id" =~ ^[A-F0-9-]{36}$ ]]; then
        if ! xcrun simctl delete "$simulator_id"; then
            echo "Could not remove disposable simulator $simulator_id." >&2
            if [[ "$exit_status" -eq 0 ]]; then
                exit_status=1
            fi
        fi
    fi
    exit "$exit_status"
}
trap cleanup_simulator EXIT

if [[ ! "$simulator_id" =~ ^[A-F0-9-]{36}$ ]]; then
    echo "Simulator creation returned an invalid device identifier." >&2
    exit 1
fi

xcrun simctl boot "$simulator_id"
xcrun simctl bootstatus "$simulator_id" -b

actual_name=$(xcrun simctl getenv "$simulator_id" SIMULATOR_DEVICE_NAME)
actual_id=$(xcrun simctl getenv "$simulator_id" SIMULATOR_UDID)
if [[ "$actual_name" != "$simulator_name" || "$actual_id" != "$simulator_id" ]]; then
    echo "Created simulator identity did not match the requested identity." >&2
    exit 1
fi

xcrun simctl spawn "$simulator_id" launchctl setenv \
    PIKADEX_WIDGET_TEST_SIMULATOR_NAME "$simulator_name"
xcrun simctl spawn "$simulator_id" launchctl setenv \
    PIKADEX_WIDGET_TEST_SIMULATOR_UDID "$simulator_id"

test "$(xcrun simctl spawn "$simulator_id" launchctl getenv PIKADEX_WIDGET_TEST_SIMULATOR_NAME)" \
    = "$simulator_name"
test "$(xcrun simctl spawn "$simulator_id" launchctl getenv PIKADEX_WIDGET_TEST_SIMULATOR_UDID)" \
    = "$simulator_id"

xcodebuild_args=(
    test
    -project Pokedex.xcodeproj
    -scheme Pokedex
    -destination "platform=iOS Simulator,id=$simulator_id"
    -only-testing:PokedexUITests/WidgetIntegrationTests/testWidgetRendersSelectedTeamAndOpensTeamsSection \
    -parallel-testing-enabled NO \
    -derivedDataPath "$derived_data_root"
    -resultBundlePath "$evidence_root/widget-integration.xcresult"
)
if [[ "$explicit_verification" -eq 1 ]]; then
    xcodebuild_args+=(
        -disableAutomaticPackageResolution
        -onlyUsePackageVersionsFromResolvedFile
        -skipPackageUpdates
        -clonedSourcePackagesDirPath "$cloned_packages_root"
    )
fi
if [[ -n "$database_build_setting" ]]; then
    xcodebuild_args+=("$database_build_setting")
fi

xcodebuild "${xcodebuild_args[@]}" \
    2>&1 | tee "$evidence_root/widget-integration.log"

xcrun xcresulttool get test-results summary \
    --path "$evidence_root/widget-integration.xcresult" \
    | tee "$evidence_root/widget-integration-summary.json" \
    | python3 -c '
import json
import sys

summary = json.load(sys.stdin)
passed = summary.get("passedTests", 0)
failed = summary.get("failedTests", 0)
skipped = summary.get("skippedTests", 0)
result = summary.get("result")
if result != "Passed" or passed != 1 or failed != 0 or skipped != 0:
    print(
        f"Expected one passed widget test and no failures or skips; "
        f"got result={result}, "
        f"passed={passed}, failed={failed}, skipped={skipped}.",
        file=sys.stderr,
    )
    sys.exit(1)
print("Widget integration passed once with no skips.")
'
