//
// github.com/screensailor 2021
//

import Foundation

public extension Lexicon {
	
	struct Graph {
		
		public var date: Date
		public var root: Node
		
		public init(name: Lemma.Name = "root", date: Date = .init()) {
			self.date = date
			self.root = Node(root: name)
		}
		
		public init(root: Node, date: Date = .init()) {
			self.date = date
			self.root = root
		}
	}
}

extension Lexicon.Graph: Equatable {
	
	public static func == (lhs: Lexicon.Graph, rhs: Lexicon.Graph) -> Bool { // TODO: super dodgy
		lhs.date == rhs.date &&
		lhs.root.name == rhs.root.name
	}
}

extension Lexicon.Graph: CustomStringConvertible {
	
	public var description: String {
		"\(Self.self)(root: \(root.name), date: \(date)"
	}
}

#if canImport(NaturalLanguage)
import NaturalLanguage

public extension Lexicon.Graph {
	
	static let underscore = CharacterSet(charactersIn: "_")
	static let specialSentenceTerminator = CharacterSet(charactersIn: ";–()[]{}")
	
	static func from(sentences string: String, root name: Lemma.Name = "root") -> Lexicon.Graph {
		
		var root = Node(root: name)
		
		root.make(child: "word")
		root.make(child: "sentence")
		
		let word: WritableKeyPath<Node, Node> = \.["word"]
		let sentence: WritableKeyPath<Node, Node> = \.["sentence"]
		
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
					
					root[keyPath: node].make(child: string)
					node = node.appending(path: \.[string])
					
					root[keyPath: node].type.insert(
						root[keyPath: word].make(child: token).id
					)
					
					return true
				}
			}
			return true
		}
		return Lexicon.Graph(root: root)
	}
}
#endif
