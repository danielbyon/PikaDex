# iPhone Duo native transition procedure

Issue #11 A3 records a repeatable way to observe native iPhone Duo transitions and separates that work from app correctness and release qualification. This runbook describes the supported controls, the probe needed to assess the newer XCTest interface, and the cases that this execution could not observe.

## Execution status

The initial A3 execution on 2026-11-12 in America/Los_Angeles verified the environment but could not access Device Hub; both UI bridge attempts timed out. It produced no transition screenshots, recordings, test result bundle, or beta probe source. That result remains in the initial evidence record.

A continuation UI check at 2026-11-12 19:39 Pacific opened Device Hub. Its visible device list did not include the iPhone Duo, and searching for “iPhone Duo” returned no results. Clearing the search restored the list without the Duo. One subsequent scroll request failed with `-10005: noWindowsAvailable`; no further UI attempts were made. A fresh `simctl` inventory still reported the Duo simulator as available and shut down. No native pose action was performed, and no pose screenshot or recording exists. Stable native transitions remain **BLOCKED** because the intended simulator was not selectable in Device Hub.

### Follow-up: Duo visible in Device Hub

A further check on 2026-11-12 found an available, booted iPhone Duo on iOS 27.2. Device Hub selected it and rendered its current screen, so View Screen worked. The Apps inspector showed “No Developer Apps” before installation. The visible controls included Closed, Partially Open, Open, and Rotate Right.

Selecting Closed produced the row description `v68_Closed`, and the visible device remained closed. It was already closed before the click, so this did not exercise a transition. The CUA response included a screenshot of the Device Hub window, but no file or hash could be retained. Opening the macOS Screenshot app through CUA then failed with `-10005: timeoutReached`; no further GUI actions were made.

The Pokedex scheme build output ended with `BUILD SUCCEEDED`. Its zsh wrapper did not capture the process exit code because it assigned to zsh’s read-only `status` variable. The resulting app installed successfully, and `simctl launch` returned a process ID. These results confirm the build output and process launch only. Device Hub was not checked again after installation, and no app correctness or persistence claim was made.

The later inventory measured 9.6 GiB free on the internal volume, below the 10 GiB minimum. A read-only check at 22:35 PST measured 3.76 GiB free; no build, simulator boot, installation, or cleanup followed the below-floor readings. The external A3 directory measures 3.6 GiB, above the 2 GiB evidence budget, because it still contains the new DerivedData tree. The proposed cleanup covered this run's DerivedData, cloned package directory, and temp directory; local safety review rejected it before execution, so no artifacts were copied or removed. The Xcode 27.3 beta was not installed.

This runbook covers A3 mechanism feasibility only:

- C1/C2 own deterministic state and persistence assertions.
- C4 owns native feature smoke and continuity checks.
- D2 owns final device and hardware qualification.

No production code, test framework, test target, or project configuration changed. The temporary beta test was not created. The original `PokedexUITests.swift` SHA-256 is `4fd3ce30b22e279b17d5e6f88cd94e4be57c76f3d71241abea7ad62a8e0c5537` and remains the source-restoration reference.

## Verified environment

| Item | Observed value |
| --- | --- |
| Host macOS | 27.0.1 |
| Stable Xcode | `/Applications/Xcode-27.2.0.app`, Xcode 27.2, build 27B52 |
| Swift compiler | Swift 6.4.2, swift-driver 1.168.6 |
| iOS Simulator SDK | 27.2 |
| Duo runtime | iOS 27.2, build 24B91016s, runtime identifier `com.apple.CoreSimulator.SimRuntime.iOS-27-2-iPhone19-4` |
| Duo simulator | `iPhone Duo`, device type `com.apple.CoreSimulator.SimDeviceType.iPhone-Duo`, iOS 27.2 runtime build 24B91016s; the latest inventory found it available and `Booted`. An earlier inventory reported `Shutdown`. Its current UDID is in the owner-managed manifest. |
| Connected physical Duo | The previous `devicectl` inventory listed an iPhone 17 Pro Max and no Duo; physical-device inventory was not repeated in the latest follow-up. |
| UI test target | `PokedexUITests` in the `Pokedex` scheme; current file has `testExample` and `testLaunchPerformance` |

