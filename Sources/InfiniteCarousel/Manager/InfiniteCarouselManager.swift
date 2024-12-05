//
//  InfiniteCarouselManager.swift
//  InfiniteCarousel
//
//  Created by Elyes Derouiche on 20/09/2024.
//

import SwiftUI
import Foundation
import Combine

/// `InfiniteCarouselManager` is responsible for implementing a Carousel behaviour using `UIScrollView`.
/// It handles features such as dual direction auto-scrolling, snapping to items, gestures and animations.
/// > Note: Ensure that you call registerScrollView to register the InfiniteCarouselManager with the UIScrollView.
@MainActor
final class InfiniteCarouselManager: NSObject, ObservableObject {
    // MARK: Public Properties

    public var currentIndex: Int = 0

    // MARK: Private Properties

    /// Width of each Carousel item
    private let itemWidth: CGFloat

    /// Total number of items
    private let itemCount: Int

    /// The spacing between
    private let spacing: CGFloat

    /// Animation transitions
    private let animation: InfiniteAnimation

    /// Scroll mode configuration, determining whether is Auto-scrolling in which direction or fixed
    private let scrollMode: ScrollMode

    /// UIScrollView deceleration rate
    private let deceleration: UIScrollView.DecelerationRate

    private let globalWidth: CGFloat

    private var rescheduleTimer: Timer?

    private weak var scrollView: UIScrollView?

    private let _scrollViewContentOffsetAnimationDurationKey = "contentOffsetAnimationDuration"

    // MARK: Initialiser

    public init(
        globalWidth: CGFloat,
        itemWidth: CGFloat,
        itemCount: Int,
        spacing: CGFloat,
        animation: InfiniteAnimation = .default(),
        scrollMode: ScrollMode = .fixed(),
        deceleration: UIScrollView.DecelerationRate = .fast
    ) {
        self.globalWidth = globalWidth
        self.itemWidth = itemWidth
        self.itemCount = itemCount
        self.spacing = spacing
        self.animation = animation
        self.scrollMode = scrollMode
        self.deceleration = deceleration
    }

    // MARK: Public Functions

    public func registerScrollView(
        scrollView: UIScrollView
    ) {
        let firstRegistration = self.scrollView == nil

        self.scrollView = scrollView
        self.scrollView?.delegate = self
        self.scrollView?.decelerationRate = deceleration

        if firstRegistration {
            snapToNearestItem(animation: InfiniteAnimation.none)
        }
    }

    deinit {
        scrollView = nil
        assumeIsolatedDuringDeinit { $0.resetTimers() }
    }

    /// Allows to snap to any item in the Scrollview using it's index
    /// - Parameters:
    ///   - index: Target index to snap to
    ///   - animation: Uses any `InfiniteAnimation`
    ///   - completion: Completion block to execute after the Scroll Animation, returns a mapped index that it
    /// is contained in the original list and
    ///   not the shadowed list ( Used for infinite Scrolling )
    public func snapToItem(
        at index: Int,
        animation: InfiniteAnimation? = nil,
        then completion: ((Int) -> Void)? = nil
    ) {
        let mappedIndex: Int = index % itemCount

        let sameIndex: Bool = mappedIndex == currentIndex

        let targetAnimation = if let animation {
            animation
        } else {
            self.animation
        }

        setContentOffset(at: index, animation: targetAnimation)

        guard let completion else { return }

        let computedThrottle: DispatchTime

        if sameIndex {
            computedThrottle = .now()
        } else if let duration = animation?.duration {
            computedThrottle = .now() + duration
        } else {
            computedThrottle = .now() + self.animation.duration
        }

        DispatchQueue.main.asyncAfter(deadline: computedThrottle) {
            completion(mappedIndex)
        }
    }

    // MARK: Private helpers

    private func resetTimers() {
        rescheduleTimer?.invalidate()
        rescheduleTimer = nil
    }

