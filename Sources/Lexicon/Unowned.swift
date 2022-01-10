//
// github.com/screensailor 2021
//

@dynamicMemberLookup
public struct Unowned<Object: AnyObject> {

    public unowned let __: Object

    public init(_ object: Object) {
        self.__ = object
    }

    public subscript<A>(dynamicMember keyPath: KeyPath<Object, A>) -> A {
        __[keyPath: keyPath]
    }

    public subscript<A>(dynamicMember keyPath: ReferenceWritableKeyPath<Object, A>) -> A {
        get {
            __[keyPath: keyPath]
        }
        nonmutating set {
            __[keyPath: keyPath] = newValue
        }
    }
}

extension Unowned: Equatable where Object: Equatable {

    @inlinable public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.__ == rhs.__
    }
}

extension Unowned: Hashable where Object: Hashable {

    @inlinable public func hash(into hasher: inout Hasher) {
        __.hash(into: &hasher)
    }
}

extension Unowned: Comparable where Object: Comparable {

    @inlinable public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.__ < rhs.__
    }
}

extension Unowned: CustomStringConvertible where Object: CustomStringConvertible {

    @inlinable public var description: String {
        __.description
    }
}

extension Unowned: CustomDebugStringConvertible where Object: CustomDebugStringConvertible {

    @inlinable public var debugDescription: String {
        __.debugDescription
    }
}

extension Dictionary where Value == Unowned<Lemma> {

    subscript(key: Key) -> Lemma? {
        get {
            self[key]?.__
        }
        set {
            self[key] = newValue.map(Unowned.init)
        }
    }
}
