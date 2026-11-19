//
//  AppRootState.swift
//  AppRootUIKit
//

/// The 1.x way to pick the current root. Kept unchanged so 1.x apps still build.
///
/// To migrate, change `AppRootState` to `AppRootProvider`. Your `currentAppRoot` keeps
/// working, and it can now return your own root type:
///
/// ```swift
/// struct LaunchState: AppRootProvider {
///     var currentAppRoot: AppFlow { ... }   // or: any AppRootFlow
/// }
/// ```
///
/// A variable typed `AppRootState` becomes `any AppRootProvider<any AppRootFlow>`.
@available(*, deprecated, message: "Conform to AppRootProvider instead. Your currentAppRoot keeps working and can return your own root type.")
public protocol AppRootState {
    /// The current app root flow.
    var currentAppRoot: AppRootFlow { get }
}
