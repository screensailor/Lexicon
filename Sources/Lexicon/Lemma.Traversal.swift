//
// github.com/screensailor 2022
//

import Collections

public extension Lemma {
    
    nonisolated var breadthFirstTraversal: BreadthFirstTraversal {
        BreadthFirstTraversal(of: self)
    }
    
    /// - note: Lemmas descendants can change during async traversal.
    struct BreadthFirstTraversal: AsyncSequence, AsyncIteratorProtocol {
        
        public typealias Element = Lemma
        public let lemma: Lemma
        
        private lazy var buffer: Deque<Lemma> = [lemma]
        
        public init(of lemma: Lemma) {
            self.lemma = lemma
        }
        
        public mutating func next() async -> Lemma? {
            guard let first = buffer.popFirst() else {
                return nil
            }
            await buffer.append(contentsOf: first.children.values.sorted(by: \.id))
            return first
        }
        
        public func makeAsyncIterator() -> BreadthFirstTraversal {
            self
        }
    }
}

public extension Lemma {
    
    nonisolated var depthFirstTraversal: DepthFirstTraversal {
        DepthFirstTraversal(of: self)
    }
    
    /// - note: Lemmas descendants can change during async traversal.
    struct DepthFirstTraversal: AsyncSequence, AsyncIteratorProtocol {
        
        public typealias Element = Lemma
        public let lemma: Lemma
        
        private lazy var buffer: [Lemma] = [lemma]
        
        public init(of lemma: Lemma) {
            self.lemma = lemma
        }
        
        public mutating func next() async -> Lemma? {
            guard let last = buffer.popLast() else {
                return nil
            }
            await buffer.append(contentsOf: last.children.values.sorted(by: \.id).reversed())
            return last
        }
        
        public func makeAsyncIterator() -> DepthFirstTraversal {
            self
        }
    }
}
