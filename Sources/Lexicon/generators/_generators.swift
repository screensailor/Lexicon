//
// github.com/screensailor 2022
//

import Collections
import UniformTypeIdentifiers

public extension UTType {
    static var taskpaper = UTType(importedAs: "com.taskpaper.plain-text")
}

public protocol CodeGenerator {
    static var utType: UTType { get }
    static func generate(_ json: Lexicon.Graph.JSON) throws -> Data
}

public extension Lexicon.Graph.JSON {
    
    static let generators: OrderedDictionary<String, CodeGenerator.Type> = [
        
        "JSON Classes": JSONClasses.self,
        
        "Swift Classes": SwiftClasses.self,
        
        "Swift Classes & Protocols": SwiftClassesAndProtocols.self,
        
        "Swift Structs & Protocols": SwiftStructsAndProtocols.self
    ]
}
