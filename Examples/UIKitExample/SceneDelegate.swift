import UIKit
import AppRootUIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // LaunchState picks onboarding, login or home from what the user has done before.
        let navigation = AppRootNavigationController(state: LaunchState())

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window

        // A link that launched the app: a custom-scheme URL or a universal link.
        let launchURL = connectionOptions.urlContexts.first?.url
            ?? connectionOptions.userActivities.first { $0.activityType == NSUserActivityTypeBrowsingWeb }?.webpageURL
        if let launchURL {
            DeepLink.open(launchURL, in: navigation)
        }
    }

    /// A universal link while the app is running.
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              let navigation = window?.rootViewController as? AppRootNavigationController else { return }
        DeepLink.open(url, in: navigation)
    }

    /// A custom-scheme link while the app is running.
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let navigation = window?.rootViewController as? AppRootNavigationController else { return }
        DeepLink.open(url, in: navigation)
    }
}
