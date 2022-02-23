//
// github.com/screensailor 2021
//

import Foundation

@LexiconActor
public class Lexicon: ObservableObject {
	
	@Published public private(set) var graph: Graph
	
	public internal(set) var dictionary: [Lemma.ID: Lemma] = [:]
	
	private var lemma: Lemma!
	
	private init(_ o: Graph) {
		graph = o
	}
	
	deinit {
		assertionFailure("🗑 \(self)")
	}
}

public extension Lexicon {
	
	private(set) static var all: [Lexicon] = []
	
	static func from(_ graph: Graph) -> Lexicon {
		let o = Lexicon(graph)
		connect(lexicon: o, with: graph)
		all.append(o)
		return o
	}
	
	func reset(to graph: Graph) {
		Lexicon.connect(lexicon: self, with: graph)
	}
	
	/// Poor performance!
	///
	/// However, this will resolve implications of mutations for synonyms correctly.
	/// Using this shortcut will give us time to build up testing facilities to more
	/// easily develop performant solutions.
	func reserialize() throws {
		let string = TaskPaper.encode(graph)
		let newGraph = try TaskPaper(string).decode()
		reset(to: newGraph)
	}
	
	private static func connect(lexicon: Lexicon, with new: Graph? = nil) {
		let graph = new ?? lexicon.graph
		lexicon.dictionary.removeAll(keepingCapacity: true)
		lexicon.lemma = Lemma(name: graph.root.name, node: graph.root, parent: nil, lexicon: lexicon)
		lexicon.graph = graph
	}
}

public extension Lemma {
	
	var graphPath: Lexicon.Graph.Path { // TODO: consider storing these with the lemma?
		node.id.split(separator: ".").dropFirst().reduce(\.self) { a, e in
			a.appending(path: \.[String(e)])
		}
	}
}

public extension Lexicon.Graph {
	
	typealias Path = WritableKeyPath<Node, Node>

	@LexiconActor subscript(_ lemma: Lemma) -> Node {
		get {
			return root[keyPath: lemma.graphPath]
		}
		set {
			root[keyPath: lemma.graphPath] = newValue
		}
	}
}

extension Lexicon {
	
	// TODO: are these still needed ↓?
	
	nonisolated func deiniting(lemma: Lemma) {
		Task(priority: .high) { [id = lemma.id] in
			await remove(lemma: id)
		}
	}
	
	private func remove(lemma id: Lemma.ID) {
		dictionary.removeValue(forKey: id)
	}
}

public extension Lexicon {
	
	// TODO: rething these too ↓
	
	var root: Lemma { lemma! }
	
	subscript(id: Lemma.ID) -> Lemma? {
		dictionary[id] ?? lemma?[id.components(separatedBy: ".")]
	}
}

public extension Lexicon {
	
	@discardableResult
	func add(child graph: Graph, to lemma: Lemma) -> Lemma? {
		add(child: graph.root.name, node: graph.root, to: lemma)
	}
	
	@discardableResult
	func add(child name: Lemma.Name, node: Graph.Node, to lemma: Lemma, date: Date? = Date()) -> Lemma? {
		
		guard !name.isEmpty, lemma.children[name] == nil else {
			return nil // TODO: throw
		}
		
		defer {
			if let date = date {
				graph.date = date
			}
		}
		
		lemma.node.children[name] = node
		
		let child = Lemma(name: name, node: node, parent: lemma, lexicon: self)
		lemma.ownChildren[name] = child
		lemma.children[name] = child
		
		for id in dictionary.keys {
			guard let o = dictionary[id], o != lemma, o.is(lemma) else {
				continue
			}
			inherit(child: name, node: node, to: o)
		}
		
		return child
	}

	@discardableResult
	func add(childrenOf node: Graph.Node, to lemma: Lemma) -> Lemma? {
		defer {
			graph.date = .init()
		}
		for (name, child) in node.children {
			add(child: name, node: child, to: lemma, date: nil)
		}
		return lemma
	}
	
	@discardableResult
	func inherit(child name: Lemma.Name, node: Graph.Node, to lemma: Lemma) -> Lemma? {
		
		guard !name.isEmpty, lemma.children[name] == nil else {
			return nil // TODO: throw
		}
		
		let child = Lemma(name: name, node: node, parent: lemma, lexicon: self)
		lemma.children[name] = child
		
		for id in dictionary.keys {
			guard let o = dictionary[id], o != lemma, o.is(lemma) else {
				continue
			}
			inherit(child: name, node: node, to: o)
		}
		
		return child
	}
}

// MARK: graph mutations

public extension Lexicon { // MARK: additive mutations
	
