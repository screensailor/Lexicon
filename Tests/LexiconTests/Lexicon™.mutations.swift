//
// github.com/screensailor 2022
//

import Lexicon

extension Lexicon™ {
	
	// MARK: additive mutations
	
	func test_make_child_graph() async throws {
				
		let taskpaper = """
			o:
				copy:
					a:
					+ o
						b:
							c:
								d:
								+ o.paste.a
									e:
									+ o
							d:
							= c.d
							e:
							= c.d.e.copy
						c:
						= copy
				paste:
					a:
			"""
			
		let src = try await taskpaper.lemma("o.copy.a.b")
		let dst = try await src.lexicon["o.paste.a"].hopefully()

		let b = try await dst.make(child: src.graph).hopefully()
		
		await hope(that: b.lexicon.taskpaper()) == """
			o:
				copy:
					a:
					+ o
						b:
							c:
								d:
								+ o.paste.a
									e:
									+ o
							d:
							= c.d
							e:
							= c.d.e.copy
						c:
						= copy
				paste:
					a:
						b:
							c:
								d:
								+ o.paste.a
									e:
									+ o
							d:
							= c.d
							e:
							= c.d.e.copy
			"""
	}
	
	func test_make_child_graph_where_root_is_a_synonym() async throws {
				
		let taskpaper = """
			o:
				a:
					b:
						c:
							d:
						x:
						= c
			"""
			
		let src = try await taskpaper.lemma("o.a.b.x")
		let dst = try await src.lexicon["o.a"].hopefully()

		let b = try await dst.make(child: src.graph).hopefully()

		await hope(that: b.lexicon.taskpaper()) == """
			o:
				a:
					b:
						c:
							d:
						x:
						= c
					x:
			"""
	}
	
	// MARK: non-additive mutations
	
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
		
		let o = try await b.delete().hopefully()
		
		await hope(that: o.lexicon.taskpaper()) == """
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
		let o = try await a.lexicon["o"].hopefully()

		let a₂ = try await a.remove(type: o).hopefully()
		
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

		let c₂ = try await c.removeProtonym().hopefully()
		
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
		
	func test_rename() async throws {
		
		let taskpaper = """
			o:
				a:
				+ o.ax
				+ o.x.y.z
					b:
					+ o.ax.xa
					+ o.x.y
						c:
						+ o.ax.xa.axa
						+ o.x
				ax:
					xa:
						axa:
						+ o.z.y
				s1:
				= x.y.z
				s2:
				= a.b.z
				s3:
				= a.b.c.y.z
				x:
					y:
						z:
				z:
					y:
			"""
			
		let y = try await taskpaper.lemma("o.x.y")

		let y₂ = try await y.rename(to: "Y").hopefully()
		
		await hope(that: y₂.lexicon.taskpaper()) == """
			o:
				a:
				+ o.ax
				+ o.x.Y.z
					b:
					+ o.ax.xa
					+ o.x.Y
						c:
						+ o.ax.xa.axa
						+ o.x
				ax:
					xa:
						axa:
						+ o.z.y
				s1:
				= x.Y.z
				s2:
				= a.b.z
				s3:
				= a.b.c.Y.z
				x:
					Y:
						z:
				z:
					y:
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
		let x = try await c.lexicon["o.a.b.x"].hopefully()

		let c₂ = try await c.set(protonym: x).hopefully()

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
