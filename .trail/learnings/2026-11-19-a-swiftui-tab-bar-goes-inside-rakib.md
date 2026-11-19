---
title: "A SwiftUI tab bar goes inside a root's single navigation stack, so pushes from any tab cover the tab bar"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 3, tokens: 33590 }
id: l-1adda7f2
scope: repo
status: active
src: agent
touches:
  - Examples/SwiftUIExample/MainTabView.swift
  - Examples/SwiftUIExample/Screens.swift
  - Examples/SwiftUIExample/AppFlow.swift
  - Sources/AppRootNavigationSwiftUI/AppRootView.swift
  - README.md
---

## Decided
- The SwiftUI example's `.home` root is a `TabView` (`MainTabView`) inside the root's one
  `NavigationStack`. All tabs push on `router.path`, so `router.push` works from any tab and
  a pushed screen covers the tab bar. No library change was needed.
- The title is set on the `TabView` (`.navigationTitle(tab.title)`), not inside each tab:
  the tabs share one navigation bar. `ActionScreen` takes an optional title for that reason.

## Tried and ruled out
- One `NavigationStack` per tab (tab bar stays visible on push): `AppRootView` already wraps
  every root in a stack and `usesNavigationStack` was removed, and `router.push` targets the
  single `router.path`, so pushes from a tab would go nowhere. It needs a library change
  (per-root stack opt-out, or per-tab paths in the router) first.

In the code: Examples/SwiftUIExample/MainTabView.swift, Examples/SwiftUIExample/Screens.swift, Examples/SwiftUIExample/AppFlow.swift, Sources/AppRootNavigationSwiftUI/AppRootView.swift, README.md
