---
title: Both libraries call the root protocol AppRootFlow
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 3, tokens: 42047 }
id: l-b144ab21
scope: repo
status: active
src: agent
touches:
  - Sources/AppRootNavigationSwiftUI/AppRootFlow.swift
  - Sources/AppRootNavigation/AppRootFlow.swift
---

## Decided
- The SwiftUI library's root protocol is `AppRootFlow`, the same name as the UIKit library's
  protocol, so both read as one family. `AppRootFlow` was kept rather than a new shared name
  because it is already public in the released UIKit library (1.0.0, README, Medium articles);
  renaming it would break existing apps.

## Watch out
- An app that imports both `AppRootNavigation` and `AppRootNavigationSwiftUI` sees two
  `AppRootFlow` types; qualify with the module name in that case.

In the code: Sources/AppRootNavigationSwiftUI/AppRootFlow.swift, Sources/AppRootNavigation/AppRootFlow.swift
