//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public protocol CodeGenerator {
    static var type: UTType { get }
    static func generate(_ json: Lexicon.Graph.JSON) throws -> Data
}

public extension Lexicon.Graph.JSON {
    
    static let generators: [CodeGenerator.Type] = [
        GenJSON.self,
        GenSwift.self,
        GenJavaScript.self,
    ]
}
