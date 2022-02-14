//
// github.com/screensailor 2022
//

import Foundation

public struct Event: @unchecked Sendable, Hashable, Identifiable, CustomStringConvertible { // TODO: Codable?
    
    private static var count: UInt = 0
    private static let lock = NSLock()
    
    public let id: UInt
    public let description: String
    
    public let l: L
    public let k: KProtocol
    public let base: AnyHashable
    
    public init(_ l: L) {
        self.init(K(l))
    }
    
    public init<A: L>(_ k: K<A>) {
        
        Self.lock.lock()
        Self.count += 1
        self.id = Self.count
        Self.lock.unlock()
        
        self.l = k.___
        self.k = k
        self.base = k
        self.description = k.__
    }
    
    public func `is`(_ i: I) -> Bool {
        switch i {
            case let i as L:
                return k(\.L) == i
                
            case let i as KProtocol:
                return k(\.L) == i(\.L) && i.____.allSatisfy {
                    k.____[$0] == $1
                }
                
            default:
                return false
        }
    }
    
    public func `is`<A>(_: A.Type) -> Bool {
        k(\.L) is A
    }

    public func `is`<A: I>(_ a: K<A>) -> Bool {
        k is A && a.____.allSatisfy {
            k.____[$0] == $1
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
        lhs.id == rhs.id
    }
    
    @inlinable func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
