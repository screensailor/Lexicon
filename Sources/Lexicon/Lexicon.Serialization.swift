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

	@LexiconActor
	static func from(sentences string: String, root name: Lemma.Name = "root") -> Lexicon.Serialization {
		
		let rootName = name
		
		let root = Lexicon.Serialization.Node()
		let word = Lexicon.Serialization.Node()
		let sentence = Lexicon.Serialization.Node()
		
		root.children = [
			"word": word,
			"sentence": sentence
		]
		
		let sentences = NLTokenizer(unit: .sentence)
		let tagger = NLTagger(tagSchemes: [.lexicalClass])
		let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther]
	
		sentences.string = string

		sentences.enumerateTokens(in: string.indices.range) { range, _ in
			
			var node = sentence
			
			let sentence = String(string[range])
			
			tagger.string = sentence
			
			tagger.enumerateTags(in: sentence.indices.range, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
				
				guard let tag = tag?.rawValue.lowercased() else {
					return true
				}
				
				var name = sentence[range].lowercased().trimmingCharacters(in: underscore).filter{ character in
					CharacterSet(charactersIn: String(character)).isSubset(of: Lemma.validCharacterOfName)
				}
				
				guard let first = name.first else {
					return true
				}
				
				if first.isNumber {
					name = "_\(name)"
				}
				
				node = node.children[name, inserting: .init()]

				if word.children[tag] == nil {
					word.children[tag] = .init()
				}
				
				node.type.insert("\(rootName).word.\(tag)")

				return true
			}
			return true
		}
		return .init(name: name, root: root)
	}
}
#endif
