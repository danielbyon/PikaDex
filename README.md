# PikaDex

## Production source layout

The production application target is `Pokedex`, which produces `PikaDex.app`.

`Modules/` is the authoritative source tree for the reusable `PokedexCore`, `PokedexUI`, `DesignSystem`, and `PokedexResources` modules. Production feature code that is compiled directly into the application remains under `Pokedex/Feature`.

`PokedexPackages` was removed because it was not consumed by the Xcode project and contained divergent copies of the production modules and features. The Xcode targets compile the authoritative implementations directly from `Modules/`.

## Database datasets and released games

`Game` is the stable identifier stored in generated database rows. Its raw
value and `databaseIndex` are persistence contracts and must not be inferred
from declaration order. `Game.national` is an aggregate dataset with its own
generated rows; queries pass `.national` directly instead of combining rows at
runtime.

`Game.bitwiseValue` is also a stable persisted StoreKit and domain identifier.
Its implementation belongs to `PokedexCore` so the application, widgets,
intents, StoreKit code, and tests consume one shared contract.

Released-game titles, generations, release groups, selector order, and
mechanics live in the `Game.releasedGameMetadata` catalog. National has no
released-game metadata. Dataset section availability is a separate policy so
National can expose authoritative aggregate rows without claiming mechanics.

Database order, selector order, and release recency are deliberately distinct:

1. `databaseIndex` and `Comparable` use stable database identity order.
2. `selectableGames` preserves the National-first selector order.
3. `releaseGroup` represents recency and allows paired releases to share a
   group; `latestReleasedGames` therefore contains both Scarlet and Violet.
4. `defaultReleasedGame` is explicit product policy and is not inferred from
   release recency.

The production build is verified with:

```sh
rtk xcodebuild build \
  -project Pokedex.xcodeproj \
  -scheme Pokedex \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Release verification

CI and local verification use the same command:

```sh
rtk Scripts/pokedex-release-verification
```

The runner checks out the crawler revision recorded in
`Scripts/DataPipeline/crawler-source.json`, verifies all 69 reviewed inputs,
and prepares Swift packages from `Scripts/DataPipeline/Package.resolved`.
Crawler and package provisioning may use the network. Catalog generation and
validation run through `Scripts/run-with-network-denied` and write a candidate
under the build root without installing it in the checkout.

Build phases select that candidate through
`PIKADEX_GENERATED_DATABASE_PATH`. An explicit path that is missing or invalid
stops the build. Ordinary app builds leave the variable unset and continue using
`Modules/PokedexCore/Resources/Database/Pokedex.sqlite`.

The runner checks scheme and target membership, then asks Xcode for the
compiled test inventory with `-enumerate-tests` in JSON format. Source
declarations are reconciled against that inventory; Xcode's compiled list
defines the executable tests. Simulator results use each suite's xcresult when
it contains a complete case list and count. Otherwise, the runner reconciles
the full `xcodebuild` log. The runner first enumerates the compiled
`DatabasePipelineTests` cases, then builds the bundle with
`xcodebuild build-for-testing` and executes it through
`Scripts/run-xctest-bundle-with-network-denied`. The runner retains the full
XCTest log, checks every case and the final count, and preserves the XCTest
exit status. Xcode enumeration and build steps use the pinned package lock
with automatic package resolution disabled; they do not run test methods.

Each run records gate logs and statuses, suite inventories and results,
toolchain and simulator identities, source and package revisions, reviewed
input hashes, and candidate and packaged-catalog hashes. CI uploads the
verification evidence and available xcresult bundles. It excludes DerivedData,
compiled products, source copies, and the candidate SQLite file. The runner
reports disk exhaustion and unavailable Xcode or simulator infrastructure
separately from test failures and incomplete runs.

`PIKADEX_SIMULATOR_DESTINATION` overrides the default
`platform=iOS Simulator,name=iPhone 17,OS=27.0`. `PIKADEX_RELEASE_BUILD_ROOT`
sets the isolated output root; the default is `build/release-verification`.
The runner records the initial and final source database and sidecar hashes and
fails if they change during verification.

To add a C-slice UI or integration suite, add a separate entry to
`Scripts/release-verification-suites.json` with its shared scheme, test target,
platform, and test-source globs. Keep the four existing entries in
`requiredSuites`. Xcode enumeration and the same result checks then apply to
the added suite; this task does not add those tests.

## Reproducible database generation

The canonical developer and CI entry point is:

```sh
Scripts/pokedex-data-pipeline generate
```

Artwork is checked out as ordinary Git content. No Git LFS setup or separate
hydration step is required. Crawler scripts, artwork, and reviewed source data
are maintained in the public `danielbyon/PikaDexCrawlers` repository. Clone it
beside PikaDex at the revision recorded in
[`Scripts/DataPipeline/crawler-source.json`](Scripts/DataPipeline/crawler-source.json),
or set `PIKADEX_CRAWLERS_ROOT` to its checkout path. Generation maps the
manifest's existing `Crawlers/...` paths to that package while keeping the
normalized loader inputs unchanged. The generated database and its SQLite
sidecars are local files ignored by Git.

It prepares the pipeline tools as needed, preflights the reviewed sources,
generates and validates the database, and safely installs the output.

The database is prepared through a hybrid crawler, manual Apple Numbers, and
tooling-only macOS workflow. The canonical automated boundary begins at
reviewed delimited exports and other explicitly pinned legacy loader inputs.
The offline command, versioned manifest, manual-workflow inventory, acquisition
policy, deterministic semantic comparison, report formats, and future-game
runbook are documented in
[`Scripts/DataPipeline/README.md`](Scripts/DataPipeline/README.md). Running
`Scripts/pokedex-data-pipeline verify` never invokes acquisition or installs a
database. It leaves reviewed inputs and model resources unchanged.

The authoritative module unit tests are verified with:

```sh
rtk xcodebuild test \
  -project Pokedex.xcodeproj \
  -scheme Modules \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Reusable stat calculation, Team/PokéPaste formatting, and `Game` persisted-value
