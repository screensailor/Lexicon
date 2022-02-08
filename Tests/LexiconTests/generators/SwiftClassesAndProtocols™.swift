//
// github.com/screensailor 2022
//

class SwiftClassesAndProtocols™: Hopes {
    
    func test() async throws {
        
        var json = try await JSONClasses™.taskpaper.lexicon().json()
        json.date = Date(timeIntervalSinceReferenceDate: 0)

        let data = try SwiftClassesAndProtocols.generate(json)
        
        try hope(data.string()) == swift
    }
}

private let swift = #"""
// Generated on: 2001-01-01T00:00:00.000Z

public let root = L_root("root")

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


public final class L_root: L, I_root {
    public override class var localized: String { .init(localized: "root") }
}
public protocol I_root: I {}
public extension I_root {
    var `a`: L_root_a { .init("\(__).a") }
    var `bad`: L_root_bad { .init("\(__).bad") }
    var `first`: L_root_first { .init("\(__).first") }
    var `good`: L_root_good { .init("\(__).good") }
    var `one`: L_root_one { .init("\(__).one") }
    var `x_y_z`: L_root_x__y__z { a.b.b.b.b.b }
}
public final class L_root_a: L, I_root_a {
    public override class var localized: String { .init(localized: "root.a") }
}
public protocol I_root_a: I_root_a_b_c {}
public extension I_root_a {
    var `b`: L_root_a_b { .init("\(__).b") }
}
public final class L_root_a_b: L, I_root_a_b {
    public override class var localized: String { .init(localized: "root.a.b") }
}
public protocol I_root_a_b: I_root_a {}
public extension I_root_a_b {
    var `c`: L_root_a_b_c { .init("\(__).c") }
}
public final class L_root_a_b_c: L, I_root_a_b_c {
    public override class var localized: String { .init(localized: "root.a.b.c") }
}
public protocol I_root_a_b_c: I_root {}
public final class L_root_bad: L, I_root_bad {
    public override class var localized: String { .init(localized: "root.bad") }
}
public protocol I_root_bad: I {}
public extension I_root_bad {
    var `worse`: L_root_bad_worse { .init("\(__).worse") }
}
public final class L_root_bad_worse: L, I_root_bad_worse {
    public override class var localized: String { .init(localized: "root.bad.worse") }
}
public protocol I_root_bad_worse: I {}
public extension I_root_bad_worse {
    var `worst`: L_root_bad_worse_worst { .init("\(__).worst") }
}
public final class L_root_bad_worse_worst: L, I_root_bad_worse_worst {
    public override class var localized: String { .init(localized: "root.bad.worse.worst") }
}
public protocol I_root_bad_worse_worst: I {}
public final class L_root_first: L, I_root_first {
    public override class var localized: String { .init(localized: "root.first") }
}
public protocol I_root_first: I {}
public extension I_root_first {
    var `second`: L_root_first_second { .init("\(__).second") }
}
public final class L_root_first_second: L, I_root_first_second {
    public override class var localized: String { .init(localized: "root.first.second") }
}
public protocol I_root_first_second: I {}
public extension I_root_first_second {
    var `third`: L_root_first_second_third { .init("\(__).third") }
}
public final class L_root_first_second_third: L, I_root_first_second_third {
    public override class var localized: String { .init(localized: "root.first.second.third") }
}
public protocol I_root_first_second_third: I {}
public final class L_root_good: L, I_root_good {
    public override class var localized: String { .init(localized: "root.good") }
}
public protocol I_root_good: I {}
public extension I_root_good {
    var `better`: L_root_good_better { .init("\(__).better") }
}
public final class L_root_good_better: L, I_root_good_better {
    public override class var localized: String { .init(localized: "root.good.better") }
}
public protocol I_root_good_better: I {}
public extension I_root_good_better {
    var `best`: L_root_good_better_best { .init("\(__).best") }
}
public final class L_root_good_better_best: L, I_root_good_better_best {
    public override class var localized: String { .init(localized: "root.good.better.best") }
}
public protocol I_root_good_better_best: I {}
public final class L_root_one: L, I_root_one {
    public override class var localized: String { .init(localized: "root.one") }
}
public protocol I_root_one: I_root_a {}
public extension I_root_one {
    var `two`: L_root_one_two { .init("\(__).two") }
}
public final class L_root_one_two: L, I_root_one_two {
    public override class var localized: String { .init(localized: "root.one.two") }
}
public protocol I_root_one_two: I_root_a, I_root_first {}
public extension I_root_one_two {
    var `three`: L_root_one_two_three { .init("\(__).three") }
}
public final class L_root_one_two_three: L, I_root_one_two_three {
    public override class var localized: String { .init(localized: "root.one.two.three") }
}
public protocol I_root_one_two_three: I_root_a, I_root_bad, I_root_first {}
public extension I_root_one_two_three {
    var `four`: L_root_one_two_three_four { .init("\(__).four") }
}
public final class L_root_one_two_three_four: L, I_root_one_two_three_four {
    public override class var localized: String { .init(localized: "root.one.two.three.four") }
}
public protocol I_root_one_two_three_four: I_root_a, I_root_bad, I_root_first, I_root_good {}
public typealias L_root_x__y__z = L_root_a_b
"""#
