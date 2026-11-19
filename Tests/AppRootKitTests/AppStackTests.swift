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
    case tabs
    var usesNavigationStack: Bool { false }
    var contentView: some View { Tabs() }
}

@available(iOS 16.0, *)
private struct Tabs: View {
    @EnvironmentObject var router: AppRouter<TabRoot>

    var body: some View {
        TabView {
            AppStack(router: router, id: "red") { Color.red.ignoresSafeArea() }
                .tabItem { Text("Red") }
            AppStack(router: router, id: "blue") { Color.blue.ignoresSafeArea() }
                .tabItem { Text("Blue") }
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
