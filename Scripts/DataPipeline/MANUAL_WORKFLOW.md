# Manual production-data workflow inventory

## 1. Evidence rules

This inventory records only relationships visible in the repository. Matching
file names are evidence that artifacts are related, but they are not proof of a
specific join, override, filter, sort, or worksheet formula. Where the
repository does not contain a transformation specification, the relationship
is marked undocumented and remains a maintainer-owned blocker.

The automated trust boundary begins at the reviewed inputs declared in
`pipeline-manifest.json`. Crawler output must remain in acquisition staging
until a maintainer completes the manual Numbers work and reviews a fresh
export. No crawler output is copied directly into a loader input path.

Crawler sources now live in the separately pinned `PikaDexCrawlers` checkout.
The `Crawlers/Data/...` paths in the manifest remain the logical source names
and map to `PikaDexCrawlers/Data/...` during preflight and normalization.
Updating the pinned source revision does not approve changed loader data;
changed inputs still require source review and matching manifest checksums.

## 2. Crawler inventory

The durable outputs below are taken from output calls or path constants in the
scripts. “Undocumented” means no durable output-to-workbook relationship is
encoded in the repository.

| Script | Observed durable output | Numbers/manual consumer | Loader impact |
| --- | --- | --- | --- |
| `AbilitiesCrawler2.py` | `Data/Abilities.json` | Undocumented | `Crawlers/Data/Abilities.json` remains a reviewed legacy JSON input |
| `AbilityExternalLinksCrawler.py` | No durable output call identified | `Research/AbilityExternalLinks.numbers` exists, but consumption is undocumented | `Research/AbilityExternalLinks.tsv` |
| `ExternalLinksCrawler.py` | `Data/ExternalLinks.json` | Undocumented | Not consumed by the current loader |
| `ItemSpriteCrawler.py` | `Artwork/RawItems/Sprites/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `ItemsBagSpritesCrawler.py` | `Artwork/RawItems/BagSprites/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `ItemsCrawlerBulbapedia.py` | `Data/BulbapediaItems.json` | `Research/ManualItems.numbers` exists, but linkage is undocumented | `Crawlers/Data/BulbapediaItems.json` |
| `ItemsCrawlerPokemonDB.py` | `Data/PokemonDBItems.json` | `Research/ManualItems.numbers` exists, but linkage is undocumented | `Crawlers/Data/PokemonDBItems.json` |
| `ItemsDreamWorldImagesCrawler.py` | `Artwork/RawItems/DreamWorld/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `LearnsetBreedingCrawler.py` | `Data/LearnsetBreeding.json` | Undocumented | `Crawlers/Data/LearnsetBreeding.json` |
| `LearnsetBreedingCrawler2.py` | `Data/LearnsetBreeding2.json` | Undocumented | Not consumed by the current loader |
| `LearnsetLevelCrawler3.py` | `Data/LearnsetLevel3.json` | Undocumented | `Crawlers/Data/LearnsetLevel3.json` |
| `LearnsetMachinesCrawler3.py` | `Data/LearnsetMachines3.json` | Undocumented | `Crawlers/Data/LearnsetMachines3.json` |
| `LearnsetTutoringCrawler3.py` | `Data/LearnsetTutoring3.json` | Undocumented | `Crawlers/Data/LearnsetTutoring3.json` |
| `MoveDescriptionCrawler.py` | `Data/MoveDescriptions.json` | Undocumented | `Crawlers/Data/MoveDescriptions.json` |
| `MoveExternalLinksCrawler.py` | No durable output call identified | `Research/MoveExternalLinks.numbers` exists, but consumption is undocumented | `Research/MoveExternalLinks.tsv` |
| `MovesCrawler.py` | `Data/Moves.json` | Undocumented | `Crawlers/Data/Moves.json` |
| `MovesCrawler2.py` | `Data/MoveDescriptions2.json` | Undocumented | Not consumed by the current loader |
| `PokedexEntriesCrawler.py` | `Data/PokedexEntries.tsv` and `Data/PokedexEntries-Vertical.tsv` | Affected workbook is undocumented | Not consumed directly; downstream use is undocumented |
| `PokedexEntriesCrawler2.py` | `Data/PokedexEntries2.json` and `Data/PokedexEntries2-Vertical.tsv` | Affected workbook is undocumented | Not consumed directly |
| `PokemonAbilitiesCrawler.py` | `Data/PokemonAbilities.json` | Affected workbook is undocumented | Not consumed directly |
| `PokemonInfoCrawler.py` | `Data/PokemonInfo.tsv` | Affected workbook is undocumented | Not consumed directly |
| `PokemonLocationCrawler.py` | `Data/PokemonLocations.json` | Manual reconciliation is undocumented | `Crawlers/Data/PokemonLocations.json` |
| `PokemonTypeCrawler.py` | `Data/PokemonTypes.tsv` | Affected workbook is undocumented | Not consumed directly |
| `PokemonWildDenCrawler.py` | `Data/PokemonWildDen.json` | `Research/WildDenPokemon.numbers` exists, but linkage is undocumented | `Crawlers/Data/PokemonWildDen.json` |
| `PokemonDreamWorldImagesCrawler.py` | `Artwork/RawPokemon/DreamWorld/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `PokemonImageCrawler.py` | `Artwork/RawImages/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `PokemonKenSugimoriImagesCrawler.py` | `Artwork/RawPokemon/KenSugimori/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `PokemonSpritesCrawler.py` | `Artwork/RawSprites/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `PokemonSpritesCrawler2.py` | `Artwork/RawSpritesNationalList/` | Manual artwork preparation; exact process undocumented | No database-loader input |
| `Playground.py` | No production output contract identified | Investigation-only script | No documented loader input |
| `PokemonDB.py` | No production output contract identified | Shared/investigation code | No documented loader input |
| `CrawlerUtils.py` | Shared cache, JSON, TSV, and image-writing helpers | Support module, not a crawler | Cannot be invoked through acquisition |

Only manifest-declared, individually verified scripts can be invoked by
`acquire`. The full inventory is intentionally broader than that allowlist.

## 3. Numbers and reviewed-export inventory

| Numbers document | Observed reviewed export or status | Known worksheet evidence | Transformation status |
| --- | --- | --- | --- |
| `AbilityExternalLinks.numbers` | `AbilityExternalLinks.tsv` | Worksheet name not recorded | Exact source mapping and override rules undocumented |
| `Base Stats.numbers` | `Base Stats/*-Table 1.tsv`; not read directly by loader | Export filenames identify generation sheets and `Table 1` | Downstream join into loader inputs undocumented |
| `Berries.numbers` | `Berries.tsv` | Worksheet name not recorded | Column and duplicate-resolution rules undocumented |
| `Evolutions.numbers` | `Evolutions.tsv` | Worksheet name not recorded | Join, filter, and override rules undocumented |
| `HMs.numbers` | `HMs/*-Table 1.tsv` | Export filenames identify dataset sheet and `Table 1` | Per-game mapping rules undocumented |
| `ItemExternalLinksBulbapedia.numbers` | `ItemExternalLinksBulbapedia.tsv` | Worksheet name not recorded | Deduplication and renamed-item override rules undocumented |
| `ItemExternalLinksPokemonDB.numbers` | `ItemExternalLinksPokemonDB.tsv` | Worksheet name not recorded | Deduplication and renamed-item override rules undocumented |
| `LocationExternalLinks.numbers` | `LocationExternalLinks.tsv` | Worksheet name not recorded | Region/name reconciliation rules undocumented |
| `LocationMaps.numbers` | `LocationMaps.tsv` | Worksheet name not recorded | Area joins and filename overrides undocumented |
| `ManualItems.numbers` | No loader-consumed export identified | Unknown | Relationship to crawler item JSON is undocumented |
| `MoveExternalLinks.numbers` | `MoveExternalLinks.tsv` | Worksheet name not recorded | Deduplication and rename rules undocumented |
| `MoveFormNameMappings.numbers` | `MoveFormNameMappings.tsv` | Worksheet name not recorded | Form-filter and manual mapping rules undocumented |
| `Natures.numbers` | `Natures.tsv`; not read by current loader | Worksheet name not recorded | Current production use is undocumented |
| `PokedexNumbers.numbers` | `PokedexNumbers/*-Table 1.tsv` | Export filenames identify region sheet and `Table 1` | Regional joins, exclusions, and overrides undocumented |
| `Pokemon.numbers` | `Pokemon.tsv` | Worksheet name not recorded | Sources, joins, deduplication, and manual corrections undocumented |
| `PokemonForms.numbers` | `PokemonForms.tsv` | Worksheet name not recorded | Sources, form joins, ability overrides, base stats, and entries undocumented |
| `TMs.numbers` | `TMs/*-Table 1.tsv` | Export filenames identify dataset sheet and `Table 1` | Per-game mapping and correction rules undocumented |
| `TRs.numbers` | `TRs.tsv` | Worksheet name not recorded | Source and override rules undocumented |
| `Temp.numbers` | No loader-consumed export identified | Unknown | Temporary authoring role undocumented |
| `WildDenPokemon.numbers` | No loader-consumed tabular export identified | Unknown | Relationship to `PokemonWildDen.json` undocumented |

## 4. Loader-input groups

The versioned manifest contains the exact 69 loader-consumed files and their
headers, hashes, row-identity policies, ordering semantics, and manual ownership. The
groups are:

1. Eleven reviewed legacy JSON inputs under `Crawlers/Data`.
2. Two manually maintained JSON inputs under `Research`.
3. Reviewed tab-delimited exports for abilities, berries, evolutions, item
   links, location links/maps, move links/forms, Pokémon, and Pokémon forms.
4. Reviewed per-dataset exports from `HMs.numbers`, `TMs.numbers`,
   `PokedexNumbers.numbers`, plus `TRs.tsv`.

The loader contains no implicit filesystem scan: every path is explicit in
loader code and must also be present in the manifest. Inputs not in the
manifest are blockers rather than candidates for implicit discovery.

## 5. Named transformation blockers

Each blocker records the evidence needed to replace “undocumented” with a
reviewable production rule.

| Blocker | Source crawler output | Numbers document/sheet | Affected reviewed export | Missing rule or decision | Evidence needed from maintainer |
| --- | --- | --- | --- | --- | --- |
| `manual-abilities-json` | `Data/Abilities.json` | Unknown | `Crawlers/Data/Abilities.json` | Reconciliation, corrections, approval, and whether Numbers is involved | Workbook/sheet or confirmation of a non-Numbers review, mappings, overrides, and a reviewed example |
| `manual-items-json` | `Data/BulbapediaItems.json`, `Data/PokemonDBItems.json` | `ManualItems.numbers` may be related; sheet unknown | Both loader JSON item files | Source join, deduplication, renamed-item overrides, and approval | Confirmed workbook/sheet, formulas or written rules, exception list, and reviewed export evidence |
| `manual-learnsets-json` | Breeding, level, machine, and tutor JSON outputs | Unknown | Four loader JSON learnset files | Cross-generation merge, form matching, exclusions, and manual corrections | Confirmed manual destination, joins, exception list, and one reviewed export diff |
| `manual-moves-json` | `Data/Moves.json`, `Data/MoveDescriptions.json` | Unknown | Both loader JSON move files | Description precedence, corrections, renamed moves, and approval | Confirmed manual process, mapping/override rules, and reviewed output evidence |
| `manual-locations-json` | `Data/PokemonLocations.json` | Unknown | `Crawlers/Data/PokemonLocations.json` | Region normalization, location matching, exclusions, and manual additions | Confirmed workbook/sheet or non-Numbers process plus mapping and exception rules |
| `manual-wild-dens-json` | `Data/PokemonWildDen.json` | `WildDenPokemon.numbers` exists; sheet unknown | `Crawlers/Data/PokemonWildDen.json` | Whether and how the workbook transforms crawler output | Confirmed linkage, sheet names, formulas/joins, overrides, and export procedure |
| `numbers-core-pokemon` | Candidate sources include `PokemonInfo.tsv`, `PokemonTypes.tsv`, Pokémon entries, and base-stat exports, but linkage is unconfirmed | `Pokemon.numbers`, `PokemonForms.numbers`; sheets unknown | `Pokemon.tsv`, `PokemonForms.tsv` | Source selection, joins, deduplication, forms, entries, abilities, base-stat corrections, and manual values | Confirmed source list, sheet/table names, formulas or written mapping, correction files, sort keys, and export settings |
| `numbers-domain-exports` | Source crawler outputs are not documented | All other manifest-linked Numbers documents; sheets listed above where filenames provide evidence | Ability/item/location/move links, berries, evolutions, maps, machines, and regional numbers | Column mappings, joins, filters, duplicate policy, overrides, manually entered values, and sort order | For each workbook: source list, sheet/table names, formulas or written rules, exception list, export delimiter/encoding settings, and reviewer sign-off |

Observed output alone is not enough to close a blocker. The evidence must explain
how a maintainer can reproduce the reviewed export from the stated sources.

## 6. Future-automation backlog

Automation may be proposed in a later phase only after the corresponding
manual rule is documented and reviewed. Candidate work is:

1. Encode workbook column mappings and joins as versioned transformations.
2. Move correction and override lists from undocumented cells into reviewed
   text fixtures.
3. Document unique keys only where the loader, domain model, or reviewed
   workbook rules establish uniqueness; otherwise retain multiset or positional
   identity and its ordering contract.
4. Encode deterministic workbook-equivalent sorting and filtering.
5. Generate review diffs that compare a new normalized export with the prior
   pinned export before any manifest hash changes.

Until then, Numbers remains required and authoritative for the manual portion
of production-data preparation.
