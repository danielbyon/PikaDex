# Hybrid production-data pipeline

## 1. Trust boundary

PikaDex production data is prepared by a hybrid workflow:

1. Python crawlers produce raw or partially structured staging material.
2. A maintainer reconciles, edits, joins, overrides, filters, sorts, and adds
   values manually in Apple Numbers documents.
3. The maintainer reviews and exports loader inputs. The repository currently
   stores the tabular exports as UTF-8 tab-delimited `.tsv` files even though
   this operating boundary is commonly described as the CSV-export boundary.
4. The offline tooling verifies the reviewed exports, creates normalized
   derived copies, loads an isolated candidate database, validates it, and
   compares it semantically with the committed database.
5. Promotion of a reviewed candidate is a separate manual change.

Crawler output is not equivalent to a reviewed loader input. Numbers documents
and their manual transformations are required production steps. This phase
does not infer, bypass, replace, or automate those transformations. See
`MANUAL_WORKFLOW.md` for the evidence-backed crawler and workbook inventory and
for named gaps that require maintainer input.

Eleven legacy JSON files under `Crawlers/Data` are still read by the existing
loader. They are pinned as reviewed legacy loader inputs, not as raw crawler
outputs. The repository does not document the manual reconciliation that
approved them, so their crawler-to-reviewed-input provenance remains a named
blocker. They cannot be regenerated or have their hashes updated automatically.

## 2. Canonical automated command

Prepare tooling products after cloning or changing pipeline Swift sources:

```sh
Scripts/pokedex-data-pipeline prepare-tools
```

Tool preparation is intentionally separate because Xcode may need to
materialize packages pinned by `Package.resolved`. Products are written only to
`build/data-pipeline-tooling`. Run the reviewed-input pipeline afterward:

```sh
Scripts/pokedex-data-pipeline verify \
  --output-dir /absolute/path/outside-committed-resources
```

If `--output-dir` is omitted, artifacts go to
`build/data-pipeline-artifacts`. `verify` does not build tools, resolve
packages, accept a network flag, invoke crawlers, launch Numbers, update
manifest hashes, or repair missing inputs. The command and its loader and
validator children run inside a macOS sandbox that denies all network access.

Exit codes are `0` for success, `2` for usage, prerequisite, manifest, path,
checksum, reviewed-input preflight, or acquisition-policy failures, `3` for
generation failures, `4` for validation failures, and `5` for semantic drift.

## 3. Automated phases

1. `preflight` loads manifest schema version 3 and checks every loader-consumed
   input's repository-relative path, SHA-256, UTF-8 encoding, delimiter,
   loader-required fields, explicit row-identity policy, ordering contract,
   provenance, upstream evidence, and responsible manual step. Only
   `uniqueKey` and `compositeUniqueKey` policies reject duplicate identities.
   Multisets preserve repeated values, while positional tables validate exact
   column positions and row widths. Loader-compatible blank or repeated headers
   are reported as warnings rather than invented schema errors.
2. `normalize` verifies the same pinned checksums and creates derived copies
   under `<output>/normalized-inputs`. It canonicalizes line endings and JSON
   key ordering without changing reviewed files.
3. `DatabaseLoader` receives explicit repository root, input root, and output
   database arguments. It reads only normalized manifest inputs and creates
   `<output>/candidate/Pokedex.sqlite`; candidate paths cannot resolve into
   committed resources.
4. `DatabaseValidator` opens the candidate with the authoritative compiled Core
   Data model and writes severity-sorted `validation.json` and `validation.txt`
   reports. Errors violate an established contract, warnings characterize
   accepted legacy anomalies, and informational findings document input traits.
5. `compare` builds canonical snapshot schema version 2 for the candidate and
   committed stores. Every semantic modeled attribute and non-inverse
   relationship is compared through explicit domain keys, never Core Data
   object IDs. Generated ability-index lookup caches are excluded because the
   corresponding named relationships remain canonical. Exact committed row
   counts and semantic digests are required. Shared baseline warnings pass;
   new errors and severity increases fail.
6. The candidate and reports remain staged. No command in this pipeline
   promotes them into `Modules/PokedexCore/Resources/Database`.

Reports contain no runtime timestamps, UUIDs, current directories, or
machine-specific paths. The semantic comparison deliberately excludes SQLite
page layout, WAL state, row IDs, Core Data object IDs, and byte layout, so it
does not claim byte-for-byte SQLite reproducibility.

