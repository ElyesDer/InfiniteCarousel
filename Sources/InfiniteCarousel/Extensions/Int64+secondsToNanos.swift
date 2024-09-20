//
//  Int64+secondsToNanos.swift
//  InfiniteCarousel
//
//  Created by Elyes Derouiche on 20/09/2024.
//
import Foundation

extension UInt64 {
    /// Converts seconds to nanoseconds
    static func secondsToNanos(_ seconds: Int) -> UInt64 {
        NSEC_PER_SEC * UInt64(seconds)
    }
}
