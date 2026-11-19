---
title: The old AppRootFlow name stays as a deprecated alias with no automatic rename fix-it
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 2, tokens: 28958 }
id: l-fe3a21ef
scope: repo
status: active
replaces: l-1a405a9a
src: agent
touches:
  - Sources/AppRootNavigation/AppRoot.swift
  - Tests/AppRootNavigationTests/SourceCompatibilityTests.swift
  - README.md
---

## Decided
- The framework is used by other apps, so no public name may break their build. The root
  protocol is `AppRoot` in both libraries; the UIKit library keeps `AppRootFlow` as a
  deprecated typealias.
- The alias uses `deprecated, message:` and not `renamed:`. The 1.0.0 README told apps to write
  `enum AppRoot: AppRootFlow`; a `renamed:` fix-it turns that into `enum AppRoot: AppRoot`,
  which doesn't compile. The message tells them to rename their own type first.
- A test mirrors the old README usage so any future rename that breaks existing apps fails CI.

## Watch out
- Before renaming or removing any public type, add it to the compatibility test first.
- `AppRootState` was left as is: it's public, and a clearer name isn't worth another alias.

In the code: Sources/AppRootNavigation/AppRoot.swift, Tests/AppRootNavigationTests/SourceCompatibilityTests.swift, README.md
