//
// github.com/screensailor 2022
//

import Lexicon

extension Lexicon™ { // MARK: delete
	
	func test_delete() async throws {
		
		let taskpaper = """
			o:
				a:
				+ o
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
				+ o
				d:
				= a
			"""
	}
}


extension Lexicon™ { // MARK: remove type
	
	func test_remove_type() async throws {

		
	}
}