tests belong to `PokedexCoreTests` and run through `Modules`. `PokedexTests` is
a deliberately small hosted app test target containing only pure deep-link
tests. Its `PikaDex.app` host provides access to the app-owned URL seam without
launching the application or involving navigation, preferences, or production
database resources. Exact legacy-test dispositions are documented in
[`PokedexTests/README.md`](PokedexTests/README.md).

## Concurrency and dependency ownership

PikaDex uses targeted strict-concurrency checking while remaining on Swift 5.
It is enabled for `PokedexCore`, `PokedexUI`, `DesignSystem`,
`PokedexResources`, `PokedexTests`, `PokedexConcurrencyTests`, `Pokedex`,
`PokedexWidgetExtension`, and `TeamIntentHandler`. Complete strict concurrency,
default actor isolation, and Swift 6 language mode are not enabled.

Main-actor isolation is limited to mutable UI owners:

1. `NavigationStore` owns navigation-path state.
2. `AppSettings` and `PurchasedProductState` publish persisted UI selections
   and purchase access.
3. `BattleAssistantViewModel`, `PokemonListViewModel`,
   `PokemonContentViewModel`, `PokemonDetailOrdering`, `TeamListViewModel`
   (including `Section`), `TeamMemberViewModel`, `TeamViewModel`, and
   `StoreViewModel` publish feature state consumed by SwiftUI.
4. `SheetState` publishes presentation state.
5. `WidgetAdapter` and `InAppReviewManager` coordinate UIKit application
   lifecycle events that must enter their frameworks on the main actor.

Services, Core Data wrappers, query types, storage types, and pure helpers are
not globally main-actor isolated. `TeamStore` instead isolates only cache
mutation, snapshots, publication, and lifecycle flushing. Its immutable
snapshots pass to a separate serial persistence writer. Replacing a debounce
cancels the prior work; explicit `flushPendingWrites()` is the guaranteed
lifecycle path, while teardown intentionally discards unflushed work and only
performs idempotent best-effort shutdown. App-group `UserDefaults` remains the
production persistence backend.

The application composition root owns `AppSettings` and
`PurchasedProductState` as `@StateObject` values. It creates the production
stores and `StoreClient` once, then passes those exact instances through
`withDependencies` while constructing the root hierarchy. SwiftUI may recreate
root view values, but it preserves the app-owned state-object storage, so the
composition wrapper keeps injecting the same observable identities rather than
creating dependency defaults or ordinary stored-property duplicates. Tests and
previews inject explicit instances. Dependency-backed previews use
`PreviewDependencyRoot`, which owns one dependency container per hierarchy and
creates fresh volatile team storage for every preview root. Team-storage tests
likewise create a new `VolatileTeamStorage` for each dependency context; no
mutable volatile storage is shared statically.

