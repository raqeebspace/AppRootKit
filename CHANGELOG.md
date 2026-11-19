# Changelog

All notable changes to AppRootKit. Versions follow [Semantic Versioning](https://semver.org).

## [1.2.0] - 2026-11-19

AppRootNavigation is now **AppRootKit**: one package with a UIKit library and a new SwiftUI
library. **Your 1.x code keeps building.** Old names still work and show a deprecation warning
with the fix.

### Added

#### SwiftUI library `AppRootKit` (iOS 16+)
- `AppRouter` holds the current root and its navigation stack. `AppRootView` shows it,
  animates root changes, and puts the router in the environment.
- Typed navigation: `push`, `pop`, `popToRoot`, `setRoot`. `setRoot` with the current root
  pops back to it.
- **Tab bars**: `AppStack` gives each tab its own stack, so the tab bar stays visible when
  you push. `push` acts on the selected tab.
- **Transitions**: set app-wide defaults on `AppRootView`, or override `transition` and
  `animation` per root. The root you switch **to** drives both sides, as in UIKit.
- **Deep links and universal links**: `open(_:path:)` and `open(_:stack:path:)` land on any
  root, tab and screen stack in one call. `stackSelection(default:)` lets a link switch tabs.

#### UIKit library `AppRootUIKit` (iOS 13+), the new name of `AppRootNavigation`
- `setRoot(_:)` switches the root of a controller right away.
- `setRoot(_:pushing:)` lands on screens above the root in one step, e.g. from a deep link.
- `setRootInAllWindows(_:)` switches every window, e.g. on logout.
- `AppRootNavigationController(state:)` starts from your launch logic.
- Only `contentController` is required. `key`, `isVisited` and `transition` have defaults.

#### Shared
- `AppRootProvider` picks the first root. `currentAppRoot` can return your own root type.

#### Example apps
- `Examples/Examples.xcworkspace` has a UIKit app and a SwiftUI app with the same flow:
  onboarding, login, a tab bar with one stack per tab, per-root transitions and deep links.

### Fixed
- A root change sent before the navigation controller loaded its view was lost. The controller
  now listens from `init`.

### Deprecated

| 1.x | Use instead |
|---|---|
| `import AppRootNavigation` / product `AppRootNavigation` | `import AppRootUIKit` / product `AppRootUIKit` |
| `AppRootState` | `AppRootProvider` |
| `AppRootNavigationController.changeAppRoot.send(_:)` | `setRoot(_:)` or `setRootInAllWindows(_:)` |

The deprecated names may be removed in a future major version.

> If your target treats warnings as errors, the deprecation warnings stop the build. Migrate in
> the same change as the update, or disable warnings-as-errors until you finish.

### Migrating from 1.x

1. Update to `1.2.0` and replace the `AppRootNavigation` library with `AppRootUIKit`.
2. Change `import AppRootNavigation` to `import AppRootUIKit`.
3. Change `AppRootState` to `AppRootProvider`. The body stays the same.
4. Replace `changeAppRoot.send(...)` with `setRoot(_:)` or `setRootInAllWindows(_:)`.

The full guide, with before/after code, is in the [README](README.md#-migrating-from-1x).

### Installation

The repository moved to `raqeebspace/AppRootKit`. GitHub redirects the old URL.

```swift
.package(url: "https://github.com/raqeebspace/AppRootKit.git", from: "1.2.0"),

.product(name: "AppRootUIKit", package: "AppRootKit"), // UIKit
.product(name: "AppRootKit", package: "AppRootKit"),   // SwiftUI
```

When you switch to the new URL, also change `package:` to `"AppRootKit"`.

**Requirements:** Xcode 16 or later (Swift 6 toolchain). iOS 13 for `AppRootUIKit`, iOS 16 for
`AppRootView` and `AppStack`.

[1.2.0]: https://github.com/raqeebspace/AppRootKit/releases/tag/1.2.0
