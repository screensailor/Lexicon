//
// github.com/screensailor 2021
//

import Foundation

@LexiconActor public final class Lexicon: ObservableObject {
	
	@Published public private(set) var graph: Graph
	
	public internal(set) var dictionary: [Lemma.ID: Lemma] = [:]
	
	private var lemma: Lemma! // TODO: serioulsy?
	
	private init(_ graph: Graph) {
		self.graph = graph
	}
	
	deinit {
		assertionFailure("🗑 \(self)") // TODO: hard rethink
	}
}

public extension Lexicon {
	
	var root: Lemma { lemma! }
	
	subscript(id: Lemma.ID) -> Lemma? {
		dictionary[id] ?? lemma?[id.components(separatedBy: ".").dropFirst()]
	}
}

public extension Lexicon {
	
	static func from(_ graph: Graph) -> Lexicon {
		let o = Lexicon(graph)
		connect(lexicon: o, with: graph)
		all.append(o)
		return o
	}

	#if EDITOR
	func reset(to graph: Graph) {
		Lexicon.connect(lexicon: self, with: graph)
	}
	#endif
}

private extension Lexicon {
	
	static var all: [Lexicon] = []
	
	static func connect(lexicon: Lexicon, with new: Graph? = nil) {
		let graph = new ?? lexicon.graph
		lexicon.dictionary.removeAll(keepingCapacity: true)
		lexicon.lemma = Lemma(name: graph.root.name, node: graph.root, parent: nil, lexicon: lexicon)
		lexicon.graph = graph
	}

	func regenerateGraph(_ ƒ: ((Lemma) -> ())? = nil) -> Lexicon.Graph {
		Lexicon.Graph(
			root: root.regenerateNode(ƒ),
			date: .init()
		)
	}
}

#if EDITOR

// MARK: graph mutations

// TODO: performance
// TODO: throwing

public extension Lexicon { // MARK: additive mutations
	
	func add(type: Lemma, to lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isValid(newType: type),
			let path = lemma.graphPath
		else {
			return nil
		}
		
		var graph = graph
		graph.date = .init()
		
		graph[path].type.insert(type.id)
		
		reset(to: graph)
		return self[lemma.id] ?? root
	}

	func make(child new: Graph, to lemma: Lemma) -> Lemma? {
		
		let name = new.root.name
		
		guard
			lemma.isValid(newChildName: name),
			let path = lemma.graphPath
		else {
			return nil
		}
		
		var new = new
		
		var protonyms: [(Graph.Node, Graph.Path)] = [] // TODO: reinstate
		var inheritance: [(Graph.Node, Graph.Path)] = [] // TODO: reinstate

		for (node, path) in new.root.graphTraversalWithPaths(.breadthFirst) {
			if node.protonym != nil {
				protonyms.append((node, path))
				new[path].protonym = nil
			}
			else if !node.type.isEmpty {
				inheritance.append((node, path))
				new[path].type = []
			}
		}
		
		var graph = graph
		graph.date = .init()
		
		graph[path].children[name] = new.root

		reset(to: graph)
		return self["\(lemma.id).\(name)"] ?? root
	}
	
	func make(child name: Lemma.Name, to lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isValid(newChildName: name),
			let path = lemma.graphPath
		else {
			return nil
		}
		
		var graph = graph
		graph.date = .init()

		graph[path].make(child: name)

		reset(to: graph)
		return self["\(lemma.id).\(name)"] ?? root
	}
}

public extension Lexicon { // MARK: non-additive mutations
	
	func delete(_ lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isGraphNode,
			let parent = lemma.parent
		else {
			return nil
		}
		
		parent.ownChildren.removeValue(forKey: lemma.name)
		
		root.graphTraversal(.depthFirst) { o in
			for (name, type) in o.ownType where type.unwrapped.isInLineage(of: lemma) {
				o.ownType.removeValue(forKey: name)
			}
		}

		let graph = regenerateGraph { o in
			for (name, child) in o.ownChildren {
				if
					let protonym = child.node.protonym,
					o[protonym.components(separatedBy: ".")] == nil
				{
					o.ownChildren.removeValue(forKey: name)
				}
			}
		}

		reset(to: graph)
		return self[parent.id] ?? root
	}
	
	func remove(type: Lemma, from lemma: Lemma) -> Lemma? {

		guard let path = lemma.graphPath else {
			return nil
		}
		
		var graph = graph

		guard graph[path].type.remove(type.id) != nil else {
			return nil
		}

		reset(to: graph)
		
		graph = regenerateGraph { o in
			for (name, child) in o.ownChildren {
				if
					let protonym = child.node.protonym,
					o[protonym.components(separatedBy: ".")] == nil
				{
					o.ownChildren.removeValue(forKey: name)
				}
			}
		}
		
		reset(to: graph)
		return self[lemma.id] ?? root
	}
	
	func removeProtonym(of lemma: Lemma) -> Lemma? {
		
		guard
			lemma.node.protonym != nil,
			let path = lemma.graphPath
		else {
			return nil
		}
		
		var graph = graph
		
		graph[path].protonym = nil
		
		reset(to: graph) // TODO: reconsider, as it is not strictly necessary
		return self[lemma.id] ?? root
	}

	func rename(_ lemma: Lemma, to name: Lemma.Name) -> Lemma? {
		
		guard lemma.isValid(newName: name) else {
			return nil
		}
		
		let old = (
			id: lemma.id,
			name: lemma.name
		)
		
		let new = (
			id: String(lemma.id.dropLast(old.name.count) + name),
			name: name
		)
		
//		lemma.node.id = new.id
//		lemma.node.name = new.name
//
//		var graph = graph
//		graph.date = .init()
//
//		if let parent = lemma.parent {
//			graph[parent.node].children[old.name] = nil
//			graph[parent.node].children[new.name] = lemma.node
//		} else {
//			graph.root = lemma.node
//		}
//
//		let namePattern = try! NSRegularExpression(pattern: "\\b\(new.name)\\b", options: [])
//
//		for node in graph.root.graphTraversal(.breadthFirst) {
//			if
//				let protonym = node.protonym,
//				namePattern.firstMatch(in: protonym, options: [], range: protonym.nsRange) != nil, // TODO: performance - not necessarily our node
//				let synonym = self[node.id]
//			{
//				let count = protonym.split(separator: ".").count
//				graph[node].protonym  = sequence(first: synonym, next: \.parent)
//					.prefix(count)
//					.map(\.node.name)
//					.reversed()
//					.joined(separator: ".")
//			}
//			else {
//				//                otherNode.type = Set(otherNode.type.map{ id in
//				//                    guard id.starts(with: old.id) else { // TODO: user range(of:)
//				//                        return id
//				//                    }
//				//                    return String(new.id + id.dropFirst(old.id.count)) // TODO: preformance (use range)
//				//                }) // TODO: performance
//			}
//		}
//
//		reset(to: graph)
//		return self[new.id]
		fatalError()
	}

	func set(protonym: Lemma, of lemma: Lemma) -> Lemma? {
		
		guard let protonym = lemma.validated(protonym: protonym) else {
			return nil
		}
		
		let id = lemma.id
		
		guard let parent = lemma.delete() else {
			return nil
		}
		
		guard let path = parent.graphPath else {
			return parent
		}

		var graph = graph
		
		let node = Lexicon.Graph.Node(name: lemma.name, protonym: protonym)
		
		graph[path].children[node.name] = node
				
		reset(to: graph)
		
		return self[id] ?? root
	}
}

#endif
