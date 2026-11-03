# Adding a released game through the hybrid data workflow

## 1. Preconditions

1. Create a clean branch and record the SHA-256 values of the committed SQLite
   files, Core Data model contents, and current reviewed-input manifest.
2. Run the current offline `verify`. If it fails, preserve its deterministic
   reports and record the blocker before preparing new data. Do not fetch,
   synthesize, or infer a repair.
3. Confirm that the Core Data model does not need to change. Schema or migration
   work requires a separate design review.
4. Obtain approval for the protected `Game` metadata change required by a real
   released game. The pipeline reads the authoritative compiled catalog; it
   does not maintain a parallel dataset list.

## 2. Crawler preparation — optional network stage

1. Inventory each required upstream source and identify the specific crawler,
   durable staging output, allowed hosts, rate limits, dependency versions, and
   redistribution constraints.
2. Review each crawler independently. Add or update one curated acquisition
   manifest entry, keep `verified: false` with a concrete blocker until review
   is complete, and set it to `true` only with recorded evidence.
3. Run only the explicitly selected crawler:

   ```sh
   Scripts/pokedex-data-pipeline acquire \
     --crawler <identifier> \
     --network \
     --output-dir /absolute/path/acquisition-review
   ```

4. Review `acquisition.json`, `acquisition.txt`, and the staged output. Never
   copy it directly into `Crawlers/Data` or `Research`, never run a second
   crawler implicitly, and never update a manifest hash during acquisition.

## 3. Manual Numbers work — required manual stage

1. Open the documented Numbers document and exact worksheet/table for the data
   domain. If either is unknown, stop and add a named blocker to
   `MANUAL_WORKFLOW.md`.
2. Import or reference the reviewed staged source files using the documented
   encoding, headers, and source version.
3. Perform only the documented column mappings, joins, deduplication,
   corrections, overrides, normalization, filtering, and sorting. Apply
   manually entered values from a reviewed exception list.
4. Record every changed formula, mapping, correction, override, manual value,
   and sort/filter decision. If a rule exists only in an unexplained workbook
   cell, it is not reproducible evidence and must remain a blocker.
5. Save the Numbers document without replacing or deleting the existing manual
   workflow. This phase does not automate the workbook.

## 4. Reviewed export — required manual stage

1. Export the documented worksheet/table as UTF-8 delimited data. The current
   repository convention is tab-delimited `.tsv`; preserve exact header names,
   delimiter, encoding, and row-identity policy declared by the manifest.
2. Review the export independently for malformed rows, missing loader-required
   fields, identity violations under unique-key policies, positional-layout
   drift, unintended ordering changes, and formula-to-value conversion errors.
   Repeated rows in multiset inputs and loader-compatible headers are not
   automatically errors.
3. Compare the export with the previous pinned input and prepare a review
   artifact explaining changes using the declared unique, multiset, or
   positional identity policy.
4. Replace a reviewed input only after approval. Do not normalize in place and
   do not use crawler output as the replacement.
5. Update the manifest entry's SHA-256 manually in the reviewed change. Confirm
   its required fields, row-identity policy, ordering semantics, upstream sources,
   Numbers document/worksheet, responsible manual step, and transformation
   blocker are still accurate. No tool updates hashes automatically.

## 5. Loader integration — automated boundary begins

1. Run `prepare-tools`, then run canonical offline `verify` with an isolated
   output directory.
2. Preflight must have no errors before normalization. Missing files, checksum
   drift, invalid UTF-8, malformed fixed-width rows, missing loader-required
   fields, positional-layout drift, or duplicate established unique identities
   are data-review failures. Baseline-compatible structural warnings remain
   visible without blocking execution.
3. Add only focused loader mappings required for the new game. Preserve the
   explicit repository root, normalized input root, and isolated output
   database arguments.
4. Reuse compiled `Game` metadata for generation, mechanics, and stable database
   identity. Make all file, dictionary, dataset, entity, and relationship
   traversal order explicit.
5. Extend existing National aggregation so reviewed released-game rows
   contribute according to documented precedence. Do not synthesize National
   at query time.

## 6. Validation and semantic comparison

1. Require the candidate to use the authoritative compiled model and to contain
   `Game.national` plus every released-game dataset.
2. Require valid metadata mappings, required relationships, stable domain keys,
   exact row counts, canonical snapshot schema compatibility, no new validation
   errors, and no severity increases relative to the committed baseline.
3. Review `validation.json`, `validation.txt`, `comparison.json`, and the
   candidate store. Repeat the run with the same pinned inputs and confirm the
   reports are identical and contain no timestamps or machine paths.
4. Explain every semantic change by entity and stable key. SQLite byte
   differences are not semantic evidence, and passing semantic comparison is
   not a claim of byte-for-byte SQLite reproducibility.
5. Run `DatabasePipelineTests`, the production `Pokedex` build, and the full
   `Modules` scheme on the required destinations. Recheck protected-path diffs
   and the original committed hashes.

## 7. Required review artifacts

1. Crawler review and acquisition reports for each optional network source.
2. Manual-workflow record naming source files, Numbers document, worksheet,
   mappings, joins, filters, sorting, overrides, and manual values.
3. Reviewed-export diff using the manifest's declared row-identity policy.
4. Manifest diff with a human-approved checksum change; never an automatic hash
   rewrite.
5. Deterministic validation and semantic comparison reports.
6. Production build, Modules tests, focused offline tests, protected-path diff,
   and before/after resource hashes.

## 8. Promotion and rollback

1. Promotion is a deliberate review change outside `verify`. Only after every
   gate passes may an authorized, narrowly scoped artifact change replace the
   committed SQLite files and update committed-artifact hashes.
2. If any gate fails, retain reports outside source resources, discard the
   staged acquisition, normalized inputs, and candidate, and leave reviewed
   inputs and committed resources untouched.
3. Roll back the Numbers document, reviewed exports, manifest, focused loader
   mappings, metadata, and promoted database as one reviewed unit. Rerun the
   previous manifest's offline verification.

## 9. Future-automation backlog

1. Encode only transformations whose workbook rules and exception lists have
   first been documented and approved.
2. Replace manual joins and overrides with versioned fixtures and deterministic
   transformations one domain at a time.
3. Keep a human-reviewed export-diff gate even after transformation code exists.
4. Do not remove Numbers from the production workflow until an explicitly
   authorized later phase proves feature and data parity.
