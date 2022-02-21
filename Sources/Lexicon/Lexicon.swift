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
		lexicon.lemma = Lemma(name: graph.name, node: graph.root, parent: nil, lexicon: lexicon)
        lexicon.graph = graph
    }
}

extension Lexicon {
    
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
	
	var root: Lemma { lemma! }

    subscript(id: Lemma.ID) -> Lemma? {
		dictionary[id] ?? lemma?[id.components(separatedBy: ".")]
    }
}

public extension Lexicon { // MARK: additive mutations
    
    @discardableResult
    func make(child name: Lemma.Name, node inherited: Graph.Node?, to lemma: Lemma) -> Lemma? {
        
        guard !name.isEmpty, lemma.children[name] == nil else {
            return nil // TODO: throw
        }
		
		defer {
			graph.date = .init()
		}
        
        let node: Graph.Node
        
        if let o = inherited ?? lemma.node.children[name] {
            node = o
        } else {
            node = Graph.Node(parent: lemma.node, name: name)
            lemma.node.children[name] = node
        }
        
        let child = Lemma(name: name, node: node, parent: lemma, lexicon: self)
        if inherited == nil {
            lemma.ownChildren[name] = child
        }
        lemma.children[name] = child
        
        for id in dictionary.keys {
            guard let o = dictionary[id], o != lemma, o.is(lemma) else {
                continue
            }
            make(child: name, node: node, to: o)
        }
        
        return child
    }
	
	@discardableResult
	func add(child graph: Graph, to lemma: Lemma) -> Lemma? {
		add(child: graph.name, node: graph.root, to: lemma)
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
			make(child: name, node: node, to: o)
		}
		
		return child
	}

    @discardableResult
    func add(type: Lemma, to lemma: Lemma) -> Bool {
        guard !lemma.is(type) else {
            return false
        }
        lemma.node.type.insert(type.id)
        lemma.ownType[type.id] = Unowned(type)
        lemma.type[type.id] = Unowned(type)
        
        for id in dictionary.keys {
            guard let o = dictionary[id], o.is(lemma) else {
                continue
            }
            for (name, lemma) in type.children {
                make(child: name, node: lemma.node, to: o)
            }
        }
        
        graph.date = .init()
        
        return true
    }
}

public extension Lexicon { // MARK: non-additive mutations

    func delete(_ lemma: Lemma) -> Lemma? { // TODO: throws
        
        guard
            let parent = lemma.parent?.node,
            let node = lemma.graphNode()
        else {
            return nil
        }
        
        defer {
            graph.date = .init()
        }
        
        parent.children.removeValue(forKey: node.name)

        root.node.traverse { (_, _, otherNode) in
            otherNode.type = otherNode.type.filter{ id in
                !id.starts(with: node.id)
            }
        }
        
        do {
            try reserialize()
        } catch {
            print("😱", #function, error)
        }

        return self[parent.id]
    }
    
    func rename(_ lemma: Lemma, to name: Lemma.Name) -> Lemma? {
        
        guard let node = lemma.graphNode(), lemma.isValid(newName: name) else {
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
        
        if let parent = lemma.parent?.node {
            parent.children[old.name] = nil
            parent.children[new.name] = node
        } else {
            graph.name = new.name
        }
        
        root.node.traverse { (_, _, otherNode) in
            if
                let protonym = otherNode.protonym?.split(separator: "."),
                protonym.contains(where: { $0 == old.name }), // TODO: performance - not necessarily our node
                let protonymLemma = self[otherNode.id]
            {
                otherNode.protonym = sequence(first: protonymLemma, next: \.parent)
                    .prefix(protonym.count)
                    .map(\.node.name)
                    .reversed()
                    .joined(separator: ".")
            }
            else {
                otherNode.type = Set(otherNode.type.map{ id in
                    guard id.starts(with: old.id) else { // TODO: user range(of:)
                        return id
                    }
                    return String(new.id + id.dropFirst(old.id.count)) // TODO: preformance (use range)
                }) // TODO: performance
            }
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
        
        guard let node = lemma.graphNode() else {
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
