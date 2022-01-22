//
// github.com/screensailor 2022
//

import Hope
import Lexicon

class Lemma_Find™: Hopes {
    
    let sentences = """
        one two three
        a b c d
        """
    
    func test_() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("").map(\.id)
        hope(o) == []
    }
    
    func test_c() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("c").map(\.id)
        hope(o) == ["root.sentence.a.b.c"]
    }
    
    func test_C() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("c").map(\.id)
        hope(o) == ["root.sentence.a.b.c"]
    }

    func test_n() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("n").map(\.id).sorted()
        hope(o) == [
            "root.word.noun",
            "root.word.number",
        ]
    }
    
    func test_w_n() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("w", "n").map(\.id).sorted()
        hope(o) == [
            "root.word.noun",
            "root.word.number",
        ]
    }
    
    func test_w__n() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("w", "", "n").map(\.id).sorted()
        hope(o) == [
            "root.word.noun",
            "root.word.number",
        ]
    }
    
    func test_a_b() async throws {
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("a", "b").map(\.id)
        hope(o) == [
            "root.sentence.a.b",
        ]
    }
    
    func test_b_d() async throws {
        
        let sentences = """
        one two three
        a b c d
        b c d
        """
        
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        let o = await lemma.find("b", "d").map(\.id).sorted()
        hope(o) == [
            "root.sentence.a.b.c.d",
            "root.sentence.b.c.d",
        ]
    }
    
    func test_a_d() async throws {
        
        let sentences = """
        one two three
        a b c d
        b c d a b c d
        """
        let lemma = await Lexicon.from(.from(sentences: sentences)).root
        do {
            let o = await lemma.find("a", "d").map(\.id).sorted()
            hope(o) == [
                "root.sentence.a.b.c.d",
                "root.sentence.b.c.d.a.b.c.d",
            ]
        }
        do {
            let o = await lemma.find("b", "d").map(\.id).sorted()
            hope(o) == [
                "root.sentence.a.b.c.d",
                "root.sentence.b.c.d",
                "root.sentence.b.c.d.a.b.c.d",
            ]
        }
    }
}
