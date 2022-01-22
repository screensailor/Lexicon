//
// github.com/screensailor 2022
//

public extension Lemma {
    
    // TODO: return an AsyncSequence
    
    @inlinable func find(_ prefixes: String...) async -> Set<Lemma> {
        await find(prefixes)
    }
    
    func find<Prefixes>(_ prefixes: Prefixes) async -> Set<Lemma> where Prefixes: Collection, Prefixes.Element == String {
        let prefixes = prefixes.drop(while: \.isEmpty)
        guard let prefix = prefixes.first else {
            return []
        }
        let rest = prefixes.dropFirst().drop(while: \.isEmpty)
        var o: Set<Lemma> = []
        for await lemma in breadthFirstTraversal.dropFirst() {
            if prefix.localizedCaseInsensitiveCompare(lemma.name.prefix(prefix.count)) == .orderedSame {
                if rest.isEmpty {
                    o.insert(lemma)
                } else {
                    await o.formUnion(lemma.find(rest))
                }
            }
        }
        return o
    }
}
