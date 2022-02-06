//
// github.com/screensailor 2021
//

import Foundation
@testable import Lexicon

class CLI™: Hopes {
    
    func test() async throws {
        
        let session: CLI.Session = try "test".json()
        
        var action: CLI.Session.Event?
        var expected: CLI.Session.Event?
        
        for event in session.events { // TODO: run in parallel
            switch event.detail.id { // TODO: generalise ↓ with composable lexicons
                    
                case "app.event.cli.append",
                    "app.event.cli.backspace",
                    "app.event.cli.enter",
                    "app.event.cli.select.next",
                    "app.event.cli.select.previous"
                    :
                    action = event
                    expected = nil
                    
                case "app.event.cli.did.change":
                    expected = event
                    
                default:
                    break
            }
            guard let event = action, let expected = expected else {
                continue
            }
            defer {
                action = nil
            }
            
            func test(_ ƒ: (inout CLI) async throws -> ()) async throws {
                var cli = try await event.cli()
                try await ƒ(&cli)
                let record = await cli.record()
                if record != expected.record {
                    let video = session.video.flatMap { o in
                        o.url.absoluteString + "?t=\(Int(o.start + event.time))\n"
                    } ?? ""
                    let message = try """
                                    
                                    🐞 Failed \(event):
                                    \(video)
                                    • EVENT:
                                    \(event.json().string())
                                    
                                    • EXPECTED:
                                    \(expected.json().string())
                                    
                                    • ACTUAL:
                                    \(record.json().string())
                                    """
                    
                    hope.less(message)
                }
            }
            
            let (id, data) = event.detail

            try await test { cli in
                switch id {
                        
                    case "app.event.cli.append":
                        let character = try data["app.event.cli.append"].try().first.try()
                        await cli.append(character)
                        
                    case "app.event.cli.backspace":
                        await cli.backspace()
                        
                    case "app.event.cli.enter":
                        await cli.enter()
                        
                    case "app.event.cli.select.next":
                        cli.selectNext()
                        
                    case "app.event.cli.select.previous":
                        cli.selectPrevious()
                        
                    default:
                        throw "unexpected test event"
                }
            }
        }
    }
}

extension CLI.Session.Event {
    
    private static let brackets = CharacterSet(charactersIn: "[]")
    
    var detail: (id: String, data: [String: String]) {
        let substrings = description.components(separatedBy: Self.brackets).filter(\.isEmpty.not)
        var id = ""
        var data: [String: String] = [:]
        for (i, (k, v)) in zip(substrings, substrings.dropFirst()).enumerated() where i.isMultiple(of: 2) {
            id = (i == 0) ? k : (id + k)
            data[id] = v
        }
        id = substrings.enumerated().filter{ $0.offset.isMultiple(of: 2) }.map(\.element).joined()
        return (id, data)
    }
}
