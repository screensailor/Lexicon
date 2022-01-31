//
// github.com/screensailor 2022
//

class Sentences™: Hopes {
	
	func test() async throws {
		
		/// https://en.wikipedia.org/wiki/Humpty_Dumpty
		let humpty = """
			Humpty Dumpty sat on a wall,
			Humpty Dumpty had a great fall.
			All the king's horses and
			All the king's men
			Couldn't put Humpty together again.
			"""
		
		let taskpaper = await TaskPaper.encode(.from(sentences: humpty, root: "rhyme"))
		
		hope(taskpaper) == """
			rhyme:
				sentence:
					all:
					+ rhyme.word.adverb
						the:
						+ rhyme.word.determiner
							king:
							+ rhyme.word.noun
								s:
								+ rhyme.word.particle
									horses:
									+ rhyme.word.noun
										and:
										+ rhyme.word.conjunction
									men:
									+ rhyme.word.noun
					could:
					+ rhyme.word.verb
						nt:
						+ rhyme.word.adverb
							put:
							+ rhyme.word.verb
								humpty:
								+ rhyme.word.noun
									together:
									+ rhyme.word.adverb
										again:
										+ rhyme.word.adverb
					humpty:
					+ rhyme.word.noun
						dumpty:
						+ rhyme.word.noun
							had:
							+ rhyme.word.verb
								a:
								+ rhyme.word.determiner
									great:
									+ rhyme.word.adjective
										fall:
										+ rhyme.word.noun
							sat:
							+ rhyme.word.verb
								on:
								+ rhyme.word.preposition
									a:
									+ rhyme.word.determiner
										wall:
										+ rhyme.word.noun
				word:
					adjective:
					adverb:
					conjunction:
					determiner:
					noun:
					particle:
					preposition:
					verb:
			"""
	}
}
