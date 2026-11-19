# 🚀 AppRootKit

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20iPadOS-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

Switch your app's **root screen** (splash → onboarding → login → home) with one call and an
animated transition, in **UIKit** or **SwiftUI**.

```swift
nav.setRoot(AppFlow.home)      // UIKit
router.setRoot(.home)          // SwiftUI
```

---

## 📑 Contents

- [Features](#-features)
- [Which library do I need?](#-which-library-do-i-need)
- [Installation](#-installation)
- [How it works](#-how-it-works)
- [UIKit guide](#-uikit-guide)
- [SwiftUI guide](#-swiftui-guide)
- [Example apps](#-example-apps)
- [Using both libraries in one app](#-using-both-libraries-in-one-app)
- [API at a glance](#-api-at-a-glance)
- [Migrating from 1.x](#-migrating-from-1x)

---

## ✨ Features

- One enum describes every root your app can show.
- One call swaps the root and throws away the old navigation stack.
- Animated root transitions, with a default push and per-root overrides.
- Pick the first root from your own logic (`AppRootProvider`): "has the user finished onboarding?"
- SwiftUI: a type-safe `NavigationStack` per root, or one per tab, with `push` / `pop` / `popToRoot`.
- **Deep links and universal links**: land on any root, tab and screen stack in one call.
- No dependencies.

## 🤔 Which library do I need?

| Your app is built with | Add this product | Minimum iOS |
|---|---|---|
| UIKit (`UIViewController`, `SceneDelegate`) | `AppRootUIKit` | 13.0 |
| SwiftUI (`App`, `View`) | `AppRootKit` | 16.0 for `AppRootView` |

Both products come from the same package, so you can add one or both.

## 📦 Installation

**Requirements:** Xcode 16 or later (Swift 6 toolchain). Your app can still use the Swift 5 language mode.

### Xcode

1. **File → Add Package Dependencies…**
2. Enter `https://github.com/raqeebspace/AppRootKit.git`
3. Dependency rule: **Up to Next Major Version** from `1.2.0`.
4. Pick `AppRootUIKit`, `AppRootKit`, or both for your target.

### `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/raqeebspace/AppRootKit.git", from: "1.2.0")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "AppRootUIKit", package: "AppRootKit"), // UIKit
            .product(name: "AppRootKit", package: "AppRootKit"),   // SwiftUI
        ]
    )
]
```

## 💡 How it works

| Concept | What it is | You write |
|---|---|---|
| **Root** | One top-level place in the app: onboarding, login, home… | An enum conforming to `AppRootFlow` |
| **State** | Logic that picks the root to start on | A type conforming to `AppRootProvider` (optional) |
| **Switch** | Replace the current root, animated, clearing its stack | `setRoot(_:)` |

A root is not a single screen. It is the bottom of a navigation stack: after `setRoot(.home)`,
the user can push screens on top of home, and the next `setRoot` clears them all.

---

## 🧱 UIKit guide

### Step 1: Define your roots

You only have to implement `contentController`.

```swift
import UIKit
import AppRootUIKit

enum AppFlow: AppRootFlow {
    case onboarding
    case home

    var contentController: UIViewController {
        switch self {
        case .onboarding: OnboardingViewController()
        case .home:       HomeViewController()
        }
    }
}
```

Optional members, all with defaults:

| Member | Default | Use it for |
|---|---|---|
| `key: String` | the case name, e.g. `"onboarding"` | A stable ID, e.g. a `UserDefaults` key |
| `isVisited: Bool` | `false` | Remembering that the user has seen a root |
| `transition: CATransition?` | `nil` = push from the right, 0.3 s | A custom animation *into* this root |

### Step 2: Decide where the app starts (optional)

```swift
struct LaunchState: AppRootProvider {
    var currentAppRoot: AppFlow {
        UserDefaults.standard.bool(forKey: "didFinishOnboarding") ? .home : .onboarding
    }
}
```

### Step 3: Install it in `SceneDelegate`

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigation = AppRootNavigationController(state: LaunchState(), isNavBarHidden: true)
        // Without a state: AppRootNavigationController(rootController: AppFlow.onboarding.contentController)

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
    }
}
```

### Step 4: Switch roots

From any view controller in the stack:

```swift
final class OnboardingViewController: UIViewController {
    @objc func finishTapped() {
        UserDefaults.standard.set(true, forKey: "didFinishOnboarding")
        (navigationController as? AppRootNavigationController)?.setRoot(AppFlow.home)
    }
}
```

`setRoot` runs right away and replaces the whole stack with the new root.

To switch every window at once (for example on logout in an iPad app with several scenes):

```swift
AppRootNavigationController.setRootInAllWindows(AppFlow.onboarding)
```

### Deep links

AppRootUIKit doesn't parse URLs. Your app turns a URL into a root and screens. Pass the screens
above the root with `pushing:`, and the controller lands on them in one step:

```swift
// SceneDelegate
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url,
          let navigation = window?.rootViewController as? AppRootNavigationController else { return }

    if url.host == "profile", let id = Int(url.lastPathComponent) {
        navigation.setRoot(AppFlow.home, pushing: [ProfileViewController(id: id)])
    }
}
```

For a link that launches the app, read `connectionOptions.urlContexts` in
`scene(_:willConnectTo:options:)` and do the same. For universal links, see
[Universal links](#universal-links).

### Custom transitions

Return a `CATransition` from the root you switch **to**:

```swift
extension AppFlow {
    var transition: CATransition? {
        guard self == .home else { return nil }   // others: default push from the right
        let fade = CATransition()
        fade.type = .fade
        fade.duration = 0.25
        return fade
    }
}
```

---

## 🎨 SwiftUI guide

> `AppRootView` needs iOS 16 (`NavigationStack`). Mark the code that uses it
> `@available(iOS 16, *)` if your app supports older versions.

### Step 1: List the screens you can push

```swift
import SwiftUI
import AppRootKit

enum AppScreen: Routable {
    case settings
    case profile(id: Int)

    var contentView: some View {
        switch self {
        case .settings:         SettingsView()
        case .profile(let id):  ProfileView(id: id)
        }
    }
}
```

### Step 2: Define your roots

```swift
enum AppFlow: AppRootFlow {
    typealias Screen = AppScreen      // leave this out if you never push screens

    case onboarding
    case home

    var contentView: some View {
        switch self {
        case .onboarding: OnboardingView()
        case .home:       HomeView()
        }
    }
}
```

> Tip: don't name your enums `Root` or `Screen`. Inside a conforming type, those names refer
> to the protocol's associated types, so `Screen.settings` won't find your enum.

### Step 3: Show it from your `App`

```swift
@main
struct MyApp: App {
    @StateObject private var router = AppRouter(root: AppFlow.onboarding)
    // Or start from your logic: AppRouter(state: LaunchState())

    var body: some Scene {
        WindowGroup {
            AppRootView(router: router)
        }
    }
}
```

`AppRootView` puts the current root in a `NavigationStack`, animates root changes, and
injects the router into the environment.

### Step 4: Navigate from any view

```swift
struct HomeView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        List {
            Button("Settings") { router.push(.settings) }
            Button("Profile")  { router.push(.profile(id: 42)) }
            Button("Log out")  { router.setRoot(.onboarding) }
        }
        .navigationTitle("Home")
    }
}
```

| Call | Effect |
|---|---|
| `router.push(_:)` | Push a screen on the current root's stack |
| `router.pop()` | Pop one screen (does nothing on an empty stack) |
| `router.popToRoot()` | Pop back to the root, animated |
| `router.setRoot(_:)` | Swap the root and clear the stack. With the current root, it pops back to it instantly. |
| `router.path` | The root's own stack (`[AppScreen]`), for setting it directly, e.g. from a deep link |

### Tab bar

Give each tab its own stack with `AppStack`, so the tab bar stays visible when you push a screen.
Tell `AppRootView` not to add its own stack for that root with `usesNavigationStack`:

```swift
enum AppFlow: AppRootFlow {
    // ...
    var contentView: some View {
        switch self {
        case .onboarding: OnboardingView()
        case .home:       MainTabView()
        }
    }

    var usesNavigationStack: Bool { self != .home }   // home brings its own stacks
}

enum Tab { case home, account }

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter<AppFlow>

    var body: some View {
        TabView(selection: router.stackSelection(default: Tab.home)) {
            AppStack(router: router, id: Tab.home) { HomeTab() }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(Tab.home)
            AppStack(router: router, id: Tab.account) { AccountTab() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
                .tag(Tab.account)
        }
    }
}
```

- `router.stackSelection(default:)` lets the router own the selected tab. Tag each tab with its
  `AppStack` id. You need it for deep links into a tab.
- `router.push` / `pop` / `popToRoot` act on the **selected tab's** stack. Each `AppStack`
  activates itself when its tab appears, and each tab keeps its pushed screens when you switch.
- To switch tabs and push in one action, call `router.activateStack(Tab.account)` before `push`.
- `router.setRoot(.home)` from inside the tabs clears every tab's stack. A switch to another
  root replaces the whole tab bar, which slides out with its pushed screens.
- Read a tab's stack with `router.path(for: Tab.home)`.

### Deep links

AppRootKit doesn't parse URLs. Your app turns a URL into a root, a tab and screens. Then one
call lands there, from any root:

```swift
AppRootView(router: router)
    .onOpenURL { url in
        guard url.host == "profile", let id = Int(url.lastPathComponent) else { return }

        // A root with its own stack:
        router.open(.home, path: [.profile(id: id)])

        // A tab bar: selects the tab and sets its stack
        router.open(.home, stack: Tab.account, path: [.settings, .profile(id: id)])
    }
```

| Call | Effect |
|---|---|
| `router.open(_:path:)` | Switch to the root and set its own stack |
| `router.open(_:stack:path:)` | Switch to the root, select the `AppStack` (tab) and set its stack |
| `router.setPath(_:for:)` | Replace one tab's stack without switching roots |

For `open(_:stack:path:)` to show the right tab, bind the `TabView` with
`router.stackSelection(default:)` (see **Tab bar**). Decide in your own code what a logged-out
user sees, before you call `open`.

### Universal links

A universal link (`https://example.com/profile/42`) uses the same router calls as a custom
scheme. Only the delivery and the parsing change.

**1. Let iOS open your app for your domain.** This needs a paid Apple Developer account.

- In Xcode, open **Signing & Capabilities**, add **Associated Domains**, and add
  `applinks:example.com`.
- Serve this file at `https://example.com/.well-known/apple-app-site-association`, as JSON,
  over HTTPS, with no redirect:

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["TEAMID.com.example.MyApp"],
        "components": [{ "/": "/profile/*" }, { "/": "/settings" }]
      }
    ]
  }
}
```

**2. Receive the link.**

| | App running | App launched by the link |
|---|---|---|
| SwiftUI | `.onOpenURL` (the same one as custom schemes) | `.onOpenURL` |
| UIKit | `scene(_:continue:)` | `connectionOptions.userActivities` in `scene(_:willConnectTo:options:)` |

```swift
// UIKit: SceneDelegate
func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL,
          let navigation = window?.rootViewController as? AppRootNavigationController else { return }
    DeepLink.open(url, in: navigation)
}
```

**3. Read the route from the path.** In a universal link, `url.host` is your domain, so the
route is in `url.pathComponents`. Check the host before you trust a link. One function can
serve both kinds:

```swift
static func route(of url: URL) -> [String]? {
    let path = url.pathComponents.filter { $0 != "/" }
    switch url.scheme {
    case "myapp":                                  // myapp://profile/42
        return [url.host].compactMap { $0 } + path
    case "https" where url.host == "example.com":  // https://example.com/profile/42
        return path
    default:
        return nil                                 // not our link
    }
}
```

Both example apps do this in `DeepLink.swift`. Set `universalLinkHost` to your domain and add
the entitlement to try universal links. Custom-scheme links work without any setup.

### Transitions and animations

Set app-wide defaults on `AppRootView`:

```swift
AppRootView(
    router: router,
    transition: .opacity,                                     // default: .push(from: .trailing)
    animation: .spring(response: 0.4, dampingFraction: 0.85)  // default: .easeInOut(duration: 0.3)
)
```

Or override them per root. `nil` (the default) uses `AppRootView`'s values:

```swift
extension AppFlow {
    // Going back to onboarding (e.g. logout) slides in from the left.
    var transition: AnyTransition? {
        self == .onboarding ? .push(from: .leading) : nil
    }

    var animation: Animation? {
        self == .home ? .spring() : nil
    }
}
```

Both values come from the root you switch **to**, as in the UIKit library. Its `transition` moves
the new root in (insertion) *and* the old root out (removal). Its `animation` times both.
In the example above, logout slides onboarding in from the left while home leaves to the right.
Login uses the default push from the right.

> Pick transitions whose insertion and removal go opposite ways, like `.push(from:)`, or use
> `.asymmetric(insertion:removal:)`. A plain `.move(edge: .leading)` would move the new root in
> from the left *and* the old root out to the left, so they'd overlap.

The old root keeps showing its pushed screens while it slides out. `router.path` is already
empty for the new root as soon as `setRoot` returns.

---

## 🧪 Example apps

`Examples/` has a UIKit app and a SwiftUI app with the same flow, both using
this package from the local checkout:

```
onboarding ──Get started──▶ login ──Log in──▶ home (tabs) ──push──▶ details / settings / profile
    ▲                         ▲                 │
    └──── Reset onboarding ───┼─────────────────┤
                              └──── Log out ────┘
```

| Target | Shows |
|---|---|
| `UIKitExample` | `AppRootNavigationController(state:)` in `SceneDelegate`, `setRoot`, `setRootInAllWindows` on logout, a fade and a push-from-left `CATransition`, deep links and universal links with `setRoot(_:pushing:)` |
| `SwiftUIExample` | `AppRouter(state:)` + `AppRootView`, a tab bar with one stack per tab as the home root, typed `push` / `pop` / `popToRoot`, `setRoot` from deep in a stack, per-root transition and animation, deep links and universal links into a tab with `open(_:stack:path:)` |

Open **`Examples/Examples.xcworkspace`** (not the `.xcodeproj` or `Package.swift`), pick a scheme,
and run. The workspace holds the package and both apps in one window, so you can edit the
library and run an app side by side. The app remembers onboarding and login between launches
(`UserDefaults`). To start over, use **Reset onboarding** on the home screen.

Try the deep links on a booted simulator (iOS asks once if it may open the app):

```bash
xcrun simctl openurl booted approot-swiftui://profile/Grace   # Explore tab → Grace
xcrun simctl openurl booted approot-swiftui://settings        # Account tab → Settings
xcrun simctl openurl booted approot-uikit://details/3         # Home → Details 1 → 2 → 3
```

## 🔀 Using both libraries in one app

Both libraries name their root protocol `AppRootFlow`. In a file that imports both, qualify it:

```swift
import AppRootUIKit
import AppRootKit

enum LegacyFlow: AppRootUIKit.AppRootFlow { /* contentController */ }
enum NewFlow: AppRootKit.AppRootFlow { /* contentView */ }
```

`AppRootRepresentable` (the shared marker protocol) and `AppRootProvider` come from `AppRootCore`.
Both libraries re-export it, so you never import it yourself.

## 📚 API at a glance

**UIKit (`AppRootUIKit`)**

| Type | Members |
|---|---|
| `AppRootFlow` | `contentController` · `transition` · `key` · `isVisited` |
| `AppRootNavigationController` | `init(rootController:isNavBarHidden:)` · `init(state:isNavBarHidden:)` · `setRoot(_:pushing:)` · `static setRootInAllWindows(_:)` |

**SwiftUI (`AppRootKit`)**

| Type | Members |
|---|---|
| `AppRootFlow` | `contentView` · `Screen` · `transition` · `animation` · `usesNavigationStack` |
| `Routable` | `contentView` |
| `AppRouter<Root>` | `init(root:)` · `init(state:)` · `root` · `path` · `setRoot(_:)` · `push(_:)` · `pop()` · `popToRoot()` · `activeStack` · `activateStack(_:)` · `path(for:)` · `setPath(_:for:)` · `open(_:path:)` · `open(_:stack:path:)` · `stackSelection(default:)` |
| `AppStack<Root, Content>` | `init(router:id:content:)` |
| `AppRootView<Root>` | `init(router:transition:animation:)` |

**Shared**

| Type | Members |
|---|---|
| `AppRootProvider<Root>` | `currentAppRoot` |

## 🔁 Migrating from 1.x

**Your 1.x code keeps building.** This release removes nothing. The old names still work, but they
are deprecated, so Xcode shows a warning with the fix at each place you use one. Migrate when it
suits you. A future major version may remove the deprecated names.

> If your target treats warnings as errors, the deprecation warnings will stop the build. Do the
> migration below in the same change as the update, or disable warnings-as-errors until you finish.

### What changed

| 1.x | Now | Why |
|---|---|---|
| Package `AppRootNavigation` | Package `AppRootKit` | The package now has a SwiftUI library too. |
| Product / module `AppRootNavigation` | `AppRootUIKit` | Says which UI framework it's for. |
| `AppRootState` | `AppRootProvider` | `currentAppRoot` can return your own root type. |
| `AppRootNavigationController.changeAppRoot.send(_:)` | `setRoot(_:)` or `AppRootNavigationController.setRootInAllWindows(_:)` | A plain method instead of a Combine subject. `setRoot` runs right away. |

### Step 1: Update the package

In Xcode, set the rule to **Up to Next Major Version** from `1.2.0`, then replace the
`AppRootNavigation` library with `AppRootUIKit` in your target's **Frameworks, Libraries, and
Embedded Content**. In `Package.swift`:

```swift
// Before
.package(url: "https://github.com/rqbctg/approotnavigation.git", from: "1.0.0"),
.product(name: "AppRootNavigation", package: "AppRootNavigation"),

// After
.package(url: "https://github.com/raqeebspace/AppRootKit.git", from: "1.2.0"),
.product(name: "AppRootUIKit", package: "AppRootKit"),
```

The repository is now `raqeebspace/AppRootKit`. GitHub redirects the old URL, so an unchanged
`Package.swift` keeps resolving. When you switch to the new URL, also change `package:` to
`"AppRootKit"`: SwiftPM names the package after the last part of the URL.

### Step 2: Change the imports

```swift
import AppRootNavigation   // before
import AppRootUIKit        // after
```

Every type keeps its name: `AppRootFlow`, `AppRootNavigationController`.

### Step 3: Replace `AppRootState` with `AppRootProvider`

Change the conformance. The body stays the same:

```swift
// Before
final class DefaultAppRootState: AppRootState {
    var currentAppRoot: any AppRootFlow { ... }
}

// After
final class DefaultAppRootState: AppRootProvider {
    var currentAppRoot: any AppRootFlow { ... }   // or your own type: var currentAppRoot: AppRoot
}
```

If you store the state as a protocol type, spell out the root type:

```swift
let state: AppRootState                                   // before
let state: any AppRootProvider<any AppRootFlow>           // after
```

You can also start the controller from the state directly:

```swift
// Before
AppRootNavigationController(rootController: DefaultAppRootState.shared.currentAppRoot.contentController)

// After
AppRootNavigationController(state: DefaultAppRootState.shared)
```

### Step 4: Replace `changeAppRoot`

```swift
// Before: every controller in the app switches, on the next run loop pass
AppRootNavigationController.changeAppRoot.send(AppRoot.home)

// After: the controller you're in, right away
(navigationController as? AppRootNavigationController)?.setRoot(AppRoot.home)

// After: every window, same behavior as before
AppRootNavigationController.setRootInAllWindows(AppRoot.home)
```

### Step 5 (optional): Remove boilerplate

`key`, `isVisited` and `transition` now have defaults (the case name, `false`, and the default
push). Delete implementations that only returned those. You only need `contentController`.

```swift
enum AppRoot: AppRootFlow {
    case onboarding, home

    var contentController: UIViewController {
        switch self {
        case .onboarding: OnboardingViewController()
        case .home:       HomeViewController()
        }
    }
}
```

When Xcode shows no more deprecation warnings from this package, your migration is complete.

## 📖 Further reading

- Part 1: [A simple yet powerful root navigation handler](https://medium.com/@rqb.ctg/a-simple-yet-powerful-rootnavigation-handler-58f7c8f72350)
- Part 2: [Deep dive: building a scalable app root flow system](https://medium.com/@rqb.ctg/deep-dive-building-a-scalable-app-root-flow-system-in-ios-with-swift-ba236862e615)

## 🤝 Contributing

1. Fork this repository.
2. Create a branch for each feature or bug fix.
3. Commit your changes and push to your fork.
4. Open a Pull Request with a clear description.

## 🪪 License

MIT. See [LICENSE](LICENSE).

## 📬 Contact

Questions or feature requests: [GitHub Issues](https://github.com/raqeebspace/AppRootKit/issues).
