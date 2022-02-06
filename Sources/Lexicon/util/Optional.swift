//
// github.com/screensailor 2021
//

protocol DictionaryProtocol: ExpressibleByDictionaryLiteral {
    subscript(key: Key) -> Value? { get set }
}

extension Dictionary: DictionaryProtocol {}

extension Optional where Wrapped: DictionaryProtocol {

    subscript(key: Wrapped.Key) -> Wrapped.Value? {
        get {
            self?[key]
        }
        set {
            switch (self, newValue) {
            case (.none, .none):            break
            case (.none, .some(let value)): self = .some([key: value])
            case (.some, _):                self![key] = newValue
            }
        }
    }
	
	subscript(key: Wrapped.Key, inserting defaultValue: @autoclosure () -> (Wrapped.Value)) -> Wrapped.Value {
		mutating get {
			let value: Wrapped.Value
			if let o = self[key] {
				value = o
			} else {
				value = defaultValue()
				self[key] = value
			}
			return value
		}
	}
}

protocol SetProtocol: ExpressibleByArrayLiteral {
    associatedtype Element: Hashable
    mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element)
}

extension Set: SetProtocol {}

extension Optional where Wrapped: SetProtocol {
    
    @discardableResult
    mutating func insert(_ newMember: Wrapped.Element) -> (inserted: Bool, memberAfterInsert: Wrapped.Element) {
        if case .none = self {
            self = .some([])
        }
        return self!.insert(newMember)
    }
}

extension Optional where Wrapped: Collection {
    
    @inlinable var isEmpty: Bool {
        self?.isEmpty ?? true
    }
    
    @inlinable var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Optional {
    
    @inlinable var isNil: Bool {
        self == nil
    }
    
    @inlinable var isNotNil: Bool {
        !isNil
    }
}

extension Optional {
    
    @inlinable public func or(_ `default`: Wrapped) -> Wrapped {
        self ?? `default`
    }
    
    @inlinable public func or(
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) throws -> Wrapped {
        try or(throw: "⚠️ \(function):\(file):\(line)")
    }
    
    @inlinable public func or(throw error: @autoclosure () -> Error) throws -> Wrapped {
        guard let o = self else { throw error() }
        return o
    }
}
