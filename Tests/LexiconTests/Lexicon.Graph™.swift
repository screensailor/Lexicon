//
// github.com/screensailor 2022
//

import Hope
import Lexicon

class Lexicon_Graph™: Hopes {
	
	func test() async throws {
		let taskpaper = """
		root:
			a:
			+ root.a.b.c
				b:
				+ root.a
					c:
					+ root
			one:
			+ root.a
			+ root.first
				two:
					three:
			first:
				second:
					third:
		"""
		
		let root = try await Lexicon.from(TaskPaper(taskpaper).decode()).root
		
		for lemma in await root.sorted() {
			print(lemma)
		}
	}
}

public extension Lemma {
	
	func sorted() async -> [Lemma] {
		let nodes = await breadthFirstTraversal.reduce(into: []){ $0.append($1) }
		return nodes.sorted{ a, b in
			!a.is(b)
		}
	}
    
    func classes() async -> [Lemma.ID: Lexicon.Graph.Node.Class] {
        var mixins: [Lemma.ID: Lexicon.Graph.Node.Class] = [:]
        return await breadthFirstTraversal
            .map{ .init(lemma: $0, with: &mixins) }
            .reduce(into: [:]){ $0[$1.id] = $1 }
            .merging(mixins, uniquingKeysWith: { _, _ in fatalError() })
    }
}

public extension Lexicon.Graph.Node {
    
    struct Class: Hashable {
        
        public var id: Lemma.ID
        public var synonymOf: Lemma.Protonym?
        public var children: Set<Lemma.Name>?
        public var supertype: Lemma.ID?
        public var mixinType: Lemma.ID?
        public var mixinChildren: Set<Lemma.ID>?
        public var type: Set<Lemma.ID>?

        @LexiconActor
        init(lemma: Lemma, with mixins: inout [Lemma.ID: Lexicon.Graph.Node.Class]) {
            id = lemma.id
            synonymOf = lemma.protonym?.id
            children = Set(lemma.children.keys).unlessEmpty
            type = Set(lemma.type.keys).unlessEmpty
        }
        
        @inlinable public func `is`(_ type: Class) -> Bool {
            self.type?.contains(type.id) ?? false
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        public static func == (lhs: Class, rhs: Class) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension Lexicon.Graph.Node.Class {
    
    static func superclass(for type: Set<Lexicon.Graph.Node.Class>?, in graph: inout [Lemma.ID: Lexicon.Graph.Node.Class]) -> Lemma.ID? {
        guard let type = type, let first = type.first else {
            return nil
        }
        guard type.count > 1 else {
            return first.id
        }
        
        
        fatalError()
    }

}
