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
  - quoted members: `$['space key']`, `$['a/b']`
  - array indexes: `$.users[0]`
  - union selectors: `$.users[0,2]`, `$.meta['source','count']`
  - wildcards: `$.users[*]`, `$.meta.*`
  - recursive member descent: `$..name`
  - positive array slices: `$.items[1:4]`, `$.items[:2]`, `$.items[3:]`
  - filters: `$.users[?(@.age > 20)]`, `?(@.isbn)`, `?(@.a == 1 && @.b)`
- Match results include both the matched JSON value and its JSON Pointer path.
- Text and file helpers for parsing JSON input and serializing query results.
- CLI output modes for values, pointers, and `{ path, value }` match objects.

## Quick Start

```moonbit nocheck
///|
test {
  let doc : Json = {
    "users": [{ "name": "Ada", "age": 36 }, { "name": "Grace", "age": 85 }],
  }

  let names = @moonjsonpath.Path::compile("$.users[*].name").unwrap().query(doc)
  inspect(names[0].pointer.to_string(), content="/users/0/name")
  @json.json_inspect(names.map(item => item.value), content=["Ada", "Grace"])
}
```

Pointer editing returns a new JSON value:

```moonbit nocheck
///|
test {
  let doc : Json = { "meta": { "count": 2 } }
  let updated = @moonjsonpath.Pointer::parse("/meta/count").unwrap().set(doc, 3)
  @json.json_inspect(updated.unwrap(), content={ "meta": { "count": 3 } })
}
```

The command can be run from the project root:

```bash
moon run cmd/main -- '$.users[*].name' data.json
moon run cmd/main -- --pointers '$..name' data.json
moon run cmd/main -- --matches --pretty '$.users[?(@.age > 20)]' data.json
```

For a file containing two users named Ada and Grace, the first command prints:

```json
["Ada","Grace"]
```

File input is supported through `moonbitlang/x/fs`. Direct stdin reading is not
exposed by the MoonBit packages used here yet, so stdin piping is documented as
a future CLI adapter task rather than claimed as complete.

## Scope

This project intentionally does not implement `jq`. `jq` is a full JSON
processing language with functions, pipes, object construction, reductions, and
many transformation operators. MoonJSONPath focuses on a compact, testable query
and location layer suitable for MoonBit tools, config processors, API clients,
and LLM/tool-call workflows.

## Current Non-goals

- Full `jq` compatibility.
- Script expressions, arithmetic expressions, or user-defined functions inside filters.
- Full RFC 9535 negative indexes, steps, or regular-expression predicates.
- Direct stdin reading until the MoonBit standard/x packages expose a stable API.

## Contest Notes

MoonJSONPath is an original MoonBit implementation driven by open standards:
JSON Pointer RFC 6901 and the JSONPath RFC 9535 query model. It is not a port of
one upstream repository. If future versions import tests or algorithms from a
specific implementation, that source and license should be documented here.
