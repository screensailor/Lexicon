//
// github.com/screensailor 2022
//

import Lexicon

extension Lexicon™ {
	
	func test_delete_1() async throws {
		
		let taskpaper = """
			o:
				a:
				+ o.b
				b:
					x:
				c:
				= a.x
				d:
				= a
			"""
			
		let b = try await taskpaper.lemma("o.b")
		
		let o = try await b.delete().try()
		
		await hope(that: o.taskpaper()) == """
			o:
				a:
				d:
				= a
			"""
	}
}
