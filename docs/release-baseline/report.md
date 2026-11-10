# PikaDex Issue #9 A1: Build and Test Baseline

## 1. Outcome

The A1 inventory and evidence report are complete for PikaDex commit `21df33f44a6818522bdb54544a07415a8efb6d13`. The canonical runner passed preflight, catalog generation, the Pokedex simulator build, and three XCTest suites. It stopped at the `DatabasePipelineTests` build-for-testing gate when the filesystem ran out of space. That test suite did not launch. No Release device archive or IPA size was measured.

The canonical runner recorded exit code `65` for `DatabasePipelineTests`. Its final log reports that the compiler could not write `Foundation.pcm` and Xcode could not save its activity log (`No space left on device`). The runner stopped after that gate. The zsh wrapper used to capture the process status tried to assign to zsh's read-only `status` variable and returned `1`; the runner status is reconciled to `65` from its own failure line and exit path. The wrapper issue did not rerun or change the canonical result.

## 2. Source and Environment

The original checkout was on `main` at `21df33f44a6818522bdb54544a07415a8efb6d13` with a clean tracked tree at execution preflight. Verification ran in a disposable checkout at the same commit. The crawler checkout was isolated at `0e5672b16e66c78140a699ef32812cdc2f0d4a15`.

The runner received explicit values for `PIKADEX_CRAWLERS_ROOT`, `PIKADEX_SIMULATOR_DESTINATION`, and `PIKADEX_RELEASE_BUILD_ROOT`. It used the iPhone 17 simulator, UDID `AA0281A0-B2BF-4A39-A095-724F98DA3EFF`, on iOS 27.0. Installed simulator runtimes included iOS 27.0, 27.1, and 27.2. The inventory showed no available device on 27.1; the iPhone Duo destination was listed on 27.2 and was not used for this run. No Duo pose or qualification claim is made.

Toolchain evidence records Xcode 27.2 (build 27B52), Swift 6.4.2, iOS device SDK 27.2, and iOS Simulator SDK 27.2. iOS 26.5 was not available in the installed runtime inventory, and no iOS 27.1 device was listed.

The primary checkout's ignored `Pokedex.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved` had been refreshed by a planning-time `xcodebuild -list` before the execution snapshot. Its earlier bytes are unknown. The preflight and final SHA-256 were both `96cc4f8a5a08cf0a1e64dd56072d66b1af32a464145dbd371343b3e4faefcaa8`; the file was left untouched during execution. The original checkout HEAD and tracked files remained unchanged by verification. The only intended repository changes from this task are this report, the manifest, and this run's `RESULT.json`.

## 3. Targets, Schemes, and Effective Settings

The project has 16 native targets: `DatabaseLoader`, `DatabasePipeline`, `DatabasePipelineSupport`, `DatabasePipelineTests`, `DatabaseValidator`, `DesignSystem`, `Pokedex`, `PokedexConcurrencyTests`, `PokedexCore`, `PokedexCoreTests`, `PokedexResources`, `PokedexTests`, `PokedexUI`, `PokedexUITests`, `PokedexWidgetExtension`, and `TeamIntentHandler`. The external inventory records each target dependency and product type.

There are 11 shared schemes with no checked-in test plans. `xcodebuild -list` reports 12 schemes; the additional `DatabasePipelineSupport` scheme has no shared scheme file. Shared test actions use Debug. The inventory retains the full Debug and Release `xcodebuild -showBuildSettings -alltargets -json` output.

All 16 targets report Swift language version `5.0`. iOS targets use deployment target `17.0`; macOS targets use `14.0`. Multiplatform frameworks report both. Effective `SWIFT_STRICT_CONCURRENCY` is `targeted` in Debug for `Pokedex`, `PokedexTests`, `PokedexConcurrencyTests`, `PokedexCore`, `PokedexUI`, `DesignSystem`, `PokedexResources`, `PokedexWidgetExtension`, and `TeamIntentHandler`. In Release it is `targeted` only for `PokedexTests` and `PokedexConcurrencyTests`. It is unset for the other target/configuration combinations; unset is not reported as a stricter checking mode.

## 4. Canonical Gate Results and XCTest Counts

