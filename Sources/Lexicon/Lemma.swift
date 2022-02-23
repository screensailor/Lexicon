//
// github.com/screensailor 2021
//

import Foundation

@LexiconActor
public class Lemma {
	
	public typealias ID = String
	public typealias Name = String
	public typealias Protonym = String
	public typealias Description = String
	
	public internal(set) var node: Lexicon.Graph.Node
	
	nonisolated public let id: ID
	nonisolated public let name: Name
	nonisolated public unowned let parent: Lemma?
	nonisolated public unowned let lexicon: Lexicon
	
	public internal(set) lazy var protonym: Unowned<Lemma>? = lazy_protonym()
	
	public internal(set) lazy var children: [Name: Lemma] = lazy_children()
	public internal(set) var ownChildren: [Name: Lemma] = [:]
	
	public internal(set) lazy var type: [ID: Unowned<Lemma>] = lazy_type()
	public internal(set) lazy var ownType: [ID: Unowned<Lemma>] = lazy_ownType()
	
	init(name: Name, node: Lexicon.Graph.Node, parent: Lemma?, lexicon: Lexicon) {
		
		self.id = parent.map{ "\($0.id).\(name)" } ?? name
		self.name = name
		self.node = node
		self.parent = parent
		self.lexicon = lexicon
		
		lexicon.dictionary[id] = self
		
		for (name, node) in node.children {
			ownChildren[name] = Lemma(name: name, node: node, parent: self, lexicon: lexicon)
		}
	}
	
	deinit {
		// TODO: just ensure that this ↓ is indeed no longer needed in view of the value semantic graph
//		lexicon.deiniting(lemma: self)
//		print("🗑 \(self)")
	}
}

public extension Lemma {
	
	func regenerateNode(_ ƒ: ((Lemma) -> ())? = nil) -> Lexicon.Graph.Node {
		ƒ?(self)
		if let protonym = node.protonym {
			return Lexicon.Graph.Node(
				id: node.id,
				name: node.name,
				protonym: protonym
			)
		} else {
			return Lexicon.Graph.Node(
				id: node.id,
				name: node.name,
				children: ownChildren.mapValues{ $0.regenerateNode(ƒ) },
				type: Set(ownType.values.map(\.node.id))
			)
		}
	}
	
	var graph: Lexicon.Graph {
		Lexicon.Graph(root: node, date: lexicon.graph.date)
	}
	
	var source: Lemma {
		sourceProtonym ?? self
	}
	
	var sourceProtonym: Lemma? {
		guard let o = protonym?.unwrapped else { return nil }
		return o.sourceProtonym ?? o
	}
}

public extension Lemma {
	
	nonisolated static let validFirstCharacterOfName = CharacterSet.letters
	nonisolated static let validCharacterOfName = CharacterSet.letters.union(.decimalDigits).union(.init(charactersIn: "_"))
	
	nonisolated static func isValid(name: Name) -> Bool {
		guard
			let first = name.first,
			CharacterSet(charactersIn: String(first)).isSubset(of: Lemma.validFirstCharacterOfName)
		else {
			return false
		}
		return CharacterSet(charactersIn: String(name.dropFirst()))
			.isSubset(of: Lemma.validCharacterOfName)
	}
	
	func isValid(newName: Name) -> Bool {
		isGraphNode &&
		parent?.children[newName] == nil &&
		name != newName &&
		Lemma.isValid(name: newName)
	}
	
	func isValid(newChildName name: Name) -> Bool {
		isGraphNode &&
		children[name] == nil &&
		Lemma.isValid(name: name)
	}
}

public extension Lemma {
	
	func isValid(newType type: Lemma) -> Bool {
		self.isGraphNode &&
		type.isGraphNode &&
		!self.is(type)
	}
}

public extension Lemma {
	
	@discardableResult @inlinable func add(child: Lexicon.Graph) -> Lemma? {
		lexicon.add(child: child, to: self)
	}
	
	@discardableResult @inlinable func add(child name: Lemma.Name, node: Lexicon.Graph.Node) -> Lemma? {
		lexicon.add(child: name, node: node, to: self)
	}
	
	@discardableResult @inlinable func add(childrenOf node: Lexicon.Graph.Node) -> Lemma? {
		lexicon.add(childrenOf: node, to: self)
	}
	
	@discardableResult func inherit(child name: Lemma.Name, node: Lexicon.Graph.Node) -> Lemma? {
		lexicon.inherit(child: name, node: node, to: self)
	}
}

public extension Lemma { // MARK: additive mutations
	
	@inlinable func make(child: Name) -> Lemma? {
		lexicon.make(child: child, to: self)
	}
	
	@inlinable func add(type: Lemma) -> Lemma? {
		lexicon.add(type: type, to: self)
	}
}

public extension Lemma { // MARK: non-additive mutations
	
	@inlinable func rename(to name: Lemma.Name) -> Lemma? {
		lexicon.rename(self, to: name)
	}
	
	@inlinable func delete() -> Lemma? {
		lexicon.delete(self)
	}
	
	@inlinable func remove(type: Lemma) -> Lemma? {
		lexicon.remove(type: type, from: self)
	}
	
