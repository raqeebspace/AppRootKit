// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppRootKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // SwiftUI: AppRouter, AppRootView, AppStack (iOS 16+).
        .library(
            name: "AppRootKit",
            targets: ["AppRootKit"]),
        // UIKit: AppRootNavigationController (iOS 13+).
        .library(
            name: "AppRootUIKit",
            targets: ["AppRootUIKit"]),
        // The 1.x name of AppRootUIKit. Deprecated aliases only; keeps 1.x apps building.
        .library(
            name: "AppRootNavigation",
            targets: ["AppRootNavigation"]),
    ],
    targets: [
        // Shared AppRootRepresentable and AppRootProvider; re-exported by every library.
        .target(
            name: "AppRootCore",
            dependencies: []
        ),
        .target(
            name: "AppRootKit",
            dependencies: ["AppRootCore"]
        ),
        .target(
            name: "AppRootUIKit",
            dependencies: ["AppRootCore"]
        ),
        .target(
            name: "AppRootNavigation",
            dependencies: ["AppRootCore", "AppRootUIKit"]
        ),
        .testTarget(
            name: "AppRootKitTests",
            dependencies: ["AppRootKit"]
        ),
        // Stand-in for a 1.x app module that declares its own `AppRoot` (1.0.0 README).
        // Not a product, so apps never see it.
        .target(
            name: "CompatFixture",
            dependencies: ["AppRootNavigation"],
            path: "Tests/CompatFixture"
        ),
        .testTarget(
            name: "AppRootUIKitTests",
            dependencies: ["AppRootUIKit", "AppRootNavigation", "CompatFixture"]
        ),
    ]
)
