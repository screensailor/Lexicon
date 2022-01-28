//
// github.com/screensailor 2022
//

import Hope
@testable import Lexicon

class JSON™: Hopes {
    
    func test() async throws {
        
		let lexicon = try await Lexicon.from(TaskPaper(Self.taskpaper).decode())
        
        var json = await lexicon.json()
        json.date = Date(timeIntervalSinceReferenceDate: 0)
        
        let data = try GenJSON.generate(json)
        
        let encoded = try String(data: data, encoding: .utf8).hopefully()
        
        hope(encoded) == expected
    }
}

extension JSON™ {

	static let taskpaper = """
	root:
		a:
		+ root.a.b.c
			b:
			+ root.a
				c:
				+ root
		x_y_z:
		= a.b.b.b.b.b
		one:
		+ root.a
			two:
			+ root.a
			+ root.first
				three:
				+ root.a
				+ root.first
				+ root.bad
					four:
					+ root.a
					+ root.first
					+ root.bad
					+ root.good
		first:
			second:
				third:
		bad:
			worse:
				worst:
		good:
			better:
				best:
	"""
}

private let expected = """
{
  "classes" : [
    {
      "children" : [
        "a",
        "bad",
        "first",
        "good",
        "one"
      ],
      "id" : "root",
      "synonyms" : {
        "x_y_z" : "a.b.b.b.b.b"
      }
    },
    {
      "children" : [
        "b"
      ],
      "id" : "root.a",
      "supertype" : "root.a.b.c",
      "type" : [
        "root.a.b.c"
      ]
    },
    {
      "id" : "root.a_&_root.bad",
      "mixin" : {
        "children" : {
          "worse" : "root.bad.worse"
        },
        "type" : "root.bad"
      },
      "supertype" : "root.a"
    },
    {
      "id" : "root.a_&_root.bad_&_root.first",
      "mixin" : {
        "children" : {
          "second" : "root.first.second"
        },
        "type" : "root.first"
      },
      "supertype" : "root.a_&_root.bad"
    },
    {
      "id" : "root.a_&_root.bad_&_root.first_&_root.good",
      "mixin" : {
        "children" : {
          "better" : "root.good.better"
        },
        "type" : "root.good"
      },
      "supertype" : "root.a_&_root.bad_&_root.first"
    },
    {
      "id" : "root.a_&_root.first",
      "mixin" : {
        "children" : {
          "second" : "root.first.second"
        },
        "type" : "root.first"
      },
      "supertype" : "root.a"
    },
    {
      "children" : [
        "c"
      ],
      "id" : "root.a.b",
      "supertype" : "root.a",
      "type" : [
        "root.a"
      ]
    },
    {
      "id" : "root.a.b.c",
      "supertype" : "root",
      "type" : [
        "root"
      ]
    },
    {
      "children" : [
        "worse"
      ],
      "id" : "root.bad"
    },
    {
      "children" : [
        "worst"
      ],
      "id" : "root.bad.worse"
    },
    {
      "id" : "root.bad.worse.worst"
    },
    {
      "children" : [
        "second"
      ],
      "id" : "root.first"
    },
    {
      "children" : [
        "third"
      ],
      "id" : "root.first.second"
    },
    {
      "id" : "root.first.second.third"
    },
    {
      "children" : [
        "better"
      ],
      "id" : "root.good"
    },
    {
      "children" : [
        "best"
      ],
      "id" : "root.good.better"
    },
    {
      "id" : "root.good.better.best"
    },
    {
      "children" : [
        "two"
      ],
      "id" : "root.one",
      "supertype" : "root.a",
      "type" : [
        "root.a"
      ]
    },
    {
      "children" : [
        "three"
      ],
      "id" : "root.one.two",
      "supertype" : "root.a_&_root.first",
      "type" : [
        "root.a",
        "root.first"
      ]
    },
    {
      "children" : [
        "four"
      ],
      "id" : "root.one.two.three",
      "supertype" : "root.a_&_root.bad_&_root.first",
      "type" : [
        "root.a",
        "root.bad",
        "root.first"
      ]
    },
    {
      "id" : "root.one.two.three.four",
      "supertype" : "root.a_&_root.bad_&_root.first_&_root.good",
      "type" : [
        "root.a",
        "root.bad",
        "root.first",
        "root.good"
      ]
    },
    {
      "id" : "root.x_y_z",
      "protonym" : "root.a.b"
    }
  ],
  "date" : 0,
  "name" : "root"
}
"""
