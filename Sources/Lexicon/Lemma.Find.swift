//
// github.com/screensailor 2022
//

import Collections

public extension Lemma {
	
	@inlinable func find(_ prefixes: String..., max: Int = 1000) -> OrderedSet<Lemma> {
		find(prefixes, max: max)
	}
	
	func find<Prefixes>(_ prefixes: Prefixes, max: Int = 1000) -> OrderedSet<Lemma> where Prefixes: Collection, Prefixes.Element == String {
		let prefixes = prefixes.drop(while: \.isEmpty)
		guard let prefix = prefixes.first else {
			return []
		}
		let rest = prefixes.dropFirst().drop(while: \.isEmpty)
		var o: OrderedSet<Lemma> = []
		
		graphTraversal(.breadthFirst) { lemma in
			guard
				o.count < max,
				lemma != self,
				prefix.localizedCaseInsensitiveCompare(lemma.name.prefix(prefix.count)) == .orderedSame
			else {
				return
			}
			if rest.isEmpty {
				o.append(lemma)
			} else {
				o.append(contentsOf: lemma.find(rest, max: max - o.count))
			}
		}
		return o
	}
}
