//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public enum JavaScriptTODO: CodeGenerator {
    
    public static let utType = UTType.javaScript
    public static var prefix = "L"
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.js(prefix: prefix).data(using: .utf8) else {
            throw "Failed to generate JavaScript file"
        }
        return o
    }
}

private extension Lexicon.Graph.JSON {
    
    func js(prefix L: String = "L") -> String {
        """
        // Generated on: \(date.iso())

        \(classes.flatMap{ $0.js(prefix: L) }.joined(separator: "\n"))
        """
    }
}

private extension Lexicon.Graph.Node.Class.JSON {
    
    func js(prefix L: String) -> [String] {
        []
    }
}
