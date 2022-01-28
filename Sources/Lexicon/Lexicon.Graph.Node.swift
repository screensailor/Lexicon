//
// github.com/screensailor 2021
//

public extension Lexicon.Graph {

    class Node {
        
        public typealias ID = String
        public typealias Name = String
        public typealias Protonym = String

        public enum CodingKeys: String, CodingKey {
            case children = "."
            case protonym = "="
            case type     = "+"
        }

        public internal(set) var children: [Name: Node]?
        public internal(set) var protonym: Protonym?
        public internal(set) var type: Set<ID>?

        public init(children: [Name: Node]? = nil, type: Set<ID>? = nil) {
            self.children = children.flatMap{ $0.isEmpty ? nil : $0 }
            self.type = type.flatMap{ $0.isEmpty ? nil : $0 }
            self.protonym = nil
        }
        
        public init(protonym: Protonym) {
            self.protonym = protonym
        }
        
        public func dictionary(id: ID = "", name: Name) -> [ID: Node] {
			let id = id.isEmpty ? name : "\(id).\(name)"
            var o: [ID: Node] = [id: self]
            for (name, child) in children ?? [:] {
                o.merge(child.dictionary(id: id, name: name)){ _, last in last }
            }
            return o
        }
        
		public func traverse(sorted: Bool = false, parent: ID? = nil, name: Name, yield: ((id: ID, name: Name, node: Node)) -> ()) {
            let id = parent.map{ "\($0).\(name)" } ?? name
            yield((id, name, self))
			guard let children = children else {
				return
			}
			let nodes = sorted ? AnyCollection(children.sorted(by: { $0.key < $1.key })) : .init(children)
			nodes.forEach { (name, child) in
				child.traverse(sorted: sorted, parent: id, name: name, yield: yield)
			}
		}
	}
}
