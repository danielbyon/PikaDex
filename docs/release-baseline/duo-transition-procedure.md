# iPhone Duo native transition procedure

Issue #11 A3 records a repeatable way to observe native iPhone Duo transitions and separates that work from app correctness and release qualification. This runbook describes the supported controls, the probe needed to assess the newer XCTest interface, and the cases that this execution could not observe.

## Execution status

Captured on 2026-11-12 in America/Los_Angeles. The environment inventory passed. Native Device Hub transitions and the Xcode 27.3 beta probe are **BLOCKED** for this run. This run produced no transition screenshots, recordings, test result bundle, or beta probe source. Device Hub appeared in the running-app inventory, but both attempts to inspect it through the UI bridge timed out. That is a tooling blocker; it does not show that Device Hub or the simulator lacks the feature.

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
| Duo simulator | `iPhone Duo`, device type `com.apple.CoreSimulator.SimDeviceType.iPhone-Duo`, UDID `0FA9C191-E5D2-452F-855B-479DCA678E4E`, state `Shutdown` |
| Connected physical Duo | None observed; `devicectl` listed an iPhone 17 Pro Max and no Duo |
| UI test target | `PokedexUITests` in the `Pokedex` scheme; current file has `testExample` and `testLaunchPerformance` |

The revalidated raw inventory is under `/Volumes/Qwizlab/pikadex-issue-11-a3/2026-11-13T023838Z/`. That directory is external to the repository. Its manifest identifies each retained file and hash. No A1 report or manifest was changed. The A1 evidence path recorded by that manifest was absent on this host and was left untouched.

## Automation findings

| Mechanism | Finding | A3 result |
| --- | --- | --- |
| Stable headless hinge control | The installed Xcode 27.2 `simctl` help exposes generic screen geometry and simulator I/O, but no fold, hinge, or pose operation. `screenConfig geometry` changes screen geometry; it does not demonstrate a fold transition. | No stable headless pose command identified. |
| XCTest orientation | `XCUIDevice.shared.orientation` simulates device orientation. It does not set a Duo hinge angle. | Orientation automation is separate from folding. |
| `devicectl` | Its installed help contains no fold, hinge, or pose operation. The attached-device inventory contains no physical Duo. | No Duo transition mechanism identified. |
| Stable Device Hub | Apple documents Closed, Partially Open, and Open controls, plus Option-drag on the slider to set other angles. The Device Hub app was listed as running, but the UI bridge timed out twice before controls could be observed. | Interactive mechanism documented; this run's transitions are BLOCKED and unobserved. |
| Xcode 27.3 beta `XCUIHinge` | Apple’s beta release notes say `XCUIAutomation` can set an iPhone Duo hinge angle using `XCUIHinge`. The beta and iOS 27.3 runtime were not installed; the actual public declarations and availability were not inspected, and no test was built or executed. | Documented candidate only; executable feasibility is BLOCKED. This is not a stable release gate. |
| Generic resizing | `simctl` can change screen geometry and UI tests can exercise app UI. Neither action proves a native fold or hinge transition. | Not accepted as native pose coverage. |

Apple’s Xcode 27.3 beta notes require macOS Tahoe 26.6 or later; this host’s macOS 27.0.1 meets that version requirement. Read-only checks reported between 12 and 16 GiB free on the internal data volume; the external Qwizlab volume had 727 GiB free. The beta app and iOS 27.3 simulator runtime were absent. Apple’s [Xcode components guide](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components) describes runtime installation but does not state the footprint for this beta/runtime. With the earlier A1 disk-capacity failure and no verified storage requirement, no beta download, installation, or runtime mutation was attempted. No credentials were entered.

## Stable manual procedure

### Preconditions

