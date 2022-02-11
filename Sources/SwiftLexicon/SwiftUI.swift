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

public extension View {
    
    func on(_ event: I, _ ƒ: @escaping @MainActor (Event) -> ()) -> some View {
        modifier(OnEvent(event: event, ƒ: ƒ))
    }
}

public struct OnEvent: ViewModifier {
    
    @Environment(\.events) var events
    
    let event: I
    let ƒ: @MainActor (Event) -> ()
    
    public func body(content: Content) -> some View {
        content.onReceive(events.filter{ $0.is(event) }) { event in
            ƒ(event)
        }
    }
}
