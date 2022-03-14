
interface I: TypeLocalized, SourceCodeIdentifiable
        
interface TypeLocalized {
    val localized: String
}
        
interface SourceCodeIdentifiable {
    val identifier: String
}
        
val SourceCodeIdentifiable.debugDescription get() = identifier
        
sealed interface CallAsFunctionExtension<X> {
    class From<X>: CallAsFunctionExtension<X>
}
        
fun <X: I> CallAsFunctionExtension<X>.id(): (I) -> String = { it.identifier }
        
open class L(override val localized: String = "", override val identifier: String,) : I
        
// MARK: generated types
        
val test = L_test("test")
        
data class L_test(override val identifier: String): L(identifier = identifier), I_test
interface I_test: I
    val I_test.`one`: L_test_one get() = L_test_one("${identifier}.one")
    val I_test.`two`: L_test_two get() = L_test_two("${identifier}.two")
    val I_test.`type`: L_test_type get() = L_test_type("${identifier}.type")
data class L_test_one(override val identifier: String): L(identifier = identifier), I_test_one
interface I_test_one: I_test_type_odd
    val I_test_one.`more`: L_test_one_more get() = L_test_one_more("${identifier}.more")
data class L_test_one_more(override val identifier: String): L(identifier = identifier), I_test_one_more
interface I_test_one_more: I
    val I_test_one_more.`time`: L_test_one_more_time get() = L_test_one_more_time("${identifier}.time")
data class L_test_one_more_time(override val identifier: String): L(identifier = identifier), I_test_one_more_time
interface I_test_one_more_time: I_test
data class L_test_two(override val identifier: String): L(identifier = identifier), I_test_two
interface I_test_two: I_test_type_even
    val I_test_two.`timing`: L_test_two_timing get() = L_test_two_timing("${identifier}.timing")
data class L_test_two_timing(override val identifier: String): L(identifier = identifier), I_test_two_timing
interface I_test_two_timing: I
data class L_test_type(override val identifier: String): L(identifier = identifier), I_test_type
interface I_test_type: I
    val I_test_type.`even`: L_test_type_even get() = L_test_type_even("${identifier}.even")
    val I_test_type.`odd`: L_test_type_odd get() = L_test_type_odd("${identifier}.odd")
data class L_test_type_even(override val identifier: String): L(identifier = identifier), I_test_type_even
interface I_test_type_even: I
    val I_test_type_even.`no`: L_test_type_even_no get() = L_test_type_even_no("${identifier}.no")
    val I_test_type_even.`bad`: L_test_type_even_bad get() = no.good
typealias L_test_type_even_bad = L_test_type_even_no_good
data class L_test_type_even_no(override val identifier: String): L(identifier = identifier), I_test_type_even_no
interface I_test_type_even_no: I
    val I_test_type_even_no.`good`: L_test_type_even_no_good get() = L_test_type_even_no_good("${identifier}.good")
data class L_test_type_even_no_good(override val identifier: String): L(identifier = identifier), I_test_type_even_no_good
interface I_test_type_even_no_good: I
data class L_test_type_odd(override val identifier: String): L(identifier = identifier), I_test_type_odd
interface I_test_type_odd: I
    val I_test_type_odd.`good`: L_test_type_odd_good get() = L_test_type_odd_good("${identifier}.good")
data class L_test_type_odd_good(override val identifier: String): L(identifier = identifier), I_test_type_odd_good
interface I_test_type_odd_good: Is

