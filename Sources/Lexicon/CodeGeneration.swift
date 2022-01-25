//
// github.com/screensailor 2022
//

import Collections

extension Lemma {
    
    public func classes() async -> [ID: Lexicon.Graph.Node.Class] {
        
        var classes: [ID: Class] = await breadthFirstTraversal
            .map(Class.init)
            .reduce(into: [:]){ $0[$1.id] = $1 }
        
        for klass in classes.values {
            klass.supertype = Self.supertype(for: klass, in: &classes)
        }
        
        return classes
    }
}

public extension Sequence where Element == Lexicon.Graph.Node.Class {
    
    func sortedByDependancy() -> [Element] {
        sorted{ l, r in l.id.lexicographicallyPrecedes(r.id) }.sorted{ l, r in
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
        guard let type = klass.type, let first = type.first else {
            return nil
        }
        guard type.count > 1 else {
            return first
        }
        let orderedType = klass.lemma?.ownType.values.map(\.unwrapped).sortedByChildCount() ?? []
        return mixin(forOrderedType: orderedType, in: &classes).id
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
            supertype: supertype.id,
            mixin: mixin,
            kind: supertype.kind.union(mixin.kind)
        )
        classes[klass.id] = klass
        return klass
    }
}

public extension Lexicon.Graph.Node {
    
    class Class: Hashable, Encodable {
        
        public var id: Lemma.ID
        public var synonymOf: Lemma.Protonym?
        public var type: OrderedSet<Lemma.ID>?
        public var children: OrderedSet<Lemma.Name>?
        public var supertype: Lemma.ID?
        public var mixinType: Lemma.ID?
        public var mixinChildren: OrderedSet<Lemma.ID>?
        
        public let lemma: Lemma?
        public var kind: Set<Lemma.ID>
        
        enum CodingKeys: String, CodingKey {
            case id
            case synonymOf
            case type
            case children
            case supertype
            case mixinType
            case mixinChildren
        }
        
        @LexiconActor
        init(lemma: Lemma) {
            
            self.id = lemma.id
            self.synonymOf = lemma.protonym?.id
            self.children = OrderedSet(lemma.ownChildren.keys.sortedByLocalizedStandard()).unlessEmpty
            self.type = OrderedSet(lemma.ownType.keys.sortedByLocalizedStandard()).unlessEmpty
            
            self.lemma = lemma
            self.kind = Set(lemma.type.keys)
        }
        
        @LexiconActor
        init(id: Lemma.ID, supertype: Lemma.ID, mixin: Lexicon.Graph.Node.Class, kind: Set<Lemma.ID>) {
            self.id = id
            self.supertype = supertype
            self.mixinType = mixin.id
            self.mixinChildren = (mixin.children?.map{ "\(mixin.id).\($0)" }).flatMap(OrderedSet.init)
            
            self.lemma = nil
            self.kind = kind
        }
        
        @inlinable public func `is`(_ type: Class) -> Bool {
            self.kind.contains(type.id)
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: Class, rhs: Class) -> Bool {
            lhs.id == rhs.id
        }
    }
}
