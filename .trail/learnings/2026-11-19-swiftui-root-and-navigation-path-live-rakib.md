---
title: "SwiftUI root and navigation path live in one AppRouter object, and each root names its own pushable Screen type"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 5, tokens: 137168 }
id: l-ce8b1573
scope: repo
status: active
replaces: l-17b20341
src: agent
touches:
  - Sources/AppRootNavigationSwiftUI/AppRootFlow.swift
  - Sources/AppRootNavigationSwiftUI/Routable.swift
  - Sources/AppRootNavigationSwiftUI/AppRouter.swift
  - Sources/AppRootNavigationSwiftUI/AppRootView.swift
  - Tests/AppRootNavigationSwiftUITests/AppRouterTests.swift
  - Sources/AppRootNavigation/AppRootFlow.swift
  - Sources/AppRootNavigation/AppRootNavigationController.swift
  - Tests/AppRootNavigationTests/AppRootNavigationControllerTests.swift
  - README.md
---

## Decided
- The SwiftUI library has one `AppRouter<Root>` (root + path + push/pop/setRoot) instead of
  `AppRootStore` + `NavigationCoordinator`. With both in one object, `setRoot` clears the path
  itself (inside a `disablesAnimations` transaction), so the same-root reset needs no
  `rootResetToken` and no `onReceive(...dropFirst())` in the view. Views read one environment
  object with one generic: `@EnvironmentObject var router: AppRouter<Root>`.
- `AppRootFlow` declares `associatedtype Screen: Routable = Never`, so `AppRootView` has one
  generic and no `screen:` argument. `Never` conforms to `Routable` for roots that push nothing.
- `usesNavigationStack` and `AppRootTransitionStyle` were removed: every root gets a
  `NavigationStack`, and the transition is a plain `AnyTransition` defaulting to
  `.push(from: .trailing)` (iOS 16, same gate as `AppRootView`). The SwiftUI library was
  never tagged, so this broke no app.
- UIKit `AppRootNavigationController` gained an instance `setRoot(_:)` and `init(state:)`;
  `key`/`isVisited`/`transition` got default implementations. The static `changeAppRoot`
  subject stays for 1.x apps, now subscribed in `init` so sends before `viewDidLoad` aren't lost.

## Tried and ruled out
- Dropping `.receive(on: DispatchQueue.main)` on the static subject to avoid the one-run-loop
  delay: 1.x apps may send from background threads, and `RunLoop.main` is also async. The new
  instance `setRoot` is the synchronous path instead.

## Watch out
- Inside a type that conforms to `AppRootFlow`/`AppRootState`, a nested name `Root` or `Screen`
  resolves to the associated type; name app enums something else (README uses `AppScreen`).
- `extension Never: Routable` cannot use `switch self {}`; the compiler needs a case or default.

In the code: Sources/AppRootNavigationSwiftUI/AppRouter.swift, Sources/AppRootNavigationSwiftUI/AppRootFlow.swift, Sources/AppRootNavigationSwiftUI/Routable.swift, Sources/AppRootNavigationSwiftUI/AppRootView.swift, Sources/AppRootNavigation/AppRootFlow.swift, Sources/AppRootNavigation/AppRootNavigationController.swift, README.md