	func make(child name: Lemma.Name, to lemma: Lemma) -> Lemma? {
		
		guard
			!name.isEmpty,
			lemma.children[name] == nil,
			lemma.isGraphNode()
		else {
			return nil // TODO: throw
		}
		
		var graph = graph
		graph.date = .init()
		
		let child = graph[lemma].make(child: name)

		reset(to: graph)
		
		return self[child.id]
	}
	
	func add(type: Lemma, to lemma: Lemma) -> Lemma? {
		
		guard
			lemma.isGraphNode(),
			type.isGraphNode(),
			!lemma.is(type)
		else {
			return nil
		}
		
		lemma.node.type.insert(type.id)

		var graph = graph
		graph.date = .init()
		
		graph[lemma].type.insert(type.id)
		
		reset(to: graph)
		
		return self[lemma.id]
	}
}

public extension Lexicon { // MARK: non-additive mutations
	
	func delete(_ lemma: Lemma) -> Lemma? { // TODO: throws
		
		guard
			var parent = lemma.parent?.node,
			let node = lemma.graphNode()
		else {
			return nil
		}
		
		defer {
			graph.date = .init()
		}
		
		parent.children.removeValue(forKey: node.name)
		
		root.node.traverse { (_, _, otherNode) in
			//            otherNode.type = otherNode.type.filter{ id in
			//                !id.starts(with: node.id)
			//            }
		}
		
		do {
			try reserialize()
		} catch {
			print("😱", #function, error)
		}
		
		return self[parent.id]
	}
	
	func rename(_ lemma: Lemma, to name: Lemma.Name) -> Lemma? {
		
		guard var node = lemma.graphNode(), lemma.isValid(newName: name) else {
			return nil
		}
		
		let old = (
			id: node.id,
			name: node.name
		)
		
		let new = (
			id: String(node.id.dropLast(old.name.count) + name),
			name: name
		)
		
		defer {
			graph.date = .init()
		}
		
		node.id = new.id
		node.name = new.name
		
		if var parent = lemma.parent?.node {
			parent.children[old.name] = nil
			parent.children[new.name] = node
		} else {
			//            graph.name = new.name
		}
		
		root.node.traverse { (_, _, otherNode) in
//			if
//				let protonym = otherNode.protonym?.split(separator: "."),
//				protonym.contains(where: { $0 == old.name }), // TODO: performance - not necessarily our node
//				let protonymLemma = self[otherNode.id]
//			{
				//                otherNode.protonym = sequence(first: protonymLemma, next: \.parent)
				//                    .prefix(protonym.count)
				//                    .map(\.node.name)
				//                    .reversed()
				//                    .joined(separator: ".")
//			}
//			else {
				//                otherNode.type = Set(otherNode.type.map{ id in
				//                    guard id.starts(with: old.id) else { // TODO: user range(of:)
				//                        return id
				//                    }
				//                    return String(new.id + id.dropFirst(old.id.count)) // TODO: preformance (use range)
				//                }) // TODO: performance
//			}
		}
		
		do {
			try reserialize()
		} catch {
			print("😱", #function, error)
		}
		
		return self[new.id]
	}
	
	func remove(type: Lemma, from lemma: Lemma) -> Lemma? {
		
		if lemma.node.type.remove(type.id).isNil {
			guard
				let id = lemma.ownType.first(where: { k, v in v.unwrapped == type })?.key,
				lemma.node.type.remove(id).isNotNil
			else {
				return nil
			}
		}
		
		defer {
			graph.date = .init()
		}
		
		do {
			try reserialize()
		} catch {
			print("😱", #function, error)
		}
		
		return self[lemma.node.id]
	}
	
	func set(protonym: Lemma?, of lemma: Lemma) -> Lemma? {
		
		guard var node = lemma.graphNode() else {
			return nil
		}
		
		if let protonym = protonym?.sourceProtonym ?? protonym {
			
			guard let (ref, _) = lemma.validated(protonym: protonym) else {
				return nil // TODO: throw
			}
			
			node.protonym = ref
			node.children.removeAll()
			node.type.removeAll()
		}
		
		else {
			
			guard node.protonym != nil else {
				return nil
			}
			
			node.protonym = nil
		}
		
		graph.date = .init()
		
		do {
			try reserialize()
		} catch {
			print("😱", #function, error) // TODO: throw
			return nil
		}
		
		if
			let parentID = lemma.parent?.id,
			let parent = self[parentID],
			let lemma = parent.children[node.name]
		{
			return lemma // fonund the synonym rather than protonym
		}
		
		return self[node.id]
	}
}
