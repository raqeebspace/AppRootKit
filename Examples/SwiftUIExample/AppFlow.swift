import SwiftUI
import AppRootKit

/// Every root the app can show.
enum AppFlow: AppRootFlow {
    typealias Screen = AppScreen

    case onboarding
    case login
    case home

    var contentView: some View {
        switch self {
        case .onboarding: OnboardingView()
        case .login:      LoginView()
        case .home:       MainTabView()
        }
    }

    /// Used when switching *to* this root, for both the incoming and the outgoing view.
    /// `nil` = AppRootView's default (push from the right).
    var transition: AnyTransition? {
        switch self {
        case .login:      return nil
        case .home:       return .opacity
        case .onboarding: return .push(from: .leading) // "Reset onboarding" goes back
        }
    }

    var animation: Animation? {
        self == .home ? .easeInOut(duration: 0.45) : nil
    }

    /// Home is a tab bar with one AppStack per tab, so it brings its own stacks.
    var usesNavigationStack: Bool { self != .home }
}

/// Screens that can be pushed on a root's NavigationStack.
enum AppScreen: Routable {
    case settings
    case profile(name: String)

    var contentView: some View {
        switch self {
        case .settings:           SettingsView()
        case .profile(let name):  ProfileView(name: name)
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
