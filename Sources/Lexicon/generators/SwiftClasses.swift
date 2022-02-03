//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public enum SwiftClasses: CodeGenerator {
    
    public static let utType = UTType.swiftSource
    public static var prefix = "L"
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.swift(prefix: prefix).data(using: .utf8) else {
            throw "Failed to generate Swift file"
        }
        return o
    }
}

extension String {
    
    static func from(playgroundPage page: String) throws -> String {
        guard let url = Bundle.module.url(
            forResource: "Contents",
            withExtension: "swift",
            subdirectory: "Resources/Swift.playground/Pages/\(page).xcplaygroundpage"
        ) else {
            throw "Contents of the playground page '\(page)' not found"
        }
        let o = try String(contentsOf: url)
        guard
            let start =  o.range(of: "//: ## Template Start")?.upperBound,
            let end = o.range(of: "//: ## Template End")?.lowerBound
        else {
            throw "Playground page \(page) is missing start and end markup"
        }
        return String(o[start..<end])
    }
}

private extension Lexicon.Graph.JSON {
    
    func swift(prefix L: String = "L") -> String {
        
        var template = try! String.from(playgroundPage: "Classes")
        
        if L != "L" {
            template = template.replacingOccurrences(of: "L", with: L)
        }

        return """
        // Generated on: \(date.iso())
        
        public let \(name) = \(L)_\(name)("\(name)")
        \(template)
        \(classes.flatMap { $0.swift(prefix: L) }.joined(separator: "\n"))
        """
    }
}

private extension Lexicon.Graph.Node.Class.JSON {
    
    // TODO: make this more readable
    
    func swift(prefix L: String) -> [String] {
        
        var lines: [String] = []
        let T = id.idToTypeSuffix
        
        if let protonym = protonym {
            lines += "public typealias \(L)_\(T) = \(L)_\(protonym.idToTypeSuffix)"
            return lines
        }
        
        let line = "public class \(L)_\(T): \(L)\(supertype.map{ "_\($0.idToTypeSuffix)" } ?? "")"
        
        guard hasProperties else {
            lines += line + " {}"
            return lines
        }
        
        lines += line + " {"
        
        for child in children ?? [] {
            let id = "\(id).\(child)"
            lines += "    public lazy var `\(child)` = \(L)_\(id.idToTypeSuffix)(\"\\(__id).\(child)\")"
        }
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(id).\(synonym)"
            lines += "    public var `\(synonym)`: \(L)_\(id.idToTypeSuffix) { \(protonym) }"
        }
        
        for (name, id) in mixin?.children?.sortedByLocalizedStandard(by: \.key) ?? [] {
            lines += "    public lazy var `\(name)` = \(L)_\(id.idToTypeSuffix)(\"\\(__id).\(name)\")"
        }
        
        lines += "}"
        
        return lines
    }
}
