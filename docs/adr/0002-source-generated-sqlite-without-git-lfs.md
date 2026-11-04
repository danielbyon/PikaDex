# Source-generated SQLite without Git LFS

Status: Accepted, 2026-11-03.

This decision supersedes ADR-0001's image-to-LFS and history-rewrite decisions.
Its source-generated database, explicit generation, validation, CI, and
recovery decisions remain in effect.

## Decision

1. The compiled Core Data model and reviewed, checked-in source inputs define
   the catalog. `DatabaseLoader` generates `Pokedex.sqlite` from the current
   checkout.
2. `Scripts/pokedex-data-pipeline generate` is the canonical developer and CI
   entry point. It prepares pinned tools as needed, checks the reviewed inputs,
   generates a candidate, validates it, and installs it safely.
3. Image files remain ordinary Git content. Developer setup and CI do not
   require Git LFS.
4. No Git history or refs are rewritten under this decision. Existing
   historical image and SQLite objects remain in their original commits and
   tags. Historical cleanup requires a separate decision and authorization.
5. Generated databases and their `-wal`, `-shm`, and `-journal` sidecars are
   ignored. A missing database produces setup guidance. Normal Xcode builds do
   not generate or download it.
6. Generation uses only reviewed local inputs. It does not run crawlers or
   fetch a precompiled database. Semantic comparison is optional and requires
   an explicitly supplied baseline.

## Context

### Why the database is generated from source

The database is derived from the current data inputs and compiled model. A
checked-in or hosted precompiled copy can lag behind either one, require a
separate update and distribution path, or fail when a checkout cannot fetch the
artifact. The generator makes the relationship between reviewed inputs, model,
and runtime catalog explicit. The model and inputs remain reviewable in Git;
the generated SQLite file is a local build resource.

The generator does not acquire data. Optional crawlers are separate network
tools. Their output must be reviewed and incorporated into pinned source inputs
before generation. Manifest checksums identify reviewed inputs; acquisition
does not update them automatically.

### Explicit setup and safe installation

Generating during every Xcode build was rejected because it would add work to
incremental builds and hide a substantial preparation step. Developers run
`Scripts/pokedex-data-pipeline generate` when they need the catalog. Xcode
reports how to create a missing resource and never downloads or generates it
implicitly.

The pipeline writes a standalone SQLite candidate, checkpoints and closes it,
sets DELETE journal mode, and validates the result before installation. It
keeps an existing database and its sidecars together until replacement is
verified. On installation failure, the installer restores the previous store
when possible and retains both directories for recovery. `verify` validates a
candidate without installing it. The release-verification command invokes
`generate`, so run it in a disposable checkout when preserving a local database.

### Why Git LFS was declined

The prior LFS rehearsal measured 20,507 unique objects and 2,465,356,417 bytes
(2.2960 GiB) for the current-main artwork set. The historical publication
candidate measured 23,619 objects and 2,868,684,214 bytes (2.6717 GiB). A cold
CI checkout of current `main` would transfer about 2.296 GiB. The preflight
report recorded a $0 spending limit and cited GitHub Free's published 10 GiB
monthly storage and download allowance. Repeated CI hydration would use a
substantial part of that bandwidth, so the owner declined LFS even though the
measured historical payload was below the published storage allowance.

Those figures describe a local migration rehearsal; no LFS objects were
published. GitHub's allowance and the account's actual usage can change. The
account dashboard and budget must be checked again before any future LFS
proposal. See [Git LFS billing](https://docs.github.com/en/billing/concepts/product-billing/git-lfs)
for the published plan allowances and billing behavior.

### History and publication risk

The original history remains intact. The 2026-11-03 local audit covered all
objects reachable from the checkout's local refs and found no blob above
GitHub's 50 MiB warning threshold. This found no per-file blocker under
GitHub's 100 MiB regular-Git object limit, but it does not verify remote refs or
the size of a future push. The local repository held 2.94 GiB of packed Git
objects. GitHub recommends repositories stay below 1 GiB, strongly recommends
less than 5 GiB, and documents a 10 GB on-disk limit and a 2 GB push limit.
These are separate repository-health and transfer risks even when no individual
blob exceeds the hard file limit. See [large-file guidance](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github)
and [repository limits](https://docs.github.com/en/repositories/creating-and-managing-repositories/repository-limits).

The blob audit is local and time-bound. Future publication work must inspect the
current refs, measure the exact objects and pack needed for the proposed push,
and assess the remote repository state. This ADR does not authorize publication,
history rewriting, or deletion of historical assets.

## Reconsideration

Revisit Git LFS only if measured cold and recurring downloads fit the account's
then-current allowance and a separately approved budget, and if the owner
accepts the effect of public clones and CI downloads. Revisit historical cleanup
if repository size or push limits become a demonstrated operational blocker.
Either change requires a new decision, measured scope, independent recovery
evidence, and explicit authorization. Preserve historical tag names and release
meanings if a later history migration is approved.
