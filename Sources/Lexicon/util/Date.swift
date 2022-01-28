//
// github.com/screensailor 2022
//

import Foundation

extension Date {
    
    func iso() -> String {
        Self.formatter.string(from: self)
    }
    
    private static let formatter: ISO8601DateFormatter = {
        let o = ISO8601DateFormatter()
        o.formatOptions.insert(.withFractionalSeconds)
        return o
    }()
}
