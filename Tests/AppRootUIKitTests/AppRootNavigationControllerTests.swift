import XCTest
import UIKit
import AppRootUIKit

// Only `contentController` is required now.
private enum Flow: AppRootFlow {
    case onboarding, home
    var contentController: UIViewController {
        let title = self.key
        return MainActor.assumeIsolated {
            let vc = UIViewController()
            vc.title = title
            return vc
        }
    }
}

private struct HomeState: AppRootProvider {
    var currentAppRoot: Flow { .home }
}

private struct ExistentialState: AppRootProvider {
    var currentAppRoot: any AppRootFlow { Flow.onboarding }
}

@MainActor
final class AppRootNavigationControllerTests: XCTestCase {
    func testDefaults() {
        XCTAssertEqual(Flow.home.key, "home")
        XCTAssertFalse(Flow.home.isVisited)
        XCTAssertNil(Flow.home.transition)
    }

    func testInitFromState() {
        XCTAssertEqual(AppRootNavigationController(state: HomeState()).viewControllers.first?.title, "home")
        XCTAssertEqual(AppRootNavigationController(state: ExistentialState()).viewControllers.first?.title, "onboarding")
    }

    /// The migration path for 1.x code that stored a plain `AppRootState`.
    func testProviderAsExistential() {
        let provider: any AppRootProvider<any AppRootFlow> = ExistentialState()
        XCTAssertEqual(provider.currentAppRoot.key, "onboarding")
    }

    func testSetRootPushingLandsOnDeepLinkedScreen() {
        let nav = AppRootNavigationController(rootController: UIViewController())
        let detail = UIViewController()
        detail.title = "detail"
        nav.setRoot(Flow.home, pushing: [detail])
        XCTAssertEqual(nav.viewControllers.map(\.title), ["home", "detail"])
    }

    func testSetRootReplacesStack() {
        let nav = AppRootNavigationController(rootController: UIViewController())
        nav.pushViewController(UIViewController(), animated: false)
        nav.setRoot(Flow.home)
        XCTAssertEqual(nav.viewControllers.map(\.title), ["home"])
    }

    func testSetRootInAllWindowsWorksBeforeViewLoads() {
        let nav = AppRootNavigationController(rootController: UIViewController())
        AppRootNavigationController.setRootInAllWindows(Flow.home)
        let done = expectation(description: "root changed")
        DispatchQueue.main.async {
            XCTAssertEqual(nav.viewControllers.map(\.title), ["home"])
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
    }
}
