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

private extension Lexicon.Graph.JSON {
    
    func swift(prefix L: String = "L") -> String {
        
        // TODO: use swift file as template

        """
        // Generated on: \(date.iso())
        
        public let \(name) = \(L)_\(name)("\(name)")
        
        public class \(L) {
            fileprivate var __id: String
            fileprivate init(_ id: String) { __id = id }
        }
        
        extension \(L) {
            public func callAsFunction() -> String { __id }
        }
        
        extension \(L): Equatable {
            public static func == (lhs: \(L), rhs: \(L)) -> Bool {
                lhs.__id == rhs.__id
            }
        }
        
        extension \(L): Hashable {
            public func hash(into hasher: inout Hasher) {
                hasher.combine(__id)
            }
        }
        
        extension \(L): CustomDebugStringConvertible {
            public var debugDescription: String { __id }
        }

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
