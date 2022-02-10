@_exported import SwiftLexicon // From https://github.com/screensailor/Lexicon
import Foundation

public let test = L_test("test")

public final class L_test: L, I_test {
    public override class var localized: String { NSLocalizedString("test", comment: "") }
}
public protocol I_test: I {}
public extension I_test {
    var `one`: L_test_one { .init("\(__).one") }
    var `two`: L_test_two { .init("\(__).two") }
    var `type`: L_test_type { .init("\(__).type") }
}
public final class L_test_one: L, I_test_one {
    public override class var localized: String { NSLocalizedString("test.one", comment: "") }
}
public protocol I_test_one: I_test_type_odd {}
public extension I_test_one {
    var `more`: L_test_one_more { .init("\(__).more") }
}
public final class L_test_one_more: L, I_test_one_more {
    public override class var localized: String { NSLocalizedString("test.one.more", comment: "") }
}
public protocol I_test_one_more: I {}
public extension I_test_one_more {
    var `time`: L_test_one_more_time { .init("\(__).time") }
}
public final class L_test_one_more_time: L, I_test_one_more_time {
    public override class var localized: String { NSLocalizedString("test.one.more.time", comment: "") }
}
public protocol I_test_one_more_time: I_test {}
public final class L_test_two: L, I_test_two {
    public override class var localized: String { NSLocalizedString("test.two", comment: "") }
}
public protocol I_test_two: I_test_type_even {}
public extension I_test_two {
    var `timing`: L_test_two_timing { .init("\(__).timing") }
}
public final class L_test_two_timing: L, I_test_two_timing {
    public override class var localized: String { NSLocalizedString("test.two.timing", comment: "") }
}
public protocol I_test_two_timing: I {}
public final class L_test_type: L, I_test_type {
    public override class var localized: String { NSLocalizedString("test.type", comment: "") }
}
public protocol I_test_type: I {}
public extension I_test_type {
    var `even`: L_test_type_even { .init("\(__).even") }
    var `odd`: L_test_type_odd { .init("\(__).odd") }
}
public final class L_test_type_even: L, I_test_type_even {
    public override class var localized: String { NSLocalizedString("test.type.even", comment: "") }
}
public protocol I_test_type_even: I {}
public extension I_test_type_even {
    var `no`: L_test_type_even_no { .init("\(__).no") }
    var `bad`: L_test_type_even_bad { no.good }
}
public typealias L_test_type_even_bad = L_test_type_even_no_good
public final class L_test_type_even_no: L, I_test_type_even_no {
    public override class var localized: String { NSLocalizedString("test.type.even.no", comment: "") }
}
public protocol I_test_type_even_no: I {}
public extension I_test_type_even_no {
    var `good`: L_test_type_even_no_good { .init("\(__).good") }
}
public final class L_test_type_even_no_good: L, I_test_type_even_no_good {
    public override class var localized: String { NSLocalizedString("test.type.even.no.good", comment: "") }
}
public protocol I_test_type_even_no_good: I {}
public final class L_test_type_odd: L, I_test_type_odd {
    public override class var localized: String { NSLocalizedString("test.type.odd", comment: "") }
}
public protocol I_test_type_odd: I {}
public extension I_test_type_odd {
    var `good`: L_test_type_odd_good { .init("\(__).good") }
}
public final class L_test_type_odd_good: L, I_test_type_odd_good {
    public override class var localized: String { NSLocalizedString("test.type.odd.good", comment: "") }
}
public protocol I_test_type_odd_good: I {}