//
// github.com/screensailor 2022
//

import Lexicon
import UniformTypeIdentifiers

public enum Generator: CodeGenerator {
	
	// TODO: prefixes?
	
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
		
		return """
		import Foundation
		
		// MARK: I
		
		public protocol I: Sendable, TypeLocalized, SourceCodeIdentifiable {}

		public protocol TypeLocalized {
			static var localized: String { get }
		}

		public protocol SourceCodeIdentifiable: CustomDebugStringConvertible {
			var __: String { get }
		}

		public extension SourceCodeIdentifiable {
			@inlinable var debugDescription: String { __ }
		}

		public enum CallAsFunctionExtensions<X> {
			case from
		}

		public extension I {
			func callAsFunction<Property>(_ keyPath: KeyPath<CallAsFunctionExtensions<I>, (I) -> Property>) -> Property {
				CallAsFunctionExtensions.from[keyPath: keyPath](self)
			}
		}

		public extension CallAsFunctionExtensions where X == I {
			var id: (I) -> String {{ $0.__ }}
			var localizedType: (I) -> String {{ type(of: $0).localized }}
		}
		
		// MARK: L
		
		open class L: @unchecked Sendable, Hashable, I {
			open class var localized: String { "" }
			public let __: String
			public required init(_ id: String) { __ = id }
		}
		
		public extension L {
			static func == (lhs: L, rhs: L) -> Bool { lhs.__ == rhs.__ }
			func hash(into hasher: inout Hasher) { hasher.combine(__) }
		}
		
		// MARK: generated types
		
		public let \(name) = L_\(name)("\(name)")
		
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
		
		lines += """
		public final class \(L)_\(T): L, \(I)_\(T) {
		\tpublic override class var localized: String { NSLocalizedString("\(id)", comment: "") }
		}
		"""
		
		let supertype = supertype?
			.replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "__&__", with: ", I_")
		
		lines += "public protocol \(I)_\(T): \(I)\(supertype.map{ "_\($0)" } ?? "") {}"
		
		guard hasProperties else {
			return lines
		}
		
		let line = "public extension \(I)_\(T)"
		
		lines += line + " {"
		
		for child in children ?? [] {
			let id = "\(id).\(child)"
			lines += "\tvar `\(child)`: \(L)_\(id.idToClassSuffix) { .init(\"\\(__).\(child)\") }"
		}
		
		for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
			let id = "\(id).\(synonym)"
			lines += "\tvar `\(synonym)`: \(L)_\(id.idToClassSuffix) { \(protonym) }"
		}
		
		lines += "}"
		
		return lines
	}
	
}

private extension Lexicon.Graph.Node.Class.JSON {
	
	func swift_with_mixins(prefix: (class: String, protocol: String)) -> [String] {
		
		var lines: [String] = []
		let T = id.idToClassSuffix
		let (L, I) = prefix
		
		if let protonym = protonym {
			lines += "public typealias \(L)_\(T) = \(L)_\(protonym.idToClassSuffix)"
			return lines
		}
		
		if mixin == nil {
			let S = type?.map{ "\(I)_\($0.idToClassSuffix)" }.unlessEmpty?.joined(separator: ", ") ?? "\(I)"
			let line = "public protocol \(I)_\(T): \(S) {"
			if hasProperties {
				lines += line
				
				for child in children ?? [] {
					let id = "\(id).\(child)"
					lines += "\tvar `\(child)`: \(L)_\(id.idToClassSuffix) { get }"
				}
				
				for (synonym, _) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
					let id = "\(id).\(synonym)"
					lines += "\tvar `\(synonym)`: \(L)_\(id.idToClassSuffix) { get }"
				}
				
				lines += "}"
			}
			else {
				lines += line + "}"
			}
		}
		
		let line = "public class \(L)_\(T): \(L)\(supertype.map{ "_\($0.idToClassSuffix)" } ?? "")\(mixin == nil ? ", \(I)_\(T)" : "")"
		
		guard hasProperties else {
			lines += line + " {}"
			return lines
		}
		
		lines += line + " {"
		
		for child in children ?? [] {
			let id = "\(id).\(child)"
			lines += "\tpublic lazy var `\(child)` = \(L)_\(id.idToClassSuffix)(\"\\(__).\(child)\")"
		}
		
		for (synonym, protonym) in (synonyms?.sortedByLocalizedStandard(by: \.key) ?? []) {
			let id = "\(id).\(synonym)"
			lines += "\tpublic var `\(synonym)`: \(L)_\(id.idToClassSuffix) { \(protonym) }"
		}
		
		for (name, id) in mixin?.children?.sortedByLocalizedStandard(by: \.key) ?? [] {
			lines += "\tpublic lazy var `\(name)` = \(L)_\(id.idToClassSuffix)(\"\\(__).\(name)\")"
		}
		
		lines += "}"
		
		return lines
	}
}

private extension String {
	
	var idToClassSuffix: String {
		replacingOccurrences(of: "_", with: "__")
			.replacingOccurrences(of: ".", with: "_")
			.replacingOccurrences(of: "_&_", with: "_")
	}
}
