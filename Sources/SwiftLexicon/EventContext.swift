//
// github.com/screensailor 2022
//

import Combine

@MainActor public protocol EventContext:
	Hashable,
	Identifiable,
	ObservableObject,
	CustomStringConvertible
{
	var events: Events { get }
}

public extension EventContext {
	
	nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
		lhs === rhs
	}
	
	nonisolated func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
