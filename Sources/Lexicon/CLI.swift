//
// github.com/screensailor 2021
//

import Foundation

public struct CLI: Equatable {
    public private(set) var date: Date
    public private(set) var root: Lemma
    public private(set) var breadcrumbs: [Lemma]
    public private(set) var error: Error = .none
    public private(set) var input: String = ""
    public private(set) var suggestions: [Lemma]
    public private(set) var selectedIndex: Int?
}

public extension CLI {
	
	enum Error: Swift.Error, Equatable {
		case none
		case invalidInputCharacter(Character)
		case noChildrenMatchInput(String)
		case invalidSelection(index: Int?)
	}
}

public extension CLI {
	
	@LexiconActor
	init(_ lemma: Lemma, root: Lemma? = nil) {
		self.breadcrumbs = lemma.lineage.reversed()
		self.root = root ?? breadcrumbs.first!
		self.suggestions = lemma.childrenSortedByType
		self.selectedIndex = self.suggestions.indices.first
		self.date = lemma.lexicon.serialization.date
	}
}

public extension CLI {
    
    @inlinable
	var lemma: Lemma {
		breadcrumbs.last!
	}
    
    var selectedSuggestion: Lemma? {
		guard let i = selectedIndex, suggestions.indices ~= i else {
			return nil
		}
        return suggestions[i]
    }
}

public extension CLI {
	
	@discardableResult
	mutating func selectPrevious(cycle: Bool = true) -> Self {
		select(index: (selectedIndex ?? 1) - 1, cycle: cycle)
	}
	
	@discardableResult
	mutating func selectNext(cycle: Bool = true) -> Self {
		select(index: (selectedIndex ?? -1) + 1, cycle: cycle)
	}
	
	@discardableResult
	mutating func select(index: Int, cycle: Bool = false) -> Self {
		if cycle {
			switch (index, suggestions.count)
			{
			case (_, 0):
				error = .invalidSelection(index: index)
				
			case (_, 1):
				error = .none
				selectedIndex = 0
				
			case (...(-1), let count):
				error = .none
				selectedIndex = count + (index % count)
				
			case (0..., let count):
				error = .none
				selectedIndex = index % count
				
			default:
				break
			}
		} else {
			guard suggestions.indices.contains(index) else {
				error = .invalidSelection(index: index)
				return self
			}
			error = .none
			selectedIndex = index
		}
		return self
	}
}

public extension CLI {

    @LexiconActor
    @discardableResult
    mutating func append(_ character: Character) -> Self {
        error = .none
        guard Self.isValid(character: character, appendingTo: input) else {
            error = .invalidInputCharacter(character)
            return self
        }
        input.append(character)
        suggestions = lemma.suggestions(for: input)
        selectedIndex = self.suggestions.indices.first
        error = suggestions.isEmpty ? .noChildrenMatchInput(input) : .none
        return self
    }
    
	@LexiconActor
	@discardableResult
	mutating func replacing(input newInput: String) -> Self {
		input = ""
		error = .none
		for character in newInput {
			guard Self.isValid(character: character, appendingTo: input) else {
				error = .invalidInputCharacter(character)
				return self
			}
			self.input.append(character)
		}
		suggestions = lemma.suggestions(for: input)
		selectedIndex = self.suggestions.indices.first
		error = suggestions.isEmpty ? .noChildrenMatchInput(input) : .none
		return self
	}

    @LexiconActor
    @discardableResult
    mutating func enter() -> Self {
        guard
            let index = selectedIndex,
            suggestions.indices.contains(index)
        else {
            error = .invalidSelection(index: selectedIndex)
            return self
        }
        error = .none
        let suggestion = suggestions[index]
        breadcrumbs.append(suggestion)
        input = ""
        suggestions = lemma.childrenSortedByType
        selectedIndex = suggestions.indices.first
        return self
    }
    
    @LexiconActor
    @discardableResult
    mutating func backspace() -> Self {
        switch (breadcrumbs.count, input.count)
        {
        case (2..., 0):
            if lemma == root {
                return self
            }
            let removed = breadcrumbs.removeLast()
            suggestions = lemma.childrenSortedByType
            selectedIndex = suggestions.firstIndex(of: removed)
            error = .none

        case (_, 1...):
            input.removeLast()
            suggestions = lemma.suggestions(for: input)
            selectedIndex = suggestions.indices.first
            if input.isEmpty {
                error = .none
            } else {
                error = suggestions.isEmpty ? .noChildrenMatchInput(input) : .none
            }

        default:
            break
        }
        return self
    }
	
	@LexiconActor
	@discardableResult
	mutating func update(with lexicon: Lexicon? = nil) -> Self {
		let lexicon = lexicon ?? self.lemma.lexicon
		var o = self
		o.date = lexicon.serialization.date
		o.root = lexicon[root.id] ?? lexicon.root
		o.breadcrumbs = (lexicon[lemma.id] ?? lexicon.root).lineage.reversed()
		o.replacing(input: input)
		if let i = selectedSuggestion.flatMap(o.suggestions.firstIndex(of:)) {
			o.selectedIndex = i
		}
		self = o
		return self
	}

    @LexiconActor
    @discardableResult
    mutating func reset(to lemma: Lemma? = nil, selecting: Lemma? = nil) -> Self {
        self = CLI(lemma ?? self.lemma)
		if let i = selecting.flatMap(suggestions.firstIndex(of:)) {
			selectedIndex = i
		}
        return self
    }
}

public extension Lemma {
    
    func suggestions(for input: String) -> [Lemma] {
        let input = input.lowercased()
        return childrenSortedByType.filter { child in
            child.name.lowercased().starts(with: input)
        }
    }

    var childrenSortedByType: [Lemma] {
		var o = ownChildren.values.sorted(by: \.name)
		for type in ownType.values.sorted(by: \.id) {
			o.append(contentsOf: type.children.keys.sorted(by: \.self).compactMap{ children[$0] })
        }
        return o
    }

    var childrenGroupedByTypeAndSorted: [(type: Lemma, children: [Lemma])] {
		var o = [(self, ownChildren.values.sorted(by: \.name))]
		for type in ownType.values.sorted(by: \.id) {
			o.append((type.unwrapped, type.children.keys.sorted(by: \.self).compactMap{ children[$0] }))
        }
        return o
    }
}

public extension CLI {
	
	static func isValid(character: Character, appendingTo input: String)  -> Bool {
		CharacterSet(charactersIn: String(character)).isSubset(
			of: input.isEmpty
				? Lemma.validFirstCharacterOfName
				: Lemma.validCharacterOfName
		)
	}
}

extension CLI: CustomStringConvertible {
	
	public var description: String {
		if input.isEmpty {
			return lemma.description
		} else {
			return "\(lemma)\(error == .none ? "?" : "+")\(input)"
		}
	}
}
