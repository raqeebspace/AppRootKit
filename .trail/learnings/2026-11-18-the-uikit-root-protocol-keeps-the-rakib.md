---
title: The UIKit root protocol keeps the name AppRootFlow; only the SwiftUI library uses AppRoot
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 4, tokens: 130208 }
id: l-839f5a85
scope: repo
status: active
replaces: l-fe3a21ef
src: agent
touches:
  - Sources/AppRootNavigation/AppRootFlow.swift
  - Sources/AppRootNavigationSwiftUI/NavigationCoordinator.swift
  - Sources/AppRootNavigationSwiftUI/AppRootView.swift
  - Package.swift
---

## Decided
- The UIKit library's root protocol stays `AppRootFlow`, with no `AppRoot` type in that module.
  The 1.0.0 README told apps to write `enum AppRoot: AppRootFlow`. When that enum lives in
  another module of the app, any file importing both modules fails with
  "'AppRoot' is ambiguous for type lookup in this context", whatever the import order.
- The SwiftUI library keeps `AppRoot`: it is a new product, so only apps that opt in can hit
  the clash, and the README tells them to write `AppRootNavigationSwiftUI.AppRoot`.
- `NavigationCoordinator` is generic over `Screen`, so `push` only accepts the type
  `AppRootView` registered a `navigationDestination` for. Pushing another type used to do nothing.
- `AppRootView` clears the stack in `onReceive(store.$rootResetToken.dropFirst())`, which runs
  inside `setRoot(_:)`. `onChange` ran after the new root had drawn with the old pushed screens.

## Tried and ruled out
- Renaming to `AppRoot` with a deprecated `AppRootFlow` typealias: the alias doesn't help,
  because the clash is with the new name. The same-module test passed, so it missed this.
  The deprecation warning also broke apps built with warnings as errors.

## Watch out
- Never add a public type named `AppRoot` to the UIKit library. The cross-module test fails
  the build if anyone does.

In the code: Sources/AppRootNavigation/AppRootFlow.swift, Tests/CompatFixture/AppRoot.swift, Tests/AppRootNavigationTests/CrossModuleCompatibilityTests.swift, Sources/AppRootNavigationSwiftUI/NavigationCoordinator.swift, Sources/AppRootNavigationSwiftUI/AppRootView.swift, Package.swift
