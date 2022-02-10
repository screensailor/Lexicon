//
// github.com/screensailor 2022
//

open class L: @unchecked Sendable, Hashable, I {
    open class var localized: String { "" }
    public let __: String
    public init(_ id: String) { __ = id }
}

public extension L {
    static func == (lhs: L, rhs: L) -> Bool { lhs.__ == rhs.__ }
    func hash(into hasher: inout Hasher) { hasher.combine(__) }
}
