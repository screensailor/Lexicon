//
// github.com/screensailor 2022
//

import Combine

public typealias BearIn = AnyCancellables
public typealias Mind = [AnyCancellable] // TODO: Set<AnyCancellable>

@resultBuilder public enum AnyCancellables {}
    
public extension AnyCancellables {
    
    static func buildArray(_ components: [[AnyCancellable]]) -> [AnyCancellable] {
        components.flatMap{ $0 }
    }
    
    static func buildBlock(_ components: AnyCancellable...) -> [AnyCancellable] {
        components
    }
    
    static func buildBlock(_ first: [AnyCancellable], _ rest: [AnyCancellable]...) -> [AnyCancellable] {
        ([first] + rest).flatMap{ $0 }
    }
    
    // TODO: ...
}

public extension Set where Element == AnyCancellable {
    
    @inlinable static func += <A: Collection>(lhs: inout Self, rhs: A) where A.Element == AnyCancellable {
        lhs.formUnion(rhs)
    }
    
    @inlinable static func += (lhs: inout Self, rhs: AnyCancellable) {
        lhs.insert(rhs)
    }
    
    @inlinable mutating func `in`(_ mind: AnyCancellable) {
        insert(mind)
    }
    
    @inlinable mutating func `in`<A: Sequence>(_ mind: A) where A.Element == AnyCancellable {
        formUnion(mind)
    }
}
