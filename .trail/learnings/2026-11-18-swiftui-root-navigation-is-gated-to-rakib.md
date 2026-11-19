---
title: "SwiftUI root navigation is gated to iOS 16 instead of raising the package's minimum iOS"
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 6, tokens: 105422 }
id: l-e1f2774b
scope: repo
status: active
src: agent
touches:
  - Sources/AppRootSwiftUI/AppRootView.swift
  - Package.swift
---

## Decided
- The SwiftUI root navigation (ported from the device finder app's AppRootState) marks
  `AppRootView` and `NavigationCoordinator` `@available(iOS 16.0, *)` because they need
  `NavigationStack`/`NavigationPath`. The package platform stays `.iOS(.v13)` so the UIKit
  `AppRootNavigation` library keeps working for iOS 13 apps; SPM has one platform list per package.
- Root changes go through `AppRootStore.setRoot(_:)`, which bumps `rootResetToken` every call.
  Setting the same root again must still pop the stack, and `onChange(of: root)` doesn't fire on equal values.
- Generic roots use `.id(store.root)` to get a new view identity per root, so the transition runs.
  The original app got that from a `switch` with one branch per case.

## Tried and ruled out
- A static `PassthroughSubject` on the view (mirroring the UIKit API): replaced by the store,
  which is what the app actually uses and supports the same-root reset.
- Porting app-specific parts (splash push, paywall, deep links, Bluetooth prompt, telemetry,
  the `AppRootCoordinator.build()` wrapper): they belong to the app, not the library.

In the code: Sources/AppRootSwiftUI/AppRootStore.swift, Sources/AppRootSwiftUI/AppRootView.swift, Package.swift
