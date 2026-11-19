import Foundation
import AppRootKit

/// Turns a link into a root, a tab and screens. The app owns the URL format;
/// AppRootKit only navigates. Custom-scheme links and universal links share the routes:
///
///   approot-swiftui://profile/Grace      https://example.com/profile/Grace   explore tab → Grace
///   approot-swiftui://settings           https://example.com/settings        account tab → settings
///   approot-swiftui://explore            https://example.com/explore         explore tab
///   approot-swiftui://home               https://example.com/home            home tab
///
/// SwiftUI delivers both kinds to `.onOpenURL`. Universal links also need the Associated
/// Domains entitlement and an apple-app-site-association file (see the README).
///
/// Try a custom-scheme link: xcrun simctl openurl booted approot-swiftui://profile/Grace
enum DeepLink {
    /// Your associated domain (`applinks:example.com`).
    static let universalLinkHost = "example.com"

    /// The link's route as path segments, or `nil` if the link isn't ours.
    /// `approot-swiftui://profile/Grace` and `https://example.com/profile/Grace` both give
    /// `["profile", "Grace"]`.
    static func route(of url: URL) -> [String]? {
        let path = url.pathComponents.filter { $0 != "/" }
        switch url.scheme {
        case "approot-swiftui":
            return [url.host].compactMap { $0 } + path
        case "https" where url.host == universalLinkHost:
            return path
        default:
            return nil
        }
    }

    @MainActor
    static func open(_ url: URL, with router: AppRouter<AppFlow>) {
        guard let route = route(of: url) else { return }

        // The app decides who may follow a link: logged-out users land on onboarding or login.
        guard Session.didFinishOnboarding else { return router.setRoot(.onboarding) }
        guard Session.isLoggedIn else { return router.setRoot(.login) }

        switch route.first {
        case "explore":
            router.open(.home, stack: MainTab.explore)
        case "profile":
            let name = route.dropFirst().first ?? "Ada"
            router.open(.home, stack: MainTab.explore, path: [.profile(name: name)])
        case "settings":
            router.open(.home, stack: MainTab.account, path: [.settings])
        default:
            router.open(.home, stack: MainTab.home)
        }
    }
}
