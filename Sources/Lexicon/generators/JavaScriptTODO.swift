//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public enum JavaScriptTODO: CodeGenerator {
    
    public static var name = "JavaScript To Do..."
    
    public static let utType = UTType.javaScript
    public static var prefix = "L"
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.js(prefix: prefix).data(using: .utf8) else {
            throw "Failed to generate JavaScript file"
        }
        return o
    }
}

public extension Lexicon.Graph.JSON {
    
    func js(prefix L: String = "L") -> String {
        """
        // Generated on: \(date.iso())

        \(classes.js(prefix: L))
        """
    }
}

extension Sequence where Element == Lexicon.Graph.Node.Class.JSON {
    
    func js(prefix L: String) -> String {
        reduce(into: []) { $1.js(prefix: L, lines: &$0) }.joined(separator: "\n")
    }
}

extension Lexicon.Graph.Node.Class.JSON {
    
    func js(prefix L: String, lines: inout [String]) {

    }
}
