//
//  InfiniteAnimation.swift
//  InfiniteCarousel
//
//  Created by Elyes Derouiche on 20/09/2024.
//

import Foundation
import SwiftUI

public enum InfiniteAnimation {
    case none
    case `default`(duration: TimeInterval = 0.5)

    var duration: CGFloat {
        switch self {
        case let .default(duration):
            return abs(duration)
        default:
            return 0
        }
    }

    var animated: Bool {
        switch self {
        case .none:
            return false
        default:
            return true
        }
    }
}

public enum ScrollMode {
    public enum ScrollDirection {
        case LTR
        case RTL
    }

    case autoScroll(
        interval: TimeInterval,
        direction: ScrollDirection = .RTL,
        isInteractionEnabled: Bool = true
    )

    case fixed(isInteractionEnabled: Bool = true)

    var isInteractionEnabled: Bool {
        switch self {
        case let .autoScroll(_, _, isInteractionEnabled), let .fixed(isInteractionEnabled):
            return isInteractionEnabled
        }
    }
}

public enum CoordinateSpaceProvider: Hashable {
    /// Custom coordinateSpace should be defined else the `global` coordinate space will be returned
    case named(String)
    case global

    public var name: String {
        switch self {
        case let .named(name):
            return name
        default:
            return ""
        }
    }

    var coordinateSpace: CoordinateSpace {
        switch self {
        case .global:
            return .global
        case let .named(name):
            return .named(name)
        }
    }
}
