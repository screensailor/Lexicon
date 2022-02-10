//
// github.com/screensailor 2022
//

import Combine
import SwiftUI

public typealias Events = PassthroughSubject<Event, Never>

private struct EventsKey: EnvironmentKey {
    static let defaultValue: Events = .init()
}

public extension EnvironmentValues {
    var events: Events { self[EventsKey.self] }
}

// MARK: send

public func >> <Event, Publisher: Subject>(event: Event, publisher: Publisher)
where Publisher.Output == Event
{
    publisher.send(event)
}

public func >> <A: L, Publisher: Subject>(event: A, publisher: Publisher) where Publisher.Output == Event {
    publisher.send(Event(event))
}

public func >> <A: L, Publisher: Subject>(event: K<A>, publisher: Publisher) where Publisher.Output == Event {
    publisher.send(Event(event))
}

// MARK: receive

public func >> <A: L, Publisher>(event: A, then: Then<Publisher>) -> AnyCancellable
where
Publisher: Combine.Publisher,
Publisher.Failure == Never,
Publisher.Output == Event
{
    then.publisher.filter{ $0.is(event) }.sink { o in
        Task { @MainActor in
            await then.ƒ(o)
        }
    }
}

public func >> <A: L, Publisher>(event: K<A>, then: Then<Publisher>) -> AnyCancellable
where
Publisher: Combine.Publisher,
Publisher.Failure == Never,
Publisher.Output == Event
{
    then.publisher.filter{ $0.is(event) }.sink { o in
        Task { @MainActor in
            await then.ƒ(o)
        }
    }
}

public extension Publisher where Failure == Never {
    
    func then(_ ƒ: @escaping (Output) async -> ()) -> Then<Self> {
        Then(publisher: self, ƒ: ƒ)
    }
}

public struct Then<Publisher: Combine.Publisher> {
    public let publisher: Publisher
    public let ƒ: (Publisher.Output) async -> ()
}

public extension Publisher where Failure == Never {
    
    func sink(receiveValue: @escaping ((Output) async -> Void)) -> AnyCancellable {
        sink { (o: Output) -> Void in
            Task {
                await receiveValue(o)
            }
        }
    }
}

