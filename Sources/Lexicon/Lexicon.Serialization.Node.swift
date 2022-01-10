//
// github.com/screensailor 2021
//

public extension Lexicon.Serialization {

    class Node: Codable {
        
        public typealias ID = String
        public typealias Name = String

        public enum CodingKeys: String, CodingKey {
            case children = "."
            case protonym = "="
            case type     = "+"
        }

        public internal(set) var children: [Name: Node]?
        public internal(set) var protonym: ID?
        public internal(set) var type: Set<ID>?
        
        public init(children: [Name: Node]? = nil, type: Set<ID>? = nil) {
            self.children = children.flatMap{ $0.isEmpty ? nil : $0 }
            self.type = type.flatMap{ $0.isEmpty ? nil : $0 }
            self.protonym = nil
        }
        
        public init(protonym: ID) {
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

#if canImport(NaturalLanguage)
import NaturalLanguage

public extension Lexicon.Serialization.Node {
	
	static func from(sentences string: String) -> Lexicon.Serialization.Node {
		
		let root = Lexicon.Serialization.Node()
		
		let sentences = NLTokenizer(unit: .sentence)
		let words = NLTokenizer(unit: .word)
		
		sentences.string = string

		sentences.enumerateTokens(in: string.indices.range) { range, _ in
			
			var node = root
			
			let sentence = String(string[range])
			words.string = sentence
			
			words.enumerateTokens(in: sentence.indices.range) { range, _ in
				let word = String(sentence[range]).lowercased().filter(\.isLetter)
				node = node.children[word] ?? {
					let child = Lexicon.Serialization.Node()
					node.children[word] = child
					return child
				}()
				return true
			}
			return true
		}
		return root
	}
}
#endif
