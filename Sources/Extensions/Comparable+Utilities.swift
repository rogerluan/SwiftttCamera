// Copyright © 2021 Roger Oba. All rights reserved.

import Foundation

public extension Comparable {
    /// Constraints Self to the given closed range.
    /// - Parameter range: The range to which Self should be constrained to.
    /// - Returns: The receiver if it was within the given range. If the receiver was below the lower bound of the range, the range's lower bound is returned. Likewise, if the receiver was greater than the upper bound of the range, the range's upper bound is returned.
    func constrained(to range: ClosedRange<Self>) -> Self {
        guard self >= range.lowerBound else { return range.lowerBound }
        guard self <= range.upperBound else { return range.upperBound }
        return self
    }
}