StoreKit product loading is owned entirely by a private serialized request
coordinator. Its active request, continuation, token generation, and teardown
state mutate on one serial executor. It clears active state before cancellation
or continuation resumption and ignores callbacks for replaced, cancelled, or
completed requests. Success returns products; StoreKit failure preserves the
original error; task cancellation, replacement, explicit teardown, and owner
release each record a distinct terminal reason and resume with
`CancellationError` exactly once. `StoreClient` uses
`withTaskCancellationHandler` so Swift-task cancellation also cancels the
underlying request. Its deinitializer synchronously delegates idempotent
shutdown to the coordinator and never captures `StoreClient` asynchronously.

`StoreViewModel` owns one refresh task. Starting a refresh cancels its
predecessor and advances an immutable generation. The task captures the client
and generation strongly but the view model weakly, so it cannot extend the
view-model lifetime. Cancellation is silent, and generation checks reject late
or non-cooperative results. Explicit Combine `.receive(on: .main)` scheduling
is retained wherever publisher delivery may originate off the main thread;
actor isolation does not change a publisher's scheduler.

Widget providers resolve the persisted game once per WidgetKit callback and
use that immutable snapshot throughout the callback. The retained loader exists
because a provider can serve multiple callbacks in one process; it must be
synchronous and safe on arbitrary threads. Fixed-width and one-decimal display
formatting, whole-number effectiveness labels, and integer editor input use
immutable `FormatStyle` values. The shared mutable height and mass formatters
are narrowly main-actor isolated. StoreKit currency and the settings copyright
year use local formatters on infrequent display paths.

Focused concurrency tests run independently of the legacy test target:

```sh
rtk xcodebuild test \
  -project Pokedex.xcodeproj \
  -scheme PokedexConcurrencyTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The repository contains no `Package.swift` manifests. Dependencies remain
configured through the Xcode project's six remote package references and
`Package.resolved`; Phase 5 does not change package URLs or resolved versions.

## Core Data bootstrap

`PersistenceBootstrap.production()` is the canonical owner of Core Data store
construction. It loads the bundled read-only Pokédex catalog and the writable
`UserData.sqlite` store synchronously, and returns `PersistenceStores` only
after both stores are ready. Successful and failed production attempts are
cached so concurrent or repeated callers cannot create divergent containers
or trigger an implicit recovery attempt.

The catalog model and SQLite resource are resolved from `Bundle.pokedexCore`,
never from the application main bundle. `Pokedex.sqlite` is required. WAL and
shared-memory sidecars are validated when packaged but are not rejected solely
because they are absent; the read-only Core Data load and representative
National and released-game queries determine whether the available files are
usable. The generated database and any packaged sidecars are always opened
read-only.

Bootstrap failures preserve their failing stage, safe store configuration,
underlying error, and internal diagnostic URLs. Release-facing descriptions do
not include filesystem paths. `PokedexCore` returns these errors; only the
outer `PokedexApp` composition boundary terminates when production persistence
cannot be prepared.

Production view contexts deliberately preserve the previous effective
configuration: main-queue concurrency, the error merge policy, automatic
merging disabled, no undo manager, no transaction author, and registered-object
retention disabled. Persistent history and remote-change notifications are not
enabled.

Tests should use `makeInMemoryForTesting()` or
`makeTemporaryForTesting(directoryURL:)`. Both factories are uncached and
isolated from bundled production data. Catalog integration tests use the
uncached internal bundled-catalog factory, which opens the catalog read-only
and keeps user data in memory. Previews follow the same read-only catalog rule
and use in-memory user data.

## Core Data queries

`QueryFilter` implementations construct deterministic `NSFetchRequest` values
without accessing persistence or executing a fetch. `DataStore` is the single
execution boundary for one-shot fetches, saves, removals, and observed queries.
It performs Core Data work on the managed-object context queue and does not
resolve `PersistenceBootstrap` during ordinary query execution.

SwiftUI features use `@Query` as a thin wrapper around a fetched-results
controller. Its wrapped `QueryResults` value remains a random-access collection,
and its projected value remains a binding to the filter. `QueryResults.state`
reports `idle`, `loading`, `loaded`, or a stable `QueryFailure`. Loading and
failure retain the last successfully loaded rows; underlying persistence errors
remain diagnostic details rather than public view state.

An unchanged filter and managed-object context reuse the existing controller.
Changing the filter or context detaches the old delegate and creates a new
controller on the appropriate context queue. A new `DataStore` wrapper around
the same context therefore does not trigger a redundant fetch. Observed-query
batching and fault defaults are applied separately from one-shot requests so a
filter's explicit request settings remain authoritative.
