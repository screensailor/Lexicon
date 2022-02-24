//
// github.com/screensailor 2022
//

class Lemma_Traversal™: Hopes {
	
	let sentences = """
		one two three
		a b c d
		"""
	
	func test_BreadthFirstTraversal() async throws {
		
		let sentences = """
			one two three
			a b c d
			"""
		
		let lemma = await Lexicon.from(.from(sentences: sentences)).root
		
		let hierarchy: [Lemma] = await lemma.breadthFirstTraversal.reduce(into: []){ $0.append($1) }
		
		hope(hierarchy.map(\.id)) == [
			"a",
			"a.sentence",
			"a.word",
			"a.sentence.a",
			"a.sentence.one",
			"a.word.determiner",
			"a.word.noun",
			"a.word.number",
			"a.sentence.a.b",
			"a.sentence.one.two",
			"a.sentence.a.b.c",
			"a.sentence.one.two.three",
			"a.sentence.a.b.c.d",
		]
	}
	
	func test_DepthFirstTraversal() async throws {
		
		let sentences = """
			one two three
			a b c d
			"""
		
		let lemma = await Lexicon.from(.from(sentences: sentences)).root
		
		let hierarchy: [Lemma] = await lemma.depthFirstTraversal.reduce(into: []){ $0.append($1) }
		
		hope(hierarchy.map(\.id)) == [
			"a",
			"a.sentence",
			"a.sentence.a",
			"a.sentence.a.b",
			"a.sentence.a.b.c",
			"a.sentence.a.b.c.d",
			"a.sentence.one",
			"a.sentence.one.two",
			"a.sentence.one.two.three",
			"a.word",
			"a.word.determiner",
			"a.word.noun",
			"a.word.number",
		]
	}
}
