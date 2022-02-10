//
// github.com/screensailor 2022
//

public extension I where Self: L {
    
    subscript<Value>(value: Value) -> K<Self> where Value: Sendable, Value: Hashable {
        K(self, [self: value])
    }
}

public protocol KProtocol: I {
    subscript() -> Any? { get }
    subscript(key: L) -> Any? { get }
    subscript<A>(as type: A.Type) -> A { get throws }
    subscript<A>(key: L, as type: A.Type) -> A { get throws }
}

@dynamicMemberLookup public struct K<A: L>: @unchecked Sendable, Hashable, KProtocol {
    
    public let __: String
    public let ___: A
    public let ____: [L: AnyHashable]
    
    internal init(_ l: A, _ d: [L: AnyHashable] = [:]) {
        self.____ = d
        self.___ = l
        self.__ = d.sorted(by: { $0.key.__.count > $1.key.__.count }).reduce(into: l.__) { (o, e) in
            assert(o.starts(with: e.key.__))
            let i = o.index(o.startIndex, offsetBy: e.key.__.count)
            o.insert(contentsOf: "[\(e.value)]", at: i) // TODO: measure performance
        }
    }
}

public extension K {
    @inlinable static var localized: String { A.localized }
}

public extension K {
    
    subscript<B: L>(dynamicMember keyPath: KeyPath<A, B>) -> K<B> {
        K<B>(___[keyPath: keyPath], ____)
    }
    
    subscript<Value>(value: Value) -> K<A> where Value: Sendable, Value: Hashable {
        K(___, ____.merging([___: value], uniquingKeysWith: { _, last in last }))
    }
}

public extension K {
    
    subscript() -> Any? { self[___] }
    
    subscript(key: L) -> Any? { ____[key]?.base }
    
    @inlinable subscript<A>(as type: A.Type = A.self) -> A {
        get throws { try self[___] }
    }
    
    @inlinable subscript<A>(key: L, as type: A.Type = A.self) -> A {
        get throws { try (self[key] as? A).try() }
    }
}

extension K { // TODO: ↓
//    private static let brackets = CharacterSet(charactersIn: "[]")
//
//    var detail: (id: String, data: [String: String]) {
//        let substrings = description.components(separatedBy: Self.brackets).filter(\.isEmpty.not)
//        var id = ""
//        var data: [String: String] = [:]
//        for (i, (k, v)) in zip(substrings, substrings.dropFirst()).enumerated() where i.isMultiple(of: 2) {
//            id = (i == 0) ? k : (id + k)
//            data[id] = v
//        }
//        id = substrings.enumerated().filter{ $0.offset.isMultiple(of: 2) }.map(\.element).joined()
//        return (id, data)
//    }
}
