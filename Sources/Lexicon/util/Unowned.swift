//
// github.com/screensailor 2021
//

@dynamicMemberLookup
public struct Unowned<Object: AnyObject> {
	
	public unowned let unwrapped: Object
	
	public init(_ object: Object) {
		self.unwrapped = object
	}
	
	public subscript<A>(dynamicMember keyPath: KeyPath<Object, A>) -> A {
		unwrapped[keyPath: keyPath]
	}
	
	public subscript<A>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, A>) -> A {
		get {
			unwrapped[keyPath: keyPath]
		}
		nonmutating set {
			unwrapped[keyPath: keyPath] = newValue
		}
	}
}

extension Unowned: Equatable where Object: Equatable {
	
	@inlinable public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.unwrapped == rhs.unwrapped
	}
}

extension Unowned: Hashable where Object: Hashable {
	
	@inlinable public func hash(into hasher: inout Hasher) {
		unwrapped.hash(into: &hasher)
	}
}

extension Unowned: Comparable where Object: Comparable {
	
	@inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.unwrapped < rhs.unwrapped
	}
}

extension Unowned: CustomStringConvertible where Object: CustomStringConvertible {
	
	@inlinable public var description: String {
		unwrapped.description
	}
}

extension Unowned: CustomDebugStringConvertible where Object: CustomDebugStringConvertible {
	
	@inlinable public var debugDescription: String {
		unwrapped.debugDescription
	}
}

extension Dictionary where Value == Unowned<Lemma> {
	
	subscript(key: Key) -> Lemma? {
		get {
			self[key]?.unwrapped
		}
		set {
			self[key] = newValue.map(Unowned.init)
		}
	}
}
