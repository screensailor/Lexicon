//
// github.com/screensailor 2022
//

extension Encodable {
    
    func json(encoder: JSONEncoder = .init(), formatting: JSONEncoder.OutputFormatting = [.prettyPrinted, .sortedKeys]) throws -> Data {
        encoder.outputFormatting.formUnion(formatting)
        return try encoder.encode(self)
    }
}
