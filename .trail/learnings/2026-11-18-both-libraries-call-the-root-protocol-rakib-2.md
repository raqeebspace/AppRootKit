---
title: "Both libraries call the root protocol AppRoot, with AppRootFlow kept as a deprecated alias"
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 1, tokens: 15123 }
id: l-1a405a9a
scope: repo
status: active
replaces: l-b144ab21
src: agent
touches:
  - Sources/AppRootNavigation/AppRoot.swift
  - Sources/AppRootNavigationSwiftUI/AppRoot.swift
  - README.md
---

## Decided
- The root protocol is `AppRoot` in both the UIKit and SwiftUI libraries. It names what a
  conforming value is (one app root, e.g. `.home`) and matches `AppRootStore`, `AppRootView`,
  `AppRootNavigationController` and `AppRootState`.
- The UIKit library keeps `AppRootFlow` as `@available(*, deprecated, renamed: "AppRoot") typealias`,
  so apps on 1.0.0 still compile and get a fix-it.
- README examples name the app's enum `Root`, because `enum AppRoot` would now clash with the protocol.

## Tried and ruled out
- Keeping `AppRootFlow` for both: "Flow" suggests a multi-step process, and the alias removes
  the compatibility reason for keeping it.
- `RootDestination` / `RootScreen`: don't match the `AppRoot*` type family, and a root can be
  a whole navigation stack, not one screen. `AppRootState` is already taken by the UIKit library.

## Watch out
- An app importing both libraries sees two `AppRoot` protocols; qualify with the module name.

In the code: Sources/AppRootNavigation/AppRoot.swift, Sources/AppRootNavigationSwiftUI/AppRoot.swift, README.md
