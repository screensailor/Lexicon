//
// github.com/screensailor 2021
//

import Lexicon
import Hope

final class CLI™: Hopes {
	
    func test() async throws {
		
		let root = await Lexicon.from(Lexicon.Serialization(name: "root")).root
		/*
		 root:
		 */
		
		var cli = await CLI(root)
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == []
		hope(cli.selectedIndex) == nil
		
        await cli.append("o")
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == "o"
		hope(cli.error) == .noChildrenMatchInput("o")
		hope(cli.suggestions) == []
		hope(cli.selectedIndex) == nil

        await cli.append("n")
		hope(cli.input) == "on"
		hope(cli.error) == .noChildrenMatchInput("on")
		
		let one = try await root.make(child: "one").hopefully()
		/*
		 root:
			 one:
		 */
		
        await cli.update()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == "on"
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
        await cli.append("e")
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == "one"
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
        await cli.enter()
		hope(cli.root) == root
		hope(cli.lemma) == one
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions.map(\.name)) == []
		hope(cli.selectedIndex) == nil
		
        await cli.backspace()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
        await cli.backspace()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
		let two = try await root.make(child: "two").hopefully()
		/*
		 root:
			 one:
			 two:
		 */
		
        await cli.update()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one, two]
		hope(cli.selectedIndex) == 0
		
        cli.selectNext()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one, two]
		hope(cli.selectedIndex) == 1
		
		cli.selectNext()
		hope(cli.selectedIndex) == 0
		
		cli.selectPrevious()
		hope(cli.selectedIndex) == 1
		
		cli.selectPrevious()
		hope(cli.selectedIndex) == 0
		
		cli.selectPrevious()
		hope(cli.selectedIndex) == 1

		let three = try await root.make(child: "three").hopefully()
		/*
		 root:
			 one:
			 three:
			 two:
		 */
		
        await cli.update()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one, three, two]
		hope(cli.selectedIndex) == 2

		// TODO: ...
    }
}
