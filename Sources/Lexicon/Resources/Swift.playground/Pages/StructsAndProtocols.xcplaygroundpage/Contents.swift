//: # Swift Template with Structs & Protocols
//: ## Template Start
public protocol I: CustomDebugStringConvertible {
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
}
//: ## Template End
let root = L_root(__: "root")

root.one.a
root.one.b(\.id)

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

root.one.synonym



let x: I = root.one

switch x {
    case is I_root_two: "✅"
    default: "😱"
}

struct L_root: Hashable, I_root { let __: String }
protocol I_root: I {}
extension I_root {
    var one: L_root_one { .init(__: "\(__).one") }
    var two: L_root_two { .init(__: "\(__).two") }
}

struct L_root_one: Hashable, I_root_one { let __: String }
protocol I_root_one: I_root_two {}
extension I_root_one {
    var a: L_root_one_a { .init(__: "\(__).a") }
    var synonym: L_root_two_b { b }
}

struct L_root_one_a: Hashable, I_root_one_a { let __: String }
protocol I_root_one_a: I {}

struct L_root_two: Hashable, I_root_two { let __: String }
protocol I_root_two: I {}
extension I_root_two {
    var b: L_root_two_b { .init(__: "\(__).b") }
}

struct L_root_two_b: Hashable, I_root_two_b { let __: String }
protocol I_root_two_b: I {}

