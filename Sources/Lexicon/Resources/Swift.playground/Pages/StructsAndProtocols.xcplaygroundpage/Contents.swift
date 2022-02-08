//: # Swift Template with Structs & Protocols
/*:
 ## To Do
 * Export shared Swift dependencies as a module
 */
//: ## Template Start
public protocol TypeLocalized {
    static var localized: String { get }
}
public protocol SourceCodeIdentifiable: CustomDebugStringConvertible {
    var __: String { get }
}
extension SourceCodeIdentifiable {
    public var debugDescription: String { __ }
}
public enum CallAsFunctionExtensions<X> {
    case from
}
public protocol I: SourceCodeIdentifiable, TypeLocalized {}
public func == (lhs: I, rhs: I) -> Bool { lhs.__ == rhs.__ }
public extension I {
    func callAsFunction<Property>(_ keyPath: KeyPath<CallAsFunctionExtensions<I>, (I) -> Property>) -> Property {
        CallAsFunctionExtensions.from[keyPath: keyPath](self)
    }
}
public extension CallAsFunctionExtensions where X == I {
    var id: (I) -> String {{ $0.__ }}
    var localized: (I) -> String {{ type(of: $0).localized }}
}
//: ## Template End
let root = L_root(__: "root")

root.one.a
root.one.b(\.id)
root.one.b(\.localized)

let x: I = root.one.b
x(\.id)
x(\.localized)

extension CallAsFunctionExtensions where X == I {

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
