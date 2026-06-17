///|
struct CatalogCase {
  name : String
  query : String
  values : Json
  pointers : Array[String]
}

///|
fn catalog_doc() -> Json {
  {
    "store": {
      "book": [
        {
          "category": "reference",
          "author": "Nigel",
          "title": "Sayings",
          "price": 8.95,
          "tags": ["classic", "quote"],
          "available": true,
        },
        {
          "category": "fiction",
          "author": "Evelyn",
          "title": "Sword",
          "price": 12.99,
          "tags": ["fiction"],
          "available": false,
        },
        {
          "category": "fiction",
          "author": "Herman",
          "title": "Moby",
          "price": 8.99,
          "tags": ["fiction", "sea"],
          "available": true,
        },
        {
          "category": "fiction",
          "author": "Tolkien",
          "title": "Ring",
          "price": 22.99,
          "tags": ["fiction", "fantasy", "classic"],
          "available": true,
        },
      ],
      "bicycle": {
        "color": "red",
        "price": 19.95,
      },
    },
    "meta": {
      "count": 4,
      "owner": "MoonJSONPath",
      "labels": ["contest", "json", "tooling"],
    },
  }
}

///|
fn catalog_cases() -> Array[CatalogCase] {
  [
    {
      name: "root store",
      query: "$.store",
      values: [{
        "book": [
          {
            "category": "reference",
            "author": "Nigel",
            "title": "Sayings",
            "price": 8.95,
            "tags": ["classic", "quote"],
            "available": true,
          },
          {
            "category": "fiction",
            "author": "Evelyn",
            "title": "Sword",
            "price": 12.99,
            "tags": ["fiction"],
            "available": false,
          },
          {
            "category": "fiction",
            "author": "Herman",
            "title": "Moby",
            "price": 8.99,
            "tags": ["fiction", "sea"],
            "available": true,
          },
          {
            "category": "fiction",
            "author": "Tolkien",
            "title": "Ring",
            "price": 22.99,
            "tags": ["fiction", "fantasy", "classic"],
            "available": true,
          },
        ],
        "bicycle": { "color": "red", "price": 19.95 },
      }],
      pointers: ["/store"],
    },
    {
      name: "all authors",
      query: "$.store.book[*].author",
      values: ["Nigel", "Evelyn", "Herman", "Tolkien"],
      pointers: [
        "/store/book/0/author",
        "/store/book/1/author",
        "/store/book/2/author",
        "/store/book/3/author",
      ],
    },
    {
      name: "first title",
      query: "$.store.book[0].title",
      values: ["Sayings"],
      pointers: ["/store/book/0/title"],
    },
    {
      name: "last title by negative index",
      query: "$.store.book[-1].title",
      values: ["Ring"],
      pointers: ["/store/book/3/title"],
    },
    {
      name: "first two titles by slice",
      query: "$.store.book[:2].title",
      values: ["Sayings", "Sword"],
      pointers: ["/store/book/0/title", "/store/book/1/title"],
    },
    {
      name: "middle titles by slice",
      query: "$.store.book[1:3].title",
      values: ["Sword", "Moby"],
      pointers: ["/store/book/1/title", "/store/book/2/title"],
    },
    {
      name: "tail titles by slice",
      query: "$.store.book[2:].title",
      values: ["Moby", "Ring"],
      pointers: ["/store/book/2/title", "/store/book/3/title"],
    },
    {
      name: "every other title",
      query: "$.store.book[0:4:2].title",
      values: ["Sayings", "Moby"],
      pointers: ["/store/book/0/title", "/store/book/2/title"],
    },
    {
      name: "reverse titles",
      query: "$.store.book[::-1].title",
      values: ["Ring", "Moby", "Sword", "Sayings"],
      pointers: [
        "/store/book/3/title",
        "/store/book/2/title",
        "/store/book/1/title",
        "/store/book/0/title",
      ],
    },
    {
      name: "union indexes",
      query: "$.store.book[0,2].title",
      values: ["Sayings", "Moby"],
      pointers: ["/store/book/0/title", "/store/book/2/title"],
    },
    {
      name: "union quoted members",
      query: "$.store['book','bicycle']",
      values: [
        [
          {
            "category": "reference",
            "author": "Nigel",
            "title": "Sayings",
            "price": 8.95,
            "tags": ["classic", "quote"],
            "available": true,
          },
          {
            "category": "fiction",
            "author": "Evelyn",
            "title": "Sword",
            "price": 12.99,
            "tags": ["fiction"],
            "available": false,
          },
          {
            "category": "fiction",
            "author": "Herman",
            "title": "Moby",
            "price": 8.99,
            "tags": ["fiction", "sea"],
            "available": true,
          },
          {
            "category": "fiction",
            "author": "Tolkien",
            "title": "Ring",
            "price": 22.99,
            "tags": ["fiction", "fantasy", "classic"],
            "available": true,
          },
        ],
        { "color": "red", "price": 19.95 },
      ],
      pointers: ["/store/book", "/store/bicycle"],
    },
    {
      name: "recursive prices",
      query: "$..price",
      values: [8.95, 12.99, 8.99, 22.99, 19.95],
      pointers: [
        "/store/book/0/price",
        "/store/book/1/price",
        "/store/book/2/price",
        "/store/book/3/price",
        "/store/bicycle/price",
      ],
    },
    {
      name: "fiction titles",
      query: "$.store.book[?(@.category == \"fiction\")].title",
      values: ["Sword", "Moby", "Ring"],
      pointers: [
        "/store/book/1/title",
        "/store/book/2/title",
        "/store/book/3/title",
      ],
    },
    {
      name: "cheap titles",
      query: "$.store.book[?(@.price < 10)].title",
      values: ["Sayings", "Moby"],
      pointers: ["/store/book/0/title", "/store/book/2/title"],
    },
    {
      name: "available titles",
      query: "$.store.book[?(@.available == true)].title",
      values: ["Sayings", "Moby", "Ring"],
      pointers: [
        "/store/book/0/title",
        "/store/book/2/title",
        "/store/book/3/title",
      ],
    },
    {
      name: "not available titles",
      query: "$.store.book[?(!(@.available == true))].title",
      values: ["Sword"],
      pointers: ["/store/book/1/title"],
    },
    {
      name: "fiction or reference",
      query: "$.store.book[?(@.category == \"fiction\" || @.category == \"reference\")].author",
      values: ["Nigel", "Evelyn", "Herman", "Tolkien"],
      pointers: [
        "/store/book/0/author",
        "/store/book/1/author",
        "/store/book/2/author",
        "/store/book/3/author",
      ],
    },
    {
      name: "fiction and available",
      query: "$.store.book[?(@.category == \"fiction\" && @.available == true)].title",
      values: ["Moby", "Ring"],
      pointers: ["/store/book/2/title", "/store/book/3/title"],
    },
    {
      name: "title contains ing",
      query: "$.store.book[?(@.title contains \"ing\")].title",
      values: ["Sayings", "Ring"],
      pointers: ["/store/book/0/title", "/store/book/3/title"],
    },
    {
      name: "title starts with S",
      query: "$.store.book[?(@.title starts_with \"S\")].title",
      values: ["Sayings", "Sword"],
      pointers: ["/store/book/0/title", "/store/book/1/title"],
    },
    {
      name: "title ends with y",
      query: "$.store.book[?(@.title ends_with \"y\")].title",
      values: ["Moby"],
      pointers: ["/store/book/2/title"],
    },
    {
      name: "tag length at least two",
      query: "$.store.book[?(@.tags.length >= 2)].title",
      values: ["Sayings", "Moby", "Ring"],
      pointers: [
        "/store/book/0/title",
        "/store/book/2/title",
        "/store/book/3/title",
      ],
    },
    {
      name: "recursive author",
      query: "$..author",
      values: ["Nigel", "Evelyn", "Herman", "Tolkien"],
      pointers: [
        "/store/book/0/author",
        "/store/book/1/author",
        "/store/book/2/author",
        "/store/book/3/author",
      ],
    },
    {
      name: "meta labels wildcard",
      query: "$.meta.labels[*]",
      values: ["contest", "json", "tooling"],
      pointers: ["/meta/labels/0", "/meta/labels/1", "/meta/labels/2"],
    },
    {
      name: "meta union",
      query: "$.meta['owner','count']",
      values: ["MoonJSONPath", 4],
      pointers: ["/meta/owner", "/meta/count"],
    },
    {
      name: "book wildcard objects",
      query: "$.store.book[*]",
      values: [
        {
          "category": "reference",
          "author": "Nigel",
          "title": "Sayings",
          "price": 8.95,
          "tags": ["classic", "quote"],
          "available": true,
        },
        {
          "category": "fiction",
          "author": "Evelyn",
          "title": "Sword",
          "price": 12.99,
          "tags": ["fiction"],
          "available": false,
        },
        {
          "category": "fiction",
          "author": "Herman",
          "title": "Moby",
          "price": 8.99,
          "tags": ["fiction", "sea"],
          "available": true,
        },
        {
          "category": "fiction",
          "author": "Tolkien",
          "title": "Ring",
          "price": 22.99,
          "tags": ["fiction", "fantasy", "classic"],
          "available": true,
        },
      ],
      pointers: [
        "/store/book/0",
        "/store/book/1",
        "/store/book/2",
        "/store/book/3",
      ],
    },
    {
      name: "missing member yields empty",
      query: "$.store.book[*].isbn",
      values: [],
      pointers: [],
    },
    {
      name: "filter missing member yields empty",
      query: "$.store.book[?(@.isbn)].title",
      values: [],
      pointers: [],
    },
    {
      name: "expensive or unavailable",
      query: "$.store.book[?(@.price > 20 || @.available == false)].title",
      values: ["Sword", "Ring"],
      pointers: ["/store/book/1/title", "/store/book/3/title"],
    },
    {
      name: "grouped cheap and available",
      query: "$.store.book[?((@.price < 10 || @.title == \"Sword\") && @.available == true)].title",
      values: ["Sayings", "Moby"],
      pointers: ["/store/book/0/title", "/store/book/2/title"],
    },
  ]
}

///|
test "catalog JSONPath cases return expected values and pointers" {
  let doc = catalog_doc()
  for case in catalog_cases() {
    inspect(case.name.length() > 0, content="true")
    let path = @moonjsonpath.Path::compile(case.query)
    inspect(path is Ok(_), content="true")
    let matches = path.unwrap().query(doc)
    @json.json_inspect(matches.map(item => item.value), content=case.values)
    @json.json_inspect(
      strings_to_json(matches.map(item => item.pointer.to_string())),
      content=strings_to_json(case.pointers),
    )
  }
}

///|
fn strings_to_json(values : Array[String]) -> Json {
  Json::array(values.map(value => value.to_json()))
}
