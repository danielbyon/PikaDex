# Adding a released game to the hybrid data workflow

## 1. Preconditions

Artwork is checked out as ordinary Git content; no Git LFS setup or separate
hydration step is required. Database generation reads the pinned local inputs
and does not fetch artwork.

1. Create a task branch and record its checkout and HEAD. Record the Core Data
   model and manifest checksums. The generated database is a local resource and
   has no committed checksum.
2. Prepare the pipeline tools, then run source-only `verify`. It does not need
   or install an existing database. If it fails, preserve the reports and
   record the blocker before preparing new data. Do not infer a repair.
3. Confirm that the Core Data model does not need to change. Schema or
   migration work requires a separate design review.
4. Get approval for the change to protected `Game` metadata required by a
   released game. The pipeline reads the authoritative compiled catalog and
   does not maintain a parallel dataset list.

## 2. Crawler preparation (optional network stage)

The crawler scripts and their support files come from the pinned
`PikaDexCrawlers` checkout. Set `PIKADEX_CRAWLERS_ROOT` or pass
`--crawlers-root` when it is not beside PikaDex. Acquisition copies only the
staged crawler files into its isolated output directory; it does not promote
their results into reviewed loader inputs.

1. Inventory each required upstream source. Identify the crawler, durable
   staging output, allowed hosts, rate limits, dependency versions, and
   redistribution constraints.
2. Review each crawler independently. Add or update one curated acquisition
   manifest entry. Keep `verified: false` and record the blocker until review
   is complete. Set it to `true` only after recording the evidence.
3. Run only the selected crawler:

   ```sh
   Scripts/pokedex-data-pipeline acquire \
     --crawler <identifier> \
     --network \
     --output-dir /absolute/path/acquisition-review
   ```

4. Review `acquisition.json`, `acquisition.txt`, and the staged output. Do
   not copy it into `Crawlers/Data` or `Research`, run another crawler
   implicitly, or update a manifest hash during acquisition.

## 3. Manual Numbers work (required manual stage)

1. Open the documented Numbers file and the exact worksheet or table that
   defines the data. If either is unknown, stop and add a named blocker to
   `MANUAL_WORKFLOW.md`.
2. Import or reference reviewed staged source files using their documented
   encoding, headers, and source version.
3. Apply only documented column mappings, joins, deduplication, corrections,
   overrides, normalization, filtering, and sorting. Apply manually entered
   values according to the reviewed exception list.
4. Record every changed formula, mapping, correction, override, manual value,
   and sort or filter decision. A rule stored only in an unexplained workbook
   cell cannot be reproduced and remains a blocker.
5. Save the Numbers document without replacing or deleting the existing manual
   workflow. This step remains manual.

## 4. Reviewed export (required manual stage)

1. Export the documented worksheet or table as UTF-8 delimited data. The
   repository uses tab-delimited `.tsv` files. Preserve the exact header
   names, delimiter, encoding, and row-identity policy declared in the
   manifest.
2. Review the export for malformed rows, missing loader-required fields,
   identity violations under unique-key policies, positional-layout drift,
   unintended ordering changes, and formula-to-value conversion errors.
   Repeated rows in multiset inputs and loader-compatible headers are not
   automatically errors.
3. Compare the export with the previous pinned input. Prepare a review artifact
   that explains changes under the declared unique, multiset, or positional
   identity policy.
4. Replace the reviewed input only after approval. Do not normalize it in
   place or replace it with crawler output.
5. Update the manifest entry's SHA-256 manually as part of the reviewed
   change. Confirm that the required fields, row-identity policy, ordering
   semantics, upstream sources, Numbers document and worksheet, responsible
   manual step, and transformation blocker remain accurate. No tool updates
   hashes automatically.

## 5. Loader integration (automated boundary)

1. Run canonical `generate` with an isolated output directory. It prepares
   missing tools, checks reviewed inputs, generates and validates a candidate,
   then safely installs `Pokedex.sqlite` into `PokedexCore`. `verify` is a
   non-installing command and requires prepared tools.
