//
// github.com/screensailor 2021
//

import Foundation

@LexiconActor
public class Lexicon: ObservableObject {
	
	private(set) static var all: [Lexicon] = []
	
	public var root: Lemma { dictionary[serialization.name]! }
    public internal(set) var dictionary: [Lemma.ID: Lemma] = [:]
    
    @Published public private(set) var serialization: Serialization
    
    private init(_ o: Serialization) {
        serialization = o
    }
}

public extension Lexicon {
	
    static func from(_ serialization: Serialization) -> Lexicon {
        let o = Lexicon(serialization)
        connect(lexicon: o, with: serialization)
		all.append(o)
        return o
    }
	
	func reset(with serialization: Serialization) {
		Lexicon.connect(lexicon: self, with: serialization)
	}
    
    private static func connect(lexicon o: Lexicon, with serialization: Serialization) {
        
        o.dictionary = [:]
        
		_ = Lemma(name: serialization.name, node: serialization.root, parent: nil, lexicon: o)

		for lemma in o.dictionary.values {
			guard let suffix = lemma.node.protonym else {
				continue
			}
			guard let parent = lemma.parent else {
				print("😱 Synonym '\(suffix)', lemma '\(lemma.id)', does not have a parent.")
				continue
			}
			guard let protonym = parent[suffix.components(separatedBy: ".")] else {
				print("😱 Could not find protonym '\(suffix)' of \(lemma.id)")
				continue
			}
			lemma.protonym = protonym
			o.dictionary[lemma.id] = protonym
        }
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
    
    subscript(id: Lemma.ID) -> Lemma? {
		dictionary[id] ?? root[id.components(separatedBy: ".")]
    }
}

public extension Lexicon {
    
    @discardableResult
    func make(child name: Lemma.Name, node inherited: Serialization.Node?, to lemma: Lemma) -> Lemma? {
        
        guard !name.isEmpty, lemma.children[name] == nil else {
            return nil // TODO: throw
        }
        
        let node: Serialization.Node
        
        if let o = inherited ?? lemma.node.children?[name] {
            node = o
        } else {
            node = .init()
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
    
        serialization.date = .init()
        
        return child
    }
	
	@discardableResult
	func add(child serialization: Serialization, to lemma: Lemma) -> Lemma? {
		add(child: serialization.name, node: serialization.root, to: lemma)
	}
	
	@discardableResult
	func add(childrenOf node: Serialization.Node, to lemma: Lemma) -> Lemma? {
		for (name, child) in node.children ?? [:] {
			add(child: name, node: child, to: lemma, date: nil)
		}
		serialization.date = .init()
		return lemma
	}

	@discardableResult
	func add(child name: Lemma.Name, node: Serialization.Node, to lemma: Lemma, date: Date? = Date()) -> Lemma? {
		
		guard !name.isEmpty, lemma.children[name] == nil else {
			return nil // TODO: throw
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
	
		if let date = date {
			serialization.date = date
		}
		
		return child
	}

	@discardableResult
	func delete(_ lemma: Lemma) -> Lemma? {
		defer {
			serialization.date = .init()
		}
		return deleteWithRecursion(lemma)
	}
    
    private func deleteWithRecursion(_ lemma: Lemma) -> Lemma? {
        
        guard let parent = lemma.parent else {
            return nil
        }
        
		parent.node.children?.removeValue(forKey: lemma.name)
        
        parent.ownChildren.removeValue(forKey: lemma.name)
        parent.children.removeValue(forKey: lemma.name)

        dictionary.removeValue(forKey: lemma.id)

        for id in dictionary.keys {
            guard let o = dictionary[id] else {
                continue
            }
            if o.protonym == lemma {
				let parent = deleteWithRecursion(o)
				assert(parent != nil)
            }
			else if let lemma = o.type[lemma.id]?.unwrapped {
				let success = removeWithDeleteRecursion(type: lemma, from: o) // TODO: there's more to remove!
				assert(success)
            }
        }
		
		return parent
    }
    
    @discardableResult
    func rename(_ lemma: Lemma, to name: Lemma.Name) -> Lemma? {
        
        guard lemma.isValid(newName: name) else {
            return nil
        }
        
        let oldID = lemma.id
        let newID: Lemma.ID
        
        if let parent = lemma.parent {
            parent.node.children[name] = parent.node.children?.removeValue(forKey: lemma.name)
            newID = "\(parent.id).\(name)"
        }
        else {
			dictionary[lemma.name] = nil
            serialization.name = name
			dictionary[name] = lemma
            newID = name
        }

        root.node.traverse(name: serialization.name) { id, name, node in
            if let type = node.type {
                guard type.contains(where: { id in id.starts(with: oldID) }) else {
                    return
                }
                node.type = Set(
                    type.map { id in
                        id == oldID ? newID : "\(newID)\(id.dropFirst(oldID.count))"
                    }
                )
            }
            else if let protonym = node.protonym {
                guard newID.starts(with: id.dropLast(name.count)) else {
                    return
                }
                let old = oldID.dropFirst(id.count - name.count)
                guard protonym.starts(with: old) else {
                    return
                }
                let new = newID.dropFirst(id.count - name.count)
                node.protonym = "\(new)\(protonym.dropFirst(old.count))"
            }
        }
        
        Lexicon.connect(lexicon: self, with: serialization)
        
        serialization.date = .init()
        
        return dictionary[newID]
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
        
        serialization.date = .init()

        return true
    }

	@discardableResult
	func remove(type: Lemma, from lemma: Lemma) -> Bool {
		defer {
			serialization.date = .init()
		}
		return removeWithDeleteRecursion(type: type, from: lemma)
	}
	
    private func removeWithDeleteRecursion(type: Lemma, from lemma: Lemma) -> Bool {
        
        guard lemma.node.type?.remove(type.id) != nil else {
            return false
        }
        if lemma.node.type?.isEmpty == true {
            lemma.node.type = nil
        }

		let children = type.children.keys
        
        for id in dictionary.keys {
            guard let o = dictionary[id], o != type, o.is(lemma) else {
                continue
            }
            for name in children {
                guard let child = o.children[name] else {
                    continue
                }
				let parent = deleteWithRecursion(child) // TODO: allow overlapping inheritance?
				assert(parent != nil)
            }
        }
        
        lemma.type.removeValue(forKey: type.id)
        lemma.ownType.removeValue(forKey: type.id)

        return true
    }
    
    func set(protonym: Lemma?, of lemma: Lemma) {
        if let protonym = protonym {
            
            let protonym = Array(sequence(first: protonym, next: \.protonym)).last!
            
            guard let (ref, protonym) = lemma.validated(protonym: protonym) else {
                print("❓ protonym", protonym, "not validated for", lemma)
                return // TODO: throw
            }
            dictionary[lemma.id] = protonym
            
            lemma.node.protonym = ref
            
            for child in lemma.ownChildren.values {
                delete(child)
            }
            
            for id in dictionary.keys {
                guard let o = dictionary[id] else {
                    continue
                }
                if remove(type: lemma, from: o) {
                    add(type: protonym, to: o)
                }
            }

            lemma.node.children = nil
            lemma.node.type = nil
            lemma.protonym = protonym
            lemma.children = [:]
            lemma.type = [:]
        }
        else {
            dictionary[lemma.id] = lemma
            lemma.node.protonym = nil
            lemma.protonym = nil
            lemma.type[lemma.id] = Unowned(lemma)
        }
        serialization.date = .init()
    }
}
