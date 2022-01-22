//
// github.com/screensailor 2022
//

import Collections

public extension Lemma {
    
    // TODO: return an AsyncSequence
    
    @inlinable func find(_ prefixes: String..., max: Int = 1000) async -> OrderedSet<Lemma> {
        await find(prefixes, max: max)
    }
    
    func find<Prefixes>(_ prefixes: Prefixes, max: Int = 1000) async -> OrderedSet<Lemma> where Prefixes: Collection, Prefixes.Element == String {
        let prefixes = prefixes.drop(while: \.isEmpty)
        guard let prefix = prefixes.first else {
            return []
        }
        let rest = prefixes.dropFirst().drop(while: \.isEmpty)
        var o: OrderedSet<Lemma> = []
        for await lemma in breadthFirstTraversal.dropFirst() where o.count < max {
            if prefix.localizedCaseInsensitiveCompare(lemma.name.prefix(prefix.count)) == .orderedSame {
                if rest.isEmpty {
                    o.append(lemma)
                } else {
                    await o.append(contentsOf: lemma.find(rest, max: max - o.count))
                }
            }
        }
        return o
    }
}
