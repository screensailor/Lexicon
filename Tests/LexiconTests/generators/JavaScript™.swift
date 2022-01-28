//
// github.com/screensailor 2022
//

class JavaScript™: Hopes {
    
    func test() async throws {
        
        let lexicon = try await Lexicon.from(TaskPaper(JSON™.taskpaper).decode())
        
        var json = await lexicon.json()
        json.date = Date(timeIntervalSinceReferenceDate: 0)
        
        hope(json.js()) == js
    }
}

private let js = #"""
// Generated on: 2001-01-01T00:00:00.000Z


"""#
