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

The canonical Phase 7 release command is:

```sh
rtk Scripts/pokedex-release-verification
```

The runner validates the simulator during its named `preflight` gate before
any build. It then fails fast in this order: `Pokedex` build, `Modules`,
`PokedexTests`, `PokedexConcurrencyTests`, `DatabasePipelineTests`, data-pipeline
`prepare-tools`, and offline data-pipeline `verify`. The pipeline gates reuse
`Scripts/pokedex-data-pipeline`; the release runner does not duplicate crawler
or generation logic.

`PIKADEX_SIMULATOR_DESTINATION` overrides the default
`platform=iOS Simulator,name=iPhone 17 Pro`. `PIKADEX_RELEASE_BUILD_ROOT`
overrides the default isolated root at `build/release-verification`. The root is
validated before cleanup, and only these owned children are recreated:

1. `DerivedData/`
2. `ResultBundles/`
3. `Profiles/`
4. `PipelineTooling/`
5. `PipelineOutput/`

Unsafe roots that overlap the repository, production source or resource
directories, or escape the repository build directory through a symbolic link
are rejected. Progress output names the current gate and completed gates. A
failure names the failed gate and exit status; success ends with
`Release verification succeeded.`, the complete gate list, and the isolated
output root.

## Reproducible database generation

The database is prepared through a hybrid crawler, manual Apple Numbers, and
tooling-only macOS workflow. The canonical automated boundary begins at
reviewed delimited exports and other explicitly pinned legacy loader inputs.
The offline command, versioned manifest, manual-workflow inventory, acquisition
policy, deterministic semantic comparison, report formats, and future-game
runbook are documented in
[`Scripts/DataPipeline/README.md`](Scripts/DataPipeline/README.md). Running
`Scripts/pokedex-data-pipeline verify` never invokes acquisition and never
mutates reviewed inputs, the committed database, or model resources.

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