2. Preflight must report no errors before normalization. Missing files,
   checksum drift, invalid UTF-8, malformed fixed-width rows, missing
   loader-required fields, positional-layout drift, and duplicate identities
   under unique-key policies require data review. Structural warnings remain
   visible in the reports.
3. Add only focused loader mappings required for the new game. Preserve the
   explicit repository root, normalized input root, and isolated output
   database arguments.
4. Reuse compiled `Game` metadata, generation mechanics, and stable database
   identity. Make file, dictionary, dataset, entity, and relationship
   traversal order explicit.
5. Extend the existing National aggregation so reviewed released-game rows
   contribute according to the documented precedence. Generate National
   records during loading.

## 6. Validation and semantic comparison

1. Require the candidate to use the authoritative compiled model and include
   `Game.national` and every released-game dataset.
2. Require valid SQLite integrity, authoritative model compatibility, dataset
   coverage, stable domain keys, required relationships, and no validation
   errors. Keep warnings visible during review.
3. Review `preflight.json`, `validation.json`, `validation.txt`, and the
   generated candidate. Repeat generation with the same reviewed inputs and
   compare the deterministic source and validation reports. Use `compare`
   when a specific historical baseline is available and its differences help
   explain reviewed data changes.
4. Explain each semantic change by entity and stable key. SQLite byte
   differences do not establish semantic differences, and a passing semantic
   comparison does not establish byte-for-byte reproducibility.
5. Run `DatabasePipelineTests`, build the production `Pokedex` scheme, and
   run the `Modules` scheme. Confirm that the generated SQLite file is in the
   `PokedexCore` bundle and that the runtime lookup test opens it. Review the
   final task diff and confirm that protected inputs did not change.

## 7. Required review artifacts

1. Crawler review and acquisition reports for each optional network source.
2. A manual-workflow record naming the source files, Numbers document,
   worksheet, mappings, joins, filters, sorting, overrides, and manual values.
3. A reviewed-export diff that uses the manifest's declared row-identity
   policy.
4. An approved manifest diff for each checksum change. Never rewrite hashes
   automatically.
5. Deterministic preflight and validation reports, plus a comparison report
   when an explicit baseline was reviewed. Record all existing data-quality
   findings.
6. App build, Modules tests, pipeline tests, generated-resource lookup
   evidence, installation summary, and protected-input diff.

## 8. Generated resource installation and rollback

1. `generate` installs the validated database at the local `Pokedex.sqlite`
   resource path. Generated database files are not committed. After a
   successful replacement, the installer retains the previous resource
   directory, including its database and sidecars, in a sibling
   `.Database.install-<UUID>` directory. Keep the backup until the app build
   and runtime lookup have been checked. The installation summary records its
   path.
2. Preflight, generation, or validation failures leave the installed resource
   untouched. If installation fails after the directory exchange, the
   installer attempts to restore the previous directory and reports whether
   rollback succeeded. Keep the reports and candidate until the failure is
   understood. If automatic rollback also fails, stop processes that may be
   using the database and follow the recovery path printed by the installer.
   Preserve both directories until the restored database opens.
3. When replacing an existing database, a hard process interruption may
   bypass automatic rollback. If it occurs before the directory exchange, the
   previous database remains at its resource path and the staging directory
   contains the candidate. After the exchange, the sibling staging directory
   contains the previous database and sidecars. Inspect both paths and follow
   the recovery steps in `Scripts/DataPipeline/README.md`.
4. To undo a successful replacement, stop the app and any build or test process
   using the catalog. Restore the complete retained resource directory to
   `Modules/PokedexCore/Resources/Database`. Keep the newer directory and
   reports until the restored database passes integrity and runtime lookup.
   When reverting source-data or loader changes, restore the reviewed changes
   and manifest together, then regenerate.

## 9. Future automation

1. Encode a transformation only after its workbook rules and exception lists
   have been documented and approved.
2. Replace manual joins and overrides with versioned fixtures and deterministic
   transformations one domain at a time.
3. Keep the human-reviewed export-diff gate after transformation code exists.
4. Keep Numbers in the production workflow until a later phase is authorized
   and feature and data parity have been demonstrated.
