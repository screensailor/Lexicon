//
// github.com/screensailor 2022
//

@_exported import Hope
@_exported import Combine
@_exported import Lexicon
@_exported import KotlinStandAlone

final class KotlinLexicon™: Hopes {
	
	func test_generator() async throws {
		
		var json = try await "test".taskpaper().lexicon().json()
		json.date = Date(timeIntervalSinceReferenceDate: 0)
		
		let code = try Generator.generate(json).string()
		        
		try hope(code) == "test.kt".file().string()
	}
	
	func test_code() throws {
        // Probably need a Kotlin project/repo for this bit, did test it though and it works fine
	}
}
