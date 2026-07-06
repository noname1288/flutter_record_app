---
name: gitnexus-guide
description: "GitNexus code intelligence guide for Cursor. Use when asking about GitNexus tools, how to query the knowledge graph, available MCP resources, graph schema, or workflow reference. Examples: 'What GitNexus tools are available?', 'How do I use GitNexus?', 'Show me available resources'"
---

# GitNexus Guide

GitNexus là MCP server cung cấp code intelligence cho codebase — symbol relationships, execution flows, blast radius analysis, và rename/refactor automation.

## MCP Tools

| Tool | What it gives you |
|------|-------------------|
| `gitnexus_query` | Process-grouped code intelligence — execution flows related to a concept |
| `gitnexus_context` | 360-degree symbol view — callers, callees, processes it participates in |
| `gitnexus_impact` | Symbol blast radius — what breaks at depth 1/2/3 with confidence scores |
| `gitnexus_detect_changes` | Git-diff impact analysis — what do your current changes affect |
| `gitnexus_rename` | Multi-file coordinated rename with confidence-tagged edits |
| `gitnexus_cypher` | Raw graph queries (read `gitnexus://repo/{name}/schema` first) |
| `gitnexus_list_repos` | Discover indexed repos |

## MCP Resources

| Resource | Content |
|----------|---------|
| `gitnexus://repo/{name}/context` | Stats + staleness check |
| `gitnexus://repo/{name}/clusters` | All functional areas with cohesion scores |
| `gitnexus://repo/{name}/cluster/{name}` | Area members |
| `gitnexus://repo/{name}/processes` | All execution flows |
| `gitnexus://repo/{name}/process/{name}` | Step-by-step execution trace |
| `gitnexus://repo/{name}/schema` | Graph schema for Cypher queries |

## Graph Schema

**Nodes:** File, Function, Class, Interface, Method, Community, Process
**Edges (CodeRelation.type):** CALLS, IMPORTS, EXTENDS, IMPLEMENTS, DEFINES, MEMBER_OF, STEP_IN_PROCESS

## Workflow Quick Reference

```
1. READ gitnexus://repo/{name}/context  → Check freshness
2. MATCH task to skill (below) → Read that skill
3. FOLLOW skill workflow + checklist
```

## Skills by Task

| Task | Skill |
|------|-------|
| Understand architecture / "How does X work?" | gitnexus-exploring |
| Blast radius / "What breaks if I change X?" | gitnexus-impact-analysis |
| Trace bugs / "Why is X failing?" | gitnexus-debugging |
| Rename / extract / split / refactor | gitnexus-refactoring |
| Index, status, clean, wiki CLI commands | gitnexus-cli |

## Staleness

If `gitnexus://repo/{name}/context` reports index is stale → run `node .gitnexus/run.cjs analyze` in terminal first, then restart Cursor so MCP reloads.

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `LadybugDB unavailable` + version mismatch (41 vs 40) | CLI rebuilt index with newer GitNexus; MCP still on old LadybugDB | Restart Cursor after `npm i -g gitnexus@latest`; see `gitnexus-cli` skill |
| `Another process may be rebuilding` | `analyze` in progress or stale lock | Wait for analyze to finish; avoid parallel graph queries |
| `Found N symbols matching 'X'` (ambiguous) | Short/generic target name | Pass `target_uid`, `file_path`, or `kind` to `impact` |
| Wrong repo / stale data | Duplicate `aimtg_mobile` paths in registry | Use full path: `repo: "/Volumes/ESD310C/FlutterProject/aimtg_mobile"` |

When `impact` fails with LadybugDB error, fall back to `context({name, repo})` for callers/callees.
