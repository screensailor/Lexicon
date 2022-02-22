//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public protocol CodeGenerator {
	static var utType: UTType { get }
	static func generate(_ json: Lexicon.Graph.JSON) throws -> Data
}
