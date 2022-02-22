//
// github.com/screensailor 2022
//

import Collections
import Foundation

public extension Lexicon.Graph {
    
    // TODO: array of referenced nodes (i.e. useful protocols/interfaces)
    
    struct JSON: Codable {
        public var date: Date
        public var name: Lemma.Name
        public var classes: [Node.Class.JSON]
    }
}

public extension Lexicon {
    
    func json() async -> Graph.JSON {
        .init(
            date: graph.date,
            name: graph.root.name,
            classes: await root.classes().values.map(\.json).sortedByLocalizedStandard(by: \.id)
        )
    }
}

extension Lemma {
    
    public func classes() async -> [ID: Lexicon.Graph.Node.Class] {
        
        var classes: [ID: Class] = await breadthFirstTraversal
            .map(Class.init)
            .reduce(into: [:]){ $0[$1.json.id] = $1 }
        
        for klass in classes.values {
            klass.json.supertype = Self.supertype(for: klass, in: &classes)
        }
        
        return classes
    }
}

public extension Sequence where Element == Lexicon.Graph.Node.Class {
    
    func sortedByDependancy() -> [Element] {
        sorted{ l, r in l.json.id.lexicographicallyPrecedes(r.json.id) }.sorted{ l, r in
            r.is(l)
        }
    }
}

private extension Sequence where Element == Lemma {
    
    @LexiconActor
    func sortedByChildCount() -> [Element] {
        sorted{ l, r in
            guard l.ownChildren.count != r.ownChildren.count else {
                return l.id.lexicographicallyPrecedes(r.id)
            }
            return l.ownChildren.count > r.ownChildren.count
        }
    }
}

private extension Lemma {
    
    typealias Class = Lexicon.Graph.Node.Class
    
    static func supertype(for klass: Class, in classes: inout [ID: Class]) -> ID? {
        guard let type = klass.json.type, let first = type.first else {
            return nil
        }
        guard type.count > 1 else {
            return first
        }
        let orderedType = klass.lemma?.ownType.values.map(\.unwrapped).sortedByChildCount() ?? []
        return mixin(forOrderedType: orderedType, in: &classes).json.id
    }
    
    static func mixin(forOrderedType type: [Lemma], in classes: inout [ID: Class]) -> Class {
        guard type.count > 1, let first = type.first, let last = type.last else {
            fatalError()
        }
        let id = type.map(\.id).joined(separator: "_&_")
        if let o = classes[id] {
            return o
        }
        let supertype: Class
        if type.count > 2 {
            supertype = mixin(forOrderedType: Array(type.dropLast()), in: &classes)
        } else {
            supertype = classes[first.id]!
        }
        let mixin = classes[last.id]!
        let klass = Class(
            id: id,
            supertype: supertype.json.id,
            mixin: mixin,
            kind: supertype.kind.union(mixin.kind)
        )
        classes[klass.json.id] = klass
        return klass
    }
}

public extension Lexicon.Graph.Node {
    
    class Class: Hashable {
        
        public var json: JSON
        public let lemma: Lemma?
        public var kind: Set<Lemma.ID>
        
        @LexiconActor
        init(lemma: Lemma) {
            
            self.json = JSON(
                id: lemma.id,
                protonym: lemma.protonym?.node.id,
                type: lemma.ownType
                    .keys
                    .sortedByLocalizedStandard()
                    .unlessEmpty
                    .map(OrderedSet.init),
                children: lemma.ownChildren
                    .filter(\.value.protonym.isNil)
                    .keys
                    .sortedByLocalizedStandard()
                    .unlessEmpty
                    .map(OrderedSet.init),
                synonyms: lemma.ownChildren
                    .compactMap{ (name, lemma) in lemma.node.protonym.map{ protonym in (name, protonym)  } }
                    .unlessEmpty
                    .map{ Dictionary($0){ _, last in last }}
            )
            
            self.lemma = lemma
            self.kind = Set(lemma.type.keys)
        }
        
        @LexiconActor
        init(id: Lemma.ID, supertype: Lemma.ID, mixin: Lexicon.Graph.Node.Class, kind: Set<Lemma.ID>) {
            
            self.json = JSON(
                id: id,
                supertype: supertype,
                mixin: JSON.Mixin(
                    type: mixin.json.id,
                    children: mixin.lemma?.children
                        .map{ (name, child) in (name, "\(child.node.id)") }
                        .unlessEmpty
                        .map{ Dictionary($0){ _, last in last } }
                )
            )
            
            self.lemma = nil
            self.kind = kind
        }
        
        @inlinable public func `is`(_ type: Class) -> Bool {
            self.kind.contains(type.json.id)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(json.id)
        }
        
        public static func == (lhs: Class, rhs: Class) -> Bool {
            lhs.json.id == rhs.json.id
        }
    }
}

extension Lexicon.Graph.Node.Class: Encodable {
    
    // TODO: replace dictionaries with OrderedDictionary when it's json serialisation is fixed
    
    public struct JSON: Codable {
        public var id: Lemma.ID
        public var protonym: Lemma.ID?
        public var type: OrderedSet<Lemma.ID>?
        public var children: OrderedSet<Lemma.Name>?
        public var synonyms: [Lemma.Name: Lemma.Protonym]?
        public var supertype: Lemma.ID?
        public var mixin: Mixin?
    }
    
    @inlinable public func encode(to encoder: Encoder) throws {
        try json.encode(to: encoder)
    }
}

public extension Lexicon.Graph.Node.Class.JSON {
    
    struct Mixin: Codable {
        public var type: Lemma.ID
        public var children: [Lemma.Name: Lemma.ID]?
    }
}

public extension Lexicon.Graph.Node.Class.JSON {
    
    @inlinable var hasProperties: Bool {
        !hasNoProperties
    }
    
    @inlinable var hasNoProperties: Bool {
        (children?.isEmpty ?? true) && (synonyms?.isEmpty ?? true) && (mixin?.children?.isEmpty ?? true)
    }
}
