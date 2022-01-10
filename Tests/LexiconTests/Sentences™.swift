//
// github.com/screensailor 2022
//

final class Sentences™: Hopes {
	
	func test() throws {
		
		let humpty = """
			Humpty Dumpty sat on a wall:
			Humpty Dumpty had a great fall.
			All the King’s horses and
			All the King’s men
			Couldn’t put Humpty Dumpty in his place again.
			"""
		
		let node = Lexicon.Serialization.Node.from(sentences: humpty)
		
		let taskpaper = TaskPaper.encode(node: node, name: "rhyme")
		
		hope(taskpaper) == """
			rhyme:
				all:
					the:
						kings:
							horses:
								and:
							men:
				couldnt:
					put:
						humpty:
							dumpty:
								in:
									his:
										place:
											again:
				humpty:
					dumpty:
						had:
							a:
								great:
									fall:
						sat:
							on:
								a:
									wall:
			"""
	}
}
