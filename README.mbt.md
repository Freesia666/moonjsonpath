# MoonJSONPath

MoonJSONPath is a MoonBit-native JSON Pointer and JSONPath utility library. It
helps MoonBit programs locate, query, and lightly edit structured JSON without
hand-written recursive traversal code.

## Features

- JSON Pointer parsing and formatting compatible with RFC 6901 escaping.
- Pointer `get`, `set`, and `remove` operations over `Json` values.
- JSON Pointer URI fragment helpers: `to_uri_fragment` and `parse_uri_fragment`.
- JSONPath core query subset:
  - root selector `$`
  - dot members: `$.users`
  - quoted members: `$['space key']`, `$['a/b']`
  - array indexes: `$.users[0]`
  - union selectors: `$.users[0,2]`, `$.meta['source','count']`
  - wildcards: `$.users[*]`, `$.meta.*`
  - recursive member descent: `$..name`
  - array slices: `$.items[1:4]`, `$.items[:2]`, `$.items[3:]`, `$.items[::-1]`
  - negative indexes: `$.items[-1]`
  - filters: `$.users[?(@.age > 20)]`, `?(@.isbn)`, `?(@.a == 1 && @.b)`
  - extended filters: `||`, `!`, grouping, `contains`, `starts_with`,
    `ends_with`, and `.length` checks
- Match results include both the matched JSON value and its JSON Pointer path.
- JSONPath helper APIs: `first`, `exists`, `values`, `pointers`, `explain`,
  `segment_count`, and `is_definite`.
- Pointer Patch operations: `add`, `replace`, `remove`, `test`,
  `copy`, and `move`.
- Text and file helpers for parsing JSON input and serializing query results.
- CLI subcommands for `query`, `get`, `set`, `remove`, and `patch`.
- CLI output modes for values, pointers, and `{ path, value }` match objects.
- A cookbook suite of runnable scenarios covering API extraction, diagnostics,
  config keys, filters, slices, and pointer output.
- Structured scenario, operator reference, readiness, and submission evidence
  catalogs that can generate contest-facing Markdown.

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
moon run cmd/main -- query '$.users[*].name' data.json
moon run cmd/main -- query --pointers '$..name' data.json
moon run cmd/main -- query --matches --pretty '$.users[?(@.age > 20)]' data.json
moon run cmd/main -- get '/users/0/name' data.json
moon run cmd/main -- set '/users/0/active' true data.json
moon run cmd/main -- remove '/users/0/secret' data.json
moon run cmd/main -- patch patch.json data.json
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
- Full RFC 9535 regular-expression predicates.
- Direct stdin reading until the MoonBit standard/x packages expose a stable API.

## Cookbook

The package includes `cookbook_entries()`, `run_cookbook()`, and
`cookbook_markdown()` for examples that double as regression coverage. These
examples are useful when preparing a submission demo or README excerpt.

It also includes structured documentation data sources:

- `scenario_catalog_markdown()`
- `operator_reference_markdown()`
- `submission_evidence_markdown()`
- `readiness_matrix_markdown()`
- `longform_handbook()`

## Project Scale

The current MoonBit source scale is just over 7k lines, including library code,
CLI support, conformance-style tests, workflow catalogs, and contest-facing
documentation generators.

## Contest Notes

MoonJSONPath is an original MoonBit implementation driven by open standards:
JSON Pointer RFC 6901 and the JSONPath RFC 9535 query model. It is not a port of
one upstream repository. If future versions import tests or algorithms from a
specific implementation, that source and license should be documented here.
