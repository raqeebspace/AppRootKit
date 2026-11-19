---
title: "In SwiftUI the destination root's transition drives both the entering and the leaving root, by swapping roots one view update after setRoot"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 10, tokens: 101755 }
id: l-ce54328c
scope: repo
status: active
replaces: l-dbb804f7
src: agent
touches:
  - README.md
  - Sources/AppRootNavigationSwiftUI/AppRootView.swift
  - Sources/AppRootNavigationSwiftUI/AppRouter.swift
  - Sources/AppRootNavigationSwiftUI/AppRootFlow.swift
  - Tests/AppRootNavigationSwiftUITests/RootTransitionTests.swift
---

## Decided
- Per-root `transition` / `animation` on the SwiftUI `AppRootFlow` belong to the root being
  switched *to*, for both sides, matching UIKit's destination `CATransition`. The previous
  "each root owns its own removal" model let roots cross (login in from the left while home,
  on the default push, also left to the left).
- `AppRootView` keeps `shownRoot` one view update behind `router.root`. Step 1, in
  `onReceive(router.$root)` (fires in `setRoot`'s willSet): snapshot `router.path` into
  `leavingPath`, set `activeTransition` to the destination's, set `pendingRoot`. Step 2, in
  `onChange(of: pendingRoot)`: `withAnimation { shownRoot = newRoot }`. SwiftUI removes a view
  with the transition from its last update, so the leaving root must be redrawn once with the
  new transition before it is removed.
- The leaving root's `NavigationStack` reads `leavingPath` (binding keyed on root ≠
  `router.root`), so it slides out with its pushed screens instead of popping first.
  `AppRouter.setRoot` sets `root` before clearing `path` so the snapshot sees the old stack.
- `router.root` and `router.path` still change synchronously in `setRoot`; only the view lags,
  by one update, not one run loop.

## Tried and ruled out
- Swapping on `DispatchQueue.main.async` instead of `onChange`: the main queue can drain before
  SwiftUI's update in the same run loop pass, so both changes may land in one update.
- Per-root ownership (previous learning): coherent only if every root picks an edge; mixing with
  the default push crossed.

## Watch out
- With destination semantics, a symmetric `.move(edge:)` moves both roots the same way and they
  overlap; use `.push(from:)` or `.asymmetric`.
- `RootTransitionTests` renders `window.layer` mid-animation and checks pixel colors (the test
  runner has no on-screen window, so `drawHierarchy` returns blank). It fails on the old code.

In the code: Sources/AppRootNavigationSwiftUI/AppRootView.swift, Sources/AppRootNavigationSwiftUI/AppRouter.swift, Sources/AppRootNavigationSwiftUI/AppRootFlow.swift, Tests/AppRootNavigationSwiftUITests/RootTransitionTests.swift, README.md
