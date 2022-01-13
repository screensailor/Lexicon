//
// github.com/screensailor 2021
//

import Foundation

public extension Lexicon {
    
    struct Serialization: Codable {

        public internal(set) var date: Date
        public internal(set) var name: Lemma.Name
        public let root: Node

		public init(name: Lemma.Name = "root", root: Node = .init(), date: Date = .init()) {
            self.name = name
            self.root = root
            self.date = date
        }
    }
}

extension Lexicon.Serialization {
	
	public func data(encoder: JSONEncoder = .init(), formatting: JSONEncoder.OutputFormatting = [.sortedKeys, .prettyPrinted]) -> Data {
		encoder.outputFormatting = formatting
		return try! encoder.encode(self)
	}
	
	public func string(formatting: JSONEncoder.OutputFormatting = [.sortedKeys, .prettyPrinted]) -> String {
		String(data: data(formatting: formatting), encoding: .utf8)!
	}
}

#if canImport(NaturalLanguage)
import NaturalLanguage

public extension Lexicon.Serialization {
	
	static let underscore = CharacterSet(charactersIn: "_")
	static let specialSentenceTerminator = CharacterSet(charactersIn: ";–()[]{}")

	@LexiconActor
	static func from(sentences string: String, root name: Lemma.Name = "root") -> Lexicon.Serialization {
		
		let root = Lexicon.Serialization.Node()
		let word = Lexicon.Serialization.Node()
		let sentence = Lexicon.Serialization.Node()
		
		root.children = [
			"word": word,
			"sentence": sentence
		]
		
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
					
					node = node.children[string, inserting: .init()]
					
					if word.children[token] == nil {
						word.children[token] = .init()
					}
					
					node.type.insert("\(name).word.\(token)")
					
					return true
				}
			}
			return true
		}
		return .init(name: name, root: root)
	}
}
#endif
