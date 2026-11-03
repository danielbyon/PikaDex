# Test target ownership

`PokedexTests` is a hosted application test target for app-owned composition behavior. It contains only `DeepLinkTests.swift`, which verifies the pure URL parsing and route-construction seam implemented by the application target. The target depends on `Pokedex`, uses `PikaDex.app` as `TEST_HOST` and `BUNDLE_LOADER`, remains on iOS 17 and Swift 5, and enables targeted strict-concurrency checking.

The application host is intentional: `URL+DeepLinks.swift` belongs to the app composition layer and is not a reusable `PokedexCore` contract. Tests do not launch the app, use `UIApplication`, mutate navigation state, read user defaults, or load production SQLite resources.

Reusable domain contracts belong to `PokedexCoreTests` and run through the shared `Modules` scheme:

1. `StatCalculatorTests.swift` protects stat calculation, nature factors, and pre-Generation-II HP-IV branches.
2. `TeamTests.swift` protects deterministic Team and PokéPaste formatting.
3. `GameBitwiseValueTests.swift` protects every persisted released-game value and the National sentinel.

## Legacy test disposition

Every removed legacy test was inspected before deletion. The exact disposition is:

| Removed file | Disposition |
| --- | --- |
| `PokedexTests.swift` | Deleted because it was the untouched generated XCTest template and asserted no product behavior. |
| `StatCalculatorTests.swift` | Moved to `ModuleTests/PokedexCoreTests/StatCalculatorTests.swift`; the same six examples remain and focused branch cases were added. |
| `TeamTests.swift` | Moved to `ModuleTests/PokedexCoreTests/TeamTests.swift`; the complete snapshot remains and focused PokéPaste cases were added. |
| `Database/DatabaseTests.swift` | Deleted because its app-bundle model setup and `PokemonForm` API no longer match production. Store creation and saving are protected by `PersistenceBootstrapTests.testInMemoryStoresAreReadyAndPreserveContextConfiguration` and `QueryLayerTests.testFetchedResultsUpdatesAfterInsertAndDelete`. |
| `Database/ModelObjectBaseTestCase.swift` | Deleted because it was only the obsolete app-bundle Core Data harness and helper superclass; it contained no tests. `PersistenceBootstrapTests` owns the current injectable store harness. |
| `Database/Model Objects/AbilityTests.swift` | Deleted because it exercised obsolete generated accessors on the removed `Ability` managed-object API. Current ability dataset behavior is protected by `PokedexCoreTests.testNationalAbilitiesUseAuthoritativeNationalDescriptions` and `testNationalAbilityFilterDoesNotApplyReleasedGenerationCutoff`. |
| `Database/Model Objects/BreedLearnsetEntryTests.swift` | Deleted because its only test body was empty and commented out. |
| `Database/Model Objects/EvolutionTests.swift` | Deleted because it only round-tripped a generated Core Data `name` accessor. |
| `Database/Model Objects/FormInfoTests.swift` | Deleted because the `PokemonForm` API no longer exists. Current form-query behavior is protected by `PokedexCoreTests.testNationalDetailUsesDirectDatasetFilter` and `QueryLayerTests.testDetailAndRelationshipHeavyRequestsPreserveSpecialSettings`. |
| `Database/Model Objects/LevelLearnestEntryTests.swift` | Deleted because its only test body was empty and commented out. |
| `Database/Model Objects/MachineLearnsetEntryTests.swift` | Deleted because its only test body was empty and commented out. |
| `Database/Model Objects/MoveInfoTests.swift` | Deleted because the `MoveInfo` production API no longer exists. Current move dataset identity is protected by `PokedexCoreTests.testNationalGameKeyedQueriesReturnOnlyNationalRows` and `CanonicalSnapshotTests.testStableKeySchemaCoversEveryCatalogEntity`. |
| `Database/Model Objects/MoveTests.swift` | Deleted because it depended on the removed `MoveInfo` API and otherwise only round-tripped generated accessors. Current move query and identity behavior is protected by `PokedexCoreTests.testNationalGameKeyedQueriesReturnOnlyNationalRows` and `CanonicalSnapshotTests.testStableKeySchemaCoversEveryCatalogEntity`. |
| `Database/Model Objects/PokedexEntriesTests.swift` | Deleted because the entire file, including both test bodies, was commented out. |
| `Database/Model Objects/PokedexNumbersTests.swift` | Deleted because it only round-tripped generated Core Data accessors. |
| `Database/Model Objects/PokemonTests.swift` | Deleted because it depended on the removed `PokemonForm` API and otherwise only round-tripped generated accessors. Current Pokémon dataset and form relationships are protected by `PokedexCoreTests.testNationalPokemonDatasetIsCompleteAndContiguous` and `testNationalDetailUsesDirectDatasetFilter`. |
| `Database/Model Objects/StatsTests.swift` | Deleted because it only round-tripped generated Core Data accessors. Stat domain behavior is protected separately by `ModuleTests/PokedexCoreTests/StatCalculatorTests.swift`. |
| `Database/Model Objects/TutorLearnsetEntryTests.swift` | Deleted because its only test body was empty and commented out. |

Pipeline implementation tests remain in `PokedexTests/DatabasePipeline` on disk but belong only to the `DatabasePipelineTests` target. Concurrency tests remain in `PokedexTests/Concurrency` on disk but belong only to `PokedexConcurrencyTests`. Neither membership changed during this test modernization.

## Running the hosted tests

Run the app-owned tests without launching the application:

```sh
rtk xcodebuild test \
  -project Pokedex.xcodeproj \
  -scheme PokedexTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
