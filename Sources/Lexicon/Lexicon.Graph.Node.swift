//
// github.com/screensailor 2021
//

public extension Lexicon.Graph.Node {
	typealias ID = String // TODO: consider [Name] or WritableKeyPath or [WritableKeyPath] instead
	typealias Name = String
	typealias Protonym = String
}

public extension Lexicon.Graph {
	
	struct Node {
		
		public var name: Name
		public var type: Set<ID>
		public var protonym: Protonym?
		public var children: [Name: Node]
		
		public init(name: Name, protonym: Protonym) {
			self.name = name
			self.type = []
			self.protonym = protonym
			self.children = [:]
		}
		
		public init(name: Name, children: [Name: Node] = [:], type: Set<ID> = []) {
			self.name = name
			self.type = type
			self.children = children
		}

		@discardableResult
		public mutating func make(child name: Name) -> Node {
			if let child = children[name] {
				return child
			}
			let child = Node(name: name)
			children[name] = child
			return child
		}
	}
}

internal extension Lexicon.Graph.Node {

	/// - note: This is not an optional subscript!
	subscript(child: String) -> Lexicon.Graph.Node {
		get { children[child]! } // TODO: rethink
		set { children[child] = newValue }
	}
}

extension Lexicon.Graph.Node: CustomStringConvertible {
	
	public var description: String {
		name
	}
}

public extension Lexicon.Graph.Node {
	
	// TODO: rewrite to reflect Node changes
	func traverse(sorted: Bool = false, parent: ID? = nil, name: Name? = nil, yield: ((id: ID, name: Name, node: Lexicon.Graph.Node)) -> ()) {
		let name = name ?? self.name
		let id = parent.map{ "\($0).\(name)" } ?? name
		yield((id, name, self))
		let nodes = sorted ? AnyCollection(children.sorted(by: { $0.key < $1.key })) : AnyCollection(children)
		nodes.forEach { (name, child) in
			child.traverse(sorted: sorted, parent: id, name: name, yield: yield)
		}
	}
}
