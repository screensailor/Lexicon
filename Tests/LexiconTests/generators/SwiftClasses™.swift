//
// github.com/screensailor 2022
//

class SwiftClasses™: Hopes {

    func test() async throws {

        var json = try await JSONClasses™.taskpaper.lexicon().json()
        json.date = Date(timeIntervalSinceReferenceDate: 0)

        let data = try SwiftClasses.generate(json)

        try hope(data.string()) == swift
    }
}

private let swift = #"""
// Generated on: 2001-01-01T00:00:00.000Z

public let root = L_root("root")

public class L {
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

public class L_root: L {
    public var `a`: L_root_a { .init("\(__id).a") }
    public var `bad`: L_root_bad { .init("\(__id).bad") }
    public var `first`: L_root_first { .init("\(__id).first") }
    public var `good`: L_root_good { .init("\(__id).good") }
    public var `one`: L_root_one { .init("\(__id).one") }
    public var `x_y_z`: L_root_x__y__z { a.b.b.b.b.b }
}
public class L_root_a: L_root_a_b_c {
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
public class L_root_a_b: L_root_a {
    public var `c`: L_root_a_b_c { .init("\(__id).c") }
}
public class L_root_a_b_c: L_root {}
public class L_root_bad: L {
    public var `worse`: L_root_bad_worse { .init("\(__id).worse") }
}
public class L_root_bad_worse: L {
    public var `worst`: L_root_bad_worse_worst { .init("\(__id).worst") }
}
public class L_root_bad_worse_worst: L {}
public class L_root_first: L {
    public var `second`: L_root_first_second { .init("\(__id).second") }
}
public class L_root_first_second: L {
    public var `third`: L_root_first_second_third { .init("\(__id).third") }
}
public class L_root_first_second_third: L {}
public class L_root_good: L {
    public var `better`: L_root_good_better { .init("\(__id).better") }
}
public class L_root_good_better: L {
    public var `best`: L_root_good_better_best { .init("\(__id).best") }
}
public class L_root_good_better_best: L {}
public class L_root_one: L_root_a {
    public var `two`: L_root_one_two { .init("\(__id).two") }
}
public class L_root_one_two: L_root_a___root_first {
    public var `three`: L_root_one_two_three { .init("\(__id).three") }
}
public class L_root_one_two_three: L_root_a___root_bad___root_first {
    public var `four`: L_root_one_two_three_four { .init("\(__id).four") }
}
public class L_root_one_two_three_four: L_root_a___root_bad___root_first___root_good {}
public typealias L_root_x__y__z = L_root_a_b
"""#
