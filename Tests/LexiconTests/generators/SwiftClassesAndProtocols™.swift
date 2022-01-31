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
    public lazy var `a` = L_root_a("\(__id).a")
    public lazy var `bad` = L_root_bad("\(__id).bad")
    public lazy var `first` = L_root_first("\(__id).first")
    public lazy var `good` = L_root_good("\(__id).good")
    public lazy var `one` = L_root_one("\(__id).one")
    public var `x_y_z`: L_root_x__y__z { a.b.b.b.b.b }
}
public protocol I_root_a: I_root_a_b_c {
    var `b`: L_root_a_b { get }
}
public class L_root_a: L_root_a_b_c, I_root_a {
    public lazy var `b` = L_root_a_b("\(__id).b")
}
public class L_root_a___root_bad: L_root_a {
    public lazy var `worse` = L_root_bad_worse("\(__id).worse")
}
public class L_root_a___root_bad___root_first: L_root_a___root_bad {
    public lazy var `second` = L_root_first_second("\(__id).second")
}
public class L_root_a___root_bad___root_first___root_good: L_root_a___root_bad___root_first {
    public lazy var `better` = L_root_good_better("\(__id).better")
}
public class L_root_a___root_first: L_root_a {
    public lazy var `second` = L_root_first_second("\(__id).second")
}
public protocol I_root_a_b: I_root_a {
    var `c`: L_root_a_b_c { get }
}
public class L_root_a_b: L_root_a, I_root_a_b {
    public lazy var `c` = L_root_a_b_c("\(__id).c")
}
public protocol I_root_a_b_c: I_root {}
public class L_root_a_b_c: L_root, I_root_a_b_c {}
public protocol I_root_bad: I {
    var `worse`: L_root_bad_worse { get }
}
public class L_root_bad: L, I_root_bad {
    public lazy var `worse` = L_root_bad_worse("\(__id).worse")
}
public protocol I_root_bad_worse: I {
    var `worst`: L_root_bad_worse_worst { get }
}
public class L_root_bad_worse: L, I_root_bad_worse {
    public lazy var `worst` = L_root_bad_worse_worst("\(__id).worst")
}
public protocol I_root_bad_worse_worst: I {}
public class L_root_bad_worse_worst: L, I_root_bad_worse_worst {}
public protocol I_root_first: I {
    var `second`: L_root_first_second { get }
}
public class L_root_first: L, I_root_first {
    public lazy var `second` = L_root_first_second("\(__id).second")
}
public protocol I_root_first_second: I {
    var `third`: L_root_first_second_third { get }
}
public class L_root_first_second: L, I_root_first_second {
    public lazy var `third` = L_root_first_second_third("\(__id).third")
}
public protocol I_root_first_second_third: I {}
public class L_root_first_second_third: L, I_root_first_second_third {}
public protocol I_root_good: I {
    var `better`: L_root_good_better { get }
}
public class L_root_good: L, I_root_good {
    public lazy var `better` = L_root_good_better("\(__id).better")
}
public protocol I_root_good_better: I {
    var `best`: L_root_good_better_best { get }
}
public class L_root_good_better: L, I_root_good_better {
    public lazy var `best` = L_root_good_better_best("\(__id).best")
}
public protocol I_root_good_better_best: I {}
public class L_root_good_better_best: L, I_root_good_better_best {}
public protocol I_root_one: I_root_a {
    var `two`: L_root_one_two { get }
}
public class L_root_one: L_root_a, I_root_one {
    public lazy var `two` = L_root_one_two("\(__id).two")
}
public protocol I_root_one_two: I_root_a, I_root_first {
    var `three`: L_root_one_two_three { get }
}
public class L_root_one_two: L_root_a___root_first, I_root_one_two {
    public lazy var `three` = L_root_one_two_three("\(__id).three")
}
public protocol I_root_one_two_three: I_root_a, I_root_bad, I_root_first {
    var `four`: L_root_one_two_three_four { get }
}
public class L_root_one_two_three: L_root_a___root_bad___root_first, I_root_one_two_three {
    public lazy var `four` = L_root_one_two_three_four("\(__id).four")
}
public protocol I_root_one_two_three_four: I_root_a, I_root_bad, I_root_first, I_root_good {}
public class L_root_one_two_three_four: L_root_a___root_bad___root_first___root_good, I_root_one_two_three_four {}
public typealias L_root_x__y__z = L_root_a_b
"""#
