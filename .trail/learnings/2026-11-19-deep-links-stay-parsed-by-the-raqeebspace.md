---
title: "Deep links stay parsed by the app; the router offers one-call open, and owns the selected tab so a link can switch tabs"
author: Raqeebspace
date: 2026-11-19
branch: release/1.2.0
cost: { minutes: 5, tokens: 50664 }
id: l-83dd247a
scope: repo
status: active
src: agent
touches:
  - ".swiftpm/xcode/package.xcworkspace/contents.xcworkspacedata"
  - Examples/Examples.xcodeproj/project.pbxproj
  - Examples/Examples.xcworkspace/contents.xcworkspacedata
  - Examples/SwiftUIExample/AppFlow.swift
  - Examples/SwiftUIExample/MainTabView.swift
  - Examples/SwiftUIExample/Screens.swift
  - Examples/SwiftUIExample/SwiftUIExampleApp.swift
  - Examples/UIKitExample/AppDelegate.swift
  - Examples/UIKitExample/AppFlow.swift
  - Examples/UIKitExample/SceneDelegate.swift
---

## Decided
- The library never parses URLs (app-specific, as ruled out at the port). It gives one-call
  navigation instead: `AppRouter.open(_:path:)` (root + its own stack), `open(_:stack:path:)`
  (root + select an AppStack/tab + set its stack), `setPath(_:for:)`; UIKit
  `setRoot(_:pushing:)` sets the root and the screens above it in one `setViewControllers`.
- `stackSelection(default:)` gives `TabView(selection:)` a binding backed by `activeStack`.
  Without it, a deep link from another root into the second tab fails: the new tab bar shows
  its first tab, whose AppStack activates itself on appear and overrides the link's stack.
  `AppStackTests.testDeepLinkIntoSecondTabFromAnotherRoot` fails without the binding.
- Example apps use separate schemes (`approot-swiftui`, `approot-uikit`) so both can be
  installed. Each has `DeepLink.swift` that checks the session first (logged-out users land on
  onboarding/login). The schemes come from `<App>-Info.plist` beside the project, merged into
  the generated Info.plist via `INFOPLIST_FILE`; inside the synced folders the plist would be
  copied as a resource too.

## Watch out
- `simctl openurl` shows an "Open in …?" alert for custom schemes; scripted taps on the
  Simulator are unreliable (one opened Wallet), so the app-level flow was checked by hand only.

In the code: Sources/AppRootKit/AppRouter.swift, Sources/AppRootUIKit/AppRootNavigationController.swift, Tests/AppRootKitTests/AppStackTests.swift, Examples/SwiftUIExample/DeepLink.swift, Examples/UIKitExample/DeepLink.swift, Examples/SwiftUIExample-Info.plist, README.md
