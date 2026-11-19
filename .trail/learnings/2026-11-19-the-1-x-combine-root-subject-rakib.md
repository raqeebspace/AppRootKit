---
title: The 1.x Combine root subject is deprecated in favor of plain setRoot methods
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 2, tokens: 27821 }
id: l-0c3a5ffd
scope: repo
status: active
src: agent
touches:
  - Sources/AppRootUIKit/AppRootNavigationController.swift
  - Tests/AppRootUIKitTests/SourceCompatibilityTests.swift
  - Tests/AppRootUIKitTests/AppRootNavigationControllerTests.swift
  - Examples/UIKitExample/Screens.swift
  - README.md
---

## Decided
- `AppRootNavigationController.changeAppRoot` (public `PassthroughSubject`) is deprecated.
  Replacements: instance `setRoot(_:)` (runs right away) and the new static
  `setRootInAllWindows(_:)` (same reach as the subject: every controller, every window, on the
  next main run loop pass). A Combine subject as public API can't be changed later without a
  break; methods can.
- The subject is now a private `rootChanges`; `changeAppRoot` became a deprecated computed
  property returning it, so 1.x `changeAppRoot.send(...)` still reaches every controller.
- The README "Migrating from 1.x" section lists every deprecation with its replacement and why,
  then gives step-by-step before/after code (package, imports, `AppRootState`, `changeAppRoot`,
  optional boilerplate). The after-code was compiled against `AppRootUIKit`.

## Watch out
- Library code must never call `changeAppRoot` itself; use `rootChanges`, or the library build
  warns.
- `SourceCompatibilityTests` covers `changeAppRoot.send` for 1.x apps;
  `AppRootNavigationControllerTests` covers `setRootInAllWindows`.

In the code: Sources/AppRootUIKit/AppRootNavigationController.swift, Tests/AppRootUIKitTests/SourceCompatibilityTests.swift, Tests/AppRootUIKitTests/AppRootNavigationControllerTests.swift, Examples/UIKitExample/Screens.swift, README.md
