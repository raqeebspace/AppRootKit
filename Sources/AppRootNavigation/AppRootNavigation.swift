//
//  AppRootNavigation.swift
//  AppRootNavigation
//
//  The 1.x module name. The UIKit library is now `AppRootUIKit`; this module keeps
//  `import AppRootNavigation` building and points every use at the new import.
//

@_exported import AppRootCore
import AppRootUIKit

@available(*, deprecated, message: "AppRootNavigation is now AppRootUIKit. Replace `import AppRootNavigation` with `import AppRootUIKit`.")
public typealias AppRootFlow = AppRootUIKit.AppRootFlow

@available(*, deprecated, message: "AppRootNavigation is now AppRootUIKit. Replace `import AppRootNavigation` with `import AppRootUIKit`.")
public typealias AppRootNavigationController = AppRootUIKit.AppRootNavigationController

@available(*, deprecated, message: "AppRootNavigation is now AppRootUIKit. Replace `import AppRootNavigation` with `import AppRootUIKit`, then conform to AppRootProvider instead.")
public typealias AppRootState = AppRootUIKit.AppRootState
