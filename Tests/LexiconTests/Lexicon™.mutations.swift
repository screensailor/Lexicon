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
		
		let taskpaper = """
			o:
				a:
				+ o
				b:
					x:
				c:
				= a.b.x
				d:
				= a
			"""
			
		let a = try await taskpaper.lemma("o.a")
		let o = try await taskpaper.lemma("o")

		let a₂ = try await a.remove(type: o).try()
		
		await hope(that: a₂.lexicon.taskpaper()) == """
			o:
				a:
				b:
					x:
				d:
				= a
			"""
	}
}
