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

public protocol I: CustomDebugStringConvertible {
    func callAsFunction() -> String
}

public let root = L_root("root")

public class L: I {
    fileprivate var __id: String
    fileprivate init(_ id: String) { __id = id }
}

extension L {
    public func callAsFunction() -> String { __id }
}

extension L: Equatable {
    public static func == (lhs: L, rhs: L) -> Bool {
        lhs.__id == rhs.__id
    }
}

extension L: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(__id)
    }
}

extension L: CustomDebugStringConvertible {
    public var debugDescription: String { __id }
}

public protocol I_root: I {
    var `a`: L_root_a { get }
    var `bad`: L_root_bad { get }
    var `first`: L_root_first { get }
    var `good`: L_root_good { get }
    var `one`: L_root_one { get }
    var `x_y_z`: L_root_x__y__z { get }
}
public class L_root: L, I_root {
    public var `a`: L_root_a { .init("\(__id).a") }
    public var `bad`: L_root_bad { .init("\(__id).bad") }
    public var `first`: L_root_first { .init("\(__id).first") }
    public var `good`: L_root_good { .init("\(__id).good") }
    public var `one`: L_root_one { .init("\(__id).one") }
    public var `x_y_z`: L_root_x__y__z { a.b.b.b.b.b }
}
public protocol I_root_a: I_root_a_b_c {
    var `b`: L_root_a_b { get }
}
public class L_root_a: L_root_a_b_c, I_root_a {
    public var `b`: L_root_a_b { .init("\(__id).b") }
}
public class L_root_a___root_bad: L_root_a {
    public var `worse`: L_root_bad_worse { .init("\(__id).worse") }
}
public class L_root_a___root_bad___root_first: L_root_a___root_bad {
    public var `second`: L_root_first_second { .init("\(__id).second") }
}
public class L_root_a___root_bad___root_first___root_good: L_root_a___root_bad___root_first {
    public var `better`: L_root_good_better { .init("\(__id).better") }
}
public class L_root_a___root_first: L_root_a {
    public var `second`: L_root_first_second { .init("\(__id).second") }
}
public protocol I_root_a_b: I_root_a {
    var `c`: L_root_a_b_c { get }
}
public class L_root_a_b: L_root_a, I_root_a_b {
    public var `c`: L_root_a_b_c { .init("\(__id).c") }
}
public protocol I_root_a_b_c: I_root {}
public class L_root_a_b_c: L_root, I_root_a_b_c {}
public protocol I_root_bad: I {
    var `worse`: L_root_bad_worse { get }
}
public class L_root_bad: L, I_root_bad {
    public var `worse`: L_root_bad_worse { .init("\(__id).worse") }
}
public protocol I_root_bad_worse: I {
    var `worst`: L_root_bad_worse_worst { get }
}
public class L_root_bad_worse: L, I_root_bad_worse {
    public var `worst`: L_root_bad_worse_worst { .init("\(__id).worst") }
}
public protocol I_root_bad_worse_worst: I {}
public class L_root_bad_worse_worst: L, I_root_bad_worse_worst {}
public protocol I_root_first: I {
    var `second`: L_root_first_second { get }
}
public class L_root_first: L, I_root_first {
    public var `second`: L_root_first_second { .init("\(__id).second") }
}
public protocol I_root_first_second: I {
    var `third`: L_root_first_second_third { get }
}
public class L_root_first_second: L, I_root_first_second {
    public var `third`: L_root_first_second_third { .init("\(__id).third") }
}
public protocol I_root_first_second_third: I {}
public class L_root_first_second_third: L, I_root_first_second_third {}
public protocol I_root_good: I {
    var `better`: L_root_good_better { get }
}
public class L_root_good: L, I_root_good {
    public var `better`: L_root_good_better { .init("\(__id).better") }
}
public protocol I_root_good_better: I {
    var `best`: L_root_good_better_best { get }
}
public class L_root_good_better: L, I_root_good_better {
    public var `best`: L_root_good_better_best { .init("\(__id).best") }
}
public protocol I_root_good_better_best: I {}
public class L_root_good_better_best: L, I_root_good_better_best {}
public protocol I_root_one: I_root_a {
    var `two`: L_root_one_two { get }
}
public class L_root_one: L_root_a, I_root_one {
    public var `two`: L_root_one_two { .init("\(__id).two") }
}
public protocol I_root_one_two: I_root_a, I_root_first {
    var `three`: L_root_one_two_three { get }
}
public class L_root_one_two: L_root_a___root_first, I_root_one_two {
    public var `three`: L_root_one_two_three { .init("\(__id).three") }
}
public protocol I_root_one_two_three: I_root_a, I_root_bad, I_root_first {
    var `four`: L_root_one_two_three_four { get }
}
public class L_root_one_two_three: L_root_a___root_bad___root_first, I_root_one_two_three {
    public var `four`: L_root_one_two_three_four { .init("\(__id).four") }
}
public protocol I_root_one_two_three_four: I_root_a, I_root_bad, I_root_first, I_root_good {}
public class L_root_one_two_three_four: L_root_a___root_bad___root_first___root_good, I_root_one_two_three_four {}
public typealias L_root_x__y__z = L_root_a_b
"""#
