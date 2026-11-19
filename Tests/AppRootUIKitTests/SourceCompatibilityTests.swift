import XCTest
import UIKit
import AppRootNavigation

// Mirrors 1.x usage (1.0.0 README, 1.1.4 API): an app enum named `AppRoot` conforming to
// `AppRootFlow`, and an `AppRootState` that returns `any AppRootFlow` and is passed around
// as a plain protocol type. If this stops compiling, existing apps break. `AppRootState` is
// deprecated, so this file is too, to keep the warnings out of the test build.
@available(*, deprecated)
private enum AppRoot: AppRootFlow {
    case home
    var key: String { "home" }
    var isVisited: Bool { false }
    var contentController: UIViewController { MainActor.assumeIsolated { UIViewController() } }
    var transition: CATransition? { nil }
}

@available(*, deprecated)
private final class OldAppRootState: AppRootState {
    var currentAppRoot: AppRootFlow { AppRoot.home }
}

@available(*, deprecated)
@MainActor
private func makeRoot(from state: AppRootState) -> UIViewController {
    AppRootNavigationController(rootController: state.currentAppRoot.contentController)
}

@available(*, deprecated)
final class SourceCompatibilityTests: XCTestCase {
    /// 1.x apps switched roots by sending on the static subject.
    @MainActor
    func testChangeAppRootSubjectStillSwitchesRoots() {
        let nav = AppRootNavigationController(rootController: UIViewController())
        AppRootNavigationController.changeAppRoot.send(AppRoot.home)
        let done = expectation(description: "root changed")
        DispatchQueue.main.async {
            XCTAssertEqual(nav.viewControllers.count, 1)
            XCTAssertFalse(nav.viewControllers.first is AppRootNavigationController)
            done.fulfill()
        }
        wait(for: [done], timeout: 1)
    }

    @MainActor
    func testOldNamesStillCompile() {
        let state: AppRootState = OldAppRootState()
        XCTAssertEqual(state.currentAppRoot.key, "home")
        XCTAssertTrue(makeRoot(from: state) is AppRootNavigationController)
    }
}
