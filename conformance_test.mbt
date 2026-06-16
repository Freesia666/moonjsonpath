///|
struct JsonPathCase {
  name : String
  path : String
  expected : Json
} derive(Debug)

///|
fn rfc_fixture() -> Json {
  {
    "store": {
      "book": [
        {
          "category": "reference",
          "author": "Nigel Rees",
          "title": "Sayings of the Century",
          "price": 8.95,
          "isbn": "0-553-21311-3",
        },
        {
          "category": "fiction",
          "author": "Evelyn Waugh",
          "title": "Sword of Honour",
          "price": 12.99,
        },
        {
          "category": "fiction",
          "author": "Herman Melville",
          "title": "Moby Dick",
          "isbn": "0-553-21311-5",
          "price": 8.99,
        },
        {
          "category": "fiction",
          "author": "J. R. R. Tolkien",
          "title": "The Lord of the Rings",
          "isbn": "0-395-19395-8",
          "price": 22.99,
        },
      ],
      "bicycle": { "color": "red", "price": 399 },
    },
    "expensive": 10,
    "weird/key": { "space key": "ok", "quote\"key": "escaped" },
  }
}

///|
fn conformance_cases() -> Array[JsonPathCase] {
  [
    {
      name: "dot member path selects all authors",
      path: "$.store.book[*].author",
      expected: [
        "Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien",
      ],
    },
    {
      name: "array index selects the third book",
      path: "$.store.book[2].title",
      expected: ["Moby Dick"],
    },
    {
      name: "union of array indexes preserves selector order",
      path: "$.store.book[0,2].title",
      expected: ["Sayings of the Century", "Moby Dick"],
    },
    {
      name: "quoted member selector handles slash and spaces",
      path: "$['weird/key']['space key']",
      expected: ["ok"],
    },
    {
      name: "quoted member selector unescapes double quotes",
      path: "$['weird/key']['quote\\\"key']",
      expected: ["escaped"],
    },
    {
      name: "recursive descent finds every price",
      path: "$..price",
      expected: [8.95, 12.99, 8.99, 22.99, 399],
    },
    {
      name: "slice keeps middle book titles",
      path: "$.store.book[1:3].title",
      expected: ["Sword of Honour", "Moby Dick"],
    },
    {
      name: "existence filter keeps books with isbn",
      path: "$.store.book[?(@.isbn)].title",
      expected: ["Sayings of the Century", "Moby Dick", "The Lord of the Rings"],
    },
    {
      name: "numeric filter keeps cheap books",
      path: "$.store.book[?(@.price < 10)].title",
      expected: ["Sayings of the Century", "Moby Dick"],
    },
    {
      name: "conjunction filter keeps cheap fiction",
      path: "$.store.book[?(@.category == \"fiction\" && @.price < 10)].title",
      expected: ["Moby Dick"],
    },
  ]
}

///|
test "RFC-style JSONPath conformance cases" {
  let fixture = rfc_fixture()
  for case in conformance_cases() {
    let compiled = @moonjsonpath.Path::compile(case.path)
    inspect(compiled is Ok(_), content="true")
    let values = compiled.unwrap().query(fixture).map(item => item.value)
    @json.json_inspect(values, content=case.expected)
  }
}

///|
test "JSON Pointer conformance examples from RFC6901" {
  let doc : Json = {
    "foo": ["bar", "baz"],
    "": 0,
    "a/b": 1,
    "c%d": 2,
    "e^f": 3,
    "g|h": 4,
    "i\\j": 5,
    "k\"l": 6,
    " ": 7,
    "m~n": 8,
  }
  let cases : Array[(String, Json)] = [
    ("", doc),
    ("/foo", ["bar", "baz"]),
    ("/foo/0", "bar"),
    ("/", 0),
    ("/a~1b", 1),
    ("/c%d", 2),
    ("/e^f", 3),
    ("/g|h", 4),
    ("/i\\j", 5),
    ("/k\"l", 6),
    ("/ ", 7),
    ("/m~0n", 8),
  ]
  for pair in cases {
    let (pointer_text, expected) = pair
    let value = @moonjsonpath.Pointer::parse(pointer_text).unwrap().get(doc)
    inspect(value is Ok(_), content="true")
    @json.json_inspect(value.unwrap(), content=expected)
  }
}