	@inlinable func set(protonym: Lemma?) -> Lemma? {
		lexicon.set(protonym: protonym, of: self)
	}
}

public extension Lemma {
	
	@inlinable subscript(descendant: Name...) -> Lemma? {
		self[descendant]
	}
	
	subscript<Descendant>(descendant: Descendant) -> Lemma? where Descendant: Collection, Descendant.Element == Name {
		var o = self
		for name in descendant {
			guard let lemma = o.children[name] else {
				return nil
			}
			o = lemma.protonym?.unwrapped ?? lemma
		}
		return o
	}
}

public extension Lemma {
	
	@inlinable var isGraphNode: Bool {
		id == node.id
	}
	
	@inlinable var graphNode: Lexicon.Graph.Node? {
		isGraphNode ? node : nil
	}

	@inlinable var lineage: UnfoldSequence<Lemma, (Lemma?, Bool)> {
		sequence(first: self, next: \.parent)
	}
	
	@inlinable func `is`(_ type: Lemma) -> Bool {
		self.type.keys.contains(type.id)
	}
	
	func validated(protonym: Lemma) -> (Protonym, Lemma)? {
		let protonym = Array(sequence(first: protonym, next: \.protonym?.unwrapped)).last!
		guard let parent = parent, protonym.isDescendant(of: parent) else {
			return nil
		}
		return (protonym.id.dotPath(after: parent.id), protonym)
	}
	
	func isValid(protonym: Lemma) -> Bool {
		guard
			let parent = parent,
			protonym != self,
			!protonym.isDescendant(of: self),
			protonym.isDescendant(of: parent)
		else {
			return false
		}
		return true
	}
	
	func isValid(inheritance type: Lemma) -> Bool {
		!self.is(type)
	}
}

public extension Lemma { // TODO: consider moving these ↓ to Node
	
	func isAncestor(of other: Lemma) -> Bool {
		id.isDotPathAncestor(of: other.id)
	}
	
	func isDescendant(of other: Lemma) -> Bool {
		id.isDotPathDescendant(of: other.id)
	}
	
	func isInLineage(of other: Lemma) -> Bool {
		id == other.id || isDescendant(of: other)
	}
}

extension String {
	
	func isDotPathAncestor(of other: String) -> Bool {
		other.count > count + 1 &&
		other[other.index(other.startIndex, offsetBy: count)] == "." &&
		other.hasPrefix(self)
	}
	
	func isDotPathDescendant(of other: String) -> Bool {
		other.isDotPathAncestor(of: self)
	}
}

extension Lemma: Equatable {
	@inlinable nonisolated public static func == (lhs: Lemma, rhs: Lemma) -> Bool {
		lhs === rhs
	}
}

extension Lemma: Hashable {
	@inlinable nonisolated public func hash(into hasher: inout Hasher) {
		hasher.combine(ObjectIdentifier(self))
	}
}

extension Lemma: Comparable {
	
	@inlinable nonisolated public static func < (lhs: Lemma, rhs: Lemma) -> Bool {
		lhs.id < rhs.id
	}
}

extension Lemma: CustomStringConvertible {
	
	@inlinable nonisolated public var description: String {
		id
	}
}

public extension Lemma {
	
	nonisolated static let numericPrefixCharacterSet = CharacterSet(charactersIn: "_")
	
	nonisolated var displayName: Lemma.Name {
		switch name.isEmpty {
			case true: return "_"
			case false: return name
					.trimmingCharacters(in: Self.numericPrefixCharacterSet)
					.replacingOccurrences(of: "_", with: " ")
		}
	}
}

extension Lemma {
	
	func lazy_protonym() -> Unowned<Lemma>? {
		guard let suffix = node.protonym else {
			return nil
		}
		guard let parent = parent else {
			print("😱Synonym '\(suffix)', lemma '\(id)', does not have a parent.")
			return nil
		}
		guard let protonym = parent[suffix.components(separatedBy: ".")] else {
			print("😱Could not find protonym '\(suffix)' of \(id)")
			return nil
		}
		lexicon.dictionary[id] = protonym
		return .init(protonym)
	}
	
	func lazy_children() -> [Name: Lemma] {
		if let protonym = protonym {
			var o: [Name: Lemma] = [:]
			for (name, child) in protonym.children {
				o[name] = Lemma(name: name, node: child.node, parent: self, lexicon: lexicon)
			}
			return o
		}
		var o = ownChildren
		for (_, type) in ownType {
			for (name, lemma) in type.children {
				o[name] = Lemma(name: name, node: lemma.node, parent: self, lexicon: lexicon)
			}
		}
		return o
	}
	
	func lazy_type() -> [ID: Unowned<Lemma>] {
		if let protonym = protonym {
			return protonym.type
		}
		var o = ownType
		o[id] = self
		for (_, lemma) in ownType {
			o.merge(lemma.type){ o, _ in o }
		}
		return o
	}
	
	func lazy_ownType() -> [ID: Unowned<Lemma>] {
		var o: [ID: Unowned<Lemma>] = [:]
		for id in node.type {
			o[id] = lexicon.dictionary[id].map(Unowned.init)
		}
		return o
	}
}
