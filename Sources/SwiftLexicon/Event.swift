//
// github.com/screensailor 2022
//

public struct Event: @unchecked Sendable, Hashable, Identifiable {
    
    public let id: String
    public let k: KProtocol
    public let base: AnyHashable
    public let `is`: (I) -> Bool
    
    public init(_ l: L) {
        self.init(K(l))
    }
    
    public init<A: L>(_ k: K<A>) {
        self.k = k
        self.id = k.__
        self.base = k
        self.is = { x in
            switch x {
                case let x as L: return x is A
                    
                case let x as K<A>: return x.____.allSatisfy {
                    dump(k.____[$0] == $1)
                }
                    
                default: return false
            }
        }
    }
}

public extension Event {
    @inlinable subscript() -> Any? { k[] }
    @inlinable subscript(key: L) -> Any? { k[key] }
    @inlinable subscript<A>(type as: A.Type = A.self) -> A { get throws { try k[as: A.self] } }
    @inlinable subscript<A>(key: L, as: A.Type = A.self) -> A { get throws { try k[key, as: A.self] } }
}

public extension Event {
    
    @inlinable static func == <A: L>(lhs: A, rhs: Event) -> Bool {
        Event(lhs) == rhs
    }
    
    @inlinable static func == <A: L>(lhs: Event, rhs: A) -> Bool {
        lhs == Event(rhs)
    }
    
    @inlinable static func == <A: L>(lhs: K<A>, rhs: Event) -> Bool {
        Event(lhs) == rhs
    }
    
    @inlinable static func == <A: L>(lhs: Event, rhs: K<A>) -> Bool {
        lhs == Event(rhs)
    }
    
    @inlinable static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.base == rhs.base
    }
    
    @inlinable func hash(into hasher: inout Hasher) {
        hasher.combine(base)
    }
}
