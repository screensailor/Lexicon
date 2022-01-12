//
// github.com/screensailor 2021
//

import Foundation

public extension Lexicon {
    
    struct Serialization: Codable {

        public internal(set) var date: Date
        public internal(set) var name: Lemma.Name
        public let root: Node

		public init(name: Lemma.Name = "root", root: Node = .init(), date: Date = .init()) {
            self.name = name
            self.root = root
            self.date = date
        }
    }
}

extension Lexicon.Serialization {
	
	public func data(encoder: JSONEncoder = .init(), formatting: JSONEncoder.OutputFormatting = [.sortedKeys, .prettyPrinted]) -> Data {
		encoder.outputFormatting = formatting
		return try! encoder.encode(self)
	}
	
	public func string(formatting: JSONEncoder.OutputFormatting = [.sortedKeys, .prettyPrinted]) -> String {
		String(data: data(formatting: formatting), encoding: .utf8)!
	}
}
