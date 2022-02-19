//
// github.com/screensailor 2022
//

import Combine
import SwiftUI

public extension EnvironmentValues {
    
    var events: Events {
        self[EventsKey.self]
    }
    
    private struct EventsKey: EnvironmentKey {
        static let defaultValue: Events = .init()
    }
}

public extension View {
    
    @available(
        *,
         deprecated,
         message: """
            No way as yet of guaranteeing SwiftUI will not coexisit \
            multiple copies of these values, whith the result of ƒ \
            being called multiple times with the same event.
            """
    )
    func on(_ events: I..., ƒ: @escaping @MainActor (Event) -> ()) -> some View {
        modifier(OnEvents(types: events, ƒ: ƒ))
    }
}

struct OnEvents: ViewModifier {
    
    @Environment(\.events) var events
    
    let types: [I]
    let ƒ: @MainActor (Event) -> ()
    
    func body(content: Content) -> some View {
        if types.isEmpty {
            content
        } else {
            let events = events.filter{ event in types.contains(where: event.is) }
            content.onReceive(events) { event in
                ƒ(event)
            }
        }
    }
}

public extension View {
    
    func update<A: AnyObject, B>(_ a: A, _ k: ReferenceWritableKeyPath<A, B>, to b: B) -> Self {
        a[keyPath: k] = b
        return self
    }
}
