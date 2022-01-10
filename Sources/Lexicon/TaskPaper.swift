//
// github.com/screensailor 2022
//

import Foundation

public class TaskPaper { // TODO: actor
	
	typealias Node = Lexicon.Serialization.Node
	
	static let linePattern = try! NSRegularExpression(pattern: "^(?<tabs>\\t*)(?<content>.+)")
	static let lemmaPattern = try! NSRegularExpression(pattern: "^(?<lemma>[\\w]+):?\\s*$") // TODO: Optional colon `:?` allows plain text (tabbed) outlines, but this should be opted into
	static let operatorPattern = try! NSRegularExpression(pattern: "^(?<operator>[+=])\\s*(?<content>\\S+)")

	let string: String
	
	private(set) var error: Error?
	private(set) var name: Node.Name?
	private(set) var root: Node?
	
	private var path: [Node] = []

	public init(_ string: String) {
		self.string = string
	}

	public init(_ UTF8: Data) throws {
		guard let string = String(data: UTF8, encoding: .utf8) else {
			throw "Data is not UTF-8"
		}
		self.string = string
	}

	public func decode() throws -> Lexicon.Serialization {
		
		if let error = error {
			throw error
		}
		
		if let root = root, let name = name {
			return .init(name: name, root: root) // TODO: date
		}
		
		string.enumerateLines{ line, stop in
			do {
				guard let match = TaskPaper.linePattern.firstMatch(in: line, options: [], range: line.nsRange) else {
					return
				}
				let range = match.range(withName: "content")
				let content = line.substring(with: range)
				let depth = match.range(withName: "tabs").length
				try self.decode(line: content, depth: depth)
			} catch {
				stop = true
				self.error = error
				print("😱", error)
			}
		}
		
		if let error = error {
			throw error
		}
		
		guard let root = root, let name = name else {
			throw "The taskpaper file does not declare a root lemma"
		}
		
		return .init(name: name, root: root) // TODO: date
	}
	
	func decode(line: String, depth: Int) throws {
		
		let name = TaskPaper.lemmaPattern.first(in: line)?["lemma"]
		
		guard !path.isEmpty else {
			guard let name = name, depth == 0 else {
				return // ignore everything before the first root node
			}
			let node = Node()
			self.name = name
			self.root = node
			self.path.append(node)
			return
		}
		
		guard depth > 0 else {
			return // ignore any additional roots
		}
		
		if let name = name {
			
			let node = Node()
			let indent = depth - (path.count - 1)

			switch indent {
				
			case 0:
				path.removeLast()
				guard let parent = path.last else {
					throw "More than one root: \(name) (current root: \(self.name ?? "?"))"
				}
				parent.children[name] = node
				path.append(node)

			case 1:
				path.last?.children[name] = node
				path.append(node)

			case ..<0:
				guard path.count + indent > 0 else {
					throw "Line with wrong indent (\(indent)): '\(line)'"
				}
				path.removeLast(1 + abs(indent))
				path.last?.children[name] = node
				path.append(node)

			default:
				throw "Line with wrong indent (\(indent)): '\(line)'"
			}
		}
		
		else if
			let node = path.last,
			let match = TaskPaper.operatorPattern.first(in: line),
			let op = match["operator"],
			let content = match["content"]
		{
			switch op {
			case "+": node.type.insert(content)
			case "=": node.protonym = content
			default: break
			}
		}
	}
}

public extension TaskPaper {
	
	static func encode(node: Lexicon.Serialization.Node, name: Lemma.Name, date: Date = .init()) -> String {
		encode(.init(name: name, root: node, date: date))
	}
	
	static func encode(_ serialization: Lexicon.Serialization) -> String {
		
		var lines: [String] = []
		
		serialization.root.traverse(sorted: true, name: serialization.name) { id, name, node in
			let depth = id.reduce(0){ a, e in e == "." ? a + 1 : a }
			let tabs = "\t" * depth
			lines.append("\(tabs)\(name):")
			if let protonym = node.protonym {
				lines.append("\(tabs)= \(protonym)")
			} else {
				for type in node.type?.sorted(by: <) ?? [] {
					lines.append("\(tabs)+ \(type)")
				}
			}
		}
		
		return lines.joined(separator: "\n")
	}
}


