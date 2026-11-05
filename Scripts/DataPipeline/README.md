# Hybrid production-data pipeline

## 1. Trust boundary

PikaDex production data follows a hybrid workflow:

1. Python crawlers produce raw or partially structured staging material.
2. A maintainer reconciles, edits, joins, overrides, filters, sorts, and adds
   values manually in Apple Numbers documents.
3. A maintainer reviews and exports loader inputs. The repository stores these
   tables as UTF-8, tab-delimited `.tsv` files, although the workflow has
   sometimes been described as a CSV-export boundary.
4. Local tools verify the reviewed exports, create normalized copies, generate
   an isolated database candidate, and validate it. Semantic comparison with
   historical data requires an explicit baseline.
5. The canonical `generate` command installs the validated database at the
   local resource path. SQLite output stays local; the reviewed inputs and
   compiled model are the reproducible generation inputs.

Maintainers review crawler output in Numbers, apply the required manual
transformations, and export loader inputs. The automated pipeline starts from
those reviewed exports and does not perform that manual work. See
`MANUAL_WORKFLOW.md` for the crawler and workbook evidence, including gaps
that require maintainer input.

The existing loader still reads eleven legacy JSON files under
`Crawlers/Data`. The repository pins them as loader inputs, but does not
record whether manual reconciliation approved them. Their crawler-to-input
provenance remains an open blocker. The tools cannot regenerate these files or
update their hashes automatically.

## 2. Canonical developer and CI command

### First-time checkout

Artwork is checked out as ordinary Git content. No Git LFS installation or
separate artwork hydration is required. To create the local catalog, run the
`generate` command below; it reads reviewed inputs from the checkout and does
not fetch artwork or a precompiled database.

### Generate

`generate` is the canonical developer and CI entry point. It builds or refreshes
the tooling products, verifies reviewed inputs, creates normalized copies,
generates and validates a SQLite candidate, and safely installs it at
`Modules/PokedexCore/Resources/Database/Pokedex.sqlite`:

```sh
Scripts/pokedex-data-pipeline generate \
  --output-dir /absolute/path/outside-committed-resources
```

When `--output-dir` is omitted, artifacts go to
`build/data-pipeline-artifacts`. `Scripts/DataPipeline/Package.resolved` pins
the Swift packages used by Xcode. On a fresh checkout, `generate` seeds
Xcode's ignored workspace lock from this file. If an existing workspace lock
still uses GitHub SSH URLs, the pipeline replaces it with the canonical lock
only when package identities, every pinned state, and the lock metadata match.
Any other graph or lock difference stops for review. Tool preparation resolves
the pinned package versions before building. Xcode may fetch package sources
that are not cached; database generation uses only the reviewed repository
inputs. Developers can run `prepare-tools` to build the tools explicitly.

`verify` runs source preflight, generation, and validation without installing
the candidate. It does not require or inspect an existing bundled database:

```sh
Scripts/pokedex-data-pipeline verify \
  --output-dir /absolute/path/outside-committed-resources
```

`verify` requires the tools to be built already. Neither command invokes
crawlers, opens Numbers, updates manifest hashes, or repairs missing inputs.
The pipeline, loader, and validator processes run with network access denied.

Semantic comparison is optional and requires an explicit baseline:

```sh
Scripts/pokedex-data-pipeline compare \
  --candidate /path/to/Pokedex.sqlite \
  --baseline /path/to/reviewed-baseline.sqlite
```

Xcode checks that the generated resource exists, then copies `Pokedex.sqlite`
into `PokedexCore`. Ordinary builds do not generate or download the database.
CI checks out source as regular Git content and runs `generate` before building
the app.

Exit codes are `0` for success, `2` for usage, prerequisite, manifest, path,
checksum, reviewed-input preflight, or acquisition-policy failures, `3` for
generation or installation failures, `4` for validation failures, and `5`
for semantic drift when an explicit baseline is supplied.

## 3. Automated phases

1. `preflight` loads manifest schema version 4. It checks each input read by
   the loader for its repository-relative path, SHA-256, UTF-8 encoding,
   delimiter, required fields, row-identity policy, ordering contract,
   provenance, upstream evidence, and responsible manual step. Only the
   `uniqueKey` and `compositeUniqueKey` policies reject duplicate identities.
   Multiset inputs preserve repeated values, while positional tables require
   exact column positions and row widths. Loader-compatible blank or repeated
   headers produce warnings rather than schema errors.
2. `normalize` verifies the pinned checksums and creates derived copies under
   `<output>/normalized-inputs`. It canonicalizes line endings and JSON key
   ordering without changing reviewed files.
