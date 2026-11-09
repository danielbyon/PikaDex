# ADR-0005: Stable game identities and fully materialized datasets

Status: Accepted, 2026-11-06.

Official RPGs and curated ROM hacks use an **immutable, namespaced game identity**, independent of generated catalog row IDs, display titles, and purchase entitlements. DLC belongs to its parent official RPG's dataset. ROM hacks may reuse a base game's content **during ingestion** but are fully materialized as independently usable datasets for the application. Each dataset declares its own capabilities and mechanics.

## Context and alternatives

The existing `Game` enum, integer `databaseIndex`, and `Int64` purchase mask combine a fixed list of games with several unrelated responsibilities. This prevents first-class identification of a growing set of ROM hacks. A new bundled SQLite catalog is generated and ships with the app, so its internal IDs need not remain compatible with older bundled copies; user-owned references do.

Namespaced identities distinguish official releases from curated ROM hacks (illustrative IDs: `official:scarlet` and `hack:radical-red`). The exact on-disk encoding and slug governance remain an implementation decision, but identity must remain stable across app versions and content changes.

At runtime a hack cannot depend on another dataset merely to exist: a hack based on FireRed, for example, may change types, evolutions, abilities, or move rules. We therefore prefer **ingestion-time inheritance plus reviewed overrides** and a fully materialized result, rather than runtime fallback or layered lookups. This avoids subtle behavior changes when the source dataset is updated and permits separate validation of the hack's final content.

DLC is attached to its existing official game, with explicit availability metadata; duplicating entire base-game datasets for DLC would create confusing selector entries and divergent content.

## Accepted constraints

1. **Stable namespaced IDs.** A game identity is immutable and independent of a database index, label, or commerce product. Renaming a game or regenerating the bundled database must not change which game a saved record identifies. Namespace categories distinguish official RPGs and ROM hacks.
2. **DLC within the parent game.** DLC adds content and availability metadata to its parent game dataset; it is not selectable as a separate game.
   **National** remains an official-only aggregate; new ROM-hack-exclusive species, forms, moves, and custom content must not leak into it.
3. **Compile-time inheritance of hack content.** An ingestion pipeline may take reviewed base-game content and apply versioned, reviewed overrides. The shipped result is a complete, independent ROM-hack dataset. No runtime inheritance/fallback dependency on the base game's dataset is required.
   **Version identity:** A new release of the same maintained ROM hack keeps its game identity and changes a separate content/version marker; a materially distinct independently maintained fork gets a different namespaced identity. Do not tie saved data identity to a particular update version.
4. **Explicit capabilities.** Game-specific reference sections, mechanics, and supported calculation rules are declared per dataset. A ROM hack's mechanics are not inferred from its base game or generation. Missing or unsupported content must not be represented as authoritative.
5. **User-owned state stays recoverable.** For the *first game-identity migration* (after Swift 6 + Duo), saved teams remain in app-group `UserDefaults` rather than moving into Core Data at the same time. Migrate the existing `teams-<Game.rawValue>` keys and embedded `TeamMember.game` references, plus caught-Pokémon Core Data records, selected-game preferences and preserved purchase access as needed. Backend consolidation, if desired, is a separate change.
6. **Unresolved saved references are preserved.** When a referenced form, move, species, or other catalog object disappears or becomes ambiguous, retain the original saved record and identify the reference as unresolved. Only validated, unambiguous mappings may be automatic. Never silently discard, substitute, or bind saved data to the wrong target.

## Failure modes and review gates

The two main hazards are (a) breaking user-owned records while replacing bundled catalog identities and (b) silently altering ROM-hack meaning through inherited defaults. Required follow-up design work includes a legacy-identity mapping and retry-safe migrations, unresolved-reference presentation, canonical override precedence, provenance and validation of the final materialized dataset, and tests that exercise missing/renamed forms and unsupported mechanics.

This ADR does **not** settle identifier syntax, storage representation, override file format, the capability taxonomy, dataset completeness rules, or ROM-hack entitlement products. Those must be decided before implementing the later content-platform milestone. The Swift 6 + MVP Duo release does not change the game identity model.

See [ADR-0004](0004-curated-game-datasets-and-user-data-migration.md) for the bundled-content, monetization, and wider user-data contract; see [ADR-0002](0002-source-generated-sqlite-without-git-lfs.md) and [ADR-0003](0003-external-crawler-source.md) for the existing pipeline boundaries.