1. Use Xcode 27.2 build 27B52 and the `iPhone Duo` simulator on the iOS 27.2 runtime listed above. Re-run `xcodebuild -version`, `xcrun swift --version`, `xcrun --sdk iphonesimulator --show-sdk-version`, `xcrun simctl list runtimes`, and `xcrun simctl list devices available`; record the output with the run.
2. Check free space before building or booting the simulator. Keep DerivedData and retained evidence on a task-specific directory on the external evidence volume. Do not erase the simulator, remove runtimes, or clear app data to make space.
3. Open `Pokedex.xcodeproj` in Xcode 27.2, select the `Pokedex` scheme and the exact iPhone Duo destination, then Run. Select the Duo in Device Hub and click **View Screen**. Do not treat a successful build or launch as a transition result.
4. Create a new run directory under `/Volumes/Qwizlab/pikadex-issue-11-a3/` with a unique UTC timestamp. Keep total A3-retained evidence at or below 2 GiB. Record the exact simulator and runtime identity in the manifest before capturing.

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
| Closed / outer display | Device Hub **Closed** control | Device Hub frame shows closed Duo; screenshot records the outer display | BLOCKED: UI bridge timeout |
| Partially open | Device Hub **Partially Open** control | Device Hub frame shows partial pose and hinge | BLOCKED: UI bridge timeout |
| Open / inner display | Device Hub **Open** control | Device Hub frame shows open Duo and inner display | BLOCKED: UI bridge timeout |
| Intermediate A | Option-drag to about 1/3 slider travel | Screenshot or short recording shows a changed native Duo pose; store the fraction, not an assumed angle | BLOCKED: UI bridge timeout |
| Intermediate B | Option-drag to about 2/3 slider travel | Same evidence as A, at a distinct slider position | BLOCKED: UI bridge timeout |
| Portrait and landscape | Device > Orientation or rotate controls | Record orientation and a Device Hub capture for the selected pose | BLOCKED: UI bridge timeout |
| Split View, left | Place PikaDex on left in system Split View | Device Hub capture shows PikaDex on the left and the other app on the right | BLOCKED: UI bridge timeout |
| Split View, right | Place PikaDex on right in system Split View | Device Hub capture shows PikaDex on the right and the other app on the left | BLOCKED: UI bridge timeout |
| Safe area and narrow window | Observe outer/inner display and each Split View side | Record visible boundaries; numeric insets remain unavailable without instrumentation | BLOCKED: UI bridge timeout |
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
6. Do not delete runtimes, databases, A1 evidence, or unrelated checkout state. Remove only exact A3-owned temporary products after verifying the retained evidence copy. If the retained evidence would exceed 2 GiB, stop capture and report what could not be retained.

No beta probe source or executed test invocation exists for this run; the command above is an unexecuted template. Probe tests executed: 0; passed: 0; failed: 0; skipped: 0. These are execution counts, not a passing result. The beta probe outcome is **BLOCKED before API inspection** and is not a stable release gate. `XCUIDevice.orientation` is documented separately as a device orientation control and does not replace the hinge API ([Apple documentation](https://developer.apple.com/documentation/xcuiautomation/xcuidevice/orientation)).

## Evidence handling and result classification

Use `/Volumes/Qwizlab/pikadex-issue-11-a3/<UTC-run-id>/` for each run. Keep its evidence manifest, command logs, screenshots, recordings, source hashes, and `.xcresult` together. Record a SHA-256 for every retained artifact. Store DerivedData in a distinct A3-owned subdirectory. Keep evidence below 2 GiB; do not prune older baseline evidence or unrelated files to meet the limit.

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
| AC1: actual toolchain/runtime/device and requested display/pose/orientation/Split View/safe-area coverage | BLOCKED overall. Toolchain, runtime, device type, and UDID inventory passed; native behavior cases were not observed. | External environment inventory; stable matrix above; owner must execute Device Hub cases. |
| AC2: documented headless native-fold interface, executable probe if available, no invented `simctl` API | BLOCKED. Stable `simctl` has no pose operation; beta release notes document an `XCUIHinge` candidate, but public declarations and an executable test were unavailable. | External CLI help; Apple beta notes; safe beta installation and probe remain. |
| AC3: repeatable Device Hub procedure and native captures or explicit unavailable disposition | BLOCKED for observed captures. Procedure and capture/retention steps are documented; this run captured no transition because the UI bridge timed out. | Device Hub timeout record; no transition screenshot or recording. |
| AC4: keep state/persistence races separate from native pose smoke | PASS for scope documentation only. No C1/C2 assertions or persistence claim was made. | Scope and classification sections above. |
| AC5: lightweight matrix and limitations handed to C/D; physical Duo not required for development absent owner exception | PASS for documented handoff. No physical Duo or D2 sign-off was performed. | Matrix above; C4 and D2 boundaries remain. |

The external evidence directory records the task identity, blocked native and beta attempts, original UI-test source hash, inventories, command-help output, and artifact hashes. It contains no screenshot, recording, beta source, or `.xcresult` because those actions did not execute.

## Handoff limits

This A3 result does not establish app layout correctness, navigation continuity, deterministic state, persistence, or device qualification. C1/C2 should continue to use deterministic tests for state and write-order assertions. C4 can use this procedure for native feature smoke after the owner runs the blocked Device Hub observations and establishes the beta probe safely. D2 still requires candidate-bound final device/hardware sign-off under the project’s release policy.
