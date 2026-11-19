---
title: "Universal links reuse the deep link routes, and the example apps leave out the Associated Domains entitlement on purpose"
author: Raqeebspace
date: 2026-11-19
branch: release/1.2.0
cost: { minutes: 1, tokens: 23271 }
id: l-eb665262
scope: repo
status: active
src: agent
touches:
  - Examples/SwiftUIExample/DeepLink.swift
  - Examples/UIKitExample/DeepLink.swift
  - Examples/UIKitExample/SceneDelegate.swift
  - README.md
---

## Decided
- Universal links need nothing new in the library: the router calls are the same. Each
  example's `DeepLink.route(of:)` maps both `approot-*://profile/Grace` and
  `https://example.com/profile/Grace` to `["profile", "Grace"]`, and rejects other hosts and
  plain `http`.
- UIKit receives universal links through `scene(_:continue:)` (running) and
  `connectionOptions.userActivities` (launch), filtered on `NSUserActivityTypeBrowsingWeb`.
  SwiftUI gets them in the same `.onOpenURL` as custom schemes.
- The example project has no Associated Domains entitlement. With a signing team set,
  automatic signing tries to enable the capability, and free developer accounts can't, so the
  examples would stop building for them. The README explains the entitlement and the
  apple-app-site-association file instead; `example.com` is a placeholder in
  `DeepLink.universalLinkHost`.

## Watch out
- Universal links can't be tested end to end without a real domain serving the association
  file; the parsing was checked with a standalone script, not on a device.

In the code: Examples/SwiftUIExample/DeepLink.swift, Examples/UIKitExample/DeepLink.swift, Examples/UIKitExample/SceneDelegate.swift, README.md
