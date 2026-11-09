# PikaDex

PikaDex provides game-specific Pokémon reference information for official core RPGs and, in the planned expansion, ROM hacks.

## Language

**Official RPG**:
A core Pokémon RPG or Legends-style Pokémon game, including its applicable downloadable content. Excludes spin-offs with distinct gameplay and information architecture.
_Avoid_: All Pokémon games

**Spin-off**:
A Pokémon game outside PikaDex's official-RPG product scope whose substantially different rules or workflows may require another app.

**ROM Hack**:
A fan-created modification of a Pokémon RPG, treated as a distinct game with its own reference content where it differs from the base game.

**Game Dataset**:
The game-specific reference content PikaDex uses for a supported official RPG or ROM hack. Distinct from National, which aggregates Pokémon data across games.

**National Dataset**:
The aggregate Pokédex reference dataset, rather than a separately released game.

**Curated Game Dataset**:
A game dataset that is reviewed and approved for inclusion in PikaDex's shipped reference catalog, whether from an official RPG or a ROM hack.
_Avoid_: User-imported content pack

**Game Identity**:
An immutable, namespaced identifier for an official RPG or ROM hack, independent of catalog row numbering, display names, and purchase entitlements.

**DLC Content**:
Additional content associated with an existing official RPG's game dataset, not a separately selectable game.

**Game Content Version**:
A revision of the reference content for a game with an unchanged game identity; content versions are not distinct selectable games.

**ROM Hack Fork**:
A materially distinct, independently maintained ROM-hack variant treated as its own game rather than a revision of its parent hack.

**Materialized Game Dataset**:
A complete game-specific dataset containing its reviewed content, including inherited and overridden data where applicable, without relying on its source dataset at runtime.

**Game Capabilities**:
An explicit description of the reference features and game mechanics supported by a dataset, independent of the game's generation or the rules of another game.

**Unresolved Reference**:
A user-owned saved reference whose former target is absent or no longer uniquely identifiable in the current catalog, retained for display or later resolution rather than silently discarded or substituted.

**User-Owned Data**:
Information created or personalized by the player that must survive application and reference-catalog updates, including caught records, saved teams, preferences, and purchase access.
_Avoid_: Bundled catalog data

**Source Acquisition**:
The gathering of external game information or media before it is accepted as production content.

**Reviewed Input**:
A source data input that has been inspected and approved for catalog generation. Raw acquired material is not a reviewed input by default.

**Content Provenance**:
The traceable origin, revision, transformation history, and review status of a content value or dataset, including when it has been combined with or overridden by another source.

**Source Conflict**:
A disagreement between acquired sources about a reference fact that requires explicit review rather than an implicit choice of one source.

**Conflict Disposition**:
A recorded, human-reviewed decision about a source conflict, including its resolution or explicitly accepted uncertainty, required before the affected content is approved for release.

**Completeness Profile**:
A game-specific declaration of which reference sections are required, supported but incomplete, or unavailable.

**Source-Generated Catalog**:
The validated, locally generated reference database derived from reviewed inputs and the application's authoritative data model.

**Media Baseline**:
An inventoried set of existing app media and its validation findings, used to assess the fidelity of future generated assets. Being present in the app does not by itself establish an asset's accuracy or redistribution rights.