The original and continuation inventories, UI-access records, and manifests remain in owner-managed external evidence storage. Each manifest lists retained artifacts and SHA-256 values. The simulator UDID is kept in that local evidence. No A1 report or manifest was changed; the A1 evidence root named in its manifest was absent on this host and was not recreated or altered.

## Automation findings

| Mechanism | Finding | A3 result |
| --- | --- | --- |
| Stable headless hinge control | The installed Xcode 27.2 `simctl` help exposes generic screen geometry and simulator I/O, but no fold, hinge, or pose operation. `screenConfig geometry` changes screen geometry; it does not demonstrate a fold transition. | No stable headless pose command identified. |
| XCTest orientation | `XCUIDevice.shared.orientation` simulates device orientation. It does not set a Duo hinge angle. | Orientation automation is separate from folding. |
| `devicectl` | Its installed help contains no fold, hinge, or pose operation. The attached-device inventory contains no physical Duo. | No Duo transition mechanism identified. |
| Stable Device Hub | Apple documents Closed, Partially Open, and Open controls, plus Option-drag on the slider to set other angles. The initial UI bridge timed out twice. The next check found no Duo in the visible list, and a later scroll request failed with `-10005: noWindowsAvailable`. The latest check selected the booted Duo and rendered its screen. It exposed Closed, Partially Open, Open, and Rotate Right. Selecting Closed left the `v68_Closed` state unchanged; a later CUA screenshot-tool lookup timed out. | Device Hub visibility and View Screen are verified. The closed state was observed, but no transition or retained chassis capture was produced. Other native cases remain BLOCKED. |
| Xcode 27.3 beta `XCUIHinge` | Apple’s beta release notes say `XCUIAutomation` can set an iPhone Duo hinge angle using `XCUIHinge`. The beta and iOS 27.3 runtime were not installed; the actual public declarations and availability were not inspected, and no test was built or executed. | Documented candidate only; executable feasibility is BLOCKED. This is not a stable release gate. |
| Generic resizing | `simctl` can change screen geometry and UI tests can exercise app UI. Neither action proves a native fold or hinge transition. | Not accepted as native pose coverage. |

Apple’s Xcode 27.3 beta notes require macOS Tahoe 26.6 or later; this host’s macOS 27.0.1 meets that version requirement. The initial A3 checks reported 12–16 GiB free on the internal data volume. The continuation check reported 6.8 GiB internal and 727 GiB external free. During the latest follow-up, internal free space was above 10 GiB before the stable build and app install, then measured 9.6 GiB at 21:45 PST. Read-only checks measured 6.05 GiB at 22:13 PST and 3.76 GiB at 22:35 PST, both below the 10 GiB minimum; no build, simulator boot, installation, or cleanup followed. The beta app and iOS 27.3 simulator runtime remain absent. Apple’s [Xcode components guide](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components) describes runtime installation but does not state the footprint for this beta/runtime. The earlier A1 disk-capacity failure, current below-floor readings, and unverified package footprint leave no safe installation plan. No beta download, installation, or runtime mutation was attempted; no credentials were entered. Owner disposition requires a verified storage plan for the official beta, Duo runtime, build products, and a safety margin before installation.

## Stable manual procedure

### Preconditions

1. Use Xcode 27.2 build 27B52 and the `iPhone Duo` simulator on the iOS 27.2 runtime listed above. Re-run `xcodebuild -version`, `xcrun swift --version`, `xcrun --sdk iphonesimulator --show-sdk-version`, `xcrun simctl list runtimes`, and `xcrun simctl list devices available`; record the output with the run.
2. Check free space before building, booting, or installing. Keep at least 10 GiB free on the internal volume. Keep DerivedData and retained evidence on a task-specific directory on the external evidence volume. Stop if the internal volume falls below the minimum. Do not erase the simulator, remove runtimes, or clear app data to make space.
3. Open `Pokedex.xcodeproj` in Xcode 27.2, select the `Pokedex` scheme and the iPhone Duo destination on the verified iOS 27.2 runtime, then Run. Open Device Hub, select that running Duo, and click **View Screen**. If the Duo is not listed, record the Device Hub state and stop with **BLOCKED**; do not substitute another simulator or generic resizing. A successful build or launch is not a transition result.
4. Create a new run directory under an owner-selected external evidence root, using a unique UTC timestamp. The approved total cap remains 2 GiB; this procedure does not grant an exception. Record the exact simulator and runtime identity in the private manifest before capturing. This follow-up's evidence directory currently occupies about 3.6 GiB, primarily because it contains the retained build's DerivedData. The proposed cleanup of this run's DerivedData, cloned package directory, and temp directory was rejected before execution. Do not add captures or start another A3 run until the owner documents whether DerivedData counts against the 2 GiB cap and how cumulative retained evidence will remain within the cap while preserving existing artifacts. If no compliant disposition is available, mark additional evidence capture **BLOCKED**. Do not retry cleanup or delete, move, or overwrite retained baseline or unrelated evidence.

