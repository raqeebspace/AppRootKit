import UIKit
import AppRootUIKit

/// Every root the app can show.
enum AppFlow: AppRootFlow {
    case onboarding
    case login
    case home

    var contentController: UIViewController {
        switch self {
        case .onboarding: OnboardingViewController()
        case .login:      LoginViewController()
        case .home:       HomeViewController()
        }
    }

    /// The animation used when switching *to* this root. `nil` = push from the right.
    var transition: CATransition? {
        switch self {
        case .login:
            return nil
        case .home:
            let fade = CATransition()
            fade.type = .fade
            fade.duration = 0.35
            return fade
        case .onboarding:
            // "Reset onboarding" goes back to the start, so slide in from the left.
            let back = CATransition()
            back.type = .push
            back.subtype = .fromLeft
            back.duration = 0.3
            back.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            return back
        }
    }
}

/// Picks the first root at launch.
struct LaunchState: AppRootProvider {
    var currentAppRoot: AppFlow {
        guard Session.didFinishOnboarding else { return .onboarding }
        return Session.isLoggedIn ? .home : .login
    }
}

/// What the app remembers between launches.
enum Session {
    static var didFinishOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "didFinishOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "didFinishOnboarding") }
    }

    static var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "isLoggedIn") }
        set { UserDefaults.standard.set(newValue, forKey: "isLoggedIn") }
    }
}
