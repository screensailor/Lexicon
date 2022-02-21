//
// github.com/screensailor 2021
//

import Foundation

public struct CLI: @unchecked Sendable, Hashable {
    public var date: Date // date is not sendable?
    public var root: Lemma
    public var breadcrumbs: [Lemma]
    public var error: Error = .none
    public var input: String = ""
    public var suggestions: [Lemma]
    public var selectedIndex: Int?
}

public extension CLI {
	
    init(_ lemma: Lemma, root: Lemma? = nil) async {
        self = await CLI.with(lemma: lemma, root: root)
	}
    
    @LexiconActor
    static func with(lemma: Lemma, root: Lemma? = nil) -> CLI {
        let breadcrumbs = lemma.lineage.reversed()
        var o = CLI(
            date: lemma.lexicon.graph.date,
            root: root ?? breadcrumbs.first!,
            breadcrumbs: breadcrumbs,
            suggestions: lemma.childrenSortedByType
        )
        o.selectedIndex = o.suggestions.indices.first
        return o
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

    @discardableResult
    mutating func append(_ character: Character) async -> Self {
        self = await appending(character)
        return self
    }
    
    @LexiconActor
    func appending(_ character: Character) -> CLI {
        var o = self
        o.error = .none
        guard Self.isValid(character: character, appendingTo: o.input) else {
            o.error = .invalidInputCharacter(character)
            return o
        }
        o.input.append(character)
        o.suggestions = o.lemma.suggestions(for: o.input)
        o.selectedIndex = o.suggestions.indices.first
        o.error = o.suggestions.isEmpty ? .noChildrenMatchInput(o.input) : .none
        return o
    }
}

public extension CLI {
    
	@discardableResult
	mutating func replace(input newInput: String) async -> Self {
        self = await replacing(input: newInput)
        return self
	}
    
    @LexiconActor
    func replacing(input newInput: String) -> CLI {
        var o = self
        o.input = ""
        o.error = .none
        for character in newInput {
            guard Self.isValid(character: character, appendingTo: o.input) else {
                o.error = .invalidInputCharacter(character)
                return o
            }
            o.input.append(character)
        }
        o.suggestions = o.lemma.suggestions(for: o.input)
        o.selectedIndex = o.suggestions.indices.first
        o.error = o.suggestions.isEmpty ? .noChildrenMatchInput(o.input) : .none
        return o
    }
}

public extension CLI {
    
    @discardableResult
    mutating func enter() async -> Self {
        self = await entered()
        return self
    }
    
    @LexiconActor
    func entered() -> CLI {
        if let protonym = lemma.deepProtonym {
            return CLI.with(lemma: protonym)
        }
        var o = self
        guard
            let index = o.selectedIndex,
            o.suggestions.indices.contains(index)
        else {
            o.error = .invalidSelection(index: o.selectedIndex)
            return o
        }
        o.error = .none
        let suggestion = o.suggestions[index]
        o.breadcrumbs.append(suggestion)
        o.input = ""
        o.suggestions = o.lemma.childrenSortedByType
        o.selectedIndex = o.suggestions.indices.first
        return o
    }
}

public extension CLI {
    
    @discardableResult
    mutating func backspace() async -> Self {
        self = await backspaced()
        return self
    }
    
    @LexiconActor
    func backspaced() -> CLI {
        var o = self
        switch (o.breadcrumbs.count, o.input.count)
        {
            case (2..., 0):
                if o.lemma == o.root {
                    return o
                }
                let removed = o.breadcrumbs.removeLast()
                o.suggestions = o.lemma.childrenSortedByType
                o.selectedIndex = o.suggestions.firstIndex(of: removed)
                o.error = .none
                
            case (_, 1...):
                o.input.removeLast()
                o.suggestions = o.lemma.suggestions(for: o.input)
                o.selectedIndex = o.suggestions.indices.first
                if o.input.isEmpty {
                    o.error = .none
                } else {
                    o.error = o.suggestions.isEmpty ? .noChildrenMatchInput(o.input) : .none
                }
                
            default:
                break
        }
        return o
    }
}

public extension CLI {
    
	@discardableResult
	mutating func update(with lexicon: Lexicon? = nil) async -> Self {
        self = await updated(with: lexicon)
        return self
	}
    
    @LexiconActor
    func updated(with lexicon: Lexicon? = nil) -> CLI {
        let lexicon = lexicon ?? self.lemma.lexicon
        var o = self
        o.date = lexicon.graph.date
        o.root = lexicon[o.root.id] ?? lexicon.root
        o.breadcrumbs = (lexicon[o.lemma.id] ?? lexicon.root).lineage.reversed()
        o = o.replacing(input: o.input)
        if let i = self.selectedSuggestion.flatMap(o.suggestions.firstIndex(of:)) {
            o.selectedIndex = i
        }
        return o
    }
}

public extension CLI {
    
    @discardableResult
    mutating func reset(to lemma: Lemma? = nil, selecting: Lemma? = nil) async -> Self {
        self = await reseting(to: lemma, selecting: selecting)
        return self
    }
    
    @LexiconActor
    func reseting(to lemma: Lemma? = nil, selecting: Lemma? = nil) -> CLI {
        var o = CLI.with(lemma: lemma ?? self.lemma)
        if let selecting = selecting, let i = o.suggestions.firstIndex(of: selecting) {
            o.selectedIndex = i
        }
        return o
    }
}

public extension Lemma {
    
    func suggestions(for input: String) -> [Lemma] {
        let input = input.lowercased()
        return childrenSortedByType.filter { child in
            child.name.lowercased().starts(with: input)
        }
    }
    
    var deepProtonym: Lemma? {
        if let protonym = rootProtonym {
            return protonym
        }
        if let protonym = node.protonym, let lemma = lexicon[String(id.dropLast(name.count) + protonym)] {
            return lemma
        }
        return nil
    }

    var childrenSortedByType: [Lemma] {
        if let deepProtonym = deepProtonym {
            return deepProtonym.childrenSortedByType
        }
		var o = ownChildren.values.sortedByLocalizedStandard(by: \.name)
		for type in ownType.values.sortedByLocalizedStandard(by: \.id) {
			o.append(contentsOf: type.children.keys.sortedByLocalizedStandard(by: \.self).compactMap{ children[$0] })
        }
        return o
    }

    var childrenGroupedByTypeAndSorted: [(type: Lemma, children: [Lemma])] {
        if let deepProtonym = deepProtonym {
            return deepProtonym.childrenGroupedByTypeAndSorted
        }
		var o = [(self, ownChildren.values.sortedByLocalizedStandard(by: \.name))]
		for type in ownType.values.sortedByLocalizedStandard(by: \.id) {
			o.append((type.unwrapped, type.children.keys.sortedByLocalizedStandard(by: \.self).compactMap{ children[$0] }))
        }
        return o
    }
}

public extension CLI {
    
    static func isValid(name: String) -> Bool {
        guard
            let first = name.first,
            CharacterSet(charactersIn: String(first)).isSubset(of: Lemma.validFirstCharacterOfName),
            CharacterSet(charactersIn: String(name.dropFirst())).isSubset(of: Lemma.validCharacterOfName)
        else { return false }
        return true
    }
    
    static func isValid(character: Character, appendingTo input: String) -> Bool {
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
