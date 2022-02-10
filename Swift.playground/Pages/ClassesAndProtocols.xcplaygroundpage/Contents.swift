//: # Swift Template with Classes & Protocols
//: ## Template Start
import Foundation
public protocol TypeLocalized {
    static var localized: String { get }
}
public protocol SourceCodeIdentifiable: CustomDebugStringConvertible {
    var __: String { get }
}
extension SourceCodeIdentifiable {
    public var debugDescription: String { __ }
}
public protocol I: TypeLocalized, SourceCodeIdentifiable {
    
}
public class L: I {
    public class var localized: String { "" }
    public let __: String
    fileprivate init(_ id: String) { __ = id }
}
extension L: Equatable {
    public static func == (lhs: L, rhs: L) -> Bool { lhs.__ == rhs.__ }
}
extension L: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(__) }
}
public enum CallAsFunctionExtensions<X> {
    case from
}
public extension L {
    func callAsFunction<Property>(_ keyPath: KeyPath<CallAsFunctionExtensions<L>, (L) -> Property>) -> Property {
        CallAsFunctionExtensions.from[keyPath: keyPath](self)
    }
}
public extension CallAsFunctionExtensions where X == L {
    var id: (L) -> String {{ $0.__ }}
    var localizedType: (L) -> String {{ type(of: $0).localized }}
}
//: ## Template End
public let root = L_root("root")

root.one.a
root.one.b(\.id)
root.one.b(\.localizedType)

let x: L = root.one.b
x(\.id)
x(\.localizedType)
x == root.one.b
x != root.two.b

public final class L_root: L, I_root {
    public override class var localized: String { .init(localized: "root") }
}
public protocol I_root: I {}
public extension I_root {
    var `one`: L_root_one { .init("\(__).one") }
    var `two`: L_root_two { .init("\(__).two") }
}
public final class L_root_one: L, I_root_one {
    public override class var localized: String { .init(localized: "root.one") }
}
public protocol I_root_one: I_root_two {}
public extension I_root_one {
    var `a`: L_root_one_a { .init("\(__).a") }
}
public final class L_root_one_a: L, I_root_one_a {
    public override class var localized: String { .init(localized: "root.one.a") }
}
public protocol I_root_one_a: I {}
public final class L_root_two: L, I_root_two {
    public override class var localized: String { .init(localized: "root.two") }
}
public protocol I_root_two: I {}
public extension I_root_two {
    var `b`: L_root_two_b { .init("\(__).b") }
}
public final class L_root_two_b: L, I_root_two_b {
    public override class var localized: String { .init(localized: "root.two.b") }
}
public protocol I_root_two_b: I {}
