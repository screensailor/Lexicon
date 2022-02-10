//
// github.com/screensailor 2022
//

import Combine

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
    
    static func += <A: Collection>(lhs: inout Self, rhs: A) where A.Element == AnyCancellable {
        lhs.formUnion(rhs)
    }
}
