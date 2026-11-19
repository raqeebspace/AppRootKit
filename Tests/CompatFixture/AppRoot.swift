import UIKit
import AppRootNavigation

// An app module that followed the 1.0.0 README: its own `AppRoot` enum, declared
// outside the module that uses it. Used by CrossModuleCompatibilityTests.
@available(*, deprecated)
public enum AppRoot: AppRootFlow {
    case home
    public var key: String { "home" }
    public var isVisited: Bool { false }
    public var contentController: UIViewController { MainActor.assumeIsolated { UIViewController() } }
    public var transition: CATransition? { nil }
}
