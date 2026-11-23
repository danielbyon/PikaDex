#!/usr/bin/env bash
# A fresh simulator keeps widget and team fixtures isolated between runs.
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $0 <new-evidence-directory>" >&2
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
mkdir -p "$(dirname "$evidence_root")"
mkdir "$evidence_root"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "$script_dir/.." && pwd)
cd "$repo_root"

simulator_name="PikaDex Issue 20 Disposable $(uuidgen)"
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

xcodebuild test \
    -project Pokedex.xcodeproj \
    -scheme Pokedex \
    -destination "platform=iOS Simulator,id=$simulator_id" \
    -only-testing:PokedexUITests/WidgetIntegrationTests/testWidgetRendersSelectedTeamAndOpensTeamsSection \
    -parallel-testing-enabled NO \
    -derivedDataPath "$evidence_root/DerivedData" \
    -resultBundlePath "$evidence_root/widget-integration.xcresult" \
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
