//
// github.com/screensailor 2021
//

import Foundation

public extension Lexicon {
    
    struct Graph {

        public internal(set) var date: Date
        public internal(set) var name: Lemma.Name
        public let root: Node

        public init(name: Lemma.Name = "root", date: Date = .init()) {
            self.date = date
            self.name = name
            self.root = Node(parent: nil, name: name)
        }

        public init(root: Node, date: Date = .init()) {
            self.date = date
            self.name = root.name
            self.root = root
        }
    }
}

public extension Lexicon.Graph {
    
    struct JSON: Codable {
        public var date: Date
        public var name: Lemma.Name
        public var classes: [Node.Class.JSON]
    }
}

public extension Lexicon {
    
    func json() async -> Graph.JSON {
        .init(
            date: graph.date,
            name: graph.name,
            classes: await root.classes().values.map(\.json).sortedByLocalizedStandard(by: \.id)
        )
    }
}

#if canImport(NaturalLanguage)
import NaturalLanguage

public extension Lexicon.Graph {
	
	static let underscore = CharacterSet(charactersIn: "_")
	static let specialSentenceTerminator = CharacterSet(charactersIn: ";–()[]{}")

	@LexiconActor
	static func from(sentences string: String, root name: Lemma.Name = "root") -> Lexicon.Graph {
		
        let root = Node(parent: nil, name: name)
        let word = Node(parent: root, name: "word")
        let sentence = Node(parent: root, name: "sentence")
		
		let tagger = NLTagger(tagSchemes: [.lexicalClass])
		let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
		let sentences = NLTokenizer(unit: .sentence)
		sentences.string = string

		sentences.enumerateTokens(in: string.indices.range) { range, _ in
			
			var node = sentence
			
			for sentence in string[range].components(separatedBy: specialSentenceTerminator) {
				
				tagger.string = sentence
				
				tagger.enumerateTags(in: sentence.indices.range, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
					
					guard let token = tag?.rawValue.lowercased() else {
						return true
					}
					
					var string = sentence[range].lowercased().trimmingCharacters(in: underscore).filter{ character in
						CharacterSet(charactersIn: String(character)).isSubset(of: Lemma.validCharacterOfName)
					}
					
					guard let first = string.first else {
						return true
					}
					
					if first.isNumber {
						string = "_\(string)"
					}
					
                    node = node.children[string, default: Node(parent: node, name: string)]
					
					if word.children[token] == nil {
						word.children[token] = Node(parent: word, name: token)
					}
					
					node.type.insert("\(name).word.\(token)")
					
					return true
				}
			}
			return true
		}
		return .init(root: root)
	}
}
#endif
