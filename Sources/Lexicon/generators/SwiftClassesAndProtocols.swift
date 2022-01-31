//
// github.com/screensailor 2022
//

import UniformTypeIdentifiers

public enum SwiftClassesAndProtocols: CodeGenerator {
    
    public static let utType = UTType.swiftSource
    public static var prefix = (class: "L", protocol: "I")
    
    public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
        guard let o = json.swift(prefix: prefix).data(using: .utf8) else {
            throw "Failed to generate Swift file"
        }
        return o
    }
}

private extension Lexicon.Graph.JSON {
    
    func swift(prefix: (class: String, protocol: String) = SwiftClassesAndProtocols.prefix) -> String {
        
        let (L, I) = prefix
        
        // TODO: use swift file as template
        
        return """
        // Generated on: \(date.iso())
        
        public protocol \(I): CustomDebugStringConvertible {
            func callAsFunction() -> String
        }
        
        public let \(name) = \(L)_\(name)("\(name)")
        
        public class \(L): \(I) {
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
        
        \(classes.flatMap{ $0.swift(prefix: prefix) }.joined(separator: "\n"))
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
