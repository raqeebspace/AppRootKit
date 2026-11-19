//
//  AppStack.swift
//  AppRootKit
//

import SwiftUI

/// A `NavigationStack` with its own path in the router, for roots that bring their own
/// stacks (`usesNavigationStack = false`), e.g. one per tab so the tab bar stays visible.
///
/// While it is on screen, `router.push` / `pop` / `popToRoot` act on it.
///
/// ```swift
/// TabView {
///     AppStack(router: router, id: Tab.home) { HomeTab() }
///         .tabItem { Label("Home", systemImage: "house") }
/// }
/// ```
@available(iOS 16.0, *)
public struct AppStack<Root: AppRootFlow, Content: View>: View {

    @ObservedObject private var router: AppRouter<Root>
    @Environment(\.appRootIsLeaving) private var isLeaving

    private let id: AnyHashable
    private let content: Content

    public init<ID: Hashable>(
        router: AppRouter<Root>,
        id: ID,
        @ViewBuilder content: () -> Content
    ) {
        self.router = router
        self.id = AnyHashable(id)
        self.content = content()
    }

    public var body: some View {
        NavigationStack(path: router.binding(forStack: id, leaving: isLeaving)) {
            content
                .navigationDestination(for: Root.Screen.self) { $0.contentView }
        }
        // Tab views appear when their tab is selected, so this tracks the visible stack.
        .onAppear { if !isLeaving { router.activateStack(id) } }
    }
}

private struct AppRootIsLeavingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// `true` inside a root that is animating out after `setRoot`.
    var appRootIsLeaving: Bool {
        get { self[AppRootIsLeavingKey.self] }
        set { self[AppRootIsLeavingKey.self] = newValue }
    }
}
