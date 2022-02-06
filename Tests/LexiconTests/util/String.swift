//
// github.com/screensailor 2022
//

import Foundation

extension String {
    
    func json<A: Decodable>(as: A.Type = A.self, using decoder: JSONDecoder = .init()) throws -> A {
        return try decoder.decode(A.self, from: json())
    }
    
    func json() throws -> Data {
        guard let url = Bundle.module.url(forResource: "Resources/\(self)", withExtension: "json") else {
            throw "Could not find '\(self).json'"
        }
        return  try Data(contentsOf: url)
    }

    func lexicon() async throws -> Lexicon {
        try await Lexicon.from(TaskPaper(self).decode())
    }
}
