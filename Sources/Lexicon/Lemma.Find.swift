//
// github.com/screensailor 2022
//

public extension Lemma {
    
    @inlinable func find(_ prefixes: String...) async -> Set<Lemma> {
        await find(prefixes)
    }
    
    func find<Prefixes>(_ prefixes: Prefixes) async -> Set<Lemma> where Prefixes: Collection, Prefixes.Element == String {
        let prefixes = prefixes.drop(while: \.isEmpty)
        guard let prefix = prefixes.first else {
            return []
        }
        let rest = prefixes.dropFirst()
        var o: Set<Lemma> = []
        for await lemma in breadthFirstTraversal.dropFirst() {
            if lemma.name.hasPrefix(prefix) {
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
