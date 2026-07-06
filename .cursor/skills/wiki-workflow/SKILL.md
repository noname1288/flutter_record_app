---
name: wiki-workflow
description: Use when creating or maintaining project working memory, indexes, ingest logs, and operational knowledge in this repository.
license: MIT
---

# Wiki Workflow

Use this skill for project-memory tasks.

## Scope

- Maintain `wiki/` as the operational working wiki.
- Keep `docs/` as documentation-only.
- Prevent overlap between the two.

## Folder contract

- `wiki/PROJECT_INDEX.md`: high-level project index
- `wiki/index.md`: link hub for wiki pages
- `wiki/log.md`: chronological operations log
- `wiki/entities/`: stable entities
- `wiki/concepts/`: reusable concepts/decisions
- `wiki/sources/`: source-ingest notes
- `wiki/graph/`: graph-related notes/config

## Execution defaults

1. For “index this project” requests, update `wiki/PROJECT_INDEX.md`.
2. For “remember this decision” requests, write under `wiki/concepts/`.
3. For source ingest requests, write under `wiki/sources/` and update `wiki/log.md`.
4. Keep docs deliverables in `docs/` and link to wiki only when needed.

## Graph default

Use Graphify first. Consider GitNexus only when repository-history graph analysis is required.
