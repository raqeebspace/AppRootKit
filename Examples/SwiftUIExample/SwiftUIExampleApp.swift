import SwiftUI
import AppRootKit

@main
struct SwiftUIExampleApp: App {
    // LaunchState picks onboarding, login or home from what the user has done before.
    @StateObject private var router = AppRouter(state: LaunchState())

    var body: some Scene {
        WindowGroup {
            AppRootView(router: router) // default: push from the right, 0.3 s ease-in-out
                // Custom-scheme links and universal links both arrive here.
                .onOpenURL { url in DeepLink.open(url, with: router) }
        }
    }
}
