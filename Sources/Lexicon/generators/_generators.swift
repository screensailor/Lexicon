//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public protocol CodeGenerator {
    static var utType: UTType { get }
    static func generate(_ json: Lexicon.Graph.JSON) throws -> Data
}

public extension Lexicon.Graph.JSON {
    
    static let generators: [String: CodeGenerator.Type] = [
        
        "JSON Classes with Mixins": JSONClassesWithMixins.self,
        
        "Swift Classes with Mixins": SwiftClassesWithMixins.self,
    ]
}
