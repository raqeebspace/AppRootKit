---
title: Example apps live in one hand-written Xcode project whose folders sync automatically and that uses the package from the parent folder
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 4, tokens: 52314 }
id: l-3ff330f6
scope: repo
status: active
src: agent
touches:
  - Examples/UIKitExample/AppDelegate.swift
  - Examples/SwiftUIExample/SwiftUIExampleApp.swift
---

## Decided
- One project with two app targets (UIKit, SwiftUI) instead of two projects or a generator
  (no XcodeGen/Tuist on the machine). It uses Xcode 16 folder-synced groups
  (objectVersion 77), so adding or removing a .swift file in a target folder needs no
  project file edit, and a local package reference to `..`, so the apps build against the
  working copy.
- Both targets use the Swift 5 language mode: in Swift 6 mode, creating view controllers
  inside the UIKit `contentController` requirement warns, because that requirement isn't
  `@MainActor`.

## Watch out
- Opening the project needs Xcode 16+ (folder-synced groups).
- The UIKit app gets its scene delegate from `AppDelegate.configurationForConnecting`,
  because the generated Info.plist scene manifest names no delegate class.

In the code: Examples/Examples.xcodeproj/project.pbxproj, Examples/UIKitExample/AppDelegate.swift, Examples/SwiftUIExample/SwiftUIExampleApp.swift
