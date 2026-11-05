# Crawler extraction acceptance evidence

## Repository and source identities

The PikaDex extraction branch is `codex/extract-crawlers-package` at
`4cc37f0ee5b3650adfcb4f21b36d22ed4c833e99`. It contains the extraction commit
`41f884288ab2a613971446af2b3bfe5b13fa7601`, whose parent is the unchanged
SQLite-only commit `be6924d7d3961c7893cd5df1a93d8efb1082a9cf`. The original
`main` tip remains `4eff17868cb6aa2cb6139cfa99605e4de27dbc8b`.

The extraction commit removes the 17,200 inventoried crawler paths and changes
17 supporting paths for the package reference, database pipeline, CI, tests,
and documentation. It contains no cached paths. The later `4cc37f0` commit is
a separate clarification about using a local crawler checkout. The PikaDex
source pin remains `0e5672b16e66c78140a699ef32812cdc2f0d4a15`.

The destination branch is `codex/pikadex-crawlers-migration` at
`0e5672b16e66c78140a699ef32812cdc2f0d4a15`. Its parent is
`01dffa862dd5ff0c877ce182760f8f80894de0c8`.

The imported-source inventory SHA-256 is
`40e5c1a6761dad2ccd8ed4a550760139192d672819cc2e89de734126f3cdae35`. It
covers 17,200 files and 2,614,633,092 bytes. Final byte and mode comparison
against the inventory found 0 missing files, 0 content mismatches, and 0 mode
mismatches. The inventory has 9,424 distinct content hashes and
1,220,898,202 bytes of distinct content. `README.md` is authored documentation,
outside the imported source inventory.

The complete 40-file whitespace exception and per-file findings are recorded
in `MIGRATION.md` at PikaDexCrawlers documentation commit
`a892b813afe81ae302ed469ff8be8a47594dfdf4`
(branch `codex/pikadex-crawlers-migration`). `git show --check`
on migration commit `0e5672b` exits 2 with 32,415 inherited findings. That
commit retains the documented check failure. No imported bytes were changed
to clear the findings, and no broad whitespace suppression was introduced.
New authored documentation was checked separately.

The exception is limited to these imported paths:

| Imported path | Findings |
| --- | ---: |
| `AbilitiesCrawler2.py` | 19 |
| `AbilityExternalLinksCrawler.py` | 7 |
| `CrawlerUtils.py` | 18 |
| `Data/PokedexEntries-Vertical.tsv` | 14,080 |
| `Data/PokedexEntries.tsv` | 899 |
| `Data/PokedexEntries2-Vertical.tsv` | 959 |
| `Data/PokemonInfo.tsv` | 1,009 |
| `Data/PokemonTypes.tsv` | 1,026 |
| `ExternalLinksCrawler.py` | 1 |
| `ItemSpriteCrawler.py` | 8 |
| `ItemsBagSpritesCrawler.py` | 2 |
| `ItemsCrawlerBulbapedia.py` | 41 |
| `ItemsCrawlerPokemonDB.py` | 17 |
| `ItemsDreamWorldImagesCrawler.py` | 2 |
| `LearnsetBreedingCrawler.py` | 13 |
| `LearnsetBreedingCrawler2.py` | 34 |
| `LearnsetLevelCrawler3.py` | 20 |
| `LearnsetMachinesCrawler3.py` | 22 |
| `LearnsetTutoringCrawler3.py` | 23 |
| `MoveDescriptionCrawler.py` | 10 |
| `MoveExternalLinksCrawler.py` | 7 |
| `MovesCrawler.py` | 20 |
| `MovesCrawler2.py` | 27 |
| `Playground.py` | 6 |
| `PokedexEntries.backup.json` | 11,225 |
| `PokedexEntries.json` | 152 |
| `PokedexEntriesCrawler.py` | 16 |
| `PokedexEntriesCrawler2.py` | 25 |
| `PokemonAbilities.json` | 2,630 |
| `PokemonAbilitiesCrawler.py` | 4 |
| `PokemonDB.py` | 1 |
| `PokemonDreamWorldImagesCrawler.py` | 2 |
| `PokemonImageCrawler.py` | 3 |
| `PokemonInfoCrawler.py` | 11 |
| `PokemonKenSugimoriImagesCrawler.py` | 2 |
| `PokemonLocationCrawler.py` | 27 |
| `PokemonSpritesCrawler.py` | 5 |
| `PokemonSpritesCrawler2.py` | 7 |
| `PokemonTypeCrawler.py` | 13 |
| `PokemonWildDenCrawler.py` | 22 |

