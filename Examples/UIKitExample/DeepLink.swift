import UIKit
import AppRootUIKit

/// Turns a link into a root and the screens above it. The app owns the URL format;
/// AppRootUIKit only navigates. Custom-scheme links and universal links share the routes:
///
///   approot-uikit://details/3     https://example.com/details/3     home → details 1 → 2 → 3
///   approot-uikit://home          https://example.com/home          home
///
/// `SceneDelegate` passes custom-scheme links (URL contexts) and universal links (web
/// browsing user activities) here. Universal links also need the Associated Domains
/// entitlement and an apple-app-site-association file (see the README).
///
/// Try a custom-scheme link: xcrun simctl openurl booted approot-uikit://details/3
enum DeepLink {
    /// Your associated domain (`applinks:example.com`).
    static let universalLinkHost = "example.com"

    /// The link's route as path segments, or `nil` if the link isn't ours.
    /// `approot-uikit://details/3` and `https://example.com/details/3` both give
    /// `["details", "3"]`.
    static func route(of url: URL) -> [String]? {
        let path = url.pathComponents.filter { $0 != "/" }
        switch url.scheme {
        case "approot-uikit":
            return [url.host].compactMap { $0 } + path
        case "https" where url.host == universalLinkHost:
            return path
        default:
            return nil
        }
    }

    @MainActor
    static func open(_ url: URL, in navigation: AppRootNavigationController) {
        guard let route = route(of: url) else { return }

        // The app decides who may follow a link: logged-out users land on onboarding or login.
        guard Session.didFinishOnboarding else { return navigation.setRoot(AppFlow.onboarding) }
        guard Session.isLoggedIn else { return navigation.setRoot(AppFlow.login) }

        switch route.first {
        case "details":
            let depth = max(1, Int(route.dropFirst().first ?? "") ?? 1)
            navigation.setRoot(AppFlow.home, pushing: (1...depth).map { DetailViewController(depth: $0) })
        default:
            navigation.setRoot(AppFlow.home)
        }
    }
}
