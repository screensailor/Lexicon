//
// github.com/screensailor 2022
//

@_exported import Hope
@_exported import Combine
@_exported import Lexicon
@_exported import SwiftLexicon

final class SwiftLexicon™: Hopes {
    
    func test_generator() async throws {
        
        var json = try await "test".taskpaper().lexicon().json()
        json.date = Date(timeIntervalSinceReferenceDate: 0)
        
        let code = try Generator.generate(json).string()
        
        try hope(code) == "test.swift".file().string()
    }
    
    func test_code() throws {
        
        hope(test.one.more.time.one.more.time(\.id)) == "test.one.more.time.one.more.time"
        
        hope(test.two.bad) == test.two.no.good
        hope(test.two.bad(\.id)) == "test.two.no.good"
    }
    
    func test_events() throws {
        
        let l = test.one.more.time.one
        
        let events = Events()
        var result: Event?
        
        let promise = expectation()
        
        let o = l >> events.then { event in
            result = event
            promise.fulfill()
        }
        
        l >> events
        
        wait(for: 1)
        o.cancel()
        
        hope(result) == Event(l)
    }
    
    func test_Event() throws {
        
        let k = test.one[1].more[2].time["3"].one[0]
        let l = k.___
        
        hope(l) == test.one.more.time.one
        
        hope(k(\.id)) == "test.one[1].more[2].time[3].one[0]"
        
        let events = Events()
        var result: Event?
        
        let promise = expectation()
        
        let o = l >> events.then { event in
            result = event
            promise.fulfill()
        }
        
        k >> events
        
        wait(for: 1)
        o.cancel()
        
        let x = try result.try()
        
        hope(x) == Event(k)
        
        try hope(x[]) == 0
        try hope(x[test.one]) == 1
        try hope(x[test.one.more]) == 2
        try hope(x[test.one.more.time]) == "3"
    }
    
    func test_Event_granularity() throws {
        
        let events = Events()
        
        let promiseTicks = expectation()
        let promiseAll = expectation()
        
        var ticks: [String] = []
        var all: [String] = []
        
        let oTicks = test.one.more.time["✅"].one >> events.then { event in
            guard let o: String = try? event[test.one.more.time] else {
                return
            }
            ticks.append(o)
            if ticks == ["✅", "✅"] {
                promiseTicks.fulfill()
            }
        }
        
        let oAll = test.one >> events.receive(on: RunLoop.main).then { event in
            guard let o: String = try? event[test.one.more.time] else {
                return
            }
            all.append(o)
            if all == ["✅", "❌", "✅"] {
                promiseAll.fulfill()
            }
        }

        test.one[1].more[1].time["✅"].one[1] >> events
        test.one[2].more[2].time["❌"].one[2] >> events
        test.one[3].more[3].time["✅"].one[3] >> events
        
        wait(for: 1)
        oTicks.cancel()
        oAll.cancel()
    }
}
