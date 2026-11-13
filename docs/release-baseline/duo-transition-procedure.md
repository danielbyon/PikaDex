# iPhone Duo native transition procedure

Issue #11 A3 records a repeatable way to observe native iPhone Duo transitions and separates that work from app correctness and release qualification. This runbook preserves each dated result. The 2026-11-13 continuation at the end records the latest observations; earlier blocked reports remain part of the history.

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

## Verified environment (2026-11-12 inventory)

This is the environment snapshot from the earlier follow-up. The later 2026-11-13 inventory is recorded in the continuation at the end of this runbook.

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

## Automation findings (2026-11-12 status)

These findings record the state before the 2026-11-13 Device Hub captures and Beta header inspection. For the later observations and current outcomes, see the dated continuation below.

| Mechanism | Finding | A3 result |
| --- | --- | --- |
| Stable headless hinge control | The installed Xcode 27.2 `simctl` help exposes generic screen geometry and simulator I/O, but no fold, hinge, or pose operation. `screenConfig geometry` changes screen geometry; it does not demonstrate a fold transition. | No stable headless pose command identified. |
| XCTest orientation | `XCUIDevice.shared.orientation` simulates device orientation. It does not set a Duo hinge angle. | Orientation automation is separate from folding. |
| `devicectl` | Its installed help contains no fold, hinge, or pose operation. The attached-device inventory contains no physical Duo. | No Duo transition mechanism identified. |
| Stable Device Hub | Apple documents Closed, Partially Open, and Open controls, plus Option-drag on the slider to set other angles. The initial UI bridge timed out twice. The next check found no Duo in the visible list, and a later scroll request failed with `-10005: noWindowsAvailable`. The latest check selected the booted Duo and rendered its screen. It exposed Closed, Partially Open, Open, and Rotate Right. Selecting Closed left the `v68_Closed` state unchanged; a later CUA screenshot-tool lookup timed out. | Device Hub visibility and View Screen are verified. The closed state was observed, but no transition or retained chassis capture was produced. Other native cases remain BLOCKED. |
| Xcode 27.3 beta `XCUIHinge` | Apple’s beta release notes say `XCUIAutomation` can set an iPhone Duo hinge angle using `XCUIHinge`. The beta and iOS 27.3 runtime were not installed; the actual public declarations and availability were not inspected, and no test was built or executed. | Documented candidate only; executable feasibility is BLOCKED. This is not a stable release gate. |
| Generic resizing | `simctl` can change screen geometry and UI tests can exercise app UI. Neither action proves a native fold or hinge transition. | Not accepted as native pose coverage. |

