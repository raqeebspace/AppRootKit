---
title: The README keeps its bold keywords even when the prose is simplified
author: Raqeebspace
date: 2026-11-19
branch: release/1.2.0
cost: { minutes: 13, tokens: 81002 }
id: l-c54c48bc
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
- Rakib wants keywords in the README bolded, e.g. **Root** / **State** / **Switch** in the
  "How it works" table, **root screen**, **UIKit**, **SwiftUI** in the intro, **to** in
  "the root you switch **to**", and **Requirements:**. They act as scan points for readers.
- A plain-English pass (ste80-humanizer) removed them as "decorative bold" (its rule §19); that
  was reverted. When simplifying the README, rewrite sentences but leave existing bold alone.

In the code: README.md
