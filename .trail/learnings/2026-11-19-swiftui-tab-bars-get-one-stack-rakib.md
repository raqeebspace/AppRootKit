---
title: "SwiftUI tab bars get one stack per tab, and push acts on the stack of the selected tab"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 4, tokens: 50451 }
id: l-e4441ffb
scope: repo
status: active
replaces: l-1adda7f2
src: agent
touches:
  - Sources/AppRootNavigationSwiftUI/AppRouter.swift
  - Sources/AppRootNavigationSwiftUI/AppStack.swift
  - Sources/AppRootNavigationSwiftUI/AppRootFlow.swift
  - Sources/AppRootNavigationSwiftUI/AppRootView.swift
  - Examples/SwiftUIExample/MainTabView.swift
---

## Decided
- A root can set `usesNavigationStack = false` (restored, default `true`) and place
  `AppStack(router:id:)` views itself, e.g. one per tab, so the tab bar stays visible on push.
  The router keeps each AppStack's path by id next to the root's own `path`.
- `push` / `pop` / `popToRoot` act on `router.activeStack`, falling back to `path`. Each
  `AppStack` activates itself in `onAppear`, which a `TabView` fires when its tab is shown, so
  the active stack is always the visible one. `activateStack(_:)` is public for "switch tab
  and push in one action", where `onAppear` would come too late.
- `setRoot` clears `path` and every AppStack path. Same root keeps `activeStack` (the tabs
  stay on screen and no `onAppear` fires); a new root resets it to `nil`.
- The leaving-root snapshot moved from `AppRootView` into the router (`leavingPath`,
  `leavingStacks`). `AppRootView` sets the internal `appRootIsLeaving` environment value
  on the leaving root so its AppStacks read the snapshot instead of popping first.

## Tried and ruled out
- Tabs inside the root's single stack (previous learning): pushes covered the tab bar.
- Typed tab selection on the router (`associatedtype Tab`): needs an optional or a default
  tab for roots without tabs; `AnyHashable` ids plus `onAppear` activation was smaller.

## Watch out
- Initialize nothing in an AppStack's `onAppear` that depends on `activeStack` being set
  before the first frame; it is `nil` until the selected tab appears.

In the code: Sources/AppRootNavigationSwiftUI/AppRouter.swift, Sources/AppRootNavigationSwiftUI/AppStack.swift, Sources/AppRootNavigationSwiftUI/AppRootView.swift, Sources/AppRootNavigationSwiftUI/AppRootFlow.swift, Tests/AppRootNavigationSwiftUITests/AppStackTests.swift, Examples/SwiftUIExample/MainTabView.swift
