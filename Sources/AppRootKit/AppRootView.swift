//
//  AppRootView.swift
//  AppRootKit
//

import SwiftUI

/// Shows `router.root` in a `NavigationStack`, animates root changes, and pushes
/// `Root.Screen` values via `Routable.contentView`.
///
/// Injects the `AppRouter<Root>` as an environment object.
@available(iOS 16.0, *)
public struct AppRootView<Root: AppRootFlow>: View {

    @ObservedObject private var router: AppRouter<Root>

    private let transition: AnyTransition
    private let animation: Animation

    /// The root on screen. Trails `router.root` by one view update during a root change.
    @State private var shownRoot: Root
    /// Transition attached to the root on screen. Set to the destination's before the swap.
    @State private var activeTransition: AnyTransition
    /// Set in step 1 of a root change, consumed in step 2.
    @State private var pendingRoot: Root?

    public init(
        router: AppRouter<Root>,
        transition: AnyTransition = .push(from: .trailing),
        animation: Animation = .easeInOut(duration: 0.3)
    ) {
        self.router = router
        self.transition = transition
        self.animation = animation
        _shownRoot = State(initialValue: router.root)
        _activeTransition = State(initialValue: router.root.transition ?? transition)
    }

    public var body: some View {
        ZStack {
            rootContent
                // A leaving root's stacks show their frozen copies instead of popping first.
                .environment(\.appRootIsLeaving, shownRoot != router.root)
                // New identity per root value so the transition runs on root change.
                .id(shownRoot)
                .transition(activeTransition)
        }
        .environmentObject(router)
        // A root change takes two view updates, so the destination's transition drives both
        // sides (like UIKit). SwiftUI removes a view with the transition from its *last*
        // update, so the leaving root must first be drawn once with the new transition.
        //
        // Step 1, inside `setRoot` (willSet of `root`).
        .onReceive(router.$root.dropFirst()) { newRoot in
            guard newRoot != shownRoot else { return } // same root: the router pops the stacks
            activeTransition = newRoot.transition ?? transition
            pendingRoot = newRoot
        }
        // Step 2, right after the update that redrew the leaving root: swap.
        .onChange(of: pendingRoot) { newRoot in
            guard let newRoot else { return }
            pendingRoot = nil
            withAnimation(newRoot.animation ?? animation) { shownRoot = newRoot }
        }
    }

    @ViewBuilder private var rootContent: some View {
        if shownRoot.usesNavigationStack {
            NavigationStack(path: path(for: shownRoot)) {
                shownRoot.contentView
                    .navigationDestination(for: Root.Screen.self) { $0.contentView }
            }
        } else {
            shownRoot.contentView // places its own AppStacks
        }
    }

    /// The current root edits the router's stack; the leaving root shows its frozen one.
    private func path(for root: Root) -> Binding<[Root.Screen]> {
        Binding(
            get: { root == router.root ? router.path : router.leavingPath },
            set: { if root == router.root { router.path = $0 } }
        )
    }
}
