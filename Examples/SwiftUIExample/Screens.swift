import SwiftUI
import AppRootKit

struct OnboardingView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        ActionScreen(title: "Welcome", color: .indigo,
                     message: "The first root. Shown until onboarding is finished.") {
            Button("Get started") {
                Session.didFinishOnboarding = true
                router.setRoot(.login)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        ActionScreen(title: "Log in", color: .teal,
                     message: "Switching here uses the default push from the right.") {
            Button("Log in") {
                Session.isLoggedIn = true
                router.setRoot(.home) // home fades in
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        ActionScreen(title: "Settings", color: .orange, message: "A pushed screen.") {
            Button("Push profile") { router.push(.profile(name: "Grace")) }
            Button("Pop every tab") { router.setRoot(.home) } // same root: clears all tab stacks
            Button("Log out from here") {
                Session.isLoggedIn = false
                router.setRoot(.login)
            }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>
    let name: String

    var body: some View {
        ActionScreen(title: name, color: .pink, message: "Pushed with a value: .profile(name:).") {
            Button("Pop") { router.pop() }
            Button("Pop to root") { router.popToRoot() }
        }
    }
}

/// A screen with a title, a message and a column of buttons.
struct ActionScreen<Actions: View>: View {
    let title: String
    let color: Color
    let message: String
    @ViewBuilder let actions: Actions

    var body: some View {
        VStack(spacing: 12) {
            Text(message)
                .multilineTextAlignment(.center)
            actions
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(color.opacity(0.15))
        .navigationTitle(title)
    }
}
