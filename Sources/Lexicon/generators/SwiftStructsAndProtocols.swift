//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public enum SwiftStructsAndProtocols: CodeGenerator {
    
    public static let utType = UTType.swiftSource
    // TODO: prefixes
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.swift().data(using: .utf8) else {
            throw "Failed to generate Swift file"
        }
        return o
    }
}

private extension Lexicon.Graph.JSON {
    
    func swift() -> String {
        
        let template = try! String.from(playgroundPage: "StructsAndProtocols")
        
        return """
        // Generated on: \(date.iso())
        
        public let \(name) = L_\(name)(__: "\(name)")
        \(template)
        \(classes.flatMap{ $0.swift(prefix: ("L", "I")) }.joined(separator: "\n"))
        """
    }
}

private extension Lexicon.Graph.Node.Class.JSON {
    
    // TODO: make this more readable
    
    func swift(prefix: (class: String, protocol: String)) -> [String] {
        
        guard mixin == nil else {
            return []
        }
        
        var lines: [String] = []
        let T = id.idToClassSuffix
        let (L, I) = prefix
        
        if let protonym = protonym {
            lines += "public typealias \(L)_\(T) = \(L)_\(protonym.idToClassSuffix)"
            return lines
        }
        
        lines += "public struct \(L)_\(T): Hashable, \(I)_\(T) { public let __: String }"
        
        let supertype = supertype?
            .replacingOccurrences(of: "_", with: "__")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "__&__", with: ", I_")

        lines += "public protocol \(I)_\(T): \(I)\(supertype.map{ "_\($0)" } ?? "") {}"
        
        let line = "public extension \(I)_\(T)"

        guard hasProperties else {
            lines += line + " {}"
            return lines
        }
        
        lines += line + " {"
        
        for child in children ?? [] {
            let id = "\(id).\(child)"
            lines += "    var `\(child)`: \(L)_\(id.idToClassSuffix) { .init(__: \"\\(__).\(child)\") }"
        }
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(id).\(synonym)"
            lines += "    var `\(synonym)`: \(L)_\(id.idToClassSuffix) { \(protonym) }"
        }
        
        lines += "}"
        
        return lines
    }
}
