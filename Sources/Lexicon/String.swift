//
// github.com/screensailor 2022
//

import Foundation

extension String: Error {} // TODO: dedicated error types

extension String {

    func dotPath(after: String) -> String {
        guard count >= after.count else { return self }
        guard hasPrefix(after) else { return self }
        guard count > after.count else { return "" }
        let i = index(startIndex, offsetBy: after.count)
        guard i < endIndex, self[i] == "." else { return self }
        return String(suffix(from: index(after: i)))
    }
}

extension String {
	
	var nsRange: NSRange { return .init(location: 0, length: utf16.count) }
	
	func substring(with range: NSRange) -> String {
		return String(NSString(string: self).substring(with: range))
	}
	
	static func * (lhs: String, rhs: Int) -> String {
		return repeatElement(lhs, count: rhs).joined()
	}
}

extension String.Indices {
	
	var range: Range<String.Index> {
		indices.startIndex ..< indices.endIndex
	}
}

extension NSString {
	var range: NSRange { return NSRange(location: 0, length: length) }
}

struct StringMatch {
	let string: String
	let result: NSTextCheckingResult?
}

extension StringMatch {
	
	subscript(_ name: String) -> String? {
		guard
			let range = result?.range(withName: name),
			range.location != NSNotFound,
			range.length > 0 else
		{
			return nil
		}
		return string.substring(with: range)
	}
}

extension NSRegularExpression {
	
	func first(in string: String, options: NSRegularExpression.MatchingOptions = []) -> StringMatch? {
		guard let match = firstMatch(in: string, options: options, range: string.nsRange) else {
			return nil
		}
		return StringMatch(string: string, result: match)
	}
}

extension Sequence {
    
    @inlinable func sortedByLocalizedStandard<S: StringProtocol>(by keyPath: KeyPath<Element, S>, _ order: ComparisonResult = .orderedAscending) -> [Element] {
        sorted { l, r in
            l[keyPath: keyPath].localizedStandardCompare(r[keyPath: keyPath]) == order
        }
    }
}

extension Sequence where Element: StringProtocol {
    
    @inlinable func sortedByLocalizedStandard(_ order: ComparisonResult = .orderedAscending) -> [Element] {
        sorted { l, r in
            l.localizedStandardCompare(r) == order
        }
    }
}
