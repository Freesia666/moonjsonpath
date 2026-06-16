# MoonJSONPath

MoonJSONPath is a MoonBit-native JSON Pointer and JSONPath utility library. It
helps MoonBit programs locate, query, and lightly edit structured JSON without
hand-written recursive traversal code.

## Features

- JSON Pointer parsing and formatting compatible with RFC 6901 escaping.
- Pointer `get`, `set`, and `remove` operations over `Json` values.
- JSONPath core query subset:
  - root selector `$`
  - dot members: `$.users`
  - array indexes: `$.users[0]`
  - wildcards: `$.users[*]`, `$.meta.*`
  - recursive member descent: `$..name`
  - positive array slices: `$.items[1:4]`, `$.items[:2]`, `$.items[3:]`
  - simple filters: `$.users[?(@.age > 20)]`
- Match results include both the matched JSON value and its JSON Pointer path.
- Text helper for parsing JSON input and serializing query results.

## Quick Start

```moonbit
test {
  let doc : Json = {
    "users": [
      { "name": "Ada", "age": 36 },
      { "name": "Grace", "age": 85 },
    ],
  }

  let names = @moonjsonpath.Path::compile("$.users[*].name").unwrap().query(doc)
  inspect(names[0].pointer.to_string(), content="/users/0/name")
  @json.json_inspect(names.map(item => item.value), content=["Ada", "Grace"])
}
```

Pointer editing returns a new JSON value:

```moonbit
test {
  let doc : Json = { "meta": { "count": 2 } }
  let updated = @moonjsonpath.Pointer::parse("/meta/count").unwrap().set(doc, 3)
  @json.json_inspect(updated.unwrap(), content={ "meta": { "count": 3 } })
}
```

The demo command can be run from the project root:

```bash
moon run cmd/main
```

It prints:

```json
["Grace"]
```

## Scope

This project intentionally does not implement `jq`. `jq` is a full JSON
processing language with functions, pipes, object construction, reductions, and
many transformation operators. MoonJSONPath focuses on a compact, testable query
and location layer suitable for MoonBit tools, config processors, API clients,
and LLM/tool-call workflows.

## Contest Notes

MoonJSONPath is an original MoonBit implementation driven by open standards:
JSON Pointer RFC 6901 and the JSONPath RFC 9535 query model. It is not a port of
one upstream repository. If future versions import tests or algorithms from a
specific implementation, that source and license should be documented here.
