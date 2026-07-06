---
name: flutter-expert
description: Use when building cross-platform applications with Flutter 3+ and Dart. Invoke for widget development, Riverpod/Bloc state management, GoRouter navigation, platform-specific implementations, performance optimization.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: '1.1.0'
  domain: frontend
  triggers: Flutter, Dart, widget, Riverpod, Bloc, GoRouter, cross-platform
  role: specialist
  scope: implementation
  output-format: code
  related-skills: react-native-expert, test-master, fullstack-guardian
---

# Flutter Expert

Senior mobile engineer building high-performance cross-platform applications with Flutter 3 and Dart.

## When to Use This Skill

- Building cross-platform Flutter applications
- Implementing state management (Riverpod, Bloc)
- Setting up navigation with GoRouter
- Creating custom widgets and animations
- Optimizing Flutter performance
- Platform-specific implementations

## Core Workflow

1. **Setup** — Scaffold project, add dependencies (`flutter pub get`), configure routing
2. **State** — Define Riverpod providers or Bloc/Cubit classes; verify with `flutter analyze`
   - If `flutter analyze` reports issues: fix all lints and warnings before proceeding; re-run until clean
3. **Widgets** — Build reusable, const-optimized components; run `flutter test` after each feature
   - If tests fail: inspect widget tree with Flutter DevTools, fix failing assertions, re-run `flutter test`
4. **Test** — Write widget and integration tests; confirm with `flutter test --coverage`
   - If coverage drops or tests fail: identify untested branches, add targeted tests, re-run before merging
5. **Optimize** — Profile with Flutter DevTools (`flutter run --profile`), eliminate jank, reduce rebuilds
   - If jank persists: check rebuild counts in the Performance overlay, isolate expensive `build()` calls, apply `const` or move state closer to consumers

## Reference Guide

Load detailed guidance based on context:

| Topic       | Reference                           | Load When                                               |
| ----------- | ----------------------------------- | ------------------------------------------------------- |
| Riverpod    | `references/riverpod-state.md`      | State management, providers, notifiers                  |
| Bloc        | `references/bloc-state.md`          | Bloc, Cubit, event-driven state, complex business logic |
| GoRouter    | `references/gorouter-navigation.md` | Navigation, routing, deep linking                       |
| Widgets     | `references/widget-patterns.md`     | Building UI components, const optimization              |
| Structure   | `references/project-structure.md`   | Setting up project, architecture                        |
| Performance | `references/performance.md`         | Optimization, profiling, jank fixes                     |

## Code Examples

### Riverpod Provider + ConsumerWidget (correct pattern)

```dart
// provider definition
final counterProvider = StateNotifierProvider<CounterNotifier, int>(
  (ref) => CounterNotifier(),
);

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  void increment() => state = state + 1; // new instance, never mutate
}

// consuming widget — use ConsumerWidget, not StatefulWidget
class CounterView extends ConsumerWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('$count');
  }
}
```

### Before / After — State Management

```dart
// ❌ WRONG: app-wide state in setState
class _BadCounterState extends State<BadCounter> {
  int _count = 0;
  void _inc() => setState(() => _count++); // causes full subtree rebuild
}

// ✅ CORRECT: scoped Riverpod consumer
class GoodCounter extends ConsumerWidget {
  const GoodCounter({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return IconButton(
      onPressed: () => ref.read(counterProvider.notifier).increment(),
      icon: const Icon(Icons.add), // const on static widgets
    );
  }
}
```

## Constraints

### MUST DO

- Use `const` constructors wherever possible
- Implement proper keys for lists
- Use `Consumer`/`ConsumerWidget` for state (not `StatefulWidget`)
- Follow Material/Cupertino design guidelines
- Profile with DevTools, fix jank
- Test widgets with `flutter_test`

### MUST NOT DO

- Build widgets inside `build()` method
- Mutate state directly (always create new instances)
- Use `setState` for app-wide state
- Skip `const` on static widgets
- Ignore platform-specific behavior
- Block UI thread with heavy computation (use `compute()`)

### ⚠️ CRITICAL - DI Lifecycle: Screen-level BLoCs Must NOT Be Singleton

**Problem**: Using `BlocProvider.value(value: getIt.get<SomeBloc>())` where SomeBloc is a singleton causes **stale state** when navigating away and back to a screen. The singleton retains its state, so re-entering the screen shows old data.

**Rule**: Screen-level BLoCs (forms, recording, create/edit flows) must be:

1. Registered as `@injectable` (factory scope), NOT `@singleton` or `@lazySingleton`
2. Provided via `BlocProvider(create: (_) => SomeBloc(...))`

**Example - WRONG**:

```dart
// ❌ RecordingBloc is @singleton
@singleton
class RecordingBloc extends Bloc<RecordingEvent, RecordingState> { ... }

// ❌ Using singleton = stale state on re-entry
return BlocProvider.value(
  value: getIt.get<RecordingBloc>(),
  child: const _RecordingPage(),
);
```

**Example - CORRECT**:

```dart
// ✅ RecordingBloc is factory-scoped
@injectable
class RecordingBloc extends Bloc<RecordingEvent, RecordingState> { ... }

// ✅ Create fresh instance per screen
return BlocProvider(
  create: (context) => RecordingBloc(...),
  child: const _RecordingPage(),
);
```

**When to use singleton/lazySingleton**:

- App-wide state (auth, settings, feature flags)
- Background coordinators (websocket, sync)
- Repositories and use cases (stateless or cache-safe)

**When to use @injectable (factory)**:

- Screen-level BLoCs (form state, recording state)
- Any BLoC where re-open should start with clean state
- Create/edit flow BLoCs

## Troubleshooting Common Failures

| Symptom                           | Likely Cause                                                        | Recovery                                                                  |
| --------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `flutter analyze` errors          | Unresolved imports, missing `const`, type mismatches                | Fix flagged lines; run `flutter pub get` if imports are missing           |
| Widget test assertion failures    | Widget tree mismatch or async state not settled                     | Use `tester.pumpAndSettle()` after state changes; verify finder selectors |
| Build fails after adding package  | Incompatible dependency version                                     | Run `flutter pub upgrade --major-versions`; check pub.dev compatibility   |
| Jank / dropped frames             | Expensive `build()` calls, uncached widgets, heavy main-thread work | Use `RepaintBoundary`, move heavy work to `compute()`, add `const`        |
| Hot reload not reflecting changes | State held in `StateNotifier` not reset                             | Use hot restart (`R` in terminal) to reset full app state                 |

## Output Templates

When implementing Flutter features, provide:

1. Widget code with proper `const` usage
2. Provider/Bloc definitions
3. Route configuration if needed
4. Test file structure
