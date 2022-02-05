//
// github.com/screensailor 2022
//

import Foundation

public extension CLI {
    
    struct Session: Codable {
        
        public var startTime: Double
        public var events: [Event]
        
        public init(startTime: Double) {
            self.startTime = startTime
            self.events = []
        }
        
        // TODO: revisit with composable lexicons
        public func event(cli: CLI, event: CustomDebugStringConvertible) async -> Event {
            Event(
                time: CFAbsoluteTimeGetCurrent() - startTime,
                record: await cli.record(),
                description: event.debugDescription
            )
        }
    }
}

extension CLI.Session: RangeReplaceableCollection {
    
    public var startIndex: Int { events.startIndex }
    public var endIndex: Int { events.endIndex }
    
    public init() {
        self.startTime = CFAbsoluteTimeGetCurrent()
        self.events = []
    }

    public subscript(position: Int) -> Event {
        events[position]
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Event == C.Element {
        events.replaceSubrange(subrange, with: newElements)
    }
    
    public func index(after i: Int) -> Int {
        events.index(after: i)
    }
    
    public func makeIterator() -> Array<Event>.Iterator {
        events.makeIterator()
    }
}

public extension CLI.Session {
    
    struct Event: Codable, CustomStringConvertible {
        public var time: Double
        public var record: Record
        public var description: String
    }
    
    struct Record: Codable, Hashable {
        public var taskpaper: String
        public var root: Lemma.ID
        public var lemma: Lemma.ID
        public var breadcrumbs: [Lemma.ID]
        public var error: CLI.Error
        public var input: String
        public var suggestions: [Lemma.ID]
        public var selectedIndex: Int?
    }
}

public extension CLI {
    
    @LexiconActor func record() -> Session.Record {
        .init(
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
}
