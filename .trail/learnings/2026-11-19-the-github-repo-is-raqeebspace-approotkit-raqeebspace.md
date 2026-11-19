---
title: "The GitHub repo is raqeebspace/AppRootKit, matching the package name"
author: Raqeebspace
date: 2026-11-19
branch: main
cost: { minutes: 1, tokens: 14061 }
id: l-3ed18b5e
scope: repo
status: active
replaces: l-5e410adc
src: agent
touches:
  - Examples/Examples.xcodeproj/project.pbxproj
  - Examples/SwiftUIExample-Info.plist
  - Examples/SwiftUIExample/DeepLink.swift
  - Examples/SwiftUIExample/MainTabView.swift
  - Examples/SwiftUIExample/SwiftUIExampleApp.swift
  - Examples/UIKitExample-Info.plist
  - Examples/UIKitExample/DeepLink.swift
  - Examples/UIKitExample/SceneDelegate.swift
  - README.md
  - Sources/AppRootKit/AppRouter.swift
---

## Decided
- Rakib renamed the repo from `raqeebspace/approotnavigation` to `raqeebspace/AppRootKit`, so the
  repo, the package (`AppRootKit`) and the SwiftUI library share one name. Libraries stay:
  `AppRootKit` (SwiftUI), `AppRootUIKit` (UIKit), `AppRootCore` (shared), and `AppRootNavigation`
  as deprecated 1.x aliases.
- SwiftPM takes a package's identity from the last part of its URL. With the new URL the identity
  is `approotkit`, so the README uses `.product(name: ..., package: "AppRootKit")`. 1.x apps that
  keep the old URL go through GitHub's redirect and keep identity `approotnavigation`, so their
  `package: "AppRootNavigation"` still resolves. Matching is case-insensitive.

## Watch out
- GitHub's redirect only holds while nobody creates a new repo named `approotnavigation`
  under `raqeebspace`. Don't reuse that name.
- The migration guide's "Before" code keeps the old `rqbctg/approotnavigation` URL on purpose;
  that is what 1.x apps have.

In the code: README.md, Package.swift, Sources/AppRootNavigation/AppRootNavigation.swift
