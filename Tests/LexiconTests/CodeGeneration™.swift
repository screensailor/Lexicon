//
// github.com/screensailor 2022
//

import Hope
import Lexicon

class CodeGeneration™: Hopes {
    
    func test() async throws {
        
        let root = try await Lexicon.from(TaskPaper(taskpaper).decode()).root
        
        let o = await root.classes().values.sortedByDependancy()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(o)
        let encoded = try String(data: data, encoding: .utf8).hopefully()

        hope(encoded) == json
    }
}

private let taskpaper = """
root:
	a:
	+ root.a.b.c
		b:
		+ root.a
			c:
			+ root
	x:
	= a.b.c
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


private let json = """
[
  {
    "children" : [
      "a",
      "bad",
      "first",
      "good",
      "one",
      "x"
    ],
    "id" : "root"
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
      "b"
    ],
    "id" : "root.a",
    "supertype" : "root.a.b.c",
    "type" : [
      "root.a.b.c"
    ]
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
    "id" : "root.a_&_root.bad",
    "mixinChildren" : [
      "root.bad.worse"
    ],
    "mixinType" : "root.bad",
    "supertype" : "root.a"
  },
  {
    "id" : "root.a_&_root.bad_&_root.first",
    "mixinChildren" : [
      "root.first.second"
    ],
    "mixinType" : "root.first",
    "supertype" : "root.a_&_root.bad"
  },
  {
    "id" : "root.a_&_root.bad_&_root.first_&_root.good",
    "mixinChildren" : [
      "root.good.better"
    ],
    "mixinType" : "root.good",
    "supertype" : "root.a_&_root.bad_&_root.first"
  },
  {
    "id" : "root.a_&_root.first",
    "mixinChildren" : [
      "root.first.second"
    ],
    "mixinType" : "root.first",
    "supertype" : "root.a"
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
    "id" : "root.x",
    "synonymOf" : "root.a.b.c"
  }
]
"""
