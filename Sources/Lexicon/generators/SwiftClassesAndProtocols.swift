//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public enum SwiftClassesAndProtocols: CodeGenerator {
    
    public static let utType = UTType.swiftSource
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.swift().data(using: .utf8) else {
            throw "Failed to generate Swift file"
        }
        return o
    }
}

private extension Lexicon.Graph.JSON {
    
    func swift() -> String {
        
        let template = try! String.from(playgroundPage: "ClassesAndProtocols")
        
        return """
        // Generated on: \(date.iso())
        
        public let \(name) = L_\(name)("\(name)")
        \(template)
        \(classes.flatMap{ $0.swift(prefix: ("L", "I")) }.joined(separator: "\n"))
        """
    }
}

private extension Lexicon.Graph.Node.Class.JSON {
    
    // TODO: make this more readable
    
    func swift(prefix: (class: String, protocol: String)) -> [String] {
        
        var lines: [String] = []
        let T = id.idToTypeSuffix
        let (L, I) = prefix
        
        if let protonym = protonym {
            lines += "public typealias \(L)_\(T) = \(L)_\(protonym.idToTypeSuffix)"
            return lines
        }

        if mixin == nil {
            let S = type?.map{ "\(I)_\($0.idToTypeSuffix)" }.unlessEmpty?.joined(separator: ", ") ?? "\(I)"
            let line = "public protocol \(I)_\(T): \(S) {"
            if hasProperties {
                lines += line
                
                for child in children ?? [] {
                    let id = "\(id).\(child)"
                    lines += "    var `\(child)`: \(L)_\(id.idToTypeSuffix) { get }"
                }
                
                for (synonym, _) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
                    let id = "\(id).\(synonym)"
                    lines += "    var `\(synonym)`: \(L)_\(id.idToTypeSuffix) { get }"
                }

                lines += "}"
            }
            else {
                lines += line + "}"
            }
        }
        
        let line = "public class \(L)_\(T): \(L)\(supertype.map{ "_\($0.idToTypeSuffix)" } ?? "")\(mixin == nil ? ", \(I)_\(T)" : "")"
        
        guard hasProperties else {
            lines += line + " {}"
            return lines
        }
        
        lines += line + " {"

        for child in children ?? [] {
            let id = "\(id).\(child)"
            lines += "    public lazy var `\(child)` = \(L)_\(id.idToTypeSuffix)(\"\\(__).\(child)\")"
        }
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(id).\(synonym)"
            lines += "    public var `\(synonym)`: \(L)_\(id.idToTypeSuffix) { \(protonym) }"
        }
        
        for (name, id) in mixin?.children?.sortedByLocalizedStandard(by: \.key) ?? [] {
            lines += "    public lazy var `\(name)` = \(L)_\(id.idToTypeSuffix)(\"\\(__).\(name)\")"
        }
        
        lines += "}"

        return lines
    }
}
