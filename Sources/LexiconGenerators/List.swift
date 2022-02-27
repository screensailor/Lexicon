//
// github.com/screensailor 2022
//

import Lexicon
import Collections
import SwiftLexicon
import SwiftStandAlone

public extension Lexicon.Graph.JSON {
	
	static let generators: OrderedDictionary<String, CodeGenerator.Type> = [
		
		"JSON Classes & Mixins": JSONClasses.self,
		
		"Swift Library": SwiftLexicon.Generator.self,
		
		"Swift Stand-Alone": SwiftStandAlone.Generator.self,
	]
}
