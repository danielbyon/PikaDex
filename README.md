# PikaDex

## Production source layout

The production application target is `Pokedex`, which produces `PikaDex.app`.

`Modules/` is the authoritative source tree for the reusable `PokedexCore`, `PokedexUI`, `DesignSystem`, and `PokedexResources` modules. Production feature code that is compiled directly into the application remains under `Pokedex/Feature`.

`PokedexPackages` was removed because it was not consumed by the Xcode project and contained divergent copies of the production modules and features. The Xcode targets compile the authoritative implementations directly from `Modules/`.

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
