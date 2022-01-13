//
// github.com/screensailor 2022
//

import Foundation

public extension Sequence {
	
	@inlinable
	func sorted<S: StringProtocol>(by keyPath: KeyPath<Element, S>, _ order: ComparisonResult = .orderedAscending) -> [Element] {
		sorted { l, r in
			l[keyPath: keyPath].localizedStandardCompare(r[keyPath: keyPath]) == order
		}
	}
}
