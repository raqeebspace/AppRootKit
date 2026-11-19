---
title: "The package is AppRootKit, with AppRootUIKit for UIKit and AppRootKit for SwiftUI, and the old UIKit module name stays as deprecated aliases"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 2, tokens: 30939 }
id: l-5e410adc
scope: repo
status: active
replaces: l-55edc14c
src: agent
touches:
  - Package.swift
  - README.md
---

## Decided
- Rakib's naming: package `AppRootKit`; UIKit library `AppRootUIKit` (was `AppRootNavigation`);
  SwiftUI library `AppRootKit`; shared core `AppRootCore` (was `AppRootNavigationCore`, never
  released).
- `AppRootNavigation` stays as a product and module because 1.x apps import it. It contains
  only `@available(*, deprecated)` typealiases (`AppRootFlow`, `AppRootNavigationController`,
  `AppRootState`) pointing at `AppRootUIKit`, plus `@_exported import AppRootCore`. Each use
  warns "Replace `import AppRootNavigation` with `import AppRootUIKit`". This follows the rule
  that released UIKit API changes ship as deprecations, not breaks.
- The deprecated `AppRootState` protocol also lives in `AppRootUIKit`, so changing the import
  and migrating to `AppRootProvider` can happen one at a time.
- The manifest name change doesn't break 1.x `Package.swift` files: SwiftPM matches
  `.product(..., package:)` against the identity from the repo URL (`approotnavigation`).
  The README uses that identity.

## Watch out
- Renaming the GitHub repo changes the package identity and does break `package:` arguments.
- `CompatFixture`, `SourceCompatibilityTests` and `CrossModuleCompatibilityTests` import
  `AppRootNavigation` on purpose: they are the 1.x app. Don't move them to `AppRootUIKit`.
- The package test scheme is now `AppRootKit-Package`.

In the code: Package.swift, Sources/AppRootNavigation/AppRootNavigation.swift, Sources/AppRootUIKit/, Sources/AppRootCore/, Tests/AppRootUIKitTests/, Examples/Examples.xcodeproj/project.pbxproj, README.md
