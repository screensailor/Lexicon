//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public struct GenSwift: CodeGenerator {
    
    public static let type = UTType.swiftSource
    public static var prefix = "L"
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.swift(prefix: prefix).data(using: .utf8) else {
            throw "Failed to generate Swift file"
        }
        return o
    }
}

public extension Lexicon.Graph.JSON {
    
    func swift(prefix L: String = "L") -> String {
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

        \(classes.swift(prefix: L))
        """
    }
}

extension Sequence where Element == Lexicon.Graph.Node.Class.JSON {
    
    func swift(prefix L: String) -> String {
        reduce(into: []) { $1.swift(prefix: L, lines: &$0) }.joined(separator: "\n")
    }
}

extension Lexicon.Graph.Node.Class.JSON {
    
    func swift(prefix L: String, lines: inout [String]) {
        
        if let protonym = protonym {
            let alias = id.idToTypeName(prefix: L)
            let type = protonym.idToTypeName(prefix: L)
            lines += "public typealias \(alias) = \(type)"
            return
        }
        
        var line = "public class \(id.idToTypeName(prefix: L))"
        
        if let supertype = supertype {
            line += ": \(L)_\(supertype.idToTypeSuffix)"
        } else {
            line += ": \(L)"
        }
        
        guard hasProperties else {
            line += " {}"
            lines += line
            return
        }
        
        line += " {"
        lines += line
        
        for child in children ?? [] {
            let id = "\(id).\(child)"
            let type = id.idToTypeName(prefix: L)
            lines += "    public var `\(child)`: \(type) { .init(\"\\(__id).\(child)\") }"
        }
        
        for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
            let id = "\(id).\(synonym)"
            let type = id.idToTypeName(prefix: L)
            lines += "    public var `\(synonym)`: \(type) { \(protonym) }"
        }
        
        for (name, id) in mixin?.children?.sortedByLocalizedStandard(by: \.key) ?? [] {
            let type = id.idToTypeName(prefix: L)
            lines += "    public var `\(name)`: \(type) { .init(\"\\(__id).\(name)\") }"
        }
        
        line = "}"
        lines += line
    }
}
