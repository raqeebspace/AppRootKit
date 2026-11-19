---
title: "Open the example apps through their workspace, because Xcode won't load the package in two windows at once"
author: Rakib
date: 2026-11-19
branch: main
cost: { minutes: 1, tokens: 11767 }
id: l-d0aa7d18
scope: repo
status: active
replaces: l-3ff330f6
src: agent
touches:
  - Package.swift
  - Examples/UIKitExample/AppDelegate.swift
  - README.md
---

## Decided
- `Examples/Examples.xcworkspace` holds the package (`group:..`) and `Examples.xcodeproj`.
  Opening the project while `Package.swift` is open in another window fails with
  "Couldn't load app_root because it is already opened from another project or workspace":
  Xcode lets one window own a local package. The workspace puts both in one window.
- The project itself stays one hand-written project with two app targets, Xcode 16
  folder-synced groups (no project file edits to add a .swift file), and a local package
  reference to `..`, so the apps build against the working copy.
- Both app targets use the Swift 5 language mode: in Swift 6 mode, creating view controllers
  inside the UIKit `contentController` requirement warns, because it isn't `@MainActor`.

## Watch out
- `xcodebuild -workspace` lists only the two app schemes; run the package's own tests from
  the package root (`-scheme AppRootNavigation-Package`), not through the workspace.
- The UIKit app gets its scene delegate from `AppDelegate.configurationForConnecting`,
  because the generated Info.plist scene manifest names no delegate class.

In the code: Examples/Examples.xcworkspace/contents.xcworkspacedata, Examples/Examples.xcodeproj/project.pbxproj, Examples/UIKitExample/AppDelegate.swift, README.md
