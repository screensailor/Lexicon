//
// github.com/screensailor 2022
//

import Foundation

public extension CLI {
    
    @LexiconActor
    func record(timestamp: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()) -> Record {
        Record(
            timestamp: timestamp,
            taskpaper: TaskPaper.encode(lemma.lexicon.graph),
            root: root.id,
            lemma: lemma.id,
            breadcrumbs: breadcrumbs.map(\.id),
            error: error,
            input: input,
            suggestions: suggestions.map(\.id),
            selectedIndex: selectedIndex
        )
    }
    
    struct Record: Codable, Hashable {
        public var timestamp: Double
        public var taskpaper: String
        public var root: Lemma.ID
        public var lemma: Lemma.ID
        public var breadcrumbs: [Lemma.ID]
        public var error: Error
        public var input: String
        public var suggestions: [Lemma.ID]
        public var selectedIndex: Int?
    }
}
