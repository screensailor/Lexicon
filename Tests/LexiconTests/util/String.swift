//
// github.com/screensailor 2022
//

import Foundation

extension String {
    
    func json<A: Decodable>(as: A.Type = A.self, using decoder: JSONDecoder = .init()) throws -> A {
		try decoder.decode(A.self, from: "\(self).json".file())
    }
	
	func taskpaper() throws -> String {
		try "\(self).taskpaper".file().string()
	}
	
	func file() throws -> Data {
		guard let url = Bundle.module.url(forResource: "Resources/\(self)", withExtension: nil) else {
			throw "Could not find '\(self)'"
		}
		return  try Data(contentsOf: url)
	}
	
	func lexicon() async throws -> Lexicon {
		try await Lexicon.from(TaskPaper(self).decode())
	}
}
