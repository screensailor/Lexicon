//
// github.com/screensailor 2022
//

@_exported import Hope
@_exported import Combine
@_exported import Lexicon
@_exported import SwiftStandAlone

final class SwiftLexicon™: Hopes {
	
	func test_generator() async throws {
		
		var json = try await "test".taskpaper().lexicon().json()
		json.date = Date(timeIntervalSinceReferenceDate: 0)
		
		let code = try Generator.generate(json).string()
		
		try hope(code) == "test.swift".file().string()
	}
	
	func test_code() throws {
		
		hope(test.one.more.time.one.more.time(\.id)) == "test.one.more.time.one.more.time"
		
		hope(test.two.bad) == test.two.no.good
		hope(test.two.bad(\.id)) == "test.two.no.good"
	}
}
