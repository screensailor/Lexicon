//
// github.com/screensailor 2022
//

final class Lemma™: Hopes {
	
	func test_Lemma_isValid_name() {
		
		hope.true(Lemma.isValid(name: "a"))
		hope.true(Lemma.isValid(name: "a_"))
		hope.true(Lemma.isValid(name: "a_t"))
		hope.true(Lemma.isValid(name: "a_2_")) // TODO: consider disallowing this!
		hope.true(Lemma.isValid(name: "a_2_z"))

		hope.false(Lemma.isValid(name: ""))
		hope.false(Lemma.isValid(name: "1"))
		hope.false(Lemma.isValid(name: "_")) // TODO: consider allowing this!
		hope.false(Lemma.isValid(name: "a__"))
	}
	
	func test_Lemma_isValid_character() {
		
		hope.true(Lemma.isValid(character: "_", appendingTo: "yet_another"))
		
		hope.false(Lemma.isValid(character: "_", appendingTo: "not_another_"))
		hope.false(Lemma.isValid(character: "_", appendingTo: "")) // TODO: consider allowing this!
	}
}
