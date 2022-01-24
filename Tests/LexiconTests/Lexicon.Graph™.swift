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
//			print(lemma)
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
    
    func classes() -> [Lexicon.Graph.Node.Class.JSON] {
        fatalError()
    }
}

public extension Lexicon.Graph.Node {
    
    class Class: Hashable {
        
        var json: JSON
        var type: Set<Lemma.ID> = []
        
        @LexiconActor init(lemma: Lemma) {
            json = .init(
                id: lemma.id,
                synonymOf: lemma.protonym?.id,
                children: Set(lemma.children.keys).unlessEmpty,
                type: Set(lemma.type.keys).unlessEmpty
            )
            type = json.type ?? []
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(json.id)
        }
        
        public static func == (lhs: Class, rhs: Class) -> Bool {
            lhs.json.id == rhs.json.id
        }
        
        public struct JSON: Decodable {
            let id: Lemma.ID
            let synonymOf: Lemma.Protonym?
            let children: Set<Lemma.Name>?
            var supertype: Lemma.ID?
            var mixinType: Lemma.ID?
            var mixinChildren: [Lemma.ID]?
            let type: Set<Lemma.ID>?
        }
    }
}
