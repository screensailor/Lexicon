//
// github.com/screensailor 2022
//

import Lexicon

extension Lexicon™ {
	
	func test_() async throws {
		
		let taskpaper = try "test".taskpaper()

		let lexicon = try await taskpaper.lexicon()
		
		// TODO: !
		
		await hope(that: TaskPaper.encode(lexicon.graph)) == taskpaper
	}
}

private let x = """
root:
	A:
	= a
	B:
	= a.b
	a:
	+ root.a.b.c
		b:
		+ root.a
			c:
			+ root
	bad:
		worse:
			worst:
	first:
		second:
			third:
	good:
		better:
			best:
	one:
	+ root.a
		two:
		+ root.a
		+ root.first
			three:
			+ root.a
			+ root.bad
			+ root.first
				four:
				+ root.a
				+ root.bad
				+ root.first
				+ root.good
	x_y_z:
	= a.b.c
"""
