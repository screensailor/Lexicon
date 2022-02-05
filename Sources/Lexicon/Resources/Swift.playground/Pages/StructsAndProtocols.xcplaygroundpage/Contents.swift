//: # Swift Template with Structs & Protocols
//: ## Template Start
public protocol I: CustomDebugStringConvertible {
    static var localized: String { get }
    var __: String { get }
}
extension I {
    public var debugDescription: String { __ }
}
public func == (lhs: I, rhs: I) -> Bool {
    lhs.__ == rhs.__
}
public extension I {
    func callAsFunction<A>(_ keyPath: KeyPath<Iextension, (I) -> A>) -> A {
        Iextension.from[keyPath: keyPath](self)
    }
}
public enum Iextension {
    case from
}
public extension Iextension {
    var id: (I) -> String {{ a in
        a.__
    }}
    var localized: (I) -> String {{ a in
        type(of: a).localized
    }}
}
//: ## Template End
let root = L_root(__: "root")

root.one.a
root.one.b(\.id)

let x: I = root.one.b
x(\.localized) // localized stically

extension Iextension {
    
    var parentId: (I) -> String? {{ a in
        guard let i = a.__.lastIndex(of: ".") else {
            return nil
        }
        return String(a.__.prefix(upTo: i))
    }}
    
    var breadcrumbs: (I) -> [Substring] {{ a in
        a.__.split(separator: ".")
    }}
}

root.one.b(\.parentId)
root.one.b(\.breadcrumbs)

public struct L_root: Hashable, I_root {
    public static let localized = String(localized: "root")
    public let __: String
}
public protocol I_root: I {}
public extension I_root {
    var `one`: L_root_one { .init(__: "\(__).one") }
    var `two`: L_root_two { .init(__: "\(__).two") }
}
public struct L_root_one: Hashable, I_root_one {
    public static let localized = String(localized: "root.one")
    public let __: String
}
public protocol I_root_one: I_root_two {}
public extension I_root_one {
    var `a`: L_root_one_a { .init(__: "\(__).a") }
}
public struct L_root_one_a: Hashable, I_root_one_a {
    public static let localized = String(localized: "root.one.a")
    public let __: String
}
public protocol I_root_one_a: I {}
public extension I_root_one_a {}
public struct L_root_two: Hashable, I_root_two {
    public static let localized = String(localized: "root.two")
    public let __: String
}
public protocol I_root_two: I {}
public extension I_root_two {
    var `b`: L_root_two_b { .init(__: "\(__).b") }
}
public struct L_root_two_b: Hashable, I_root_two_b {
    public static let localized = String(localized: "root.two.b")
    public let __: String
}
public protocol I_root_two_b: I {}
public extension I_root_two_b {}
