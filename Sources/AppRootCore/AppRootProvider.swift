//
//  AppRootProvider.swift
//  AppRootCore
//

/// Decides which root the app should show now, e.g. onboarding until it's finished.
///
/// `Root` is your root type (`var currentAppRoot: AppFlow`), or `any AppRootFlow` in UIKit.
/// It is unconstrained because an existential like `any AppRootFlow` doesn't conform to
/// its own protocol.
///
/// Replaces the UIKit library's `AppRootState`, whose name stays for 1.x apps.
public protocol AppRootProvider<Root> {
    associatedtype Root
    /// The current app root.
    var currentAppRoot: Root { get }
}
