---
name: code-review
description: "Use when performing comprehensive code review of Flutter/Dart changes. Accepts task name, task ID, commit SHA, or branch name. Reviews implementation correctness, code quality, documentation compliance, and cross-platform consistency. Examples: 'Review PR for task Test-73', 'Review branch `feature/demo` against develop', 'Do a code review for meeting notes filter feature'"
---

# Code Review Skill

Comprehensive code review workflow for Flutter/Dart mobile applications with GitNexus integration.

## Required Inputs

Before starting, gather:

- **Task ID/Name**: e.g., `Test-73`, `demo 1`
- **Commit SHA or Branch**: e.g., `xxxxx` or `feature/demo`
- **Target Branch**: usually `develop` or `main`
- **Task Requirements**: brief description of what the task should implement

## Review Workflow

```
1. GATHER inputs (task ID, commit SHA, task requirements)
2. FETCH diff → git diff against target branch
3. VERIFY implementation correctness
4. REVIEW code quality
5. CHECK documentation compliance (dynamic docs directory discovery)
6. VALIDATE GitNexus/Graphify consistency
7. GENERATE review report
```

## Step-by-Step Checklist

### Step 1: Gather Information

```bash
# Get current directory and repo name dynamically
CURRENT_DIR=$(pwd)
REPO_NAME=$(basename "$CURRENT_DIR")
echo "Reviewing repo: $REPO_NAME"

# Detect target branch (usually develop or main)
git fetch origin 2>/dev/null
TARGET_BRANCH="develop"
if ! git show-ref --quiet refs/heads/develop 2>/dev/null; then
    TARGET_BRANCH="main"
fi
echo "Target branch: $TARGET_BRANCH"

# Get commit info (if commit-sha provided, use it; otherwise HEAD)
COMMIT_REF="${1:-HEAD}"
git fetch origin "$TARGET_BRANCH" 2>/dev/null
git log -1 --stat "$COMMIT_REF" 2>/dev/null || git log -1 --stat

# Get diff against target branch
git diff "origin/$TARGET_BRANCH...$COMMIT_REF" --name-only 2>/dev/null || git diff HEAD --name-only

# Find documentation directory dynamically
DOCS_DIR=""
for dir in docs documentation wiki doc; do
    if [ -d "$dir" ]; then
        DOCS_DIR="$dir"
        break
    fi
done
echo "Docs directory: $DOCS_DIR"

# Find design docs if docs directory exists
if [ -n "$DOCS_DIR" ]; then
    find "$DOCS_DIR" -type d \( -name "design" -o -name "screens" -o -name "specifications" \) 2>/dev/null
fi
```

### Step 2: Implementation Correctness

- [ ] Compare diff against task requirements
- [ ] Verify all required features are implemented
- [ ] Check for missing functionality
- [ ] Verify edge cases are handled
- [ ] Validate API contracts match requirements

### Step 3: Code Quality Review

- [ ] **Naming Conventions**: Follow PascalCase/camelCase/underscores_case correctly
- [ ] **Architecture**: Clean architecture layers respected (data/domain/presentation)
- [ ] **DI Pattern**: BLoCs use `@injectable` (factory), not `@singleton`/`@lazySingleton`
  - ⚠️ **CRITICAL RULE - Screen-level BLoCs must NOT be singleton**: If a BLoC holds form/input state or any per-screen state that should be fresh on each page open, it MUST be registered as `@injectable` (factory scope), NOT `@singleton` or `@lazySingleton`
  - **Pattern violation detected**: Using `BlocProvider.value(value: getIt.get<SomeBloc>())` where SomeBloc is a singleton = stale state on re-entry
  - **Correct pattern**: For screen-level BLoCs, use `BlocProvider(create: (_) => SomeBloc(...))` with factory-scoped bloc
  - **Why this matters**: Singleton BLoCs retain their state across navigation. When user leaves and returns to a screen, the old state persists, causing incorrect behavior (e.g., old recording session data appearing on new recording)
  - **Examples of screen-level BLoCs**: Form BLoCs, recording BLoCs, create/edit flow BLoCs, any BLoC where re-open should start with clean state
  - **Allowed singleton BLoCs**: App-wide state managers (auth state, app settings, feature flags), background coordinators
