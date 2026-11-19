//
//  AppRootRepresentable.swift
//  AppRootCore
//

/// One root of the app (e.g. onboarding, home), shared by the UIKit and SwiftUI libraries.
///
/// Conform through `AppRootFlow`. Each library declares its own `AppRootFlow` with what it
/// needs to show the root: a view controller (UIKit) or a view (SwiftUI).
///
/// Not named `AppRoot`: the 1.0.0 README told apps to name their own enum `AppRoot`, and a
/// library type with that name makes it ambiguous in files that import both.
public protocol AppRootRepresentable {}
