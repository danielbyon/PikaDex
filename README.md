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

The authoritative module unit tests are verified with:

```sh
rtk xcodebuild test \
  -project Pokedex.xcodeproj \
  -scheme Modules \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

The legacy `PokedexTests` application test target is not included in the verified command because its model-object tests reference types that are no longer present in the production code. The target requires a separate test-modernization pass.

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