## 4. Reviewed-input manifest

`pipeline-manifest.json` is the versioned automated-boundary contract. Its
sorted `sourceInputs` array contains every file the current loader reads. Each
entry records:

1. Repository-relative path and SHA-256.
2. UTF-8 encoding, format, delimiter, and required headers.
3. One explicit row-identity policy and its ordering or positional contract.
4. Provenance and repository evidence used upstream.
5. Numbers document and worksheet when the repository identifies them.
6. The responsible manual review/export step.
7. A transformation blocker when exact manual rules are undocumented.

Manifest hashes are review evidence. Acquisition and normalization never
change them. A maintainer may update a reviewed-input hash only after the
manual workbook/export review described in `NEW_GAME.md` is complete and its
review artifacts are available.

The committed database's dataset identities come only from the compiled
`Game.allDatasets` and `Game.releasedGameMetadata` catalog. `Game.national` is a
required first-class dataset. National records are generated by the loader's
explicit aggregation passes rather than query-time synthesis.

## 5. Optional crawler staging

Crawler acquisition is outside the automated reviewed-input boundary. It can
run only one curated manifest entry at a time and requires both `--network` and
an individually reviewed entry with `verified: true`:

```sh
Scripts/pokedex-data-pipeline acquire \
  --crawler abilities \
  --network \
  --output-dir /absolute/path/acquisition-review
```

The crawler runs only in `<output>/acquisition/<crawler>/Crawlers` with a host
allowlist. It emits deterministic `acquisition.json` and `acquisition.txt`
evidence stating that manual Numbers reconciliation is still required. It
never copies staged output into `Crawlers/Data` or `Research`, invokes the
loader, updates a checksum, or launches another crawler.

All curated entries currently remain `verified: false`. Shared requests use a
fixed user agent, a 30-second timeout, per-host rate limiting, bounded retries,
`Retry-After`, and an environment-supplied host allowlist. No credentials,
cookies, API keys, or secrets are accepted. Raw pages and newly acquired image
sets must not be committed without separate redistribution review.

## 6. Tool targets and legacy scheme

`DatabaseLoader`, `DatabaseValidator`, `DatabasePipeline`, and the static
`DatabasePipelineSupport` framework are tooling-only macOS targets.
`DatabasePipelineTests` is the dedicated macOS test target; shared support code
has one source membership and is not duplicated into production targets.

`DatabaseLoader/Config.txt` is retained temporarily as legacy developer
configuration. The shared `DatabaseLoader` scheme now supplies explicit safe
paths and writes to `build/data-pipeline-legacy`, while canonical `verify`
ignores the legacy file and always uses normalized manifest inputs.

## 7. Baseline characterization and follow-ups

1. The committed database has 246 duplicate snapshot-key warnings: one for
   `StoredLocationMap` and 245 for `StoredLocationPokemon`. These are accepted
   baseline warnings because the loader preserves repeated rows and the current
   snapshot keys do not establish uniqueness for those multisets.
2. Fourteen former `StoredPokemonForm.z_primaryAbility` errors were validator
   false positives. The compiled model and runtime API make that relationship
   optional, so the required-relationship check no longer reports them.
3. Regeneration changes ability numeric indices and the matching form lookup
   caches while preserving named ability relationships. Snapshot schema version
   2 classifies those generated caches as nonsemantic.
4. Regeneration still changes 78 `StoredPokemon.z_spriteName` values for
   Pokémon 1000 through 1025. The current three-digit formatter truncates the
   leading digit, so this remains genuine production-output drift and a
   separately actionable remediation item. It is intentionally not excluded
   from semantic comparison.
5. Exact crawler-to-Numbers transformations and the legacy JSON review chain
   remain undocumented manual-workflow follow-ups. Missing evidence is never
   synthesized or fetched by verification, but it does not invalidate the
   immutable reviewed inputs that form the current compatibility baseline.

## 8. Focused verification

```sh
rtk xcodebuild test \
  -project Pokedex.xcodeproj \
  -scheme DatabasePipelineTests \
  -destination 'platform=macOS,arch=arm64' \
  -enableCodeCoverage YES
```

Tests use temporary fixtures and fake process runners. They do not invoke live
crawlers or require Numbers. See `NEW_GAME.md` for the complete hybrid
released-game procedure.
