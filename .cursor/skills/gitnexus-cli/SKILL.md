---
name: gitnexus-cli
description: "Use GitNexus CLI commands via terminal: analyze/index repo, check status, clean index, generate wiki, list repos. Examples: 'Index this repo', 'Reanalyze the codebase', 'Generate a wiki', 'Check gitnexus status'"
---

# GitNexus CLI

Commands below use `node .gitnexus/run.cjs <command>` — the project-local runner `gitnexus analyze` drops next to the index. It auto-selects an available runner at call time (global `gitnexus`, else `pnpm dlx`, else `npx`), so no package-manager assumption and no global install is required.

> **Not analyzed yet, or `node .gitnexus/run.cjs` reports `Cannot find module`** (the gitignored runner is absent — e.g. a fresh clone or `git clean`)? (Re)generate it with `npx gitnexus analyze` from the project root. On **npm 11.x**, if `npx` crashes during install (`node.target is null`), install once with `npm i -g gitnexus` (then `gitnexus analyze`) or use `pnpm --allow-build=@ladybugdb/core --allow-build=gitnexus --allow-build=tree-sitter dlx gitnexus@latest analyze`. See [#1939](https://github.com/abhigyanpatwari/GitNexus/issues/1939).

## analyze — Build/refresh index

```bash
node .gitnexus/run.cjs analyze
```

| Flag | Effect |
|------|--------|
| `--force` | Force full re-index even if up to date |
| `--embeddings` | Enable semantic search embeddings (off by default) |
| `--drop-embeddings` | Drop existing embeddings on rebuild |

**When to run:** First time in a project, after major code changes, or when context reports stale index.

## status — Check freshness

```bash
node .gitnexus/run.cjs status
```

Shows whether repo has a GitNexus index, last updated time, and symbol/relationship counts.

## clean — Delete index

```bash
node .gitnexus/run.cjs clean
```

| Flag | Effect |
|------|--------|
| `--force` | Skip confirmation |
| `--all` | Clean all indexed repos |

## wiki — Generate docs from graph

```bash
node .gitnexus/run.cjs wiki
```

Generates repository documentation using LLM. Requires API key (saved to `~/.gitnexus/config.json` on first use).

| Flag | Effect |
|------|--------|
| `--force` | Force full regeneration |
| `--model <model>` | LLM model (default: minimax/minimax-m2.5) |
| `--concurrency <n>` | Parallel LLM calls (default: 3) |

## list — Show indexed repos

```bash
node .gitnexus/run.cjs list
```

## After Indexing

1. READ `gitnexus://repo/{name}/context` to verify index loaded
2. Use other GitNexus skills for your task

## Troubleshooting

- **"Not inside a git repository"**: Run from a directory inside a git repo
- **Index stale after re-analyzing**: Restart Cursor to reload the MCP server (CLI and MCP must use the same `gitnexus` version)
- **Embeddings slow**: Omit `--embeddings` (off by default) or set `OPENAI_API_KEY` for faster API-based embedding

### LadybugDB version mismatch (`Database file version: N, Current build storage version: M`)

Graph tools (`impact`, `cypher`, `detect_changes`) read `.gitnexus/lbug` via LadybugDB. This error means the **index was built by a newer GitNexus/LadybugDB** than the **MCP server process** currently running (common right after `analyze` or `npm i -g gitnexus@latest` without restarting Cursor).

**Fix (in order):**

1. Wait if `analyze` is still running — do not call MCP graph tools during rebuild.
2. Align versions: `npm i -g gitnexus@latest` and verify `gitnexus --version`.
3. **Restart Cursor** (or reload the GitNexus MCP server) so MCP picks up the same version as CLI.
4. If still failing: `node .gitnexus/run.cjs clean --force && node .gitnexus/run.cjs analyze`, then restart Cursor again.
5. Fallback while graph is down: use `context({name, repo})` or `query({query, repo})` — these may still work; `impact` needs LadybugDB.

### Duplicate repo name (`aimtg_mobile` registered at multiple paths)

If `list_repos` shows siblings (e.g. an old clone under `~/Downloads/...`), always pass the **full workspace path** as `repo`:

```
repo: "/Volumes/ESD310C/FlutterProject/aimtg_mobile"
```

Optionally remove stale clones from the registry: `node .gitnexus/run.cjs clean --force` from the old path, or edit `~/.gitnexus/registry.json`.
