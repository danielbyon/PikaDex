# ADR-0004: Curated first-class game datasets with independent catalog evolution

Status: Accepted, 2026-11-05.

PikaDex will treat official core RPGs and curated ROM hacks as first-class game datasets with explicit game-specific capabilities. All supported datasets and their reviewed media ship with the application; runtime plugin systems and user-imported content packs are out of scope. The bundled catalog is generated, replaceable reference content: its model and internal dataset identifiers may evolve, but existing **user-owned state and purchase access** must survive the transition.

## Context and rationale

The current `Game` enum, per-dataset numeric index, and fixed `Int64` purchase mask are workable for the existing fixed list of official games, not for a growing catalog with divergent ROM hacks and mechanics. Preserving internal schema compatibility of a database rebuilt and shipped with each app version would impede the new domain model without providing value to users.

Importable plugins would create an additional product and security surface (content validation, quality, trust, rights, version compatibility, and distribution). The owner chose a curated, bundled approach to maintain control of data quality, provenance, and the actual user experience. This is a deliberate scope boundary, not a first-stage plugin implementation.

## Decision

1. **First-class datasets.** Both official core Pokémon RPGs and ROM hacks participate in the application's shared game selector, reference model, and ingestion/validation process, subject to their declared game-specific capabilities. A ROM hack is not necessarily constrained by the rules of its base game.
2. **Shipping only.** All final datasets and media are bundled in the app release, including curated ROM-hack content. No on-demand resources (ODR), remote content downloads, user-side import of game data, user-installable plugins, ROM execution, or ROM/patch distribution. Offline availability and app-controlled content/version alignment are deliberate constraints. ROM hacks will be paid; their products, prices, and entitlement mechanism require an additional decision before launch. Do not silently classify hacks as free simply because an existing purchase mask cannot express them.
3. **Replaceable catalog.** A future implementation may change the generated `Pokedex.sqlite` Core Data model, catalog schema, `Game` representation, and internal numeric dataset identifiers. No on-device migration of an old **bundled** catalog is required; it is replaced as a resource by the application.
4. **Preserved user state.** All previously saved user-owned data must survive or be explicitly migrated. Currently this includes caught-Pokémon records in writable Core Data `UserData.sqlite`, app-group `UserDefaults` JSON teams under `teams-<Game.rawValue>`, `TeamMember.game` references, selected-game preferences, and purchase bits synchronized with iCloud key-value storage. Preserving previously granted purchase access is not optional. The new identity model must provide a well-defined legacy mapping.
5. **Release isolation.** The first milestone remains Swift 6 language-mode migration plus MVP iPhone Duo support, with an iOS 26 minimum deployment target under the N-1 OS policy. Do not introduce a new catalog identity schema or ROM-hack runtime architecture into that milestone.
6. **National dataset.** National remains a distinct aggregate dataset, not an official released game or a ROM hack, unless a later product decision explicitly revises that meaning.

## Rejected alternatives and why

- **Freeze generated catalog IDs forever:** rejected because the bundled catalog is derived from reviewed inputs, and requiring perpetual internal-schema compatibility would restrict a proper unified game model. User-owned references, not a shipped SQLite file, are the real migration contract.
- **Encode all ROM hacks as cases in the legacy game-bitmask scheme:** rejected as the assumed long-term architecture; it mixes content identity with StoreKit purchase bookkeeping and is not a scalable general-purpose dataset model. Exact replacement implementation remains undecided.
- **User-imported plugins or content packs:** rejected as a product scope due to quality, provenance, rights, and compatibility costs.
- **Ship ROM hacks free because existing entitlements are limited:** explicitly rejected. Monetization must be designed before ROM-hack launch.

## Consequences and failure modes

The catalog model, generation tools, queries, user data, widget/intent preferences, and entitlements may need coordinated changes. A broken migration could orphan teams, silently drop caught flags, misassociate a saved Pokémon with a different game or form, reset selected-game preferences, or revoke access paid for previously. Before replacing any saved identity, define mapping behavior for missing/renamed data, idempotent migration and recovery, and tests using legacy persisted fixtures.

**ADR-0005** settles the immutable, namespaced game identity requirement, DLC dataset parentage, ingestion-time ROM-hack inheritance with materialized outputs, explicit per-dataset capabilities, preservation of unresolved saved references, and retention of app-group team storage during the first identity migration. The precise identity encoding, migration procedures, capability taxonomy, paid-product model, and first curated ROM-hack candidate remain **open implementation or product decisions**. This ADR authorizes the architecture direction, not an implementation of those choices. ADR-0002's explicit offline source-generated SQLite workflow and ADR-0003's two-repository acquisition boundary remain in force.
