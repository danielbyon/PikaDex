# ADR-0003: Keep crawler sources in PikaDexCrawlers

Status: Accepted

## Context

Crawler scripts, artwork, and reviewed crawler exports are large enough to
keep outside the PikaDex application repository. Database generation still
needs the reviewed exports, and acquisition still needs the crawler scripts.
The SQLite database remains generated from reviewed inputs and is not a source
artifact.

## Decision

Move the current `Crawlers/` tree into the public `danielbyon/PikaDexCrawlers`
repository. Preserve the existing manifest paths and hashes. The pipeline
maps logical `Crawlers/...` paths to the external checkout and keeps those
logical paths in its normalized loader inputs. `Research/...` inputs remain in
PikaDex.

PikaDex records the exact external commit in
`Scripts/DataPipeline/crawler-source.json`. CI fetches that public commit
anonymously with a blobless partial clone and checks out only `Data/`. Updating
the pin requires reviewing the source commit. Any changed loader input also
requires review and a matching manifest checksum update.

Acquisition uses scripts from the external checkout but continues to stage
their results for manual review. It never promotes crawler output to a loader
input. Local `Cached/` website data remains ignored and is excluded from
current and historical security scans.

## Consequences

Developers need a `PikaDexCrawlers` checkout beside PikaDex or must set
`PIKADEX_CRAWLERS_ROOT` or pass `--crawlers-root`. Missing or incomplete source
checkouts fail before generation with setup instructions. Xcode builds continue
to consume the generated database from `PokedexCore` and do not fetch or
regenerate it during ordinary incremental builds.
