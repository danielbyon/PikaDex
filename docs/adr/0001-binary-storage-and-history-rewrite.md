# Store images in Git LFS and generate SQLite from checked-in source data

Current status (2026-11-03): Historical proposal, partially superseded by
[ADR-0002](0002-source-generated-sqlite-without-git-lfs.md). Source-generated
SQLite, explicit generation, validation, CI, and recovery decisions remain
active. Git LFS tracking and historical Git rewriting are deferred and are not
current policy. The proposal below is retained as a record; its publication
instructions do not authorize a rewrite or push.

Original status: Accepted. Design confirmed through Q1-Q18; execution still
required separate approval.

PikaDex includes substantial versioned artwork and a bundled SQLite catalog. To reduce normal Git history and clone transfer overhead without giving up local Xcode builds, retain image version history in Git LFS but treat SQLite as a disposable, regenerable build artifact. The inputs, model, and loader—not a checked-in or remotely hosted database—define the database for any checkout.

## Decisions

- **Images:** Store all tracked image binaries, of any size or location (app assets, crawled/processed artwork, screenshots, icons, and historical revisions), in Git LFS. Keep text metadata, including `Contents.json`, as ordinary Git blobs. Apply the image policy to all rewritten history and future commits.
- **Databases:** Ignore SQLite database files and their `-wal`, `-shm`, and journal companions; remove all such binaries from reachable historical Git commits and tags. Do not put database binaries into LFS, GitHub Releases, or another remote store.
- **Source of truth:** Build the database from the current checkout's committed JSON, TSV, and other required source inputs with `DatabaseLoader`. No separately versioned database releases or schema-linked database versions. Legitimate source edits may change the generated database within a single app version or Core Data schema.
- **Developer workflow:** Provide one explicit, documented local generation command. Ordinary incremental Xcode builds do not generate a database or access the network behind the developer's back; missing output produces actionable setup guidance.
- **Failure-safe replacement:** Generate to an isolated temporary location, validate the complete candidate, and only then atomically install it into the expected resource location. Never delete or overwrite the previous local database until the candidate has passed; preserve it on build, validation, or installation failure.
- **CI:** On every relevant run, use the same generation flow to invoke the `DatabaseLoader` target from the checked-in inputs before SQLite integrity checks, dataset validation, and Xcode builds/tests. Do not download or cache a precompiled database. Validate integrity, schema, and content invariants rather than a fixed checksum or byte-for-byte equality with an old database snapshot.
- **Input boundary:** Generation must work from the checkout without invoking scrapers/crawlers or fetching upstream content. Audit required inputs and address gaps needed for a fresh clone. Content acquisition redesign is separate work.
- **History:** Before rewriting, make an independent, recoverable backup of all original refs/history and the existing local SQLite files, outside the repository. Preserve commits, authors, messages, timestamps, paths, branch intent, and tags wherever feasible while converting image blobs into LFS pointers and removing SQLite history. Do not squash or perform unrelated cleanup.
- **Historical compatibility:** Older rewritten commits are not required to have working bootstrap/build workflows. The migrated current revision must regenerate and build from a fresh clone.
- **LFS budget:** Estimate required LFS storage and transfer before uploading; halt for explicit approval if they exceed the account's applicable allowance or the configured budget.
- **Publication:** Verify migrated Git refs/history, full LFS object availability, clean fresh checkout, source-only database regeneration, integrity/content checks, and Xcode builds/tests. Stage the first Git/LFS push and then verify a fresh clone/CI end to end, with a documented recovery procedure for partially published refs or objects. No database release step.
- **Recovery retention:** Retain independent pre-rewrite Git and local database backups until the owner explicitly authorizes deletion. Do not automatically prune or discard them.

- **Historical publication handoff (superseded by ADR-0002):** This records the former rewritten-history plan and is not an active instruction. Do not publish the rewritten candidate under the current decision. The earlier plan required the uncommitted Issue #1 implementation to be incorporated into rewritten `main` and historical tags to remain attached to the rewritten counterparts of their original release commits, without retargeting them to the new `main` tip.

## Why, and rejected alternatives

- Conventional Git blobs force image histories into ordinary clones; LFS preserves binary revisions while moving payloads out of normal Git object history. Deleting historical artwork was rejected because historical provenance remains valuable. LFS optimizes Git-object footprint and transfer, **not** disk usage of a fully hydrated image checkout.
- SQLite-in-Git or SQLite-in-LFS was rejected: the database is derived output, while committed source inputs and loader are authoritative.
- **Superseded earlier decision:** Initially a versioned precompiled SQLite snapshot distributed through GitHub Releases was proposed, including checksum-pinned download for dev/CI. This was explicitly rejected in Q12 because datasets evolve with source edits independently of application releases and schema changes. No hosted database artifact or baseline checksum remains part of the architecture.
- Implicit Xcode downloads/generation were rejected to keep incremental builds predictable and avoid surprising network and time costs. Rebuilding from source inputs in CI is preferred to shipping or caching an opaque database snapshot.
- Generating directly over the existing SQLite database was rejected because current loader behavior destroys its output first; generation or validation failure must not wipe a useful local database.
- Crawling as part of CI was rejected because upstream availability and manually curated transformations are not reproducible checkout inputs. Upstream refresh and content pipeline modernization are separate.
- Squashing Git history, unrelated restructuring, and automatic LFS publication without a cost gate were rejected to preserve auditability and control risks.

## Current implementation hazards and acceptance invariants

- `DatabaseLoader/Config.txt` embeds an absolute developer-specific path; `DatabaseLoader/Helpers.swift` resolves output from it and `Helper.loadContainer(removeExistingContainer: true)` destroys its existing store. The implementation must remove checkout-specific configuration, stage generated data safely, and maintain runtime's expected bundled `Pokedex.sqlite` path.
- Some previous pipeline run records reference tooling absent from the current checkout. Do not presume the prior tooling can be invoked; audit and implement only what the current repository needs to satisfy this policy.
- A fresh checkout must have all required versioned inputs and a repeatable offline database generation workflow. A generation failure must leave any previously valid local database undamaged.
- No SQLite binaries survive in reachable rewritten Git history; image asset paths/content and their revisions remain recoverable through LFS. CI and local generation never depend on a hosted precompiled database.
- Publish only after recovery and cost safeguards are satisfied. This ADR is a decision record, **not** authorization to rewrite history or push to GitHub.
