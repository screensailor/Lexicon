//
// github.com/screensailor 2022
//

import Combine
import SwiftUI

private struct EventsKey: EnvironmentKey {
    static let defaultValue: Events = .init()
}

public extension EnvironmentValues {
    var events: Events { self[EventsKey.self] }
}

