//
//  AppRootFlow.swift
//  AppRootKit
//

import SwiftUI
@_exported import AppRootCore

/// A SwiftUI app root: an `AppRootRepresentable` that knows its view and the screens it can push.
///
/// Usually an enum. Keep it small: it only models *which root* the user sees.
public protocol AppRootFlow: AppRootRepresentable, Hashable {
    associatedtype Content: View
    /// Screens pushable on this root's `NavigationStack`. Leave as `Never` when nothing is pushed.
    associatedtype Screen: Routable = Never
    /// The root view for this state.
    @MainActor @ViewBuilder var contentView: Content { get }
    /// Transition used when switching *to* this root: its insertion moves this root in, its
    /// removal moves the leaving root out. `nil` (default) uses `AppRootView`'s `transition`.
    @MainActor var transition: AnyTransition? { get }
    /// Animation used when switching *to* this root, for both sides.
    /// `nil` (default) uses `AppRootView`'s `animation`.
    @MainActor var animation: Animation? { get }
    /// `true` (default): `AppRootView` wraps the root in a `NavigationStack` on `router.path`.
    /// `false`: the root places its own `AppStack`s, e.g. one per tab of a `TabView`.
    var usesNavigationStack: Bool { get }
}

public extension AppRootFlow {
    var transition: AnyTransition? { nil }
    var animation: Animation? { nil }
    var usesNavigationStack: Bool { true }
}
