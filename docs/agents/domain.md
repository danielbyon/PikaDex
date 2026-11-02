# Domain docs

Engineering skills use these rules when reading domain documentation in this repo.

## Before exploring

Read `GLOSSARY.md` at the repo root, if it exists. Read relevant ADRs in `docs/adr/`. If a file or directory isn't present, continue without flagging its absence; create domain docs when a term or decision is resolved.

## File layout

This is a single-context repo. Keep the glossary at the root and architecture decision records in `docs/adr/`:

```
/
├── GLOSSARY.md
├── docs/adr/
│   └── 0001-example-decision.md
└── src/
```

## Use glossary terms

Use the terms defined in `GLOSSARY.md` when naming domain concepts in issues, proposals, and tests. If a needed term is missing, check whether the project uses another term or whether the glossary has a real gap.

## Check ADRs

If a proposed change conflicts with an existing ADR, name the ADR and explain the conflict instead of silently overriding the decision.
