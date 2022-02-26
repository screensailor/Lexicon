//
// github.com/screensailor 2022
//

import Collections

public extension Lemma {
	
	func graphTraversal(_ traversal: Lexicon.Graph.Traversal, _ ƒ: (Lemma) -> ()) {
		
		guard isGraphNode else {
			return
		}
		
		let next: @LexiconActor () -> Lemma?
		
		switch traversal {
			
			case .depthFirst:
				
				var buffer: [Lemma] = [self]
				
				next = {
					guard let last = buffer.popLast() else {
						return nil
					}
					buffer.append(contentsOf: last.ownChildren.values.sortedByLocalizedStandard(by: \.id).reversed())
					return last
				}

			case .breadthFirst:
				
				var buffer: Deque<Lemma> = [self]

				next = {
					guard let first = buffer.popFirst() else {
						return nil
					}
					buffer.append(contentsOf: first.ownChildren.values.sortedByLocalizedStandard(by: \.id))
					return first
				}
		}
		
		while let descendant = next() {
			ƒ(descendant)
		}
	}
}
