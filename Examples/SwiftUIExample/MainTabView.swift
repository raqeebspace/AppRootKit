import SwiftUI
import AppRootKit

/// The tabs inside the `.home` root.
enum MainTab: Hashable {
    case home, explore, account

    var title: String {
        switch self {
        case .home:    "Home"
        case .explore: "Explore"
        case .account: "Account"
        }
    }

    var icon: String {
        switch self {
        case .home:    "house"
        case .explore: "safari"
        case .account: "person.crop.circle"
        }
    }
}

/// The `.home` root: a tab bar with one `AppStack` per tab.
///
/// Each tab keeps its own stack and the tab bar stays visible when pushing. `router.push`
/// acts on the selected tab's stack; switching tabs keeps each tab's pushed screens.
struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        // The router owns the selected tab, so a deep link can switch tabs.
        TabView(selection: router.stackSelection(default: MainTab.home)) {
            AppStack(router: router, id: MainTab.home) { HomeTab() }
                .tabItem { Label(MainTab.home.title, systemImage: MainTab.home.icon) }
                .tag(MainTab.home)
            AppStack(router: router, id: MainTab.explore) { ExploreTab() }
                .tabItem { Label(MainTab.explore.title, systemImage: MainTab.explore.icon) }
                .tag(MainTab.explore)
            AppStack(router: router, id: MainTab.account) { AccountTab() }
                .tabItem { Label(MainTab.account.title, systemImage: MainTab.account.icon) }
                .tag(MainTab.account)
        }
    }
}

struct HomeTab: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        ActionScreen(title: "Home", color: .green,
                     message: "Push a few screens, switch tabs and come back: each tab keeps its own stack.") {
            Button("Settings") { router.push(.settings) }
            Button("Profile") { router.push(.profile(name: "Ada")) }
        }
    }
}

struct ExploreTab: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>
    private let people = ["Ada", "Grace", "Alan", "Katherine"]

    var body: some View {
        List(people, id: \.self) { name in
            Button(name) { router.push(.profile(name: name)) }
        }
        .navigationTitle("Explore")
    }
}

struct AccountTab: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        ActionScreen(title: "Account", color: .purple, message: "Switching roots from inside a tab replaces the whole tab bar.") {
            Button("Settings") { router.push(.settings) }
            Button("Log out") {
                Session.isLoggedIn = false
                router.setRoot(.login)
            }
            Button("Reset onboarding") {
                Session.didFinishOnboarding = false
                Session.isLoggedIn = false
                router.setRoot(.onboarding) // slides in from the left
            }
        }
    }
}

#Preview {
    AppRootView(router: AppRouter(root: AppFlow.home))
}
