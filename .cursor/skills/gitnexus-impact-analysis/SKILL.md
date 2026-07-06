---
name: gitnexus-impact-analysis
description: "Use before making code changes to understand blast radius, or when assessing risk of modifications. Examples: 'Is it safe to change X?', 'What depends on this?', 'What will break?', 'Show me the blast radius'"
---

# Impact Analysis with GitNexus

## Workflow

```
1. gitnexus_impact({target: "X", direction: "upstream"})  → What depends on this
2. READ gitnexus://repo/{name}/processes                  → Check affected execution flows
3. gitnexus_detect_changes()                              → Map current git changes to affected flows
4. Assess risk and report to user
```

If "Index is stale" → run `node .gitnexus/run.cjs analyze` in terminal first, then restart Cursor.

If `impact` returns **LadybugDB version mismatch** → CLI and MCP are on different GitNexus versions. Restart Cursor after aligning `gitnexus --version`; see `.cursor/skills/gitnexus-cli/SKILL.md`.

If `impact` returns **ambiguous** (multiple symbols named `stop`, etc.) → disambiguate:

```
impact({
  target: "stop",
  target_uid: "Method:lib/features/recording-list/data/services/recording_runtime_service_impl.dart:RecordingRuntimeServiceImpl.stop#0",
  direction: "upstream",
  repo: "/Volumes/ESD310C/FlutterProject/aimtg_mobile"
})
```

Or use `file_path` / `kind`. Always pass full `repo` path when duplicate clones exist in `list_repos`.

## Checklist

```
- [ ] gitnexus_impact({target, direction: "upstream"}) to find dependents
- [ ] Review d=1 items first (these WILL BREAK)
- [ ] Check high-confidence (>0.8) dependencies
- [ ] READ gitnexus://repo/{name}/processes to check affected execution flows
- [ ] gitnexus_detect_changes() for pre-commit check
- [ ] Assess risk level and report to user
```

## Understanding Depth

| Depth | Risk Level | Meaning |
|-------|------------|---------|
| d=1 | **WILL BREAK** | Direct callers/importers |
| d=2 | LIKELY AFFECTED | Indirect dependencies |
| d=3 | MAY NEED TESTING | Transitive effects |

## Risk Assessment

| Affected | Risk |
|----------|------|
| <5 symbols, few processes | LOW |
| 5-15 symbols, 2-5 processes | MEDIUM |
| >15 symbols or many processes | HIGH |
| Critical path (auth, payments) | CRITICAL |

## Tools

**gitnexus_impact** — symbol blast radius:

```
gitnexus_impact({
  target: "validateUser",
  direction: "upstream",
  minConfidence: 0.8,
  maxDepth: 3
})

→ d=1 (WILL BREAK):
  - loginHandler (src/auth/login.ts:42) [CALLS, 100%]
  - apiMiddleware (src/api/middleware.ts:15) [CALLS, 100%]

→ d=2 (LIKELY AFFECTED):
  - authRouter (src/routes/auth.ts:22) [CALLS, 95%]
```

**gitnexus_detect_changes** — git-diff based impact:

```
gitnexus_detect_changes({scope: "staged"})

→ Changed: 5 symbols in 3 files
→ Affected: LoginFlow, TokenRefresh, APIMiddlewarePipeline
→ Risk: MEDIUM
```

## Example: "What breaks if I change validateUser?"

```
1. gitnexus_impact({target: "validateUser", direction: "upstream"})
   → d=1: loginHandler, apiMiddleware (WILL BREAK)
   → d=2: authRouter, sessionManager (LIKELY AFFECTED)

2. READ gitnexus://repo/my-app/processes
   → LoginFlow and TokenRefresh touch validateUser

3. Risk: 2 direct callers, 2 processes = MEDIUM
```
