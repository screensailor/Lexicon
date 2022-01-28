//
// github.com/screensailor 2022
//

import Foundation

public extension Lexicon.Graph.JSON {
    
    func swift() -> String {
        
        return """
        // Generated on: \(Self.formatter.string(from: date))
        
        public let \(name) = \(L)_\(name)("\(name)")
        
        \(rootClass)
        
        \(classes.swift())
        """
    }
    
    static let formatter: ISO8601DateFormatter = { o in
        o.formatOptions.insert(.withFractionalSeconds)
        return o
    }(ISO8601DateFormatter())
}

public extension Sequence where Element == Lexicon.Graph.Node.Class.JSON {
    
    func swift() -> String {
        
        var lines: [String] = []
        
        for klass in self {
            
            if let protonym = klass.synonymOf {
                lines += "public typealias \(klass.id.idToClassName) = \(protonym.idToClassName)"
                continue
            }
            
            var line = "public class \(klass.id.idToClassName)"
            
            if let supertype = klass.supertype?.idToTypeSuffix {
                line += ": \(L)_\(supertype)"
            } else {
                line += ": \(L)"
            }
            
            if klass.children.isNotEmpty || klass.synonyms.isNotEmpty {
                line += " {"
                lines += line
                
                for child in klass.children ?? [] {
                    let id = klass.id + "." + child
                    lines += "    public var `\(child)`: \(id.idToClassName) { .init(\"\\(__id).\(child)\") }"
                }
                
                for (synonym, protonym) in klass.synonyms ?? [:] {
                    let id = klass.id + "." + synonym
                    lines += "    public var `\(synonym)`: \(id.idToClassName) { \(protonym) }"
                }
                
                line = "}"
                lines += line
            }
            else {
                line += " {}"
                lines += line
            }
        }
        
        return lines.joined(separator: "\n")
    }
}

private extension String {
    
    var idToClassName: String {
        "\(L)_\(idToTypeSuffix)"
    }
    
    var idToTypeSuffix: String {
        replacingOccurrences(of: "_", with: "__")
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "_&_", with: "_")
    }
}

private extension RangeReplaceableCollection {
    
    static func += (lhs: inout Self, rhs: Element) {
        lhs.append(rhs)
    }
}

private let L = "L"

private let rootClass = """
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
"""
