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

public extension Publisher where Output == Event, Failure == Never {
    
    func then(_ ƒ: @escaping (Event) async -> ()) -> (Self, (Event) async -> ()) {
        (self, ƒ)
    }
}

public func >> <A, P>(event: A.Type, context: (P, (Event) async -> ())) -> AnyCancellable
where P: Publisher, P.Output == Event, P.Failure == Never
{
    context.0.filter{ $0.k(\.L) is A }.sink { @MainActor event in
        await context.1(event)
    }
}

public func >> <A, P>(event: A, context: (P, (Event) async -> ())) -> AnyCancellable
where A: L, P: Publisher, P.Output == Event, P.Failure == Never
{
    context.0.filter{ $0.is(event) }.sink { @MainActor event in
        await context.1(event)
    }
}

public func >> <A, P>(event: K<A>, context: (P, (Event) async -> ())) -> AnyCancellable
where A: L, P: Publisher, P.Output == Event, P.Failure == Never
{
    context.0.filter{ $0.is(event) }.sink { @MainActor event in
        await context.1(event)
    }
}

// MARK: receive in context

public extension EventContext {
    
    func context<P, E>(_ p: P) -> (@escaping (Self, E) async -> ()) -> (Self?, P, (Self, E) async -> ())
    where P: Publisher, P.Output == E, P.Failure == Never
    {
        { [weak self] in (self, p, $0) }
    }

    func context(_ when: @escaping (Self, Event) -> Bool) -> (@escaping (Self, Event) async -> ()) -> (Self?, AnyPublisher<Event, Never>, (Self, Event) async -> ()) {
        let p = events.filter{ [weak self] event in
            guard let self = self else { return false }
            return when(self, event)
        }
        return { [weak self] in (self, p.share().eraseToAnyPublisher(), $0) }
    }
    
    func context(_ when: @escaping (Self) -> Bool) -> (@escaping (Self, Event) async -> ()) -> (Self?, AnyPublisher<Event, Never>, (Self, Event) async -> ()) {
        let p = events.filter{ [weak self] event in
            guard let self = self else { return false }
            return when(self)
        }
        return { [weak self] in (self, p.share().eraseToAnyPublisher(), $0) }
    }
    
    func context() -> (@escaping (Self, Event) async -> ()) -> (Self?, AnyPublisher<Event, Never>, (Self, Event) async -> ()) {
        { [weak self] in
            (self, self?.events.share().eraseToAnyPublisher() ?? Empty().eraseToAnyPublisher(), $0)
        }
    }
}

public func >> <O, P, A>(event: A, context: (O?, P, (O, Event) async -> ())) -> AnyCancellable
where A: L, O: AnyObject, P: Publisher, P.Output == Event, P.Failure == Never
{
    context.1.filter{ $0.is(event) }.sink { @MainActor [weak o = context.0, ƒ = context.2] event in
        guard let o = o else { return }
        await ƒ(o, event)
    }
}

public func >> <O, P, A>(event: K<A>, context: (O?, P, (O, Event) async -> ())) -> AnyCancellable
where A: L, O: AnyObject, P: Publisher, P.Output == Event, P.Failure == Never
{
    context.1.filter{ $0.is(event) }.sink { @MainActor [weak o = context.0, ƒ = context.2] event in
        guard let o = o else { return }
        await ƒ(o, event)
    }
}
