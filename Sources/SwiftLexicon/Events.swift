//
// github.com/screensailor 2022
//

import Combine

public typealias Events = PassthroughSubject<Event, Never>

// MARK: send

public func >> <Publisher: Subject>(event: Event, publisher: Publisher) where Publisher.Output == Event {
    publisher.send(event)
}

public func >> <A: L, Publisher: Subject>(event: A, publisher: Publisher) where Publisher.Output == Event {
    publisher.send(Event(event))
}

public func >> <A: L, Publisher: Subject>(event: K<A>, publisher: Publisher) where Publisher.Output == Event {
    publisher.send(Event(event))
}

// MARK: receive

public extension Publisher where Failure == Never {
    
    @inlinable func sink(receiveValue: @escaping ((Output) async -> Void)) -> AnyCancellable {
        self.sink { (o: Output) -> Void in
            Task { // TODO: detached?
                await receiveValue(o)
            }
        }
    }
}

// MARK: receive out of context

public extension Then {
    
    static func >> <A>(event: A.Type, then: Self) -> AnyCancellable {
        then.publisher.filter{ $0.is(A.self) }.sink { @MainActor event in
            await then.ƒ(event)
        }
    }
    
    static func >> <A: L>(event: A, then: Self) -> AnyCancellable {
        then.publisher.filter{ $0.is(event) }.sink { @MainActor event in
            await then.ƒ(event)
        }
    }

    static func >> <A: L>(event: K<A>, then: Self) -> AnyCancellable {
        then.publisher.filter{ $0.is(event) }.sink { @MainActor event in
            await then.ƒ(event)
        }
    }
}

public extension Publisher where Failure == Never, Output == Event {
    
    func then(_ ƒ: @escaping (Output) async -> ()) -> Then<Self> {
        Then(publisher: self, ƒ: ƒ)
    }
}

public struct Then<Publisher>
where Publisher: Combine.Publisher, Publisher.Failure == Never, Publisher.Output == Event
{
    public let publisher: Publisher
    public let ƒ: (Publisher.Output) async -> ()
}

// MARK: receive in context

public extension EventContext {
    
    func then(_ ƒ: @escaping (Self, Event) async -> ()) -> ThenInContext<Self, Events> {
        ThenInContext(context: self, publisher: events, ƒ: ƒ)
    }
}

public extension ThenInContext {
    
    static func >> <A: L>(event: A.Type, then: Self) -> AnyCancellable {
        then.publisher.filter{ $0.is(A.self) }.sink { @MainActor event in
            guard let context = then.context else { return }
            await then.ƒ(context, event)
        }
    }
    
    static func >> <A: L>(event: A, then: Self) -> AnyCancellable {
        then.publisher.filter{ $0.is(event) }.sink { @MainActor event in
            guard let context = then.context else { return }
            await then.ƒ(context, event)
        }
    }

    static func >> <A: L>(event: K<A>, then: Self) -> AnyCancellable {
        then.publisher.filter{ $0.is(event) }.sink { @MainActor event in
            guard let context = then.context else { return }
            await then.ƒ(context, event)
        }
    }
}

public extension Publisher where Failure == Never, Output == Event {

    func `in`<Context: AnyObject>(_ context: Context, _ ƒ: @escaping (Context, Output) async -> ()) -> ThenInContext<Context, Self> {
        ThenInContext(context: context, publisher: self, ƒ: ƒ)
    }
}

public struct ThenInContext<Context, Publisher>
where Context: AnyObject, Publisher: Combine.Publisher, Publisher.Failure == Never, Publisher.Output == Event
{
    public private(set) weak var context: Context?
    public let publisher: Publisher
    public let ƒ: (Context, Publisher.Output) async -> ()
}
