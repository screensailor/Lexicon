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
		dictionary[id] ?? lemma?[id.components(separatedBy: ".")]
	}
}

public extension Lexicon {
	
	static func from(_ graph: Graph) -> Lexicon {
		let o = Lexicon(graph)
		connect(lexicon: o, with: graph)
		all.append(o)
		return o
	}

	func reset(to graph: Graph) {
		Lexicon.connect(lexicon: self, with: graph)
	}
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

// MARK: graph mutations

public extension Lexicon { // MARK: additive mutations
	
	func make(child new: Graph, to lemma: Lemma) -> Lemma? {
		
		let name = new.root.name
		
		guard
			lemma.isValid(newChildName: name),
			let path = lemma.graphPath
		else {
			return nil // TODO: throw
		}
		
		var graph = graph
		graph.date = .init()
		
		graph[path].children[name] = new.root // TODO: fix inheritance and synonyms where pasting from other lexicons

		reset(to: graph)
		return self["\(lemma.id).\(name)"]
	}
	
	func make(child name: Lemma.Name, to lemma: Lemma) -> Lemma? {
		
		guard lemma.isValid(newChildName: name) else {
			return nil // TODO: throw
		}
		
//		var graph = graph
//		graph.date = .init()
//
//		let child = graph[lemma.node].make(child: name)
//
//		reset(to: graph)
//		return self[child.id]
		fatalError()
	}
	
	func add(type: Lemma, to lemma: Lemma) -> Lemma? {
		
		guard lemma.isValid(newType: type) else {
			return nil // TODO: throw
		}

//		var graph = graph
//		graph.date = .init()
//
//		graph[lemma.node].type.insert(type.id)
//
//		reset(to: graph)
//		return self[lemma.id]
		fatalError()
	}
}

public extension Lexicon { // MARK: non-additive mutations
	
	func delete(_ lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isGraphNode,
			let parent = lemma.parent
		else {
			return nil // TODO: throw
		}
		
		parent.ownChildren.removeValue(forKey: lemma.name)
		
		let graph = regenerateGraph { o in
			if let protonym = o.protonym {
				if protonym.unwrapped.isInLineage(of: lemma) {
					o.protonym = nil
				}
			} else {
				for (name, type) in o.type where type.unwrapped.isInLineage(of: lemma) {
					o.type.removeValue(forKey: name)
				}
			}
		}
		
		reset(to: graph)
		return self[parent.id]
	}
	
	func rename(_ lemma: Lemma, to name: Lemma.Name) -> Lemma? {
		
		guard lemma.isValid(newName: name) else {
			return nil // TODO: throw
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
//		for node in graph.root.descendants(.breadthFirst) {
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

	func remove(type: Lemma, from lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isGraphNode,
			let type = lemma.ownType.removeValue(forKey: type.id)?.unwrapped
		else {
			return nil
		}
		
		let graph = regenerateGraph { o in
			if let protonym = o.protonym {
				// TODO: !
			}
		}
		
		reset(to: graph)
		return self[lemma.id]
	}
	
	func set(protonym: Lemma, of lemma: Lemma) -> Lemma? {
		
		guard lemma.isValid(protonym: protonym) else {
			return nil
		}

		lemma.protonym = Unowned(protonym)
		lemma.ownChildren.removeAll()
		lemma.ownType.removeAll()
		
		let graph = regenerateGraph { o in
			if let protonym = o.protonym {
				if protonym.unwrapped.isAncestor(of: lemma) {
					o.protonym = nil
				}
			} else {
				for (name, type) in o.type where type.unwrapped.isAncestor(of: lemma) {
					o.type.removeValue(forKey: name)
				}
			}
		}
				
		reset(to: graph)

		guard
			let id = lemma.parent?.id,
			let parent = self[id],
			let lemma = parent.children[lemma.name] // fonund the synonym rather than protonym
		else {
			return self[lemma.id]
		}
		
		return lemma
	}
	
	func removeProtonym(of lemma: Lemma) -> Lemma? {
		
		guard lemma.isGraphNode else {
			return nil
		}
		
		lemma.protonym = nil

		let graph = regenerateGraph()
		
		reset(to: graph)
		return self[lemma.id]
	}
}
