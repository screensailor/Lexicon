//
// github.com/screensailor 2022
//

import Lexicon
import Collections
import SwiftLexicon

public extension Lexicon.Graph.JSON {
	
	static let generators: OrderedDictionary<String, CodeGenerator.Type> = [
		
		"JSON with Mixins": JSONClasses.self,
		
		"Swift with Dependency": SwiftLexicon.Generator.self,
	]
}
