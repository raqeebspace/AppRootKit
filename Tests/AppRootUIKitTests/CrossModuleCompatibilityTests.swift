import XCTest
import AppRootNavigation
import CompatFixture

// A 1.x app: it still imports AppRootNavigation, so it uses the deprecated aliases.
// The 1.0.0 README told apps to declare `enum AppRoot: AppRootFlow`. When that enum lives in
// another module, a file importing both must still be able to write plain `AppRoot`: the
// library must never put a public type named `AppRoot` in scope.
@available(*, deprecated)
final class CrossModuleCompatibilityTests: XCTestCase {
    func testAppRootFromAnotherModuleNeedsNoQualifier() {
        let root: AppRoot = .home
        let flow: any AppRootFlow = root
        XCTAssertEqual(flow.key, "home")
    }
}
