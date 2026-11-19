---
title: UIKit and SwiftUI root protocols share the name AppRootFlow on top of the shared AppRoot
author: Rakib
date: 2026-11-18
branch: main
cost: { minutes: 1, tokens: 16528 }
id: l-0bc5f0f2
scope: repo
status: active
replaces: l-b22b5e9e
src: agent
touches:
  - Sources/AppRootNavigationCore/AppRoot.swift
  - Sources/AppRootNavigationCore/AppRootState.swift
  - Sources/AppRootNavigation/AppRootFlow.swift
  - Sources/AppRootNavigationSwiftUI/AppRootFlow.swift
  - README.md
---

## Decided
- `AppRoot` and `AppRootState` live in `AppRootNavigationCore`, which both libraries
  `@_exported import`. Released as 2.0.0, because an app whose own `AppRoot` enum is declared
  in another module now gets "'AppRoot' is ambiguous" and must rename it or qualify it.
- Each library refines `AppRoot` with a protocol named `AppRootFlow`: UIKit requires
  `contentController`/`transition`, SwiftUI requires `Hashable` + `contentView`. Rakib asked for
  one name in both libraries. It is UIKit's released name, so UIKit conformers don't change.
- `AppRootState.Root` is an unconstrained associated type. Constraining it to `AppRoot` breaks
  1.x states returning `any AppRootFlow`, because an existential doesn't conform to its protocol.

## Tried and ruled out
- A separate SwiftUI name (`SwiftUIAppRoot`): no clash for apps importing both libraries, but
  Rakib wanted the same name in both.
- One shared `AppRootFlow` in the core module: the two libraries share no requirements.

## Watch out
- A file importing both libraries must write `AppRootNavigation.AppRootFlow` or
  `AppRootNavigationSwiftUI.AppRootFlow`.
- Using `AppRootState` as a plain type (`let s: AppRootState`) no longer compiles.

In the code: Sources/AppRootNavigationCore/AppRoot.swift, Sources/AppRootNavigationCore/AppRootState.swift, Sources/AppRootNavigation/AppRootFlow.swift, Sources/AppRootNavigationSwiftUI/AppRootFlow.swift, README.md
