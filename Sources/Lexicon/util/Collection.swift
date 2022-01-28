//
// github.com/screensailor 2022
//

import Foundation

extension Collection {
    
    @inlinable var isNotEmpty: Bool {
        !isEmpty
    }
    
    @inlinable var unlessEmpty: Self? {
        isEmpty ? nil : self
    }
}

extension RangeReplaceableCollection {
    
    static func += (lhs: inout Self, rhs: Element) {
        lhs.append(rhs)
    }
}