- [ ] **Error Handling**:
  - Try-catch should be specific — catch general `Exception` when you need to handle ALL cases (network errors, parsing errors, platform errors)
  - Catch with `on` clause when you only need specific exception types
  - Both patterns are acceptable depending on use case — catching all is VALID when you want to show user-friendly error for ANY failure
  - Either type for results from use cases
- [ ] **Performance**: No unnecessary rebuilds, const constructors used
- [ ] **Imports**: Use `package:` imports, not relative imports

### Step 3b: Edge Cases & Spec Compliance

For EACH feature in the diff, verify against design docs:

- [ ] **Empty state handling**: What displays when data is null/empty/loading?
- [ ] **Error state handling**: What displays on API failure?
- [ ] **Boundary conditions**: Long text, large lists, max items
- [ ] **User feedback**: Success/error messages match spec
- [ ] **Navigation edge cases**: Back navigation, deep linking, invalid params
- [ ] **Data validation**: Type checks, null safety, fallback values
- [ ] **Button states**: Disabled during loading, loading indicators

**Cross-check with design docs** (dynamically discovered):

```bash
# Find design docs directory
DESIGN_DIR=""
for subdir in "$DOCS_DIR/design" "$DOCS_DIR/design/screens" "$DOCS_DIR/specifications"; do
    if [ -d "$subdir" ]; then
        DESIGN_DIR="$subdir"
        break
    fi
done
echo "Design docs: $DESIGN_DIR"
ls -la "$DESIGN_DIR" 2>/dev/null
```

- UI elements match spec (headers, buttons, cards)
- Conditional messages match spec exactly
- Navigation flow matches spec
- All states (loading, empty, error, success) handled

### Step 4: Documentation Compliance

- [ ] Code follows project conventions in `AGENTS.md`
- [ ] Public APIs have appropriate documentation
- [ ] No hardcoded error messages (should use centralized error mapping)
- [ ] Follows guidelines from `.roo/rules-code/` directory

### Step 5: GitNexus Consistency

```bash
# Check GitNexus index freshness
npx gitnexus analyze --dry-run

# Get codebase overview (dynamic repo name)
REPO_NAME=$(basename $(pwd))
gitnexus://repo/$REPO_NAME/clusters

# Run impact analysis on changed symbols
gitnexus_impact({target: "symbolName", direction: "upstream"})
gitnexus_impact({target: "symbolName", direction: "downstream"})

# Detect changes
gitnexus_detect_changes()
```

- [ ] Run `gitnexus analyze` to refresh index if stale
- [ ] Verify affected symbols have proper blast radius
- [ ] Check for any breaking changes detected
- [ ] Ensure Graphify platform shows consistent status

## Flutter/Dart Commands Reference

**ALWAYS use `fvm` when available (check with `which fvm`):**

```bash
# Check if fvm is available
if command -v fvm &> /dev/null; then
    # Use fvm for Flutter commands
    fvm flutter analyze
    fvm flutter test
    fvm flutter run
    fvm dart run build_runner build
else
    # Fallback to direct flutter commands
    flutter analyze
    flutter test
    flutter run
    dart run build_runner build
fi
```

## Review Report Template

