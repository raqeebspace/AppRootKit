---
title: The SwiftUI library is named AppRootKit
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 1, tokens: 16935 }
id: l-55edc14c
scope: repo
status: active
replaces: l-17b20341
src: agent
touches:
  - Package.swift
  - README.md
---

## Decided
- The SwiftUI product, module and folders are `AppRootKit` (was `AppRootNavigationSwiftUI`,
  first `AppRootSwiftUI`). Rakib picked it: short, keeps the `AppRoot` prefix, and the library
  is more than navigation now (router, per-tab stacks, transitions). It was never tagged, so
  the rename broke nobody and needs no alias.
- The UIKit library keeps `AppRootNavigation`: it is released (1.x).
- `AppRootView` / `AppStack` stay `@available(iOS 16.0, *)` while the package stays iOS 13
  for the UIKit library.

## Tried and ruled out
- `AppRootRouting`, `SwiftUIAppRoot`, `AppRootUI` (offered, not picked).
- Any module name equal to a type inside it (`AppRouter`, `AppStack`): Swift then can't
  qualify `Module.Type`.

In the code: Package.swift, Sources/AppRootKit/, Tests/AppRootKitTests/, Examples/Examples.xcodeproj/project.pbxproj, Examples/SwiftUIExample/, README.md
