import XCTest
import SwiftUI
import UIKit
@testable import AppRootKit

@available(iOS 16.0, *)
private enum ColorScreen: Routable {
    case green
    var contentView: some View { Color.green.ignoresSafeArea() }
}

@available(iOS 16.0, *)
private enum TabRoot: AppRootFlow {
    typealias Screen = ColorScreen
    case start, tabs
    var usesNavigationStack: Bool { self != .tabs }
    @ViewBuilder var contentView: some View {
        if self == .tabs { Tabs() } else { Color.yellow.ignoresSafeArea() }
    }
}

@available(iOS 16.0, *)
private struct Tabs: View {
    @EnvironmentObject var router: AppRouter<TabRoot>

    var body: some View {
        TabView(selection: router.stackSelection(default: "red")) {
            AppStack(router: router, id: "red") { Color.red.ignoresSafeArea() }
                .tabItem { Text("Red") }
                .tag("red")
            AppStack(router: router, id: "blue") { Color.blue.ignoresSafeArea() }
                .tabItem { Text("Blue") }
                .tag("blue")
        }
    }
}

@available(iOS 16.0, *)
final class AppStackTests: XCTestCase {
    /// The selected tab's AppStack activates itself, so `router.push` lands on that tab's
    /// own stack, which shows the pushed screen.
    @MainActor
    func testSelectedTabStackReceivesPushes() {
        let router = AppRouter(root: TabRoot.tabs)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        window.rootViewController = UIHostingController(rootView: AppRootView(router: router))
        window.makeKeyAndVisible()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        XCTAssertEqual(router.activeStack, AnyHashable("red"))

        router.push(.green)
        RunLoop.main.run(until: Date().addingTimeInterval(1))

        XCTAssertEqual(router.path(for: "red"), [.green])
        XCTAssertTrue(router.path(for: "blue").isEmpty)
        XCTAssertTrue(router.path.isEmpty)
        let center = pixel(in: window, at: CGPoint(x: 100, y: 150))
        XCTAssertGreaterThan(center.green, center.red, "the pushed screen should be on screen")
    }

    /// A deep link from another root into the second tab: the tab bar must show that tab
    /// (not the first one, whose AppStack would otherwise activate itself on appear), with
    /// the deep-linked screen pushed on it.
    @MainActor
    func testDeepLinkIntoSecondTabFromAnotherRoot() {
        let router = AppRouter(root: TabRoot.start)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 400))
        window.rootViewController = UIHostingController(rootView:
            AppRootView(router: router, transition: .identity))
        window.makeKeyAndVisible()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        router.open(.tabs, stack: "blue", path: [.green])
        RunLoop.main.run(until: Date().addingTimeInterval(1))

        XCTAssertEqual(router.activeStack, AnyHashable("blue"))
        XCTAssertEqual(router.path(for: "blue"), [.green])
        XCTAssertTrue(router.path(for: "red").isEmpty)
        let center = pixel(in: window, at: CGPoint(x: 100, y: 150))
        XCTAssertGreaterThan(center.green, center.red, "the deep-linked screen should be on screen")
    }

    @MainActor
    private func pixel(in window: UIWindow, at point: CGPoint) -> (red: UInt8, green: UInt8) {
        var bytes = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &bytes, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.translateBy(x: -point.x, y: point.y - window.bounds.height + 1)
        window.layer.render(in: context)
        return (bytes[0], bytes[1])
    }
}
