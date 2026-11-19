//
//  AppRootNavigationController.swift
//  AppRootUIKit
//

import UIKit
import Combine

/// A UINavigationController that swaps its root view controller when the app flow changes.
final public class AppRootNavigationController: UINavigationController {

    /// Every `AppRootNavigationController` listens here, so a send reaches all windows.
    private static let rootChanges = PassthroughSubject<AppRootFlow, Never>()

    /// The 1.x way to switch roots. Sends still reach every controller.
    @available(*, deprecated, message: "Use setRoot(_:) on your AppRootNavigationController, or AppRootNavigationController.setRootInAllWindows(_:) to switch every window.")
    static public var changeAppRoot: PassthroughSubject<AppRootFlow, Never> { rootChanges }

    private var cancellable: AnyCancellable?
    private let navbarHidden: Bool

    /// Push from the right, 0.3 s, ease-in-out.
    private static var defaultTransition: CATransition {
        let transition = CATransition()
        transition.type = .push
        transition.subtype = .fromRight
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return transition
    }

    /// - Parameters:
    ///   - rootController: The initial view controller.
    ///   - isNavBarHidden: Hides the navigation bar.
    public init(
        rootController: UIViewController,
        isNavBarHidden: Bool = false
    ) {
        self.navbarHidden = isNavBarHidden
        super.init(rootViewController: rootController)
        subscribeToRootChanges()
    }

    /// Starts on whatever root `state` picks.
    public convenience init<State: AppRootProvider>(state: State, isNavBarHidden: Bool = false)
    where State.Root: AppRootFlow {
        self.init(rootController: state.currentAppRoot.contentController, isNavBarHidden: isNavBarHidden)
    }

    /// Starts on whatever root `state` picks (states returning `any AppRootFlow`).
    public convenience init<State: AppRootProvider>(state: State, isNavBarHidden: Bool = false)
    where State.Root == any AppRootFlow {
        self.init(rootController: state.currentAppRoot.contentController, isNavBarHidden: isNavBarHidden)
    }

    required init?(coder aDecoder: NSCoder) {
        self.navbarHidden = false
        super.init(coder: aDecoder)
        subscribeToRootChanges()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(navbarHidden, animated: false)
    }

    /// Switches the root of every `AppRootNavigationController` in the app (all windows),
    /// e.g. on logout. Runs on the next main run loop pass; use `setRoot(_:)` to switch one
    /// controller right away.
    public static func setRootInAllWindows(_ flow: any AppRootFlow) {
        rootChanges.send(flow)
    }

    /// Replaces the whole stack with `flow.contentController`, using `flow.transition`
    /// (or the default push from the right). Runs immediately.
    public func setRoot(_ flow: any AppRootFlow) {
        view.layer.add(flow.transition ?? Self.defaultTransition, forKey: kCATransition)
        setViewControllers([flow.contentController], animated: false)
    }

    // Subscribed in init, not viewDidLoad, so a send before the view loads isn't lost.
    private func subscribeToRootChanges() {
        cancellable = Self.rootChanges
            // ponytail: hops to main even when already there (one run-loop delay); kept because
            // existing apps may send from background threads.
            .receive(on: DispatchQueue.main)
            .sink { [weak self] flow in self?.setRoot(flow) }
    }
}