3. `DatabaseLoader` receives explicit repository-root, input-root, and output
   database arguments. It reads only normalized manifest inputs and creates
   `<output>/candidate/Pokedex.sqlite`. Candidate paths cannot resolve into
   committed resources.
4. `DatabaseValidator` opens the candidate with the authoritative compiled
   Core Data model and writes severity-sorted `validation.json` and
   `validation.txt` reports. Errors violate an established contract. Warnings
   describe accepted legacy anomalies, and informational findings document
   input traits.
5. The coordinator checks `DatabaseValidator`'s exit status before reading
   the reports. A nonzero status fails the pipeline even when report files
   exist. The validator checks SQLite integrity, Core Data model compatibility,
   dataset coverage, stable keys, and required relationships. Existing warnings
   remain in the reports.
6. `generate` installs the validated candidate at
   `Modules/PokedexCore/Resources/Database/Pokedex.sqlite`. It checkpoints and
   closes the candidate, stages it beside the resource directory, and
   exchanges the directories atomically. When an old database exists, the old
   database and its sidecars stay together in the `.Database.install-*`
   directory until the new installation is verified. An open database,
   unsafe resource directory, insufficient space, or incomplete candidate
   makes installation fail without replacing the existing store.

`compare` is a separate optional command. Given explicit candidate and
baseline paths, it builds canonical snapshot schema version 2 and compares
semantic attributes and relationships through domain keys rather than Core
Data object IDs. The comparison excludes generated ability-index lookup caches
because named relationships remain canonical. Shared baseline warnings pass;
new errors, severity increases, and semantic differences appear in the report.
Comparison is not required for generation or CI.

Preflight, validation, and semantic-comparison reports contain no runtime
timestamps, UUIDs, current directories, or machine-specific paths. The
installation summary is run-specific and records the retained backup
directory, so a maintainer can recover the previous database and sidecars.
Semantic comparison excludes SQLite page layout, WAL state, row IDs, Core Data
object IDs, and byte layout. It does not establish byte-for-byte SQLite
reproducibility.

## 4. Reviewed-input manifest

`pipeline-manifest.json` schema 4 defines the source boundary. Its sorted
`sourceInputs` array lists every file read by the current loader. The manifest
also pins the compiled Core Data model through `modelInputs`; it does not
require a checksum for a committed database. Each source entry records:

1. Repository-relative path and SHA-256.
2. UTF-8 encoding, format, delimiter, and required headers.
3. One explicit row-identity policy and its ordering or positional contract.
4. Provenance and repository evidence for the upstream source.
5. Numbers document and worksheet when the repository identifies them.
6. The responsible manual review or export step.
7. A transformation blocker when the exact manual rules are undocumented.

Manifest hashes record reviewed inputs. Acquisition and normalization do not
change them. A maintainer may update a reviewed-input hash after completing
the manual workbook and export review described in `NEW_GAME.md` and saving
the review artifacts.

Dataset identities in the generated database come from the compiled
`Game.allDatasets` and `Game.releasedGameMetadata` catalog. `Game.national`
is a required first-class dataset. The loader generates National records in
explicit aggregation passes.

## 5. Optional crawler staging

Crawler acquisition stays outside the reviewed-input boundary. It can run one
curated manifest entry at a time and requires both `--network` and an
individually reviewed entry with `verified: true`:

```sh
Scripts/pokedex-data-pipeline acquire \
  --crawler abilities \
  --network \
  --output-dir /absolute/path/acquisition-review
```

The crawler runs only in `<output>/acquisition/<crawler>/Crawlers`, with a
host allowlist. It emits deterministic `acquisition.json` and
`acquisition.txt` evidence that manual Numbers reconciliation remains
required. It does not copy staged output into `Crawlers/Data` or `Research`,
invoke the loader, update a checksum, or launch another crawler.

All curated entries currently remain `verified: false`. Shared requests use a
fixed user agent, a 30-second timeout, per-host rate limiting, bounded retries,
`Retry-After`, and an environment-supplied host allowlist. The requests accept
no credentials, cookies, API keys, or secrets. Raw pages and newly acquired
image sets require a separate redistribution review before they are committed.

## 6. Tool targets and legacy scheme

`DatabaseLoader`, `DatabaseValidator`, `DatabasePipeline`, and the static
`DatabasePipelineSupport` framework are tooling-only macOS targets.
`DatabasePipelineTests` is the dedicated macOS test target. Shared support
code has one source membership and is not duplicated into production targets.

