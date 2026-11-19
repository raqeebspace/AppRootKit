---
title: SwiftUI root navigation ships as AppRootNavigationSwiftUI and is gated to iOS 16
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 2, tokens: 14490 }
id: l-17b20341
scope: repo
status: active
replaces: l-e1f2774b
src: agent
touches:
  - Package.swift
---

## Decided
- The SwiftUI library is named `AppRootNavigationSwiftUI` so it pairs with the UIKit
  `AppRootNavigation` library in the same package. It was first named `AppRootSwiftUI`;
  renamed on request because that name didn't read as part of the same family.
- `AppRootView` and `NavigationCoordinator` are `@available(iOS 16.0, *)` because they need
  `NavigationStack`/`NavigationPath`. The package platform stays `.iOS(.v13)` so the UIKit
  library keeps working for iOS 13 apps; SPM has one platform list per package.
- Root changes go through `AppRootStore.setRoot(_:)`, which bumps `rootResetToken` every call.
  Setting the same root again must still pop the stack, and `onChange(of: root)` doesn't fire on equal values.
- Generic roots use `.id(store.root)` to get a new view identity per root, so the transition runs.
  The original device finder app got that from a `switch` with one branch per case.

## Tried and ruled out
- A static `PassthroughSubject` on the view (mirroring the UIKit API): replaced by the store,
  which is what the device finder app uses and supports the same-root reset.
- Porting app-specific parts (splash push, paywall, deep links, Bluetooth prompt, telemetry,
  the `AppRootCoordinator.build()` wrapper): they belong to the app, not the library.

In the code: Sources/AppRootNavigationSwiftUI/AppRootStore.swift, Sources/AppRootNavigationSwiftUI/AppRootView.swift, Package.swift