Apple’s Xcode 27.3 Beta notes require macOS Tahoe 26.6 or later; this host’s macOS 27.0.1 meets that version requirement. The initial A3 checks reported 12–16 GiB free on the internal data volume. The continuation check reported 6.8 GiB internal and 727 GiB external free. In the 2026-11-12 follow-up, internal free space was above 10 GiB before the stable build and app install, then measured 9.6 GiB at 21:45 PST. Read-only checks measured 6.05 GiB at 22:13 PST and 3.76 GiB at 22:35 PST, both below the 10 GiB minimum; no build, simulator boot, installation, or cleanup followed those readings. At that point, the Beta app and iOS 27.3 simulator runtime were not installed. Apple’s [Xcode components guide](https://developer.apple.com/documentation/xcode/downloading-and-installing-additional-xcode-components) describes runtime installation but does not state the footprint for this Beta/runtime. The earlier A1 disk-capacity failure, those below-floor readings, and the unverified package footprint left no safe installation plan. No Beta download, installation, or runtime mutation was attempted in that run; no credentials were entered. Owner disposition required a verified storage plan for the official Beta, Duo runtime, build products, and a safety margin before installation.

## Stable manual procedure

### Preconditions

1. Use Xcode 27.2 build 27B52 and the `iPhone Duo` simulator on the iOS 27.2 runtime listed above. Re-run `xcodebuild -version`, `xcrun swift --version`, `xcrun --sdk iphonesimulator --show-sdk-version`, `xcrun simctl list runtimes`, and `xcrun simctl list devices available`; record the output with the run.
2. Check free space before building, booting, or installing. Keep at least 10 GiB free on the internal volume. Keep DerivedData and retained evidence on a task-specific directory on the external evidence volume. Stop if the internal volume falls below the minimum. Do not erase the simulator, remove runtimes, or clear app data to make space.
3. Select the booted iPhone Duo in Device Hub and click **View Screen**. The native hinge controls do not require PikaDex to be running. Run the `Pokedex` scheme on the Duo only when observing app-specific Split View or window behavior; a build or process launch alone is not a transition result. If the Duo is not listed, record the Device Hub state and stop with **BLOCKED**; do not substitute another simulator or generic resizing.
4. Keep cumulative retained evidence below 2 GiB, counting the original evidence root and the targeted-correction evidence folder. Keep reproducible build scratch separate. The earlier run was blocked when its task root exceeded the cap and cleanup was rejected; the later dated storage-disposition record resolves that blocker by preserving and moving the rebuildable caches. Further bounded captures may proceed while evidence remains below the cap. Stop and report an overage; preserve baseline evidence, databases, runtimes, and unrelated state.

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

### Stable coverage matrix (2026-11-12 status)

This matrix preserves the earlier blocked results. It is superseded for current status by the 2026-11-13 matrix below, which records the later screenshots and remaining blocked cases.

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

After the Beta and a Duo simulator runtime supported by that Xcode are available safely. Do not install an additional runtime solely to run this probe when the verified Duo runtime is already supported.

1. Record Xcode build, macOS version, Swift version, iOS SDK/runtime build, simulator device type and UDID, and free space. Inspect the installed public `XCUIHinge` declarations and availability. Record the declaration file, accepted angle type and units, supported range, set/get behavior, and any simulator or OS availability annotation. Do not implement against a release-note mention alone or use private APIs.
2. Add one temporary test method to the existing `PokedexUITests` source and use the existing `PokedexUITests` target in the `Pokedex` scheme. Save the exact temporary source and its SHA-256 outside the repository before running. Do not add a target or framework.
3. Request closed, partially open, open, and two documented intermediate angles. Record the requested value and units. Where the public API exposes an observable native state, capture that state; compare requested and observed angles. A setter returning successfully or a changed app frame alone is not proof that the simulator folded.
4. Use a unique external DerivedData path and result bundle. After the API declaration and test method are verified, run only that method, with the exact verified Duo destination and runtime, and select the Beta per command. Example command shape (fill paths and UDID from the verified install; this command was **not run**):

   ```sh
   DEVELOPER_DIR="/path/to/Xcode-27.3-beta.app/Contents/Developer" \
   xcodebuild test \
     -project Pokedex.xcodeproj \
     -scheme Pokedex \
     -destination 'platform=iOS Simulator,id=<verified-ios-27.3-duo-udid>' \
     -derivedDataPath '<external-run-directory>/DerivedData' \
     -resultBundlePath '<external-run-directory>/DuoHingeProbe.xcresult' \
     -only-testing:PokedexUITests/PokedexUITests/testXCUHingeNativeAngleProbe \
     -parallel-testing-enabled NO
   ```

5. Retain the exact source and hash, command, stdout/stderr log, `.xcresult`, screenshots or recording, environment inventory, requested/observed values and units, deviations, and executed/passed/failed/skipped counts. Report a setter-only result as inconclusive. Restore `PokedexUITests.swift` and verify the original SHA-256 before review.
6. Do not delete runtimes, databases, A1 evidence, or unrelated checkout state. Remove exact A3-owned temporary products only after verifying the retained evidence copy and obtaining owner authorization. If a proposed cleanup is rejected, do not retry it; stop capture and record the overage until the owner documents a safe disposition.

The 2026-11-12 execution had no beta probe source or executed test invocation; the command above was an unexecuted template. Probe tests executed: 0; passed: 0; failed: 0; skipped: 0. These are execution counts, not a passing result. That run's beta probe outcome was **BLOCKED before API inspection** and was not a stable release gate. `XCUIDevice.orientation` is documented separately as a device orientation control and does not replace the hinge API ([Apple documentation](https://developer.apple.com/documentation/xcuiautomation/xcuidevice/orientation)). The later Beta probe attempts are recorded in the 2026-11-13 continuation below.

## Evidence handling and result classification

Use `<owner-selected-external-evidence-root>/<UTC-run-id>/` for each run. Keep its evidence manifest, command logs, screenshots, recordings, source hashes, and `.xcresult` together. Record a SHA-256 for every retained artifact. Store DerivedData in a distinct A3-owned subdirectory. Keep evidence below 2 GiB; if the cap is exceeded, stop adding captures and obtain an owner-approved disposition. Do not prune older baseline evidence or unrelated files to meet the limit.

For every matrix row, use one outcome:

- **PASS** only when the requested native operation was observed and its evidence is retained.
- **FAIL** when the documented operation was attempted and did not produce the expected native state; include the exact action and evidence.
- **BLOCKED** when the environment, UI access, runtime, permission, or required evidence prevents execution.
- **NOT RUN** when the case was deliberately not attempted. State why.

Do not classify a build, generic resize, successful setter call, or app screenshot without visible device pose as a native transition pass. Do not claim app feature correctness or persistence from this procedure.

## Issue #11 acceptance mapping (2026-11-12 status)

This table preserves the earlier acceptance status. The current mapping is the dated table at the end of this runbook.

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

The earlier follow-up confirms that Device Hub could select the booted Duo and render its screen. `simctl launch` returned a process ID after the successful install, but a later observation recorded that process terminating with `SIGTRAP` (signal 5). The launch result therefore does not establish that PikaDex remained available for Split View or other app observations. The sanitized summary is `public-summary.txt` (SHA-256 `1f4527a9bae8d49bfdda45e4eaaaa058f91f880d0b0aee8fe3ae0d0e6d175930`). The private inventory and evidence manifest record the exact simulator identity, local paths, command lines, and raw log hashes. No hashed chassis-pose screenshot or recording existed for the earlier run; the later pose captures are listed in the 2026-11-13 addendum. The external task root remains above the 2 GiB cap when its retained build scratch is included; its size and unresolved disposition are recorded in the private manifests.

## Handoff limits recorded 2026-11-12

This A3 result does not establish app layout correctness, navigation continuity, deterministic state, persistence, or device qualification. C1/C2 should continue to use deterministic tests for state and write-order assertions. C4 can use this procedure for native feature smoke after the owner runs the blocked Device Hub observations and establishes the beta probe safely. D2 still requires candidate-bound final device/hardware sign-off under the project’s release policy.

## 2026-11-13 continuation: observed native transitions and Beta probe

This dated addendum supplements the earlier results without replacing them. It records a later Device Hub session, the bounded Xcode 27.3 Beta probe attempts, and the remaining limits. The older statements that no retained pose screenshots or Beta source existed describe the earlier runs.

### Environment and storage

| Item | Verified value |
| --- | --- |
| Repository at start of this continuation | `codex/issue-11-native-duo-test-mechanism`, HEAD `f76e93d872d306966d175548c93e2a450cd32eef`; approved baseline is an ancestor; worktree was clean before the temporary probe source was added. |
| Host | macOS 27.0.1, build 26A434 |
| Stable toolchain | Xcode 27.2, build 27B52; Swift 6.4.2; iOS Simulator SDK 27.2 |
| Stable destination | iPhone Duo, type `com.apple.CoreSimulator.SimDeviceType.iPhone-Duo`, iOS 27.2 runtime `com.apple.CoreSimulator.SimRuntime.iOS-27-2-iPhone19-4`, build 24B91016s; available and Booted at inventory. The exact UDID is in the private evidence manifest. |
| Beta toolchain | Xcode 27.3 Beta, build 27C5020n; iOS Simulator SDK 27.3. The installed destination remained the iOS 27.2 Duo above; no iOS 27.3 runtime was installed. |
| Internal free space | 153,686,052 KiB (about 146.5 GiB) before the final Beta attempt, above the 10 GiB floor. |
| External free space | 735,389,976 KiB (about 701 GiB) at the same check. |
| External task-root usage | 5,508,932 KiB (about 5.25 GiB). The native evidence folder measured 21,792 KiB and the Beta evidence folder 3,708 KiB. The isolated Beta DerivedData and package scratch measured 1,700,304 KiB. Older DerivedData and package caches remain in place. |

The two new evidence folders contain about 24.9 MiB combined. The full task root remains above 2 GiB when all contents are counted. Earlier records leave unresolved whether retained DerivedData counts toward the evidence cap, so this addendum does not claim aggregate cap compliance. It does not relabel, move, or delete any older build products, databases, simulator runtimes, or evidence. A private external manifest named `2026-11-13-followup-evidence-manifest.json` records the exact artifact paths and hashes.

### Device Hub observations

Device Hub listed the booted iPhone Duo, **View Screen** worked, and its native chassis controls showed **Closed**, **Partially Open**, **Open**, and **Rotate Right**. The following screenshots show the Device Hub chassis, rather than only the simulated display. Hashes are SHA-256.

| Case | Native operation and expected state | Observed state | Outcome and retained evidence |
| --- | --- | --- | --- |
| Closed / outer display | Select **Closed**; expect the Duo closed with its outer display visible. | Closed chassis and outer display visible. | **PASS** — `closed-before-transition.png`, `7d1766e449852cb214e626e788805e96bfa0db8661a41a52e3b6b6856c1c85a0`. |
| Closed → Partially Open | Select **Partially Open**; expect an intermediate chassis pose and inner display. | Device Hub showed the partial pose and inner display. | **PASS** — `partially-open.png`, `a948e098121e8186012f0d028240e8fe788e7a8e73328ac96f1bfa7c9a50b8a4`. |
| Partially Open → Open | Select **Open**; expect the open chassis and inner display. | Device Hub showed the open pose and inner display. | **PASS** — `open.png`, `c7801a6e6a07b089708dfdc1d9660619c6389abd43e996c8ae9df797704306ff`. |
| Open → Closed | Select **Closed** after the open pose; expect the closed chassis and outer display. | Device Hub returned to the closed pose. | **PASS** — `closed-after-open.png`, `8b7818ec2139ad3da9ca7eea3081457766a2062b60002d17ba2e0af5b48a3e0c`. |
| Portrait | Observe closed, partial, and open presets in portrait. | The three pose captures above show the Duo in portrait. | **PASS** for these three portrait presets; see the four pose captures above. |
| Landscape | Choose **Device > Orientation > Landscape Left**, then use **Rotate Right**; expect a landscape device orientation. | The Device Hub chassis was visibly rotated and the selected accessibility state was `v68_Closed`; no hinge angle was measured. | **PASS** for landscape orientation only — `landscape-after-rotate-right.png`, `ce2fb5c396704f2a382038d7ad33b2908b9705821c45ba4f030c8b282dcf5c20`. Landscape partial/open cases were **NOT RUN**. |
| Intermediate A | Hold Option and drag the native hinge slider to about one-third travel; expect a distinct angle between presets. | The retained attempt shows the device still Closed; no intermediate angle or slider value was verified. | **BLOCKED** — diagnostic `intermediate-one-third.png`, `c4713b645b0cbea04f7ebc3df177d9116395e40d9feae9df26f69e72d6d3bb37`. |
| Intermediate B | Hold Option and drag to about two-thirds travel; expect a second distinct intermediate angle. | The retained attempt shows the Open preset, not an intermediate angle. | **BLOCKED** — diagnostic `intermediate-two-thirds.png`, `d8b2944f8de20aa2efd2e2ec0f87bd0b648473fcdc3154bf6f64c377c3896ebdb`. |
| Slider interaction | Reveal the slider while holding Option and verify a non-endpoint position. | A slider was visible at the Open endpoint; later pointer/Option attempts did not produce a verified interior position. | **BLOCKED** — `slider-visible-open.png`, `95dbbd263fbb3ec23d6b5b8c0541b9238ac79674a761fbbfdf4841755ea8aea8`; pointer diagnostics `option-hover-for-slider.png` (`4197c2362b2f17fdbf50ce2da56c91dcc6028898b925939c4b33cc5cabd5e06d`) and `option-hover-slider-attempt.png` (`45ce26369c8051c8f7d0ad02f08a50528ace3e2c20ca92d355b2a47b58900c8d`). |
| PikaDex launch for app-specific cases | With stable Xcode 27.2 build 27B52 and the iOS 27.2 Duo runtime, run the Pokedex scheme; expect PikaDex to remain available for Split View observations. | PikaDex 2.1.2 (51) installed and `simctl launch` returned a process ID; that process later terminated with `SIGTRAP` (signal 5). No cause was diagnosed in A3. | **FAIL** for this stable-toolchain launch attempt only; it is not a hinge-mechanism result. |
| System Split View, PikaDex left/right | Place PikaDex on each side using the system Split View controls; expect the Duo to show both apps in each arrangement. | Not observable because PikaDex crashed. | **BLOCKED** for both sides; no app or split-screen capture is claimed. |
| Narrow window and app safe area | Observe PikaDex on the outer/inner display and in each narrow Split View window. | The native outer and inner displays are visible in the pose captures, but no PikaDex window, numeric safe-area inset, or narrow-window layout was observed. | **BLOCKED** for app window and safe-area behavior. |
| Generic geometry change | Change simulator screen geometry. | Not attempted. | **NOT RUN**; geometry changes do not establish folding. |

The two intermediate-angle attempts do not prove distinct hinge angles. They remain blocked even though diagnostic screenshots exist. The stable Device Hub GUI is interactive native pose control; this run did not establish a reliable unattended slider action. No `simctl` folding command or generic resize was used.

### Xcode 27.3 Beta `XCUIHinge` probe

The Beta installation passed the macOS compatibility and disk-space checks and came from the official Apple Xcode distribution. The stable Xcode selection was not changed. The installed public headers expose `XCUIDevice.shared.hinge` and `XCUIHinge.angle` as a `CGFloat` in radians. `hinge` is nullable on devices without a hinge. The header has no declared angle range or availability annotation; its documentation says programmatic closed-to-open transitions are unsupported on physical devices and fail the test. Apple’s [Xcode 27.3 Beta release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27_3-release-notes) and the [public `XCUIDevice.hinge` documentation](https://developer.apple.com/documentation/xctest/xcuidevice/hinge) establish that the API exists; they do not prove that it drives a native Duo pose in this simulator.

The temporary test method `testXCUHingeNativeAngleProbe` requested `[0, π/3, π/2, 2π/3, π]` radians (0°, 60°, 90°, 120°, 180°), with a getter read after each setter. No request/readback pair was observed because the test method never ran. The original UI test source was restored and verified at SHA-256 `4fd3ce30b22e279b17d5e6f88cd94e4be57c76f3d71241abea7ad62a8e0c5537`; the exact temporary source is retained externally with SHA-256 `eda9dd4e420de14e4b8a0c57a9d01e0b4f370ff7a9081817fd8c63e807a4fa0e`.

| Attempt | Result before test execution | Test counts |
| --- | --- | --- |
| 1 | Build stopped because the worktree lacked the generated `Pokedex.sqlite` input. | 0 executed, 0 passed, 0 failed, 0 skipped. |
| 2 | The temporary database copy inside the worktree was rejected by the build script sandbox (`Operation not permitted`). The copy was removed and the primary-checkout database was left unchanged. | 0 executed, 0 passed, 0 failed, 0 skipped. |
| 3 | With the documented generated-database check bypassed for this no-app-launch probe, Xcode reached test-runner packaging but failed because `PokedexUITests/Info.plist` is absent while the project build setting points to that path. | 0 executed, 0 passed, 0 failed, 0 skipped. |
| 4 | A command-line empty `INFOPLIST_FILE` override applied to every scheme target and caused additional targets to fail Info.plist generation. No project files were changed. | 0 executed, 0 passed, 0 failed, 0 skipped. |

All four result bundles report `totalTestCount: 0`; each xcodebuild invocation exited 65. The probe is **BLOCKED**, not PASS or FAIL: there is no setter-only, getter, visual, or test-run evidence. The Beta build used Xcode 27.3 with the installed iOS 27.2 Duo runtime; it did not test an iOS 27.3 runtime. Do not infer feasibility from the public declaration, compilation, or the recorded requested values. A further probe requires an owner-approved disposition for the missing UI-test Info.plist input and a valid target-specific way to build the existing test target.

### Updated Issue #11 acceptance mapping

Issue #11 provides five acceptance criteria but no separate PAC/TAC identifiers. The table maps each criterion directly to the evidence above.

| Criterion | Current outcome | Evidence and remaining work |
| --- | --- | --- |
| AC1: verify installed toolchain, runtime, Duo device support, poses, orientations, Split View, safe area, and window behavior | **BLOCKED overall** — stable toolchain/device and Closed/Partial/Open plus portrait and closed-landscape observations are verified. | Intermediate angles, landscape partial/open, Split View, and app window/safe-area observations remain unavailable. |
| AC2: identify supported headless native folding automation and execute a probe where supported | **BLOCKED** — stable `simctl`/`devicectl` expose no native fold operation. Local public-header inspection confirms the Beta API declaration only; the test method did not execute, so no setter, getter, angle readback, or native pose was observed. | All four Beta result bundles report zero tests. Resolve the existing UI-test Info.plist input before a later isolated probe. |
| AC3: define repeatable Device Hub actions and retain pose evidence or report unavailable cases | **BLOCKED** — the procedure and four preset pose captures are retained, but two distinct intermediate angles and app-specific cases remain unverified. | Owner-operated steps below complete the missing Device Hub evidence. |
| AC4: separate deterministic state/persistence assertions from native pose smoke | **PASS** for scope separation. | No state, persistence, navigation, or app-correctness assertion is made here; C1/C2 own deterministic claims. |
| AC5: provide a lightweight matrix and limitations to C/D; physical Duo is not required for development unless policy says otherwise | **PASS** for the documented handoff. | C4 still owns native feature smoke/continuity; D2 still owns final device/hardware qualification. No physical Duo sign-off is claimed. |

### Owner-operated completion steps (status at the earlier handoff)

At the earlier handoff, the 2 GiB cap treatment of build scratch was unresolved, so further capture was **BLOCKED** pending owner disposition. The later storage update at the end of this document resolves that condition. The steps below cover the remaining technical work.

Additional captures may proceed while the retained evidence root stays below 2 GiB and new build scratch remains in the separate scratch folder. Stop and report any measured overage. Do not delete or relocate retained evidence without a new owner disposition.

1. Use Xcode 27.2 build 27B52 and the iOS 27.2 runtime. Open Device Hub, select the booted Duo recorded in the private manifest, and confirm **View Screen**. Running PikaDex is not required to repeat native hinge-preset or orientation observations.
2. For the two intermediate cases, hold Option and drag the Device Hub hinge slider to two distinct positions inside its travel, away from **Closed**, **Partially Open**, and **Open**. Capture the complete Device Hub window after each action so both chassis and slider are visible. Record the requested slider fraction; record degrees only if Device Hub displays them. If the slider cannot be manipulated, retain a screenshot of the control and classify both cases **BLOCKED**.
3. To complete landscape coverage, capture the partial and open presets in landscape as well as the already retained closed landscape observation. Keep the orientation action separate from the hinge preset.
4. For Split View and app safe-area observations, use the `Pokedex` scheme in Xcode 27.2 on the verified Duo destination `platform=iOS Simulator,id=<verified-Duo-UDID-from-private-manifest>`. The recorded `SIGTRAP` followed the stable Xcode 27.2 launch attempt. Proceed with these app-dependent cases only if PikaDex remains running; if it exits again, record the exact outcome and leave those rows **BLOCKED** for C4 follow-up. Do not substitute another app or claim an app layout result.
5. Save original screenshots or recordings and a SHA-256 for each in the owner-managed external evidence folder. Record the exact Xcode/runtime/UDID, operation, expected and observed state, outcome, and artifact hash. Keep build scratch in its separate folder and check the evidence-root total after capture. If the total exceeds 2 GiB, stop and report the measured overage.

### Handoff limits

This continuation verifies several native Device Hub pose transitions and their chassis appearance. It does not qualify the Beta API, app feature correctness, Split View layout, persistence, safe-area values, or hardware behavior. C1/C2 retain deterministic state and persistence claims. C4 can use the stable procedure after the remaining native observations and app launch are available. D2 still requires candidate-bound device and hardware sign-off. The Beta experiment remains feasibility work, not a release gate.

## 2026-11-13 follow-up: environment and evidence storage revalidation

Earlier test outcomes remain unchanged. This follow-up supersedes the earlier statement that the evidence-storage disposition was unresolved.

### Current environment

The host reported macOS 27.0.1 build 26A434. Internal free space was about 139 GiB and the external evidence volume had about 701 GiB free. The internal volume remains above the 10 GiB floor. Stable Xcode 27.2 build 27B52 and iOS Simulator SDK 27.2 remain installed. The Duo simulator is available and booted on the iOS 27.2 runtime, build 24B91016s. Its UDID and full simulator record remain in the private evidence manifest.

Device Hub displayed the booted Duo and rendered its screen. The Closed, Partially Open, and Open controls were available. This revalidation invoked Closed → Partially Open → Open → Closed, leaving the device closed in portrait. No new external screenshot or recording was retained for this brief control check, so it adds no new acceptance result. The hashed captures listed in the earlier addendum remain the evidence for the recorded transitions.

Xcode 27.3 Beta build 27C5020n is present as an installed application bundle, which occupies 3,883,152 KiB. It includes iOS Simulator SDK 27.3. The host meets the macOS Tahoe 26.6 minimum in Apple's [Xcode 27.3 Beta release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-27_3-release-notes). The installed simulator inventory has iOS 27.0, 27.1, and 27.2 runtimes; it has no iOS 27.3 runtime. No runtime download or installation was started. Apple's [component installation guide](https://developer.apple.com/documentation/Xcode/downloading-and-installing-additional-xcode-components) describes runtime installation through Xcode Settings → Components, but the published pages do not give the iOS 27.3 runtime's download size. Check the size shown in Components before an owner-authorized installation.

The Beta public headers were rechecked. `XCUIDevice.h` exposes a nullable hinge property; `XCUIHinge.h` exposes a readable and writable `CGFloat` angle in radians. The declarations provide no availability annotation or valid angle range. The public header warns that opening a closed physical device programmatically is unsupported and fails the test. The release notes establish API presence, but do not establish successful native pose control. No new API test ran: the iOS 27.3 Duo runtime is absent, no runtime installation was authorized, and the existing UI-test target still has the previously documented Info.plist packaging blocker. The four earlier attempts remain four zero-test results (zero passed, failed, or skipped; each xcodebuild invocation exited 65). The Beta probe remains **BLOCKED**.

### Evidence-storage disposition

The evidence root measured 5,508,932 KiB, above the 2 GiB budget. Inventory identified 5,480,648 KiB of reproducible DerivedData, Swift Package caches, and temporary build directories. All eight directories had zero open file handles and were moved by same-volume rename to a separate task-specific build-scratch folder. No files were deleted. The evidence root measured 28,292 KiB after the disposition manifest was added, well below the cap. Both prior manifests and all ten retained Device Hub screenshots still match their recorded SHA-256 hashes.

The 2 GiB budget applies to every file and subdirectory under the `evidence_root` recorded in the storage disposition manifest. The separately named `build_scratch_root` contains the eight moved caches and is outside that evidence total. Keep these roots separate; do not move other contents between them without an owner disposition.

The external `storage-disposition-manifest.json` records the moved directories, paths, sizes, file counts, preserved manifest hashes, screenshot-hash verification, and budget boundary. Its SHA-256 is `8bf77b8239125783b446536f83a46b285166fb1fc31f4f2fff7abd38ba3856b2`. The move resolves the storage-cap blocker for additional bounded evidence capture; intermediate angles, landscape partial/open, app Split View, and app safe-area/window observations remain outstanding for the reasons recorded above.

## 2026-11-13 targeted acceptance correction

The worktree and draft PR started clean at reviewed HEAD `3d48b9748cae342a130ae0a76d4b5d75b1ca53c4`. The following results supplement the earlier runs. Their failures and blocked outcomes remain historical evidence.

### Remaining stable native cases

Stable Xcode 27.2 build 27B52 used the same available, booted iOS 27.2 Duo, runtime build 24B91016s. The private native manifest records the exact UDID. Screenshots were saved directly from the Device Hub window, including the chassis. No display-only screenshot or generic resize was substituted.

| Case | Requested action and expected result | Observed result | Classification and SHA-256 evidence |
| --- | --- | --- | --- |
| Partial in landscape | Select Partially Open and use Rotate Right to place the chassis in a wide orientation. | The inner Home Screen appeared on the visibly bent, wide chassis. | **PASS**: `partial-wide-landscape.png`, `0ef0db505a5aaa0d8844d229ef75753278de1877420696cc8a56110480add551`. |
| Open in landscape | Select Open and use Rotate Right to place the chassis in a wide orientation. | The inner Home Screen appeared on the flat, wide chassis. | **PASS**: `open-wide-landscape.png`, `6a106b41ef4fe51eb9efc5900223d65b714dba7db7eb1413da80b61899266d11`. |
| Two non-preset angles | Hold Option while moving the native slider to two interior positions. | The GUI bridge rejected modifier names `Alt` and `option` with `keyNotFound`. Neither angle was observed. | **BLOCKED** for both; `ui-control-errors.txt` preserves the errors. Earlier tall-orientation screenshots are retained as diagnostics only. |
| Native Split View, both sides | Use Safari and Files to observe system placement independently of PikaDex. | Safari opened; the next Home/second-app setup action returned `noWindowsAvailable`. No Split View placement executed. | **BLOCKED** for both sides. This blocker is the GUI bridge, independent of the PikaDex launch failure. |

The native manifest is `native/manifest.json`, SHA-256 `923f033fbe2a8f36f313f56556361c7e476fd2791e1a3116e216cf1bb91d29b6`. It includes screenshot hashes, expected and observed states, GUI errors, and owner actions. No numeric angle is assigned to the landscape preset captures.

For the remaining angle observations, hold the physical Option key in Device Hub and drag the slider below the bezel to two distinct positions away from all three presets. Capture the entire Device Hub window with the chassis and slider visible. Record fractions of slider travel, or degrees only if the control displays them. This is Apple's [documented native hinge gesture](https://developer.apple.com/documentation/xcode/interacting-with-your-app-in-device-hub).

For native Split View, fully open the Duo in landscape. Touch and hold Files on the Home Screen or in App Library, choose **Open in Split View**, then select Safari. Capture the two apps and chassis. Swap sides by swiping up from the bottom of one app, pausing in the center, then continuing to drag it to the opposite side; capture the second arrangement. These are [Apple's documented system actions](https://support.apple.com/en-ph/guide/iphone/iphrj13y9uxz/27/ios/27). Keep the native mechanism result separate from PikaDex layout smoke. If no second window appears, retain that observation and leave the case blocked.

### PikaDex SIGTRAP diagnosis and C4 handoff

Four retained crash reports have the same main-thread stack: Swift `_assertionFailure`, `PokedexApp.init()` at `PokedexApp.swift:50`, then the SwiftUI entry point. Historical simulator messages identify the preceding error: SQLite attempts to open the absent `Pokedex.sqlite-wal`, reports `NSSQLiteErrorDomain=14` and `NSCocoaErrorDomain=256`, and the app's persistence bootstrap catch calls `fatalError`. This is an observed catalog-packaging prerequisite failure; it does not implicate the native hinge transition.

The installed catalog is present, 405,344,256 bytes, and has WAL header bytes `02 02`. Its bundle has no WAL or SHM sidecars. Its SHA-256, `ea88293e22e15a25cfe67be05abd9e0a4e13e1d30b142882951e28608a6e4a5e`, matches the existing primary-checkout development resource. Core Data model hashes match. The task worktree itself lacks the generated resource. These checks distinguish an absent worktree build input from the installed app's present but unsuitable read-only catalog package. Immutable SQLite inspection can read the catalog; that does not reproduce Core Data startup.

`crash/REPORT.md`, `crash-stacks.txt`, copied `.ips` reports, filtered historical logs, source excerpts, and `diagnostics.json` retain the diagnosis. The database hashes were unchanged by inspection. No production source or user database was modified. SQLite documents the [read-only WAL conditions](https://sqlite.org/wal.html#read_only_databases).

C4 must generate and validate the catalog through the canonical pipeline, confirm checkpointed DELETE-mode packaging, rebuild/install the stable candidate, and verify startup before PikaDex Split View and safe-area smoke. The exact prerequisite command is retained in the private crash report. The remedy and subsequent app behavior have not been executed or qualified by this A3 diagnosis; any failure with a canonical catalog remains an application investigation for C4.

### Executed Beta probe on the existing iOS 27.2 Duo

The earlier claim that an absent iOS 27.3 runtime prevents probe execution is superseded. Xcode 27.3 Beta build 27C5020n built and executed the selected UI-test method on the existing iOS 27.2 Duo, build 24B91016s. No runtime was installed, and global Xcode selection was unchanged.

A temporary `PokedexUITests/Info.plist` supplied the missing target input. No global `INFOPLIST_FILE` override was used. The generated-database check remained enabled with `PIKADEX_SKIP_GENERATED_DATABASE_CHECK=NO`; `PIKADEX_GENERATED_DATABASE_PATH` identified the preserved database build input. That WAL-format input is sufficient for this no-app-launch probe's existence check, but it is not a canonical catalog qualification or an app-startup remedy.

Two setup invocations were rejected before execution: the one-iteration argument was invalid, and a reused result path already existed. Their commands, errors, and available zero-test result are preserved. The first executed run used a command-level `ENABLE_USER_SCRIPT_SANDBOXING=NO` override. A further run removed that override: temporary `inputPaths` on the database-check script phase declared the exact script and database inputs, and `ENABLE_USER_SCRIPT_SANDBOXING=YES` remained set. The final result reproduced the same API failure with that narrower setup. The project file was restored afterward; canonical verification and its sources were unchanged.

| Executed run | Tests executed / passed / failed / skipped | Observed result |
| --- | --- | --- |
| First executable run, retained under `probe/attempt2` | 1 / 0 / 1 / 0 | `XCUIDevice.shared.hinge` returned an object, but its initial angle getter failed. |
| Final run with declared inputs and sandbox enabled, under `probe/attempt3` | 1 / 0 / 1 / 0 | Same getter failure on the iOS 27.2 Duo. |

Both result bundles report: `Failed to get hinge angle: Getting hinge angle is unsupported on this device, ignoring.` The method configured 0, π/3, π/2, 2π/3, and π radians (0°, 60°, 90°, 120°, 180°), but the initial getter failed before the loop. None of those setter requests, readbacks, deviations, or per-angle screenshots occurred. There is no headless native-pose PASS. The executed tests are **FAIL**; native automation feasibility remains **BLOCKED** for this combination. A newer runtime may change support, but these results do not establish that iOS 27.3 is required. Any runtime installation still needs owner authorization and a verified storage cost.

To reproduce the final infrastructure, use the exact temporary source and plist retained under `probe/attempt3`, apply only its `project-inputs.diff`, and use its `command.json` environment and arguments. Set a new external result-bundle path for each run. The essential invocation is:

```sh
DEVELOPER_DIR=/Applications/Xcode-27.3.0-Beta.app/Contents/Developer \
PIKADEX_GENERATED_DATABASE_PATH="$PROBE_DATABASE" \
PIKADEX_SKIP_GENERATED_DATABASE_CHECK=NO \
xcodebuild -project Pokedex.xcodeproj -scheme Pokedex -configuration Debug \
  -destination 'platform=iOS Simulator,id=<verified-Duo-UDID>' \
  -destination-timeout 60 -derivedDataPath "$EXTERNAL_DERIVED_DATA" \
  -clonedSourcePackagesDirPath "$EXTERNAL_PACKAGES" \
  -resultBundlePath "$UNIQUE_EXTERNAL_RESULT" -parallel-testing-enabled NO \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 30 \
  -maximum-test-execution-time-allowance 60 \
  -only-testing:PokedexUITests/PokedexUITests/testXCUHingeNativeAngleProbe \
  ENABLE_USER_SCRIPT_SANDBOXING=YES test
```

The private command record also fixes the external `TMPDIR` and actual destination. Restore the originals after execution. The UI-test source SHA-256 is again `4fd3ce30b22e279b17d5e6f88cd94e4be57c76f3d71241abea7ad62a8e0c5537`; the project file is again `a73ab49ef2d126788394a24a5c0af3b95430d736aab125c3b751c61b5fab1041`; the temporary plist is absent. The retained temporary source hash is `1b5b780929aa1e6f6cc2024108e995248604c0181ec951ad2c38abba2f149b85`, and its plist hash is `58c5c0911cdf7c6fe4a120892acde2ae1e7298e967243284d83257554c756f4f`.

### Acceptance after this correction

| Criterion | Outcome | Evidence and limitation |
| --- | --- | --- |
| AC1 | **BLOCKED** | Partial/Open landscape now have chassis captures. Two non-preset angles and both native Split View arrangements remain unobserved; PikaDex window smoke awaits canonical catalog packaging and C4. |
| AC2 | **BLOCKED** | The public API probe now executes, but the current combination rejects the first native angle observation. Setter support and native pose automation remain unproven. Geometry resizing supplies no native folding evidence. |
| AC3 | **PASS** for procedure and unavailable-case reporting | Stable actions, expected results, screenshot hashes, exact owner gestures, and failure reporting are defined. This does not turn the blocked AC1 cases into passes. |
| AC4 | **PASS** | C1/C2 retain deterministic state and persistence claims. |
| AC5 | **PASS** for handoff | C4 retains app smoke/continuity; D2 retains hardware qualification. Beta feasibility is not a release gate. |

## 2026-11-13 feasibility-completion pass

This pass started from clean worktree and draft PR HEAD `0ef77009313dfe0250bcf2e9b7bfb4f088d70107` on `codex/issue-11-native-duo-test-mechanism`. The earlier attempts and their evidence remain unchanged. The observations below supersede the previous current-status statements for native Split View and the untested setter.

### Environment and native evidence

Stable Xcode 27.2 build 27B52 remained globally selected. Xcode 27.3 Beta build 27C5020n was selected only through `DEVELOPER_DIR` for the XCTest probe. The available, booted iPhone Duo used `com.apple.CoreSimulator.SimRuntime.iOS-27-2-iPhone19-4`, iOS 27.2 build 24B91016s, device type `com.apple.CoreSimulator.SimDeviceType.iPhone-Duo`. `environment.json` retains its exact UDID, toolchain versions, runtime inventory, and free-space measurements. Internal free space was above 120 GiB before the build and diagnostic installation, above the 10 GiB minimum. No Xcode or runtime installation occurred.

The owner supplied three original Device Hub screenshots. Copies and their original Desktop provenance are retained privately under `2026-11-13-feasibility-completion/owner`; the originals were left untouched. The current native Device Hub window also rendered the opposite Split View arrangement. Its capture includes the chassis and both windows. No swap gesture was performed by the agent in this pass.

| Case | Expected state / actual operation | Observed result | Outcome and artifact SHA-256 |
| --- | --- | --- | --- |
| Files left / Safari right | Owner-operated native Split View in Open landscape; inspect supplied full-window capture. | Files on the left, Safari on the right, native divider and chassis visible. | **PASS** for this system mechanism observation: `owner/owner-03.png`, `160659516e129634309fbf1f337229761935c25439590b99057c512fe617fd13`. |
| Safari left / Files right | Inspect the currently displayed opposite native arrangement. | Safari on the left, Files on the right, native divider and chassis visible. | **PASS** for this system mechanism observation: `native/safari-left-files-right.png`, `a43ad296dddd0c0d55d7b69d8db0165acece42de5c43d62439b317fb7403b04b`. |
| Owner closed capture | Inspect outer display and chassis. | Closed outer Home Screen; no arbitrary hinge angle established. | **PASS** for Closed only: `owner/owner-01.png`, `915cd633e6a813e4406439f03d85e7055bbedcbc8340dc0faa5dffd0472805ea`. |
| Owner partial capture | Inspect bent inner display and chassis. | Partial pose visible, without a numeric angle or proof that it differs from the partial preset. | **PASS** for a partial pose only: `owner/owner-02.png`, `37dfc8d1366c7c1b65c4cf17b1777b6d6aa2a9a7e05a59aaa3f5f4eea31ae7c5`. |
| Two non-preset intermediate angles | Observe two native hinge angles away from the three presets. | The supplied captures do not establish two such angles. The public observer described below is available for owner operation. | **BLOCKED** pending actual angle observations and chassis captures. Slider position alone is insufficient. |

The previously retained Partial/Open landscape captures remain PASS. The two new Split View observations establish native system window placement and narrow system-app windows. They do not establish PikaDex layout, safe-area insets, startup, or state continuity. Those app-specific observations remain with C4.

A post-probe Device Hub screenshot request timed out after 30 seconds and reset the GUI bridge session. It produced no retained post-probe capture. No retry, server management, or authorization change followed.

### Disposable public hinge observer

A standalone UIKit diagnostic was built with stable Xcode 27.2 outside the repository, installed on the exact Duo, and launched successfully. It adds a public `UIHingeInteraction` to its view, displays each update's angle in radians/degrees and status, and writes timestamped updates to its own Documents directory. Its first delivered update was 180 degrees, status 3 (fully open). This observation occurred after the failed XCTest request; it is not a synchronized observation of that setter.

Apple documents [UIHingeInteraction](https://developer.apple.com/documentation/uikit/uihingeinteraction) as an observer for the view hierarchy. The inspected public `UIHinge.h` declares radians and warns that update granularity is system policy. The observer does not drive a hinge or replace native Device Hub controls. Exact source, headers, app bundle, build command/log, installation and launch commands are retained under `diagnostic/`. No production app source or project configuration was used or changed for it.

To complete the two remaining angle cases:

1. Open stable Device Hub and select the iOS 27.2 Duo whose UDID is in `environment.json`. Open **A3 Hinge Observer**, bundle ID `org.pikadex.a3.HingeDiagnostic`, if it is not already visible. The retained `diagnostic/build.sh` rebuilds it; `install-launch.json` contains the exact destination and commands.
2. Select the three native presets and record their delivered observer values as reference points. Hold the physical Option key and drag the hinge slider below the bezel to an interior position that differs from each preset. Wait for a delivered numeric update. Save the complete Device Hub window, including the chassis and observer text.
3. Repeat at a second distinct non-preset angle. Save a second complete window capture or a short recording spanning both poses. Compare the delivered values against the preset values; do not substitute slider fractions for angle observations or demand precision beyond the delivered updates.
4. Retain the diagnostic's `Documents/hinge-updates.jsonl` with the captures and their hashes. If the control or observer is unavailable, record that exact result and leave both cases BLOCKED. The agent's GUI bridge cannot currently perform or verify the Option-drag gesture.

No non-preset PASS is assigned until those actual observations have been checked.

### Setter-first XCUIHinge execution

The existing reversible infrastructure was reused with a unique result bundle under `probe/setter-first`. The temporary method performs no hinge getter and no PikaDex launch. It requests 0, π/3, 2π/3, and π radians (0°, 60°, 120°, 180°), with log markers before and after each setter. The first request reached the setter; no after-set marker appeared.

| Configuration | Executed / passed / failed / skipped | Actual result |
| --- | --- | --- |
| Xcode 27.3 Beta 27C5020n, SDK 27.3, existing iOS 27.2 Duo 24B91016s | **1 / 0 / 1 / 0** | First request, 0 radians: `Failed to set hinge angle: Setting hinge angle is unsupported on this device, ignoring.` `xcodebuild` exited 65. |

The exact test method is `PokedexUITests/PokedexUITests/testXCUHingeNativeAngleProbe`. The result bundle confirms execution; this is not a compile-only result. The later three requests, per-angle screen attachments, and intermediate deviations were **NOT RUN** because the first setter failed. No native pose change was independently verified. The attempt to capture the post-test chassis encountered the GUI timeout recorded above.

The temporary target-specific plist and database-check script inputs were the same as the prior sandbox-enabled run. `ENABLE_USER_SCRIPT_SANDBOXING=YES` and `PIKADEX_SKIP_GENERATED_DATABASE_CHECK=NO` remained set. The preserved WAL-format database was only an existence-check build input for a test that does not launch PikaDex. Canonical release verification was unchanged. To reproduce, use this pass's retained `PokedexUITests.swift`, `Info.plist`, `project-inputs.diff`, and `command.json`, select a fresh external result path, then restore the original files. The command shape is the sandbox-enabled invocation above; the private command record fixes the actual destination, scratch directories, database path, and `TMPDIR`.

The exact temporary setter-first source SHA-256 is `5122c3d3bd6b18d8420ae6225259070602503e91c66dfa25c5d809f17b279025`. Restoration verifies the original UI-test source at `4fd3ce30b22e279b17d5e6f88cd94e4be57c76f3d71241abea7ad62a8e0c5537`, project at `a73ab49ef2d126788394a24a5c0af3b95430d736aab125c3b751c61b5fab1041`, and the temporary plist absent. The tracked source diff remains documentation-only.

### Automation finding and acceptance

1. **Demonstrated:** interactive native Device Hub presets, portrait/landscape observations, and both Files/Safari Split View arrangements. `UIHingeInteraction` delivered the diagnostic's initial native angle. No headless native folding automation was demonstrated.
2. **Unsupported in the tested configuration:** the Beta XCTest hinge getter in two earlier executed runs and the setter in this new run reject the iOS 27.2 Duo. This is a bounded configuration result, not a claim that every simulator/runtime rejects XCUIHinge. Generic geometry/resizing supplies no native fold coverage.
3. **Unverified:** non-preset Device Hub angles pending owner evidence; XCUIHinge on an iOS 27.3 Duo runtime; physical-device behavior. A 27.3 comparison is justified as a separate compatibility probe because the API first appears in this Beta and the 27.2 runtime rejects both operations. Neither the declarations nor these failures prove that runtime 27.3 is required or sufficient. Before installation, the owner must approve it, verify Duo runtime availability, download and expanded/scratch sizes in official Xcode Components, retain the 10 GiB internal floor, and confirm external evidence capacity. No new runtime was installed.

| Criterion | Latest outcome | Evidence and remaining limitation |
| --- | --- | --- |
| AC1 | **BLOCKED overall** | Toolchain/runtime, native presets, landscape partial/open, outer/inner displays, and both native Split View sides are observed. Two non-preset poses await checked evidence. PikaDex layout/startup and safe-area smoke stay C4. |
| AC2 | **BLOCKED overall; tested probe FAIL** | The setter-first test executed once and rejected the first request. No supported headless pose automation was demonstrated in the tested configuration. The newer-runtime comparison remains unverified. |
| AC3 | **PASS** for procedure and unavailable-case reporting | Native actions, exact private destination/commands, expected/observed states, artifact hashes, and remaining owner actions are recorded. |
| AC4 | **PASS** | C1/C2 retain deterministic state and persistence assertions. |
| AC5 | **PASS** for handoff | C4 retains PikaDex smoke/continuity and its existing catalog prerequisite; D2 retains hardware qualification. Beta feasibility is not a release gate. |

Issue #11 has no separate PAC/TAC identifiers; these rows map its five actual acceptance criteria. The draft PR must remain blocked on the missing native angle evidence and unverified headless support. No release status changes follow from this run.
