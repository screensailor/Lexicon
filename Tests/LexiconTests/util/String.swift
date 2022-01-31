//
// github.com/screensailor 2022
//

extension String {
    
    func lexicon() async throws -> Lexicon {
        try await Lexicon.from(TaskPaper(self).decode())
    }
}
