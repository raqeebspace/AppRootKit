---
title: "Changes to the released UIKit library keep the old API working as deprecated, so 1.x apps build and migrate at their own pace"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 4, tokens: 55331 }
id: l-a31095cf
scope: repo
status: active
replaces: l-0bc5f0f2
src: agent
touches:
  - Sources/AppRootNavigationCore/AppRootProvider.swift
  - Sources/AppRootNavigationCore/AppRootRepresentable.swift
  - Tests/AppRootNavigationTests/SourceCompatibilityTests.swift
  - Tests/AppRootNavigationTests/CrossModuleCompatibilityTests.swift
  - README.md
---

## Decided
- Rakib's rule: anything in the UIKit library that changes from the last release (1.1.4) keeps
  its old form, marked `@available(*, deprecated, message:)` with the migration, and the new
  form is added beside it. 1.x apps must build unchanged.
- `AppRootState` is back in the UIKit library exactly as in 1.1.4 (`currentAppRoot: AppRootFlow`),
  deprecated. The generic shared protocol is `AppRootProvider<Root>` in the core module;
  `init(state:)` on `AppRootNavigationController` and `AppRouter` take it. The primary
  associated type lets 1.x code that stored the state migrate to
  `any AppRootProvider<any AppRootFlow>`.
- The core marker is `AppRootRepresentable`, not `AppRoot`: the 1.0.0 README told apps to name
  their enum `AppRoot`, and a library `AppRoot` made it ambiguous in any file importing both
  modules. Core and SwiftUI were never tagged, so renaming them broke nobody.
- With no breaking change, the README targets 1.2.0, so 1.x apps on "up to next major" get the
  deprecation warnings instead of never seeing the release.

## Tried and ruled out
- Shipping 2.0.0 with the `AppRoot` clash and the generic `AppRootState` (previous learning):
  breaks 1.x apps; the user wants deprecation and migration instead.

## Watch out
- `SourceCompatibilityTests` and `CrossModuleCompatibilityTests` pin 1.x usage, including
  unqualified `AppRoot` from another module and `AppRootState` used as a plain type. Never
  add a public type named `AppRoot` or `AppRootState` elsewhere in the package.

In the code: Sources/AppRootNavigation/AppRootState.swift, Sources/AppRootNavigationCore/AppRootProvider.swift, Sources/AppRootNavigationCore/AppRootRepresentable.swift, Tests/AppRootNavigationTests/SourceCompatibilityTests.swift, Tests/AppRootNavigationTests/CrossModuleCompatibilityTests.swift, README.md
