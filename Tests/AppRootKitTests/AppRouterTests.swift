import XCTest
import SwiftUI
@testable import AppRootKit

private enum Screen: Routable {
    case a, b
    var contentView: some View { EmptyView() }
}

private enum Root: AppRootFlow {
    typealias Screen = AppRootKitTests.Screen
    case onboarding, home
    var contentView: some View { EmptyView() }
}

// A root that pushes nothing compiles without declaring `Screen`.
private enum Splash: AppRootFlow {
    case splash
    var contentView: some View { EmptyView() }
}

private enum Login: AppRootFlow {
    case login
    var contentView: some View { EmptyView() }
    var transition: AnyTransition? { .move(edge: .leading) }
    var animation: Animation? { .spring() }
}

private struct VisitedState: AppRootProvider {
    var currentAppRoot: Root { .home }
}

final class AppRouterTests: XCTestCase {
    @MainActor
    func testInitFromAppRootProvider() {
        XCTAssertEqual(AppRouter(state: VisitedState()).root, .home)
    }

    @MainActor
    func testPushPop() {
        let router = AppRouter(root: Root.home)
        router.push(.a); router.push(.b)
        XCTAssertEqual(router.path, [.a, .b])
        router.pop()
        XCTAssertEqual(router.path, [.a])
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
        router.pop() // empty pop is a no-op, not a crash
        XCTAssertTrue(router.path.isEmpty)
    }

    @MainActor
    func testSetRootClearsStackEvenForSameRoot() {
        let router = AppRouter(root: Root.onboarding)
        router.push(.a)
        router.setRoot(.home)
        XCTAssertEqual(router.root, .home)
        XCTAssertTrue(router.path.isEmpty)
        router.push(.b)
        router.setRoot(.home)
        XCTAssertTrue(router.path.isEmpty)
    }

    @MainActor
    func testRootWithoutScreens() {
        XCTAssertTrue(AppRouter(root: Splash.splash).path.isEmpty)
    }

    @MainActor
    func testPushGoesToActiveStack() {
        let router = AppRouter(root: Root.home)
        router.activateStack("feed")
        router.push(.a)
        router.activateStack("account")
        router.push(.b); router.push(.a)
        router.pop()
        XCTAssertEqual(router.path(for: "feed"), [.a])
        XCTAssertEqual(router.path(for: "account"), [.b])
        XCTAssertTrue(router.path.isEmpty) // the root's own stack is untouched
        router.popToRoot()
        XCTAssertTrue(router.path(for: "account").isEmpty)
        XCTAssertEqual(router.path(for: "feed"), [.a])
    }

    @MainActor
    func testSetRootClearsEveryStack() {
        let router = AppRouter(root: Root.home)
        router.activateStack("feed")
        router.push(.a)
        // Same root: tabs stay on screen, so the active stack is kept.
        router.setRoot(.home)
        XCTAssertTrue(router.path(for: "feed").isEmpty)
        XCTAssertEqual(router.activeStack, AnyHashable("feed"))
        // New root: back to the root's own stack until its AppStacks appear.
        router.push(.b)
        router.setRoot(.onboarding)
        XCTAssertTrue(router.path(for: "feed").isEmpty)
        XCTAssertNil(router.activeStack)
        router.push(.a)
        XCTAssertEqual(router.path, [.a])
    }

    @MainActor
    func testPerRootTransitionAndAnimation() {
        XCTAssertNil(Root.home.transition)       // default: AppRootView's transition
        XCTAssertNil(Root.home.animation)        // default: AppRootView's animation
        XCTAssertNotNil(Login.login.transition)
        XCTAssertNotNil(Login.login.animation)
    }
}
