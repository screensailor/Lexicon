//
// github.com/screensailor 2022
//

import Foundation
import UniformTypeIdentifiers

public enum JSONClasses: CodeGenerator {
    
    public static let utType: UTType = .json
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(json)
    }
}
