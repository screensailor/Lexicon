//
// github.com/screensailor 2022
//

import Lexicon

extension Lexicon™ {
	
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
		let o = try await a.lexicon["o"].try()

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
	
	func test_remove_protonym() async throws {
		
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
			
		let c = try await taskpaper.lemma("o.c")

		let c₂ = try await c.removeProtonym().try()
		
		await hope(that: c₂.lexicon.taskpaper()) == """
			o:
				a:
				+ o
				b:
					x:
				c:
				d:
				= a
			"""
	}
	
	func test_set_protonym() async throws {
		
		let taskpaper = """
			o:
				a:
				+ o
				b:
					x:
				c:
				d:
				= a
			"""
			
		let c = try await taskpaper.lemma("o.c")
		let x = try await c.lexicon["o.a.b.x"].try()

		let c₂ = try await c.set(protonym: x).try()

		await hope(that: c₂.lexicon.taskpaper()) == """
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
	}
}
