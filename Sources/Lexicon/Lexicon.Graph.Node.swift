//
// github.com/screensailor 2021
//

public extension Lexicon.Graph {

    class Node {
        
        public typealias ID = String
        public typealias Name = String
        public typealias Protonym = String
        
        public internal(set) var id: ID = ""
        public internal(set) var name: Name = ""
        public internal(set) var type: Set<ID> = []
        public internal(set) var protonym: Protonym?
        public internal(set) var children: [Name: Node] = [:]

        public init(parent: Node?, name: Name, children: [Name: Node] = [:], type: Set<ID> = []) {
            self.id = parent?.id.unlessEmpty.map{ "\($0).\(name)" } ?? name
            self.name = name
            self.type = type
            self.protonym = nil
            self.children = children
            parent?.children[name] = self
        }
        
        public func dictionary(id: ID = "", name: Name) -> [ID: Node] {
			let id = id.isEmpty ? name : "\(id).\(name)"
            var o: [ID: Node] = [id: self]
            for (name, child) in children {
                o.merge(child.dictionary(id: id, name: name)){ _, last in last }
            }
            return o
        }
        
		public func traverse(sorted: Bool = false, parent: ID? = nil, name: Name, yield: ((id: ID, name: Name, node: Node)) -> ()) {
            let id = parent.map{ "\($0).\(name)" } ?? name
            yield((id, name, self))
			let nodes = sorted ? AnyCollection(children.sorted(by: { $0.key < $1.key })) : AnyCollection(children)
			nodes.forEach { (name, child) in
				child.traverse(sorted: sorted, parent: id, name: name, yield: yield)
			}
		}
	}
}
