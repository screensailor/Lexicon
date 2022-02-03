//: # Swift Template with Classes & Protocols
//: ## Template Start
public protocol I: CustomDebugStringConvertible {
    func callAsFunction() -> String
}
public class L: I {
    fileprivate var __: String
    fileprivate init(_ id: String) { __ = id }
}
extension L {
    public func callAsFunction() -> String { __ }
}
extension L: Equatable {
    public static func == (lhs: L, rhs: L) -> Bool {
        lhs.__ == rhs.__
    }
}
extension L: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(__)
    }
}
extension L: CustomDebugStringConvertible {
    public var debugDescription: String { __ }
}
//: ## Template End

class L_root: L {
    lazy var one: L_root_one = .init("\(__).one")
}
class L_root_one: L {
    
}
let root = L_root("root")
root.one