## Release verification

The full `Scripts/pokedex-release-verification` wrapper ran in the disposable
PikaDex worktree. It received the explicit crawler root at
`0e5672b16e66c78140a699ef32812cdc2f0d4a15` and used an isolated release build
root. Xcode was 27.2 (build 27B52); the simulator destination was iPhone 17
with iOS 27.0.

| Gate | Result |
| --- | ---: |
| Preflight, generation, validation, and installation | Passed |
| Pokedex app build | Passed |
| Modules | 61/61 passed |
| PokedexTests | 6/6 passed |
| PokedexConcurrencyTests | 16/16 passed |
| DatabasePipelineTests, network-isolated direct `xcrun xctest` | 37/37 passed |
| Total native tests | 120/120 passed |

The pipeline report marked preflight, normalization, generation, validation,
and installation as passed. It verified the reviewed source checksums and
model checksums, generated an isolated candidate, validated SQLite integrity
and Core Data compatibility, checked dataset coverage and relationships, and
installed a closed, self-contained database. The previous resource set was
retained by the installer in the disposable worktree. Preflight validated 11
crawler source inputs and all 58 Research inputs against their reviewed
checksums.

The generated candidate at
`build/crawler-extraction-final-acceptance-20261104/PipelineOutput/candidate/Pokedex.sqlite`
is 405,868,544 bytes with SHA-256
`2a898b8d836a7311799b9094c27487695a5708148e94e2cfb3464eb6cf52f474`. The
Pokedex app bundle and the Modules, PokedexTests, PokedexConcurrencyTests, and
DatabasePipelineTests framework resources have the same size and hash. Their
WAL and SHM sidecars are absent. The native test gates passed, including
resource loading through the runtime package.

The tooling-preparation host framework contains a separate pre-generation
resource copy. The release app and test bundles each use the generated
candidate listed above.

## Existing source-data findings

Preflight passed with 0 errors and 2 warnings in `Research/Berries.tsv`:

1. `legacy_blank_header`: the pinned positional layout has blank header
   columns accepted by the loader.
2. `legacy_duplicate_header`: the pinned layout has duplicate header values;
   the loader uses last-column-wins lookup.

Semantic validation passed with 246 existing `duplicate_stable_key` warnings:

1. 245 in `StoredLocationPokemon`.
2. 1 in `StoredLocationMap`.

No finding was suppressed for this acceptance run.

## Historical security scan

Gitleaks 8.30.1 scanned original PikaDex `refs/heads/main` with
`--full-history --no-renames` and excluded the approved historical
`Crawlers/Cached/**` path. Git reports 208 reachable commits, including 40
merges. Gitleaks reported 162 commits scanned, 192,123,194 bytes processed,
and no findings. The earlier extraction-branch scan reported 165 commits,
192,242,770 bytes, and no findings; that branch had 211 reachable commits,
40 merges, and three commits beyond original `main`.

These counts measure different things. Gitleaks reads a `git log -p -U0`
patch stream ([Gitleaks v8.30.1 source](https://github.com/gitleaks/gitleaks/blob/v8.30.1/sources/git.go)),
while `git rev-list` counts every reachable commit object. Merge commits
without a standalone patch and commits that yield no additions can reduce
Gitleaks' reported scan count. The scanner's output is therefore not expected
to equal the raw graph count. The `--full-history` scan completed with zero
findings under the approved cache exclusion.

The PikaDexCrawlers historical scan covered the migration repository with its
approved `Cached/**` exclusion and reported no findings. Newly authored
documentation is checked separately from the imported history.

## Protected primary state

The primary checkout database remained unchanged after release verification:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `Pokedex.sqlite` | 405,344,256 | `ea88293e22e15a25cfe67be05abd9e0a4e13e1d30b142882951e28608a6e4a5e` |
| `Pokedex.sqlite-wal` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `Pokedex.sqlite-shm` | 32,768 | `fd4c9fda9cd3f9ae7c962b0ddf37232294d55580e1aa165aa06129b8549389eb` |

The release workflow generated and installed only in the disposable worktree.
No remote refs or external repository settings were changed.