### Transition observations

For each case, capture a Device Hub screenshot after the screen settles. A single short Device Hub recording may cover the sequence; record the filename and SHA-256. Apple’s screenshot and recording controls save to the Desktop, so copy each A3 capture to the external run directory and retain the source path in the manifest. Do not remove a Desktop file unless its A3 ownership and retained copy have both been verified.

1. In portrait orientation, select **Closed** and record the outer display.
2. Select **Partially Open** and record the inner display, visible hinge region, and the UI around it.
3. Select **Open** and record the inner display.
4. Hold Option and drag the hinge slider to two repeatable intermediate positions, approximately one-third and two-thirds of its travel. Record those as slider fractions. Record an angle in degrees only if Device Hub or a verified probe displays one; do not infer degrees from slider position.
5. Repeat the relevant closed, partially open, and open observations in landscape. Use **Device > Orientation** or the documented rotate controls, and record the chosen orientation separately from the hinge pose.
6. Use the iPhone Duo system Split View gesture to place PikaDex on the left side, capture the result, then repeat with PikaDex on the right. Record the other app, side, orientation, and pose. This also provides the narrow-window observation. Do not substitute a generic simulator resize for system Split View.
7. For each captured state, note the visible screen/display, device pose, orientation, split side if applicable, and any safe-area or window boundary that can be observed. A screenshot records appearance; without app instrumentation it does not report numeric safe-area insets. These are mechanism observations, not assertions that the app layout, navigation, data, or persistence is correct.