| Gate | Expected cases | Executed | Result | Skips | Evidence |
| --- | ---: | ---: | --- | ---: | --- |
| Preflight | — | — | pass | — | Canonical log and execution preflight record |
| Data pipeline generate, validate, install | — | — | pass | — | Runner summary reports each phase passed; candidate database retained externally |
| Pokedex simulator build | — | — | pass | — | Canonical log |
| Modules | 61 | 61 | pass, 61 passed | 0 | `Modules.xcresult` and extracted case list |
| PokedexTests | 6 | 6 | pass, 6 passed | 0 | `PokedexTests.xcresult` and extracted case list |
| PokedexConcurrencyTests | 16 | 16 | pass, 16 passed | 0 | `PokedexConcurrencyTests.xcresult` and extracted case list |
| DatabasePipelineTests build-for-testing | 37 declared | 0 | fail, exit 65 | not applicable | `Foundation.pcm` and Xcode activity-log writes failed with `No space left on device` |
| DatabasePipelineTests XCTest | 37 declared | 0 | not run | not reported | Build-for-testing failed before XCTest launch; no result bundle was produced |
| PokedexUITests | 2 declared | 0 | not run | not reported | Not invoked by the canonical runner |
| Release device archive size | — | — | not run | — | Runner stopped before any separate Release archive measurement |

For each executed suite, the extracted XCTest names match the expected source inventory exactly: no expected case was missing, no unexpected case ran, and no case was skipped. DatabasePipelineTests has 37 source-declared cases, but none executed. The two UI methods are `testExample` and `testLaunchPerformance`; source presence is not execution evidence or feature-flow coverage.

The canonical runner's gate sequence was `preflight`, `data pipeline generate`, `Pokedex build`, `Modules`, `PokedexTests`, `PokedexConcurrencyTests`, then `DatabasePipelineTests`. It exited at the last gate; it did not report later gates or overall success.

## 5. Input Provenance, CI, and Network Boundaries

The pinned `Scripts/DataPipeline/pipeline-manifest.json` declares 69 reviewed source inputs. All 69 actual input hashes matched: 58 from the PikaDex checkout and 11 from the isolated crawler checkout. The run also retained the source manifest and `crawler-source.json` hashes and the exact `Scripts/DataPipeline/Package.resolved` hash.

Catalog generation used the pinned local source checkout and completed preflight, normalization, generation, validation, and installation. No crawler acquisition was invoked. The separate SwiftPM provisioning step used pinned resolved versions; the log reports package fetches as cached and does not establish network denial for provisioning. Catalog generation itself used reviewed local inputs through the network-denied helper. The simulator XCTest commands disabled automatic package resolution and package updates. The `DatabasePipelineTests` XCTest network-denial helper was not reached because its build failed first. The app simulator suites were not run inside that network-denial helper.

`.github/workflows/ci.yml` currently runs Modules and DatabasePipelineTests. The local canonical runner also builds Pokedex and runs PokedexTests and PokedexConcurrencyTests. In this run the latter three simulator gates passed; the DatabasePipelineTests build gate failed before its tests. CI parity remains Issue #10 work.

## 6. Feature and Prior-Install Evidence

| Journey or persisted state | Existing evidence | Gap for later work |
| --- | --- | --- |
| Reference browsing and catalog reads | Modules tests cover bundled database loading, generated snapshot counts, dataset completeness, and representative read-only catalog access. | No end-to-end browsing flow was exercised. |
| Search and relationships | Modules tests assert request filtering, sorting, batching, prefetching, relationship-heavy request settings, and query updates. | These are data/query assertions; no search-to-detail UI journey ran. |
| Team editing and autosave | Modules tests cover PokePaste output. Concurrency tests cover synchronous flush and deliberate discard of an unflushed snapshot. | No complete edit/reopen UI flow or prior-install app-group round trip was tested. |
| Battle tools | No executed assertion was identified for a complete battle-tool user journey. | Feature behavior needs later C-scope evidence. |
| Settings, StoreKit, and entitlements | Concurrency tests cover request completion, cancellation, replacement, shutdown, and disabled payments. | Purchase UI, entitlement persistence, and selected-game behavior across an upgrade were not exercised. |
| Widgets and intents | Widget and intent targets are present in the target inventory. | No widget/intent functional test ran. |
| Prior-install user data | Persistence tests cover store bootstrap, read-only bundled catalog behavior, error handling, and stable game-bit compatibility. | No controlled old-install fixture covers app-group records, team data, selected game, purchases, or interrupted migration. Issue #8/D owns this follow-up. |
| UI smoke | `PokedexUITests` declares only `testExample` and `testLaunchPerformance`. | Neither method ran; these declarations do not prove feature coverage. |

