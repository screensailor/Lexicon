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

// TODO: consider whether `@AnyCancellables var mind: [AnyCancellable]` is a better pattern thand ↓

public extension View {
    
    func on(_ first: I, _ rest: I..., ƒ: @escaping @MainActor (Event) -> ()) -> some View {
        modifier(OnEvents(types: [first] + rest, ƒ: ƒ))
    }
}

struct OnEvents: ViewModifier {
    
    @Environment(\.events) var events
    
    let types: [I]
    let ƒ: @MainActor (Event) -> ()
    
    func body(content: Content) -> some View {
        content.onReceive(events.filter{ event in types.contains(where: event.is) }) { event in
            ƒ(event)
        }
    }
}
