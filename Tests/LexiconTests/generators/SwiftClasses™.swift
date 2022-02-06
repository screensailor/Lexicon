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

public class L_root: L {
    public lazy var `a` = L_root_a("\(__).a")
    public lazy var `bad` = L_root_bad("\(__).bad")
    public lazy var `first` = L_root_first("\(__).first")
    public lazy var `good` = L_root_good("\(__).good")
    public lazy var `one` = L_root_one("\(__).one")
    public var `x_y_z`: L_root_x__y__z { a.b.b.b.b.b }
}
public class L_root_a: L_root_a_b_c {
    public lazy var `b` = L_root_a_b("\(__).b")
}
public class L_root_a___root_bad: L_root_a {
    public lazy var `worse` = L_root_bad_worse("\(__).worse")
}
public class L_root_a___root_bad___root_first: L_root_a___root_bad {
    public lazy var `second` = L_root_first_second("\(__).second")
}
public class L_root_a___root_bad___root_first___root_good: L_root_a___root_bad___root_first {
    public lazy var `better` = L_root_good_better("\(__).better")
}
public class L_root_a___root_first: L_root_a {
    public lazy var `second` = L_root_first_second("\(__).second")
}
public class L_root_a_b: L_root_a {
    public lazy var `c` = L_root_a_b_c("\(__).c")
}
public class L_root_a_b_c: L_root {}
public class L_root_bad: L {
    public lazy var `worse` = L_root_bad_worse("\(__).worse")
}
public class L_root_bad_worse: L {
    public lazy var `worst` = L_root_bad_worse_worst("\(__).worst")
}
public class L_root_bad_worse_worst: L {}
public class L_root_first: L {
    public lazy var `second` = L_root_first_second("\(__).second")
}
public class L_root_first_second: L {
    public lazy var `third` = L_root_first_second_third("\(__).third")
}
public class L_root_first_second_third: L {}
public class L_root_good: L {
    public lazy var `better` = L_root_good_better("\(__).better")
}
public class L_root_good_better: L {
    public lazy var `best` = L_root_good_better_best("\(__).best")
}
public class L_root_good_better_best: L {}
public class L_root_one: L_root_a {
    public lazy var `two` = L_root_one_two("\(__).two")
}
public class L_root_one_two: L_root_a___root_first {
    public lazy var `three` = L_root_one_two_three("\(__).three")
}
public class L_root_one_two_three: L_root_a___root_bad___root_first {
    public lazy var `four` = L_root_one_two_three_four("\(__).four")
}
public class L_root_one_two_three_four: L_root_a___root_bad___root_first___root_good {}
public typealias L_root_x__y__z = L_root_a_b
"""#
