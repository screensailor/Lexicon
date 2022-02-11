//
// github.com/screensailor 2022
//

import Foundation

public struct Event: @unchecked Sendable, Hashable, Identifiable, CustomStringConvertible { // TODO: Codable?
    
    private static var count: UInt = 0
    private static let lock = NSLock()
    
    public let id: UInt
    public let description: String
    
    public let k: KProtocol
    public let base: AnyHashable
    public let `is`: (I) -> Bool
    
    public init(_ l: L) {
        self.init(K(l))
    }
    
    public init<A: L>(_ k: K<A>) {
        
        Self.lock.lock()
        Self.count += 1
        self.id = Self.count
        Self.lock.unlock()
        
        self.k = k
        self.base = k
        self.description = k.__
        
        self.is = { x in
            switch x {
                case let x as L: return x is A
                    
                case let x as KProtocol where x(\.L) is A: return x.____.allSatisfy {
                    k.____[$0] == $1
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