`DatabaseLoader/Config.txt` remains temporarily as legacy developer
configuration. The shared `DatabaseLoader` scheme supplies explicit safe
paths and writes to `build/data-pipeline-legacy`. The canonical `generate`
command ignores the legacy file and always uses normalized manifest inputs.

## 7. Baseline characterization and follow-ups

1. Current source data produces 246 duplicate snapshot-key warnings: one for
   `StoredLocationMap` and 245 for `StoredLocationPokemon`. These warnings
   reflect repeated rows preserved by multiset inputs. The snapshot keys do
   not establish uniqueness, so the findings remain visible in validation
   reports.
2. Fourteen former `StoredPokemonForm.z_primaryAbility` findings were
   validator false positives. The compiled model and runtime API define this
   relationship as optional, so the required-relationship check no longer
   reports them.
3. Regeneration changes ability numeric indices and matching form lookup
   caches while preserving named ability relationships. Snapshot schema
   version 2 treats those generated caches as nonsemantic.
4. A previous comparison reported 78 `StoredPokemon.z_spriteName` differences
   for Pokémon 1000 through 1025. A later comparison against a preserved
   independent database copy produced matching semantic digests and no
   differences. The earlier comparison's baseline identity is unavailable, so
   that 78-row finding remains unconfirmed until it is repeated against the
   exact baseline.
5. The crawler-to-Numbers transformations and the legacy JSON review chain
   remain undocumented manual-workflow follow-ups. Missing evidence has not
   been synthesized or fetched. The pinned inputs remain the compatibility
   baseline until their provenance is documented.

## 8. Installation recovery

After a successful installation, `reports/summary.txt` records the sibling
directory that contains the previous `Pokedex.sqlite` and its sidecars. Keep
that directory until the new build is accepted. If installation reports an
error or the process stops, stop PikaDex and any build process that may have
the database open. Use `lsof` to check the database and sidecars. Inspect the
resource directory and each `.Database.install-*` directory before restoring
anything. If the process stops before the directory exchange, the previous
database remains at the resource path and the staging directory contains the
candidate. After an exchange that replaces an existing resource, the staging
directory contains the previous database and sidecars. A hard stop may happen
before the summary is written; in that case, locate the staging directory under
`Modules/PokedexCore/Resources` and inspect its contents.

Run these commands only after confirming that `ROLLBACK` contains the
previous resource directory and `Database` contains the replacement. If
`Database` still contains the previous database and the staging directory
contains the candidate, leave the resource in place and do not run these moves.
Otherwise, use the exact previous-directory path as `ROLLBACK`, choose a new
unused path for `FAILED`, and run the commands from the repository root:

```sh
RESOURCE_PARENT=Modules/PokedexCore/Resources
ROLLBACK='/exact/path/from/reports/summary.txt'
FAILED="${RESOURCE_PARENT}/.Database.failed-unique"
mv "${RESOURCE_PARENT}/Database" "${FAILED}"
mv "${ROLLBACK}" "${RESOURCE_PARENT}/Database"
```

If the second move fails, the new database remains at `FAILED` and the old
directory stays at `ROLLBACK`. Fix the problem and retry the second move. If
there is no `Database` directory because the process stopped between moves,
move the verified rollback directory directly into place. Keep the failed and
rollback directories until the restored database is confirmed.

## 9. Release verification

Run the release verification command in a disposable checkout. It runs
`generate`, which installs the generated catalog into that checkout, then
builds the app and runs the native test gates. Set its build root to a
temporary path outside the checkout:

```sh
PIKADEX_RELEASE_BUILD_ROOT="$TMPDIR/pokedex-release-verification" \
  Scripts/pokedex-release-verification
```

The `DatabasePipelineTests` gate uses `xcodebuild build-for-testing` with the
`platform=macOS,arch=arm64` destination, then runs the bundle through
`Scripts/run-xctest-bundle-with-network-denied`, which executes
`/usr/bin/xcrun xctest`. DerivedData is stored at
`$PIKADEX_RELEASE_BUILD_ROOT/DerivedData/DatabasePipelineTests`, and the test
bundle is at
`$PIKADEX_RELEASE_BUILD_ROOT/DerivedData/DatabasePipelineTests/Build/Products/Debug/DatabasePipelineTests.xctest`.

The `Modules` tests open the catalog through the `PokedexCore` bundle.
Pipeline tests use temporary SQLite fixtures and fake process runners; they do
not invoke live crawlers or require Numbers. See `NEW_GAME.md` for the full
released-game workflow.
