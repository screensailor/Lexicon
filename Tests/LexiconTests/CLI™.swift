//
// github.com/screensailor 2021
//

import Lexicon
import Hope

final class CLI™: Hopes {
	
	@LexiconActor
    func test() throws {
		
		let root = try Lexicon.from(Lexicon.Serialization(name: "root")).root.hopefully()
		/*
		 root:
		 */
		
		var cli = CLI(root)
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == []
		hope(cli.selectedIndex) == nil
		
		cli.append("o")
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == "o"
		hope(cli.error) == .noChildrenMatchInput("o")
		hope(cli.suggestions) == []
		hope(cli.selectedIndex) == nil

		cli.append("n")
		hope(cli.input) == "on"
		hope(cli.error) == .noChildrenMatchInput("on")
		
		let one = try root.make(child: "one").hopefully()
		/*
		 root:
			 one:
		 */
		
		cli.update()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == "on"
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
		cli.append("e")
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == "one"
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
		cli.enter()
		hope(cli.root) == root
		hope(cli.lemma) == one
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions.map(\.name)) == []
		hope(cli.selectedIndex) == nil
		
		cli.backspace()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
		cli.backspace()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one]
		hope(cli.selectedIndex) == 0
		
		let two = try root.make(child: "two").hopefully()
		/*
		 root:
			 one:
			 two:
		 */
		
		cli.update()
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

		let three = try root.make(child: "three").hopefully()
		/*
		 root:
			 one:
			 three:
			 two:
		 */
		
		cli.update()
		hope(cli.root) == root
		hope(cli.lemma) == root
		hope(cli.input) == ""
		hope(cli.error) == .none
		hope(cli.suggestions) == [one, three, two]
		hope(cli.selectedIndex) == 2

		// TODO: ...
    }
}
