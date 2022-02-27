//
// github.com/screensailor 2022
//

import Foundation
import UniformTypeIdentifiers

public extension UTType {
	static var lexicon = UTType(importedAs: "com.github.screensailor.lexicon")
	static var taskpaper = UTType(importedAs: "com.taskpaper.text")
}

public class TaskPaper {
	
	public typealias Node = Lexicon.Graph.Node
	
	public static let pattern = try! (
		line: NSRegularExpression(pattern: "^(?<tabs>\\t*)(?<content>.+)"),
		lemma: NSRegularExpression(pattern: "^(?<lemma>[\\w]+):?\\s*$"), // TODO: Optional colon `:?` allows plain text (tabbed) outlines, but this should be opted into
		operator: NSRegularExpression(pattern: "^(?<operator>[+=])\\s*(?<content>\\S+)")
	)
	
	public let string: String
	
	private var result: Result<Lexicon.Graph, Error>?
	
	public init(_ string: String) {
		self.string = string
	}
	
	public init(_ UTF8: Data) throws {
		guard let string = String(data: UTF8, encoding: .utf8) else {
			throw "Data is not UTF-8"
		}
		self.string = string
	}
	
	public func decode() throws -> Lexicon.Graph {
		
		if let result = result {
			return try result.get()
		}
		
		var path: [Node] = []
		var error: Error?
		
		string.enumerateLines{ line, stop in
			do {
				guard let match = TaskPaper.pattern.line.firstMatch(in: line, options: [], range: line.nsRange) else {
					return
				}
				let range = match.range(withName: "content")
				let content = line.substring(with: range)
				let depth = match.range(withName: "tabs").length
				try self.decode(line: content, depth: depth, path: &path)
			} catch let o {
				stop = true
				error = o
			}
		}
		
		while path.count > 1 {
			reduce(&path)
		}

		if let error = error {
			result = .failure(error)
			throw error
		}
		
		guard let root = path.first else {
			let error = "The taskpaper file does not declare a root lemma"
			result = .failure(error)
			throw error
		}
		
		let graph = Lexicon.Graph(root: root)
		result = .success(graph)
		return graph
	}
	
	func reduce(_ path: inout [Node]) {
		let child = path.removeLast()
		path[path.endIndex - 1].children[child.name] = child
	}
	
	func decode(line: String, depth: Int, path: inout [Node]) throws {
		
		let name = TaskPaper.pattern.lemma.first(in: line)?["lemma"]
		
		guard path.isNotEmpty else {
			guard let name = name, depth == 0 else {
				return // ignore everything before the first root node
			}
			path = [Node(name: name)]
			return
		}
		
		if let name = name, depth > 0 { // ignore any additional roots... for now :)
			
			let indent = depth - (path.count - 1)
			
			switch indent {
					
				case 1: // child
					break

				case 0: // sibling
					guard path.count > 1 else {
						throw "Found a second root: \(name)" // TODO: allow multiple roots!
					}
					reduce(&path)

				case ..<0: // ancestor
					guard path.count + indent > 0 else {
						throw "Line with wrong indent (\(indent)): '\(line)'"
					}
					for _ in 0...abs(indent) {
						reduce(&path)
					}
					
				default:
					throw "Line with wrong indent (\(indent)): '\(line)'"
			}
			
			path.append(Node(name: name))
		}
		
		else if
			let match = TaskPaper.pattern.operator.first(in: line),
			let symbol = match["operator"],
			let content = match["content"]
		{
			switch symbol {
				case "+": path[path.endIndex - 1].type.insert(content)
				case "=": path[path.endIndex - 1].protonym = content
				default: break
			}
		}
	}
}

public extension TaskPaper {
	
	static func encode(_ node: Lexicon.Graph.Node, date: Date = .init()) -> String {
		encode(Lexicon.Graph(root: node, date: date))
	}
	
	static func encode(_ graph: Lexicon.Graph) -> String {
		
		var lines: [String] = []
		
		graph.root.traverse(sorted: true) { id, name, node in
			let depth = id.reduce(0){ a, e in e == "." ? a + 1 : a }
			let tabs = "\t" * depth
			lines.append("\(tabs)\(name):")
			if let protonym = node.protonym {
				lines.append("\(tabs)= \(protonym)")
			} else {
				for type in node.type.sorted(by: <) { // TODO: consider whether to sort it lexicographically
					lines.append("\(tabs)+ \(type)")
				}
			}
		}
		
		return lines.joined(separator: "\n")
	}
}


