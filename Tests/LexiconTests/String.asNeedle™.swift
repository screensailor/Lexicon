//
// github.com/screensailor 2022
//

class String_asNeedle™: Hopes {
    
    func test__() throws {
        let (needle, hay) = ("", "")
        let o = try needle.asNeedle(in: hay).hopefully()
        hope(o.indices.in(hay)) == []
        hope(o.score) == 1
    }
    
    func test__a() throws {
        let (needle, hay) = ("", "a")
        let o = try needle.asNeedle(in: hay).hopefully()
        hope(o.indices.in(hay)) == []
        hope(o.score) == 1
    }
    
    func test__aa() throws {
        let (needle, hay) = ("", "aa")
        let o = try needle.asNeedle(in: hay).hopefully()
        hope(o.indices.in(hay)) == []
        hope(o.score) == 0.5
    }
    
    func test_a_() throws {
        let (needle, hay) = ("a", "")
        let o = needle.asNeedle(in: hay)
        hope.none(o)
    }
}

extension Sequence where Element == String.Index {
    
    func `in`(_ string: String) -> [Int] {
        map{ string.distance(from: string.startIndex, to: $0) }
    }
}

