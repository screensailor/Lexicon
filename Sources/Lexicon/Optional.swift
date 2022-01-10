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
