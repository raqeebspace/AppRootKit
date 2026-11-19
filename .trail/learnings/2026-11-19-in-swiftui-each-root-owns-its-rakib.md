---
title: "In SwiftUI, each root owns its transition for both entering and leaving, while the destination root's animation drives the switch"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 2, tokens: 31183 }
id: l-dbb804f7
scope: repo
status: active
src: agent
touches:
  - Sources/AppRootNavigationSwiftUI/AppRootFlow.swift
  - Sources/AppRootNavigationSwiftUI/AppRootView.swift
  - Tests/AppRootNavigationSwiftUITests/AppRouterTests.swift
  - README.md
---

## Decided
- The SwiftUI `AppRootFlow` has optional `transition: AnyTransition?` and `animation: Animation?`
  (default `nil`, falling back to `AppRootView`'s init values). A root's transition plays its
  insertion when it enters and its removal when it leaves. `animation` comes from the new root
  and applies to both sides, because `.animation(_:value:)` is evaluated with the new root.
- This differs from UIKit, where the destination's `CATransition` drives the whole swap. In
  SwiftUI a removed view plays the transition captured at its last render, so a
  destination-driven transition would need two renders (set transition, then swap root next
  run loop), which delays the root change a frame and shows the old root's cleared stack.

## Tried and ruled out
- A per-call `setRoot(_:transition:)` override: same stale-removal problem, and an extra API.

## Watch out
- Roots that each pick an edge must agree: if `login` enters from the leading edge while
  `home` uses a default `.push(from: .trailing)` (which leaves toward leading), they cross.
  Give every customized root the edge it lives on.

In the code: Sources/AppRootNavigationSwiftUI/AppRootFlow.swift, Sources/AppRootNavigationSwiftUI/AppRootView.swift, README.md