The Device Hub controls are described in [Apple’s Device Hub guide](https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-device-hub). Apple describes iPhone Duo Split View as a 50/50 system layout created by dragging an app to a side in [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111466/). Device Hub screenshot and recording behavior is documented in [Capturing screenshots and videos from devices](https://developer.apple.com/documentation/xcode/capturing-screenshots-and-videos-from-devices).

### Stable coverage matrix

| Case | Operation | Success evidence | This run |
| --- | --- | --- | --- |
| Closed / outer display | Device Hub **Closed** control | Device Hub frame shows closed Duo; screenshot records the outer display | BLOCKED for transition evidence: `v68_Closed` was observed, but the Duo was already closed and no hashed chassis capture was retained |
| Partially open | Device Hub **Partially Open** control | Device Hub frame shows partial pose and hinge | BLOCKED: control was visible; after the Closed selection, opening the macOS Screenshot app through CUA timed out, so no further controls were used |
| Open / inner display | Device Hub **Open** control | Device Hub frame shows open Duo and inner display | BLOCKED: control was visible; after the Closed selection, opening the macOS Screenshot app through CUA timed out, so no further controls were used |
| Intermediate A | Option-drag to about 1/3 slider travel | Screenshot or short recording shows a changed native Duo pose; store the fraction, not an assumed angle | BLOCKED: no intermediate action or retained capture |
| Intermediate B | Option-drag to about 2/3 slider travel | Same evidence as A, at a distinct slider position | BLOCKED: no intermediate action or retained capture |
| Portrait and landscape | Device > Orientation or rotate controls | Record orientation and a Device Hub capture for the selected pose | BLOCKED: the closed portrait state was visible; no orientation change was made before the CUA timeout |
| Split View, left | Place PikaDex on left in system Split View | Device Hub capture shows PikaDex on the left and the other app on the right | BLOCKED: not observed; Device Hub was not revisited after installing PikaDex |
| Split View, right | Place PikaDex on right in system Split View | Device Hub capture shows PikaDex on the right and the other app on the left | BLOCKED: not observed; Device Hub was not revisited after installing PikaDex |
| Safe area and narrow window | Observe outer/inner display and each Split View side | Record visible boundaries; numeric insets remain unavailable without instrumentation | BLOCKED: no app view, Split View, narrow-window, or safe-area observation was retained |
| Generic geometry change | `simctl screenConfig geometry` | Geometry may change; this is not evidence of folding | NOT RUN; excluded from native pose coverage |

## Xcode 27.3 beta probe procedure

Apple’s [Xcode 27.3 beta release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27_3-release-notes) identify `XCUIHinge`. The [Xcode system requirements](https://developer.apple.com/xcode/system-requirements/) and release notes specify macOS Tahoe 26.6 or later. The owner must establish a safe storage plan and use only Apple’s official Xcode beta download. Do not change global `xcode-select`; set `DEVELOPER_DIR` on each command to the beta’s `Contents/Developer` path. Stop before download if Apple credentials, a new permission, or additional storage approval is required.

After the beta and its iOS 27.3 Duo runtime are installed safely:

1. Record Xcode build, macOS version, Swift version, iOS SDK/runtime build, simulator device type and UDID, and free space. Inspect the installed public `XCUIHinge` declarations and availability. Record the declaration file, accepted angle type and units, supported range, set/get behavior, and any simulator or OS availability annotation. Do not implement against a release-note mention alone or use private APIs.
2. Add one temporary test method to the existing `PokedexUITests` source and use the existing `PokedexUITests` target in the `Pokedex` scheme. Save the exact temporary source and its SHA-256 outside the repository before running. Do not add a target or framework.
3. Request closed, partially open, open, and two documented intermediate angles. Record the requested value and units. Where the public API exposes an observable native state, capture that state; compare requested and observed angles. A setter returning successfully or a changed app frame alone is not proof that the simulator folded.
4. Use a unique external DerivedData path and result bundle. After the API declaration and test method are verified, run only that method, with an exact iOS 27.3 Duo destination and beta selected per command. Example command shape (fill paths and UDID from the verified install; this command was **not run**):

   ```sh
   DEVELOPER_DIR="/path/to/Xcode-27.3-beta.app/Contents/Developer" \
   xcodebuild test \
     -project Pokedex.xcodeproj \
     -scheme Pokedex \
     -destination 'platform=iOS Simulator,id=<verified-ios-27.3-duo-udid>' \
     -derivedDataPath '<external-run-directory>/DerivedData' \
     -resultBundlePath '<external-run-directory>/DuoHingeProbe.xcresult' \
     -only-testing:PokedexUITests/PokedexUITests/testNativeDuoHingeAngleProbe \
     -parallel-testing-enabled NO
   ```

5. Retain the exact source and hash, command, stdout/stderr log, `.xcresult`, screenshots or recording, environment inventory, requested/observed values and units, deviations, and executed/passed/failed/skipped counts. Report a setter-only result as inconclusive. Restore `PokedexUITests.swift` and verify the original SHA-256 before review.
6. Do not delete runtimes, databases, A1 evidence, or unrelated checkout state. Remove exact A3-owned temporary products only after verifying the retained evidence copy and obtaining owner authorization. If a proposed cleanup is rejected, do not retry it; stop capture and record the overage until the owner documents a safe disposition.

No beta probe source or executed test invocation exists for this run; the command above is an unexecuted template. Probe tests executed: 0; passed: 0; failed: 0; skipped: 0. These are execution counts, not a passing result. The beta probe outcome is **BLOCKED before API inspection** and is not a stable release gate. `XCUIDevice.orientation` is documented separately as a device orientation control and does not replace the hinge API ([Apple documentation](https://developer.apple.com/documentation/xcuiautomation/xcuidevice/orientation)).

## Evidence handling and result classification

Use `<owner-selected-external-evidence-root>/<UTC-run-id>/` for each run. Keep its evidence manifest, command logs, screenshots, recordings, source hashes, and `.xcresult` together. Record a SHA-256 for every retained artifact. Store DerivedData in a distinct A3-owned subdirectory. Keep evidence below 2 GiB; if the cap is exceeded, stop adding captures and obtain an owner-approved disposition. Do not prune older baseline evidence or unrelated files to meet the limit.

For every matrix row, use one outcome:

- **PASS** only when the requested native operation was observed and its evidence is retained.
- **FAIL** when the documented operation was attempted and did not produce the expected native state; include the exact action and evidence.
- **BLOCKED** when the environment, UI access, runtime, permission, or required evidence prevents execution.
- **NOT RUN** when the case was deliberately not attempted. State why.

Do not classify a build, generic resize, successful setter call, or app screenshot without visible device pose as a native transition pass. Do not claim app feature correctness or persistence from this procedure.

## Issue #11 acceptance mapping

Issue #11 does not assign separate PAC/TAC identifiers. This table maps its five acceptance criteria directly:

| Issue #11 criterion | Outcome | Evidence or remaining work |
| --- | --- | --- |
| AC1: actual toolchain/runtime/device and requested display/pose/orientation/Split View/safe-area coverage | BLOCKED overall. Toolchain, runtime, and device availability were verified. Device Hub showed the closed state; other poses, orientations, Split View, and safe-area behavior were not observed. | Initial, continuation, and latest inventories; owner must complete and capture the remaining matrix. |
| AC2: documented headless native-fold interface, executable probe if available, no invented `simctl` API | BLOCKED. Stable `simctl` has no pose operation; beta release notes document an `XCUIHinge` candidate, but public declarations and an executable test were unavailable. | External CLI help; Apple beta notes; safe beta installation and probe remain. |
| AC3: repeatable Device Hub procedure and native captures or explicit unavailable disposition | BLOCKED. Device Hub showed the Duo and rendered its screen. The Closed selection left it in the existing `v68_Closed` state; no transition capture was retained. Opening the macOS Screenshot app through CUA failed with `-10005: timeoutReached`. | The latest inventory and UI summary are retained externally. The owner must document a storage disposition, then capture the remaining native poses and retain screenshots or a recording with hashes. |
| AC4: keep state/persistence races separate from native pose smoke | PASS for scope documentation only. No C1/C2 assertions or persistence claim was made. | Scope and classification sections above. |
| AC5: lightweight matrix and limitations handed to C/D; physical Duo not required for development absent owner exception | PASS for documented handoff. No physical Duo or D2 sign-off was performed. | Matrix above; C4 and D2 boundaries remain. |

The original run and the 19:39 continuation produced no screenshots, recordings, beta source, or `.xcresult`; their corresponding UI and beta actions did not execute. The latest follow-up returned an inline Device Hub screenshot, but it was not saved to a file or hashed. The earlier Desktop screenshot shows the simulator display only and does not show the Duo chassis pose.

The original evidence archive is preserved and its file hashes were rechecked. The continuation archive records the earlier UI observation, simulator inventory, beta reassessment, owner-operated steps, review, and CI results. The UI observation summary is `device-hub-followup.txt` (SHA-256 `fdb38cd5a2a0466c5887d2191d37d6c35217529fed04967e618c39ffcd9392d9`); the raw simulator record is `duo-simctl-record.json` (SHA-256 `244deaf9b761fce4328ff2361aa9e13c54d7fb5479144f81c69c5b842c029114`). The private owner procedure, which contains the exact local project path and simulator destination, is `owner-operator-steps.txt` (SHA-256 `106f4906726ddb67a74fcdac1e2c9d33608aeb7f656a5a8ae48aef745cb51dc5`). The exact simulator identifier and local paths are kept in owner-managed external evidence, not in this runbook or the PR summary.

The latest follow-up confirms that Device Hub can select the booted Duo and render its screen. It records the existing closed state and the successful PikaDex install and launch. The sanitized summary is `public-summary.txt` (SHA-256 `1f4527a9bae8d49bfdda45e4eaaaa058f91f880d0b0aee8fe3ae0d0e6d175930`). The private inventory and evidence manifest record the exact simulator identity, local paths, command lines, and raw log hashes. No hashed chassis-pose screenshot or recording exists for the latest run. The external evidence directory currently exceeds the 2 GiB budget because it contains the successful build’s DerivedData; its size and disposition are recorded in the private manifest.

## Handoff limits

This A3 result does not establish app layout correctness, navigation continuity, deterministic state, persistence, or device qualification. C1/C2 should continue to use deterministic tests for state and write-order assertions. C4 can use this procedure for native feature smoke after the owner runs the blocked Device Hub observations and establishes the beta probe safely. D2 still requires candidate-bound final device/hardware sign-off under the project’s release policy.