```markdown
# Code Review Report: [TASK-ID]

## Task Summary

- **Task ID**: [e.g., Test-73]
- **Branch**: [commit-sha or branch name]
- **Target**: [develop/main]
- **Review Date**: [YYYY-MM-DD]
- **Status**: ❌ Changes Requested / ✅ Approved / 🚫 Rejected

---

## Issues Found (Grouped by Priority)

### 🔴 CRITICAL (Must Fix Before Merge)

| #   | File:Line        | Issue                         | Recommendation |
| --- | ---------------- | ----------------------------- | -------------- |
| 1   | [file.dart:42]() | [Description of critical bug] | [How to fix]   |

**Rationale**: [Why this is critical - e.g., causes crash, security issue, data loss]

---

### 🟠 HIGH (Should Fix Before Merge)

| #   | File:Line        | Issue         | Recommendation |
| --- | ---------------- | ------------- | -------------- |
| 1   | [file.dart:42]() | [Description] | [How to fix]   |

**Rationale**: [Why this is high priority]

---

### 🟡 MEDIUM (Fix After Merge - Tech Debt)

| #   | File:Line        | Issue         | Recommendation |
| --- | ---------------- | ------------- | -------------- |
| 1   | [file.dart:42]() | [Description] | [How to fix]   |

**Rationale**: [Why this is medium priority]

**Note**: Try-catch without `on` clause is NOT a bug — catching general `Exception` is valid when you want to gracefully handle ALL failure cases (network, platform, parsing). Only flag if catch is clearly unnecessary or masks real bugs.

---

### 🟢 LOW (Nice to Have)

| #   | File:Line        | Issue         | Recommendation |
| --- | ---------------- | ------------- | -------------- |
| 1   | [file.dart:42]() | [Description] | [How to fix]   |

**Rationale**: [Why this is low priority / suggestion]

---

## Implementation Gaps

| Missing Feature | Status     | Notes     |
| --------------- | ---------- | --------- |
| [Feature name]  | ❌ Missing | [Details] |

---

## GitNexus Analysis

- **Index Status**: ✅ Fresh / ⚠️ Stale (run `npx gitnexus analyze`)
- **Blast Radius**: [LOW/MEDIUM/HIGH/CRITICAL]
- **Breaking Changes**: [Yes/No]
- **Symbols Affected**: [list]

---

## Final Verdict

**Status**: ❌ Changes Requested

**Summary**: [Brief summary of issues - what must be fixed before merge]

**Blocking Issues**: [Count] Critical, [Count] High
**Non-Blocking**: [Count] Medium, [Count] Low

**Next Steps**: [What the author should do next]
```

### Priority Classification Guide

| Priority    | Criteria                                                              |
| ----------- | --------------------------------------------------------------------- |
| 🔴 CRITICAL | Crashes, data loss, security vulnerabilities, blocking bugs           |
| 🟠 HIGH     | Functional bugs, missing required features, DI misconfigurations      |
| 🟡 MEDIUM   | Code smells, minor bugs, performance concerns, maintainability issues |
| 🟢 LOW      | Suggestions, style preferences, minor improvements                    |

### Issue Description Format

Each issue should include:

1. **File and line number** with link
2. **What is wrong** - clear description
3. **Why it is wrong** - impact assessment
4. **How to fix** - specific recommendation

### Do NOT Include

- ✅ Good practices observed (focus only on issues)
- ✅ Compliments or positive feedback
- ✅ Things that are working correctly
- ✅ Personal preferences unrelated to project standards

### Best Practices Checklist

- [ ] No magic numbers — use constants
- [ ] Reusable widgets extracted for repeated UI patterns
- [ ] No deep widget nesting (> 5 levels)
- [ ] Const constructors used where applicable
- [ ] Proper keyboard handling (dismiss on tap outside)
- [ ] Safe area / notch handling on all screen sizes
- [ ] Loading states shown during async operations
- [ ] Error states show actionable messages
- [ ] Animations are smooth (60fps target)
- [ ] No memory leaks (dispose controllers, close streams)

## Example Usage

```
Skill: code-review @/.roo/skills/code-review
Task: Review task Test-73 for meeting notes filter implementation
Commit: 812123112313213123123AAXXXX
Target branch: develop
Requirements: Implement filter functionality for meeting notes list with date range, status, and keyword search filters
Please perform a comprehensive code review following the workflow and checklist provided. Focus on implementation correctness, code quality, documentation compliance, and GitNexus + Graphify consistency.
Check carefully docs in the @/docs directory for UI/UX specifications and requirements.
```

## Important Notes

1. **Use `fvm`** for all Flutter/Dart commands if available in this project
2. **Run impact analysis** before suggesting changes to existing symbols
3. **Check DI lifecycle** - screen-level BLoCs must NOT be singleton
4. **Import convention** - always use `package:` imports not relative imports
5. **Generated files** - do not edit `*.g.dart`, `*.freezed.dart`, `injection.config.dart`
6. **Discover paths dynamically** - do not hardcode absolute paths; use `$(pwd)`, `$(basename $(pwd))`
