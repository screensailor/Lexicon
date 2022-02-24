//
// github.com/screensailor 2022
//

import Collections

public extension Lexicon.Graph.Node {
	
	func descendants(_ traversal: Traversal) -> AnySequence<Lexicon.Graph.Node> {
		switch traversal {
			case .depthFirst: return AnySequence(DepthFirstTraversal(of: self))
			case .breadthFirst: return AnySequence(BreadthFirstTraversal(of: self))
		}
	}
	
	enum Traversal {
		case depthFirst
		case breadthFirst
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
			buffer.append(contentsOf: first.children.values.sortedByLocalizedStandard(by: \.name))
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
			buffer.append(contentsOf: last.children.values.sortedByLocalizedStandard(by: \.name).reversed())
			return last
		}
		
		public func makeIterator() -> DepthFirstTraversal {
			self
		}
	}
}