## 7. Release-Size Evidence and Follow-ups

No shipping-configuration size is reported. The uncompressed Release device `PikaDex.app` bundle was **not measured**, and no distributable IPA was produced or measured. Debug simulator app products are retained as build evidence but are not substitutes for either value. No distribution or OTA threshold is inferred.

### Reproducible Release Archive Procedure

Run this in a fresh disposable checkout at `21df33f44a6818522bdb54544a07415a8efb6d13`, with the isolated crawler checkout pinned to `0e5672b16e66c78140a699ef32812cdc2f0d4a15`. Set `EVIDENCE_ROOT` to a durable directory outside the repository and `PIKADEX_CRAWLERS_ROOT` to that crawler checkout. Generate and validate the reviewed catalog before archiving; do not run acquisition:

```sh
export EVIDENCE_ROOT="/path/to/durable/external/release-size"
export PIKADEX_CRAWLERS_ROOT="/path/to/isolated/PikaDexCrawlers-at-0e5672b16e66c78140a699ef32812cdc2f0d4a15"

PIKADEX_PIPELINE_BUILD_ROOT="$EVIDENCE_ROOT/PipelineTooling" \
  Scripts/pokedex-data-pipeline generate \
  --output-dir "$EVIDENCE_ROOT/PipelineOutput"

PIKADEX_RELEASE_BUILD_ROOT="$EVIDENCE_ROOT/runner" \
  xcodebuild archive \
  -project Pokedex.xcodeproj \
  -scheme Pokedex \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath "$EVIDENCE_ROOT/PikaDex-Release.xcarchive" \
  -derivedDataPath "$EVIDENCE_ROOT/ArchiveDerivedData" \
  -disableAutomaticPackageResolution \
  -onlyUsePackageVersionsFromResolvedFile \
  -skipPackageUpdates
```

Use the project's Release signing settings. Capture the archive command, full log, and true exit code outside the repository as `archive.log` and `archive.exit`. Measure the uncompressed app bundle at `PikaDex-Release.xcarchive/Products/Applications/PikaDex.app` by summing `st_size` for regular files recursively under that bundle without following symlinks. Store the byte count and regular-file count in `release-app-size.json`. This Python command reports those values:

```sh
APP_BUNDLE="$EVIDENCE_ROOT/PikaDex-Release.xcarchive/Products/Applications/PikaDex.app"
python3 - "$APP_BUNDLE" <<'PY'
import os
import stat
import sys

root = sys.argv[1]
logical_bytes = 0
regular_files = 0
for current, directories, names in os.walk(root, followlinks=False):
    directories[:] = [name for name in directories if not os.path.islink(os.path.join(current, name))]
    for name in names:
        path = os.path.join(current, name)
        metadata = os.lstat(path)
        if stat.S_ISREG(metadata.st_mode):
            logical_bytes += metadata.st_size
            regular_files += 1
print(f"logical_bytes={logical_bytes}")
print(f"regular_files={regular_files}")
PY
```

Record those counts, the bundle path, and source commit. This excludes archive metadata and disk-allocation overhead.

If a distributable IPA is separately exported, record its file byte length with `stat -f %z "$IPA_PATH"` and retain the export options used. Keep that compressed IPA measurement separate from the uncompressed `.app` bundle count; do not infer one from the other.

This procedure was **not executed**. The canonical run stopped at the DatabasePipelineTests build gate after Xcode reported `No space left on device` while writing `Foundation.pcm` and its activity log; the last observed free-space reading at the failure was 121 MiB. No archive or IPA was created. Issue #8/D should repeat the procedure with adequate free space and report both measurements separately if an IPA is produced. Other follow-ups remain Issue #10 CI parity, Issue #11 Duo feasibility, and Issue #7/C feature-journey evidence. No work from those issues is included here.

## 8. External Evidence and Retention

Large logs, `.xcresult` bundles, the generated SQLite candidate, normalized input copies, DerivedData, and compiled app/test products are outside the repository at:

`/Users/daniel/.codex/artifacts/pikadex/issue-9-a1/2026-11-09T220316Z-issue-9-a1-pikadex-build-and-test-baseline`

`manifest.json` lists exact evidence paths, byte counts, SHA-256 values or deterministic directory-tree hashes, source commit, and retention requirements. Keep the evidence through Issue #9 A1 maintainer review and completion of Issues #7/C and #8/D; do not auto-delete it. The `/private/tmp` checkouts were not cleaned up in this run.
