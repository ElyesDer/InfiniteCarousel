//
//  Array+subscript.swift
//  InfiniteCarousel
//
//  Created by Elyes Derouiche on 20/09/2024.
//

import Foundation

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
