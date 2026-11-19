import XCTest
import SwiftUI
import UIKit
@testable import AppRootKit

@available(iOS 16.0, *)
private enum ColorRoot: AppRootFlow {
    case home, login
    var contentView: some View { (self == .home ? Color.blue : Color.red).ignoresSafeArea() }
    var transition: AnyTransition? { self == .login ? .push(from: .leading) : nil }
}

@available(iOS 16.0, *)
final class RootTransitionTests: XCTestCase {
    /// home uses the default push from trailing, login pushes from leading. Switching to
    /// login must use login's transition for *both* views: login comes in on the left while
    /// home leaves on the right. Before the fix, home left with its own removal (toward the
    /// left), so both views overlapped on the left half and the right half was empty.
    @MainActor
    func testDestinationTransitionDrivesBothSides() {
        let router = AppRouter(root: ColorRoot.home)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        window.rootViewController = UIHostingController(rootView:
            AppRootView(router: router, animation: .linear(duration: 2)))
        window.makeKeyAndVisible()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        router.setRoot(.login)
        RunLoop.main.run(until: Date().addingTimeInterval(1)) // halfway

        let left = color(in: window, at: CGPoint(x: 50, y: 50))
        let right = color(in: window, at: CGPoint(x: 150, y: 50))
        XCTAssertGreaterThan(left.red, left.blue, "login should be entering on the left")
        XCTAssertGreaterThan(right.blue, right.red, "home should be leaving on the right")
    }

    @MainActor
    private func color(in window: UIWindow, at point: CGPoint) -> (red: UInt8, blue: UInt8) {
        var pixel = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.translateBy(x: -point.x, y: point.y - window.bounds.height + 1)
        // Render the layer tree: SwiftUI updates it per animation frame, and the test
        // runner has no on-screen window for drawHierarchy.
        window.layer.render(in: context)
        return (pixel[0], pixel[2])
    }
}
