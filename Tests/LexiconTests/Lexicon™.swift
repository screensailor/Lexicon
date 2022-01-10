//
// github.com/screensailor 2021
//

@_exported import Hope
@_exported import Lexicon

final class Lexicon™: Hopes {

	@LexiconActor
    func test() throws {
		
		let lexicon = try Lexicon.from(TaskPaper(taskpaper).decode())
		let root = try lexicon.root.hopefully()
		var cli = CLI(root)
		
		hope(cli.suggestions.map(\.name)) == ["idea", "purpose", "type", "ui", "ux"]
		
		cli.replacing(input: "idea")
		cli.enter()
		
		hope(cli.suggestions.map(\.name)) == ["knowledge"]
		
		let outline = try lexicon["root.idea.knowledge.mind_map"].hopefully()
		let tree = try lexicon["root.idea.knowledge.tree"].hopefully()

		hope(outline) == tree
		hope.true(outline === tree)
		
		// TODO: ...
    }
}

private let taskpaper = """
root:
	idea:
		knowledge:
			directory:
			= tree
			mind_map:
			= tree
			outline:
			= tree
			tree:
				branch:
				+ root.idea.knowledge.tree
				leaf:
	purpose:
		lexicon:
			lemma:
		vocabulary:
		= lexicon
	type:
		ux:
			journey:
				entry:
				+ root.ui.view.control
	ui:
		placeable:
			placed:
				above:
				+ root.ux
				below:
				+ root.ux
		view:
			control:
				button:
				+ root.ui.placeable
			label:
			+ root.ui.placeable
	ux:
		menu:
			File:
				New:
				+ root.type.ux.journey
				Open:
				+ root.type.ux.journey
					json:
					taskpaper:
"""
