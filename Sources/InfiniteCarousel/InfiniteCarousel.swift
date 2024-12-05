//
//  InfiniteCarousel.swift
//  InfiniteCarousel
//
//  Created by Elyes Derouiche on 20/09/2024.
//

import Foundation
import SwiftUI
import UIKit
@_spi(Advanced) import SwiftUIIntrospect

/// A SwiftUI view that represents a carousel of items.
///
/// Example usage:
///
/// ```swift
/// InfiniteCarousel(
///   items: [
///       UIColor.red,
///       UIColor.blue,
///       UIColor.brown,
///       UIColor.cyan,
///       UIColor.magenta
///   ],
///   spacing: 10,
///   size: InfiniteCarousel.Size.init(
///       width: .ratio(0.8),
///       height: .pixel(200)
///   ),
///   scrollMode: .autoScroll(interval: 0.5),
///   gesture: .scrollTo(animation: .default(duration: 1))
///   ) { item in
///       RoundedRectangle(cornerRadius: 30)
///           .fill(Color(uiColor: item))
///   }
/// ```
///
/// - Parameters:
///        - Content: The type of content view to be displayed in the carousel.
///     - Item: A type conforming to RandomAccessCollection representing the collection of items in the Carousel.
///
/// > Note: This view uses the `InfiniteCarouselManager` and an external library `Introspect` to provide Carousel
/// behaviour using `SwiftUI.ScrollView`.
public struct InfiniteCarousel<
    Content: View,
    Item: RandomAccessCollection
>: View where Item.Element: Equatable {

    public struct Size {
        public enum SizeMode {
            case ratio(CGFloat)
            case pixel(CGFloat)
        }

        let globalWidth: CGFloat
        let globalHeight: CGFloat

        private let width: SizeMode
        private let height: SizeMode

        public init(
            globalWidth: CGFloat,
            globalHeight: CGFloat,
            width: SizeMode,
            height: SizeMode
        ) {
            self.width = width
            self.height = height
            self.globalWidth = globalWidth
            self.globalHeight = globalHeight
        }

        func getHeight() -> CGFloat {
            switch height {
            case let .ratio(cGFloat):
                return globalHeight * cGFloat
            case let .pixel(cGFloat):
                return cGFloat
            }
        }

        func getWidth() -> CGFloat {
            switch width {
            case let .ratio(cGFloat):
                return globalWidth * cGFloat
            case let .pixel(cGFloat):
                return cGFloat
            }
        }
    }

    public enum Gesture {
        case scrollTo(
            animation: InfiniteAnimation,
            handler: ((Item.Element) -> Void)? = nil
        )

        case centerBeforeAction(
            animation: InfiniteAnimation,
            handler: ((Item.Element) -> Void)? = nil
        )
        case none

        var animation: InfiniteAnimation {
            switch self {
            case let .scrollTo(animation, _), let .centerBeforeAction(animation, _):
                return animation
            case .none:
                return .none
            }
        }

        var handler: ((Item.Element) -> Void)? {
            switch self {
            case let .scrollTo(_, handler), let .centerBeforeAction(_, handler):
                return handler
            case .none:
                return nil
            }
        }
    }

    // MARK: Private Props

    private var spacing: CGFloat = 10

    private let items: Item

    private let size: Size

    @ViewBuilder
    private let content: (Item.Element) -> Content

    private var gesture: Gesture = .none

    private var axis: Axis.Set

    @ObservedObject
    private var manager: InfiniteCarouselManager

    private var itemCount: Int {
        items.count
    }

    // MARK: Initializer

    public init(
        items: Item,
        spacing: CGFloat = 10,
        size: Size,
        deceleration: UIScrollView.DecelerationRate = .fast,
        scrollMode: ScrollMode = .fixed(),
        gesture: Gesture,
        @ViewBuilder content: @escaping (Item.Element) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.size = size
        self.content = content
        self.gesture = gesture
        axis = scrollMode.isInteractionEnabled ? Axis.Set.horizontal : []
        manager = .init(
            globalWidth: size.globalWidth,
            itemWidth: size.getWidth(),
            itemCount: items.count,
            spacing: spacing,
            animation: gesture.animation,
            scrollMode: scrollMode,
            deceleration: deceleration
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            let repeatingCount = Int((proxy.size.width / size.getWidth()).rounded()) * 2

            let computedMirrorRange: ClosedRange<Int> = itemCount ... max(itemCount + 2, repeatingCount)

            ScrollView(axis, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        render(item: item, at: index)
                    }

                    ForEach(computedMirrorRange, id: \.self) { index in
                        if let item = Array(items)[safeIndex: index % max(1, items.count)] {
                            render(item: item, at: index)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            .introspect(.scrollView, on: .iOS(.v15...)) { @MainActor scrollView in
                manager.registerScrollView(scrollView: scrollView)
            }
        }
        .frame(height: size.getHeight())
    }

    @ViewBuilder
    func render(item: Item.Element, at index: Int) -> some View {
        content(item)
            .frame(
                width: size.getWidth(),
                height: size.getHeight()
            )
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        // Save currentIndex before mutation from snapToItem
                        let currentIndex = manager.currentIndex

                        let handleCenteredElement: (Int) -> Void = { mappedIndex in
                            if isCentralElement(
                                current: currentIndex,
                                target: index,
                                mappedIndex: mappedIndex
                            ) {
                                gesture.handler?(item)
                            }
                        }

                        if axis.isEmpty {
                            handleCenteredElement(index)
                        } else {
                            manager.snapToItem(at: index) { mappedIndex in
                                switch gesture {
                                case .scrollTo:
                                    gesture.handler?(item)
                                case .centerBeforeAction:
                                    handleCenteredElement(mappedIndex)
                                default:
                                    break
                                }
                            }
                        }
                    }
            )
    }

    private func isCentralElement(
        current: Int,
        target: Int,
        mappedIndex: Int
    ) -> Bool {
        if itemCount == 1 {
            return target == 1
        }
        return mappedIndex == current
    }
}
