//
// github.com/screensailor 2022
//

import Lexicon
import Hope

class Lemma_Traversal™: Hopes {

    func test_BreadthFirstTraversal() async throws {
        
        let sentences = """
            one two three
            a b c d
            """
        
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        
        for await lemma in lemma.breadthFirstTraversal {
            print(lemma)
            try await Task.sleep(nanoseconds: 100000)
        }
        
        let hierarchy: [Lemma] = await lemma.breadthFirstTraversal.reduce(into: []){ $0.append($1) }
        
        hope(hierarchy.map(\.id)) == [
            "root",
            "root.sentence",
            "root.word",
            "root.sentence.a",
            "root.sentence.one",
            "root.word.determiner",
            "root.word.noun",
            "root.word.number",
            "root.sentence.a.b",
            "root.sentence.one.two",
            "root.sentence.a.b.c",
            "root.sentence.one.two.three",
            "root.sentence.a.b.c.d",
        ]
    }
    
    func test_DepthFirstTraversal() async throws {
        
        let sentences = """
            one two three
            a b c d
            """
        
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        
        let hierarchy: [Lemma] = await lemma.depthFirstTraversal.reduce(into: []){ $0.append($1) }
        
//        for lemma in hierarchy {
//            print("\"\(lemma)\",")
//        }
        
        hope(hierarchy.map(\.id)) == [
            "root",
            "root.sentence",
            "root.sentence.a",
            "root.sentence.a.b",
            "root.sentence.a.b.c",
            "root.sentence.a.b.c.d",
            "root.sentence.one",
            "root.sentence.one.two",
            "root.sentence.one.two.three",
            "root.word",
            "root.word.determiner",
            "root.word.noun",
            "root.word.number",
        ]
    }
}
