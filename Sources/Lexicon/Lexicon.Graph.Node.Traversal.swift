//
// github.com/screensailor 2022
//

import Collections

public extension Lexicon.Graph {
	
	enum Traversal {
		case depthFirst
		case breadthFirst
	}
}

public extension Lexicon.Graph.Node {
	
	func descendants(_ traversal: Lexicon.Graph.Traversal) -> AnySequence<Lexicon.Graph.Node> {
		switch traversal {
			case .depthFirst: return AnySequence(DepthFirstTraversal(of: self))
			case .breadthFirst: return AnySequence(BreadthFirstTraversal(of: self))
		}
	}
	
	struct BreadthFirstTraversal: Sequence, IteratorProtocol {
		
		public typealias Element = Lexicon.Graph.Node
		public let node: Element
		
		private lazy var buffer: Deque<Element> = [node]
		
		public init(of node: Element) {
			self.node = node
		}
		
		public mutating func next() -> Element? {
			guard let first = buffer.popFirst() else {
				return nil
			}
			buffer.append(contentsOf: first.children.values.sortedByLocalizedStandard(by: \.name, .orderedAscending))
			return first
		}
		
		public func makeIterator() -> BreadthFirstTraversal {
			self
		}
	}
	
	struct DepthFirstTraversal: Sequence, IteratorProtocol {
		
		public typealias Element = Lexicon.Graph.Node
		public let node: Element
		
		private lazy var buffer: [Element] = [node]
		
		public init(of node: Element) {
			self.node = node
		}
		
		public mutating func next() -> Element? {
			guard let last = buffer.popLast() else {
				return nil
			}
			buffer.append(contentsOf: last.children.values.sortedByLocalizedStandard(by: \.name, .orderedDescending))
			return last
		}
		
		public func makeIterator() -> DepthFirstTraversal {
			self
		}
	}
}

public extension Lexicon.Graph.Node {
	
	func descendantsWithPaths(_ traversal: Lexicon.Graph.Traversal) -> AnySequence<(Lexicon.Graph.Node, Lexicon.Graph.Path)> {
		switch traversal {
			case .depthFirst: return AnySequence(DepthFirstTraversalWithPaths(of: self))
			case .breadthFirst: return AnySequence(BreadthFirstTraversalWithPaths(of: self))
		}
	}
	
	struct BreadthFirstTraversalWithPaths: Sequence, IteratorProtocol {

		public typealias Element = (Node, Path)
		public typealias Path = Lexicon.Graph.Path
		public typealias Node = Lexicon.Graph.Node
		
		public let node: Node

		private lazy var buffer: Deque<Element> = [(node, \.self)]

		public init(of node: Node) {
			self.node = node
		}

		public mutating func next() -> Element? {
			guard let (node, path) = buffer.popFirst() else {
				return nil
			}
			let children = node.children.values.lazy
				.sortedByLocalizedStandard(by: \.name, .orderedAscending)
				.map{ child in (child, path.appending(path: \.[child.name])) }
			buffer.append(contentsOf: children)
			return (node, path)
		}

		public func makeIterator() -> BreadthFirstTraversalWithPaths {
			self
		}
	}
	
	struct DepthFirstTraversalWithPaths: Sequence, IteratorProtocol {
		
		public typealias Element = (Node, Path)
		public typealias Path = Lexicon.Graph.Path
		public typealias Node = Lexicon.Graph.Node

		public let node: Node
		
		private lazy var buffer: [Element] = [(node, \.self)]

		public init(of node: Node) {
			self.node = node
		}
		
		public mutating func next() -> Element? {
			guard let (node, path) = buffer.popLast() else {
				return nil
			}
			let children = node.children.values.lazy
				.sortedByLocalizedStandard(by: \.name, .orderedDescending)
				.map{ child in (child, path.appending(path: \.[child.name])) }
			buffer.append(contentsOf: children)
			return (node, path)
		}
		
		public func makeIterator() -> DepthFirstTraversalWithPaths {
			self
		}
	}
}
