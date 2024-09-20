//
//  CarouselPreview.swift
//  InfiniteCarousel
//
//  Created by Elyes Derouiche on 20/09/2024.
//

import Foundation
import SwiftUI

private struct CarouselBasicPreview: View {
    var body: some View {
        InfiniteCarousel(
            items: [
                UIColor.red,
                UIColor.blue,
                UIColor.brown,
                UIColor.cyan,
                UIColor.magenta,
            ],
            size: InfiniteCarousel.Size(
                globalWidth: UIScreen.main.bounds.width,
                globalHeight: UIScreen.main.bounds.height,
                width: .ratio(0.8),
                height: .ratio(0.8)
            ),
            deceleration: UIScrollView.DecelerationRate.fast,
            scrollMode: .autoScroll(
                interval: 5,
                direction: .LTR
            ),
            gesture: .scrollTo(
                animation: .default(duration: 0.5)
            )
        ) { item in
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(item))
                .padding(.vertical, 4)
        }
    }
}

private struct CarouselStructuredPreview: View {

    private let data = [
        UIColor.red,
        UIColor.blue,
        UIColor.brown,
        UIColor.cyan,
        UIColor.magenta,
    ]

    var body: some View {
        VStack {
            VStack {
                InfiniteCarousel(
                    items: data,
                    spacing: 25,
                    size: InfiniteCarousel.Size(
                        globalWidth: UIScreen.main.bounds.width,
                        globalHeight: 400,
                        width: .ratio(0.8),
                        height: .ratio(0.9)
                    ),
                    deceleration: UIScrollView.DecelerationRate.fast,
                    scrollMode: .autoScroll(
                        interval: 3,
                        direction: .LTR
                    ),
                    gesture: .scrollTo(
                        animation: .default(duration: 0.5)
                    )
                ) { item in
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(item))
                        .padding(.vertical, 4)
                }            }
            .frame(
                height: 400
            )
            .background(Color.blue.opacity(0.5))

            HStack {
                VStack {
                    InfiniteCarousel(
                        items: data,
                        size: InfiniteCarousel.Size(
                            globalWidth: 200,
                            globalHeight: 300,
                            width: .ratio(0.8),
                            height: .ratio(0.8)
                        ),
                        deceleration: UIScrollView.DecelerationRate.fast,
                        scrollMode: .autoScroll(
                            interval: 1,
                            direction: .RTL
                        ),
                        gesture: .scrollTo(
                            animation: .default(duration: 1)
                        )
                    ) { item in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(item))
                            .padding(.vertical, 4)
                    }
                }
                .frame(
                    width: 200,
                    height: 300
                )
                .background(Color.orange.opacity(0.5))

                VStack(spacing: 0) {
                    VStack {
                        InfiniteCarousel(
                            items: data,
                            size: InfiniteCarousel.Size(
                                globalWidth: 200,
                                globalHeight: 150,
                                width: .ratio(0.8),
                                height: .ratio(0.8)
                            ),
                            deceleration: UIScrollView.DecelerationRate.fast,
                            scrollMode: .autoScroll(
                                interval: 1,
                                direction: .LTR
                            ),
                            gesture: .scrollTo(
                                animation: .none
                            )
                        ) { item in
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color(item))
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(
                        width: 200,
                        height: 150
                    )
                    .background(Color.red.opacity(0.5))

                    VStack {
                        InfiniteCarousel(
                            items: data,
                            size: InfiniteCarousel.Size(
                                globalWidth: 200,
                                globalHeight: 150,
                                width: .ratio(0.9),
                                height: .ratio(0.8)
                            ),
                            deceleration: UIScrollView.DecelerationRate.fast,
                            scrollMode: .fixed(isInteractionEnabled: true),
                            gesture: .scrollTo(
                                animation: .default(duration: 1)
                            )
                        ) { item in
                            Circle()
                                .fill(Color(item))
                                .padding(.vertical, 4)
                        }
                    }
                    .frame(
                        width: 200,
                        height: 150
                    )
                    .background(Color.purple.opacity(0.5))
                }
            }
        }
    }
}

#Preview("Basic") {
    CarouselBasicPreview()
}

#Preview("Structured") {
    CarouselStructuredPreview()
}

