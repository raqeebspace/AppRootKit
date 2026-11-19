---
title: "AppRoot and AppRootState live in a shared core module that both libraries re-export, released as 2.0.0"
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 3, tokens: 39127 }
id: l-b22b5e9e
scope: repo
status: active
replaces: l-839f5a85
src: agent
touches:
  - Sources/AppRootNavigationCore/AppRootState.swift
  - Sources/AppRootNavigation/AppRootFlow.swift
  - Sources/AppRootNavigationSwiftUI/SwiftUIAppRoot.swift
  - Tests/AppRootNavigationTests/CrossModuleCompatibilityTests.swift
  - Package.swift
  - README.md
---

## Decided
- `AppRoot` and `AppRootState` live in `AppRootNavigationCore`. Both libraries
  `@_exported import` it, so apps get one shared `AppRoot` whichever library they import.
  Rakib chose this knowing it re-breaks one 1.x case, so it ships as 2.0.0.
- The known break: an app whose own `AppRoot` enum (the 1.0.0 README suggested that name) is
  declared in another module gets "'AppRoot' is ambiguous" in files importing both. Fix:
  rename the enum or qualify it. Same-module enums are unaffected.
- Core `AppRoot` is an empty marker. The UIKit and SwiftUI roots share no requirements
  (`contentController`/`CATransition` vs `Hashable` + `contentView`), so each library refines it:
  `AppRootFlow` (UIKit, released name kept so conformers don't change) and `SwiftUIAppRoot`.
- `AppRootState.Root` is an unconstrained associated type. Constraining it to `AppRoot` breaks
  1.x states returning `any AppRootFlow`, because an existential doesn't conform to its protocol.

## Tried and ruled out
- Keeping UIKit free of any `AppRoot` (the previous learning): safe for 1.x apps, but gave
  no shared type, which Rakib wanted.
- A SwiftUI-only `AppRootState` with no shared module: same reason.

## Watch out
- Using `AppRootState` as a plain type (`let s: AppRootState`) no longer compiles.
- `CrossModuleCompatibilityTests` now pins the qualified-name migration path, not the old
  unqualified usage.

In the code: Sources/AppRootNavigationCore/AppRoot.swift, Sources/AppRootNavigationCore/AppRootState.swift, Sources/AppRootNavigation/AppRootFlow.swift, Sources/AppRootNavigationSwiftUI/SwiftUIAppRoot.swift, Tests/AppRootNavigationTests/CrossModuleCompatibilityTests.swift, Package.swift, README.md
