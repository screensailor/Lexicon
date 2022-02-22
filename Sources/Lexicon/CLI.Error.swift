//
// github.com/screensailor 2022
//

public extension CLI {
	
	enum Error: Swift.Error, Codable, Hashable {
		case none
		case invalidInputCharacter(Character)
		case noChildrenMatchInput(String)
		case invalidSelection(index: Int?)
	}
}

public extension CLI.Error {
	
	struct JSON: Codable {
		var `case`: String
		var int: Int?
		var string: String?
	}
	
	init(from decoder: Decoder) throws {
		let json = try JSON(from: decoder)
		switch json.case {
				
			case "none":
				self = .none
				
			case "invalidInputCharacter":
				guard let string = json.string, string.count == 1 else {
					throw "CLI.Error.invalidInputCharacter missing character in \(json)"
				}
				self = .invalidInputCharacter(string.first!)
				
			case "noChildrenMatchInput":
				guard let string = json.string else {
					throw "CLI.Error.noChildrenMatchInput missing string in \(json)"
				}
				self = .noChildrenMatchInput(string)
				
			case "invalidSelection":
				guard let int = json.int else {
					throw "CLI.Error.invalidSelection missing int in \(json)"
				}
				self = .invalidSelection(index: int)
				
			default:
				throw "CLI.Error cannot decode \(json)"
		}
	}
	
	func encode(to encoder: Encoder) throws {
		let json: JSON
		switch self {
				
			case .none:
				json = JSON(case: "none", int: nil, string: nil)
				
			case .invalidInputCharacter(let o):
				json = JSON(case: "invalidInputCharacter", int: nil, string: String(o))
				
			case .noChildrenMatchInput(let o):
				json = JSON(case: "noChildrenMatchInput", int: nil, string: o)
				
			case .invalidSelection(let o):
				json = JSON(case: "invalidSelection", int: o, string: nil)
		}
		try json.encode(to: encoder)
	}
}
