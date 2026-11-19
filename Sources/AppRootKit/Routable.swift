//
//  Routable.swift
//  AppRootKit
//

import SwiftUI

/// A screen that can be pushed on a root's navigation stack.
public protocol Routable: Hashable {
    associatedtype Content: View
    @MainActor @ViewBuilder var contentView: Content { get }
}

/// Default `AppRootFlow.Screen` for roots that push nothing.
extension Never: Routable {
    public var contentView: Never { fatalError("Never has no values") }
}
