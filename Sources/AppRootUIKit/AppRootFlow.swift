//
//  AppRootFlow.swift
//  AppRootUIKit
//
//  Created by raqeebspace on 9/9/25.
//

import UIKit
@_exported import AppRootCore

/// A UIKit app root: an `AppRootRepresentable` that knows its view controller.
///
/// Only `contentController` is required; the rest have defaults.
public protocol AppRootFlow: AppRootRepresentable {
    /// Unique key for the flow, used for persistence. Default: `String(describing: self)`.
    var key: String { get }
    /// Indicates whether the flow has been visited. Default: `false`.
    var isVisited: Bool { get }
    /// The view controller associated with the flow.
    var contentController: UIViewController { get }

    /// The animation of the view controller transition. Default: `nil` (push from right).
    var transition: CATransition? { get }
}

public extension AppRootFlow {
    var key: String { String(describing: self) }
    var isVisited: Bool { false }
    var transition: CATransition? { nil }
}