    private func rescheduleAutoScroll(in time: TimeInterval) {
        resetTimers()
        rescheduleTimer = Timer.scheduledTimer(
            withTimeInterval: time,
            repeats: false,
            block: { [weak self] timer in
                guard let self else {
                    timer.invalidate()
                    return
                }
                Task {
                    await snapToNearestItem(offset: 1)
                }
            }
        )
    }

    private func snapToNearestItem(
        offset: Int = 0,
        animation: InfiniteAnimation? = nil
    ) {
        guard let scrollView else { return }

        let computedWidth = itemWidth + spacing
        let visibleRect = CGRect(
            origin: scrollView.contentOffset,
            size: scrollView.bounds.size
        )
        let centerX = visibleRect.midX
        let centerItemIndex = Int(centerX / computedWidth)
        let computedIndex = switch scrollMode {
        case .autoScroll(_, .LTR, _):
            centerItemIndex - offset
        default:
            centerItemIndex + offset
        }

        let targetAnimation = if let animation {
            animation
        } else {
            self.animation
        }

        setContentOffset(at: computedIndex, animation: targetAnimation)
    }

    /// Adapts `UIScrollview.setContentOffset` to InfiniteCarouselManager behaviour with target scroll to Index,
    /// custom Animation transition and duration
    /// Calculates target offset based on configured ItemWidth. Splitting by 2 for having the item on center
    /// of the screen.
    /// Manages the auto scrolling behaviour when enabled.
    private func setContentOffset(
        at index: Int,
        animation: InfiniteAnimation
    ) {
        defer {
            currentIndex = index % itemCount
        }

        let computedWidth = itemWidth + spacing
        let targetX = (CGFloat(index) * computedWidth) - (globalWidth - itemWidth) / 2

        if case let .autoScroll(interval, _, _) = scrollMode {
            rescheduleAutoScroll(in: animation.duration + interval)
        }

        scrollView?.setValue(
            animation.duration,
            forKeyPath: _scrollViewContentOffsetAnimationDurationKey
        )

        scrollView?.setContentOffset(
            CGPoint(x: targetX, y: 0),
            animated: animation.animated
        )
    }
}

extension InfiniteCarouselManager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let minX = scrollView.contentOffset.x
        let computedWidth = CGFloat(itemCount) * (itemWidth + spacing)
        if minX > computedWidth {
            scrollView.contentOffset.x -= computedWidth
        } else if minX < 0 {
            scrollView.contentOffset.x += computedWidth
        }
    }

    public func scrollViewDidEndDragging(
        _: UIScrollView,
        willDecelerate isDecelerating: Bool
    ) {
        if !isDecelerating {
            snapToNearestItem()
        }
    }

    public func scrollViewDidEndDecelerating(_: UIScrollView) {
        snapToNearestItem()
    }
}

// https://github.com/onevcat/Kingfisher/blob/ee44579d71cf7ad21046b829aed074c0229a6ec6/Sources/Views/AnimatedImageView.swift#L478-L493
extension InfiniteCarouselManager {
    // An actor's deinit is nonisolated so we need to cleanup state that needs to exist past this instance's deinit.
    // Currently there is no way to accomplish this that wouldn't be an error in Swift 6, hopefully that changes at
    // some point. This evolution proposal attempts to address this problem:
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0371-isolated-synchronous-deinit.md
    // Method influenced from
    // https://github.com/swiftlang/swift/blob/47803aad3b0d326e5231ad0d7936d40264f56edd/stdlib/public/Concurrency/ExecutorAssertions.swift#L351
    @_unavailableFromAsync(message: "express the closure as an explicit function declared on the specified 'actor' instead")
    private nonisolated func assumeIsolatedDuringDeinit<T>(_ operation: @MainActor (InfiniteCarouselManager) throws -> T) rethrows -> T {
        typealias Isolated = (InfiniteCarouselManager) throws -> T
        // To do the unsafe cast, we have to pretend it's @escaping.
        return try withoutActuallyEscaping(operation) { (_ fn: @escaping Isolated) throws -> T in
            try fn(self)
        }
    }
}
