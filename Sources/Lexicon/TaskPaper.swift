//
// github.com/screensailor 2022
//

import Foundation
import UniformTypeIdentifiers

public extension UTType {
    static var taskpaper = UTType(importedAs: "com.taskpaper.plain-text") // TODO: rethink
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
        
        var path: [WritableKeyPath<Node, Node>] = []
        var root = Node(root: "")
        var error: Error?
		
		string.enumerateLines{ line, stop in
			do {
                guard let match = TaskPaper.pattern.line.firstMatch(in: line, options: [], range: line.nsRange) else {
					return
				}
				let range = match.range(withName: "content")
				let content = line.substring(with: range)
				let depth = match.range(withName: "tabs").length
                try self.decode(line: content, depth: depth, path: &path, in: &root)
			} catch let o {
				stop = true
				error = o
			}
		}
		
		if let error = error {
            result = .failure(error)
            throw error
        }
        
        guard root.name.isNotEmpty else {
            let error = "The taskpaper file does not declare a root lemma"
            result = .failure(error)
            throw error
        }
        
        let graph = Lexicon.Graph(root: root)
        result = .success(graph)
		return graph
	}
	
    func decode(line: String, depth: Int, path: inout [WritableKeyPath<Node, Node>], in root: inout Node) throws {
		
        let name = TaskPaper.pattern.lemma.first(in: line)?["lemma"]
		
        guard var parent = path.last else {
			guard let name = name, depth == 0 else {
				return // ignore everything before the first root node
			}
            root = Node(root: name)
            path = [\.self]
			return
		}
		
		guard depth > 0 else {
			return // ignore any additional roots
		}
		
        if let name = name {
            
            let indent = depth - (path.count - 1)
            
            switch indent {
                    
                case 0:
                    path.removeLast()
                    guard path.isNotEmpty else {
                        throw "More than one root: \(name) (current root: '\(root.name)')" // TODO: allow multiple roots!
                    }
                    parent = path.last!
                    
                case 1:
                    break
                    
                case ..<0:
                    guard path.count + indent > 0 else {
                        throw "Line with wrong indent (\(indent)): '\(line)'"
                    }
                    path.removeLast(1 - indent)
                    parent = path.last!

                default:
                    throw "Line with wrong indent (\(indent)): '\(line)'"
            }
            
            root[keyPath: parent].make(child: name)
            path.append(parent.appending(path: \.[name]))
        }
		
		else if
            let node = path.last,
            let match = TaskPaper.pattern.operator.first(in: line),
			let symbol = match["operator"],
			let content = match["content"]
		{
			switch symbol {
			case "+": root[keyPath: node].type.insert(content)
			case "=": root[keyPath: node].protonym = content
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


