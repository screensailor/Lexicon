//
// github.com/screensailor 2022
//

import Foundation
import UniformTypeIdentifiers

public enum JSONClasses: CodeGenerator {
	
	public static let utType: UTType = .json
	
	public static func generate(_ json: Lexicon.Graph.JSON) throws -> Data {
		let encoder = Encoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		return try encoder.encode(json)
	}
	
	public class Encoder: JSONEncoder {
		public override init() {
			super.init()
			self.dateEncodingStrategy = .formatted(DateFormatter.shared)
		}
	}
	
	public class Decoder: JSONDecoder {
		public override init() {
			super.init()
			self.dateDecodingStrategy = .formatted(DateFormatter.shared)
		}
	}
	
	public class DateFormatter: Foundation.DateFormatter {
		
		public static let shared = DateFormatter()
		
		public private(set) lazy var iso: ISO8601DateFormatter = {
			self.dateStyle = .long
			self.timeStyle = .short
			let o = ISO8601DateFormatter()
			o.formatOptions.insert(.withFractionalSeconds)
			o.timeZone = .none
			return o
		}()
		
		public override func date(from string: String) -> Date? {
			iso.date(from: string)
		}
		
		public override func string(from date: Date) -> String {
			iso.string(from: date)
		}
	}
}
