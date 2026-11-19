//
//  AppRouter.swift
//  AppRootKit
//

import SwiftUI

/// The current app root and its navigation stacks, in one object.
///
/// A root shows either its own stack (`path`) or, when it sets `usesNavigationStack = false`,
/// any number of `AppStack`s (e.g. one per tab), each with its own path.
///
/// `AppRootView` injects it with `.environmentObject`; read it as
/// `@EnvironmentObject var router: AppRouter<Root>`.
@MainActor
public final class AppRouter<Root: AppRootFlow>: ObservableObject {

    /// Change it only through `setRoot(_:)`, so the stacks are always cleared with it.
    @Published public private(set) var root: Root

    /// The root's own stack, shown when `root.usesNavigationStack` is `true`.
    @Published public var path: [Root.Screen] = []

    /// The `AppStack` that `push` / `pop` / `popToRoot` act on; `nil` means `path`.
    /// An `AppStack` activates itself when it appears (e.g. when its tab is selected).
    @Published public private(set) var activeStack: AnyHashable?

    /// Paths of the `AppStack`s, by id.
    @Published private var stacks: [AnyHashable: [Root.Screen]] = [:]

    /// What the leaving root shows while it animates out, so it doesn't pop first.
    private(set) var leavingPath: [Root.Screen] = []
    private(set) var leavingStacks: [AnyHashable: [Root.Screen]] = [:]

    public init(root: Root) {
        self.root = root
    }

    /// Starts on whatever root `state` picks.
    public convenience init<State: AppRootProvider>(state: State) where State.Root == Root {
        self.init(root: state.currentAppRoot)
    }

    /// Switches the app root and clears every stack, also when `newRoot` equals the current
    /// root (`home → push details → setRoot(.home)` pops back to home, on every tab).
    public func setRoot(_ newRoot: Root) {
        let isNewRoot = newRoot != root
        if isNewRoot {
            leavingPath = path
            leavingStacks = stacks
        }
        root = newRoot
        // Clear without animation, so only the root transition animates.
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            path.removeAll()
            stacks.removeAll()
            // The same root keeps its tabs on screen, so its active stack stays.
            if isNewRoot { activeStack = nil }
        }
    }

    /// Pushes on the stack on screen: the active `AppStack`, or `path`.
    public func push(_ screen: Root.Screen) {
        updateCurrentStack { $0.append(screen) }
    }

    public func pop() {
        updateCurrentStack { if !$0.isEmpty { $0.removeLast() } }
    }

    public func popToRoot() {
        updateCurrentStack { $0.removeAll() }
    }

    /// The path of the `AppStack` with this id.
    public func path<ID: Hashable>(for stack: ID) -> [Root.Screen] {
        stacks[AnyHashable(stack)] ?? []
    }

    /// Makes `push` / `pop` / `popToRoot` act on this `AppStack`. `AppStack` calls it when it
    /// appears; call it yourself when you switch tabs and push in the same action.
    public func activateStack<ID: Hashable>(_ stack: ID) {
        let id = AnyHashable(stack)
        if activeStack != id { activeStack = id }
    }

    /// Binding for an `AppStack`; a leaving root reads its frozen copy.
    func binding(forStack id: AnyHashable, leaving: Bool) -> Binding<[Root.Screen]> {
        Binding(
            get: { (leaving ? self.leavingStacks[id] : self.stacks[id]) ?? [] },
            set: { if !leaving { self.stacks[id] = $0 } }
        )
    }

    private func updateCurrentStack(_ change: (inout [Root.Screen]) -> Void) {
        if let id = activeStack {
            change(&stacks[id, default: []])
        } else {
            change(&path)
        }
    }
}
