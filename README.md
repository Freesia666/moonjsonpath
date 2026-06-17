# MoonJSONPath

MoonJSONPath is a MoonBit-native JSON Pointer, JSONPath, and lightweight JSON
patch toolkit. It helps MoonBit programs locate, inspect, and update structured
JSON data without hand-written recursive traversal code.

This project is designed for MoonBit tooling, configuration validation, API
clients, documentation processing, test fixtures, and LLM tool-calling
workflows.

## Highlights

- JSON Pointer parser and formatter compatible with RFC 6901 escaping.
- JSON Pointer `get`, `set`, `remove`, and URI fragment helpers.
- JSONPath query engine with members, quoted members, arrays, wildcards,
  recursive descent, slices, unions, filters, and match locations.
- Extended filter expressions: `&&`, `||`, `!`, grouped expressions,
  `contains`, `starts_with`, `ends_with`, and `.length`.
- Pointer Patch operations: `add`, `replace`, `remove`, `test`, `copy`, and
  `move`.
- CLI subcommands: `query`, `get`, `set`, `remove`, and `patch`.
- Output modes for values, JSON Pointer paths, and `{ path, value }` match
  objects.
- Runnable cookbook, conformance-style tests, workflow catalog, operator
  reference, readiness matrix, and contest submission evidence generators.

## Quick Start

Install MoonBit, then run the test suite from the project root:

```bash
moon check
moon test
```

Run the CLI:

```bash
moon run cmd/main -- query '$.users[*].name' data.json
moon run cmd/main -- query --pointers '$..name' data.json
moon run cmd/main -- query --matches --pretty '$.users[?(@.age > 20)]' data.json
moon run cmd/main -- get '/users/0/name' data.json
moon run cmd/main -- set '/users/0/active' true data.json
moon run cmd/main -- remove '/users/0/secret' data.json
moon run cmd/main -- patch patch.json data.json
```

Running without arguments prints help:

```bash
moon run cmd/main
```

## Library Example

```moonbit
///|
test {
  let doc : Json = {
    "users": [
      { "name": "Ada", "age": 36, "active": true },
      { "name": "Grace", "age": 85, "active": false },
    ],
  }

  let path = @moonjsonpath.Path::compile("$.users[?(@.age > 40)].name").unwrap()
  let matches = path.query(doc)

  inspect(matches[0].pointer.to_string(), content="/users/1/name")
  @json.json_inspect(matches.map(item => item.value), content=["Grace"])
}
```

## JSON Pointer

JSON Pointer identifies one exact location inside a JSON document.

```moonbit
///|
test {
  let doc : Json = { "meta": { "count": 2 }, "tags": ["old"] }

  let pointer = @moonjsonpath.Pointer::parse("/meta/count").unwrap()
  @json.json_inspect(pointer.get(doc).unwrap(), content=2)

  let updated = pointer.set(doc, 3).unwrap()
  @json.json_inspect(updated, content={
    "meta": { "count": 3 },
    "tags": ["old"],
  })
}
```

Supported Pointer features:

- root pointer: `""`
- object fields: `/user/name`
- array indexes: `/users/0`
- RFC 6901 escaping: `/a~1b` for `a/b`, `/m~0n` for `m~n`
- URI fragments: `#/users/0/name`
- immutable `set` and `remove`

## JSONPath

JSONPath queries can return multiple matches. Each match includes both the value
and its JSON Pointer location.

Supported JSONPath selectors:

| Feature | Example |
| --- | --- |
| Root | `$` |
| Dot member | `$.users` |
| Quoted member | `$['display name']` |
| Array index | `$.users[0]` |
| Negative index | `$.users[-1]` |
| Wildcard | `$.users[*]`, `$.meta.*` |
| Recursive member | `$..name` |
| Slice | `$.items[1:4]`, `$.items[::-1]` |
| Union | `$.items[0,2]`, `$.meta['owner','count']` |
| Filter | `$.users[?(@.active == true)]` |

Filter examples:

```text
$.users[?(@.age >= 18)]
$.users[?(@.active == true && @.role == "admin")]
$.users[?(@.name starts_with "A" || @.name contains "ace")]
$.files[?(@.name ends_with ".mbt")]
$.items[?(@.tags.length >= 2)]
$.items[?(!(@.hidden == true))]
```

## Pointer Patch

MoonJSONPath includes a lightweight pointer-based transformation layer.

```moonbit
///|
test {
  let doc : Json = {
    "users": [{ "name": "Ada", "active": false }],
    "secret": true,
  }

  let changed = @moonjsonpath.apply_patch(doc, [
    @moonjsonpath.PatchOp::replace("/users/0/active", true),
    @moonjsonpath.PatchOp::remove("/secret"),
  ]).unwrap()

  @json.json_inspect(changed, content={
    "users": [{ "name": "Ada", "active": true }],
  })
}
```

Patch operation constructors:

- `PatchOp::add(path, value)`
- `PatchOp::replace(path, value)`
- `PatchOp::remove(path)`
- `PatchOp::assert_value(path, value)`
- `PatchOp::copy(from, path)`
- `PatchOp::move_to(from, path)`
- `PatchOp::parse_many(json)`

The patch layer is intentionally documented as MoonJSONPath's own lightweight
transform API. It is not advertised as full RFC 6902 compatibility.

## CLI Usage

```text
Usage:
  moonjsonpath query [--values|--pointers|--matches] [--pretty] <jsonpath> <file>
  moonjsonpath get [--pretty] <pointer> <file>
  moonjsonpath set [--pretty] <pointer> <json-value> <file>
  moonjsonpath remove [--pretty] <pointer> <file>
  moonjsonpath patch [--pretty] <patch-file> <file>

Legacy:
  moonjsonpath [--values|--pointers|--matches] [--pretty] <jsonpath> <file>
```

Example input:

```json
{
  "users": [
    { "name": "Ada", "active": false },
    { "name": "Grace", "active": true }
  ]
}
```

Examples:

```bash
moon run cmd/main -- query '$.users[*].name' users.json
# ["Ada","Grace"]

moon run cmd/main -- query --pointers '$.users[*].name' users.json
# ["/users/0/name","/users/1/name"]

moon run cmd/main -- get '/users/0/name' users.json
# "Ada"

moon run cmd/main -- set '/users/0/active' true users.json
# {"users":[{"name":"Ada","active":true},{"name":"Grace","active":true}]}
```

File input is supported through `moonbitlang/x/fs`. Direct stdin reading is not
claimed yet because the MoonBit standard/x packages used here do not currently
expose a stable stdin API.

## Public API Overview

Core query APIs:

- `Path::compile(input)`
- `Path::query(doc)`
- `Path::to_string()`
- `Path::first(doc)`
- `Path::exists(doc)`
- `Path::values(doc)`
- `Path::pointers(doc)`
- `Path::explain()`
- `query_json_text(path, json)`
- `query_json_file(path, file)`

Pointer APIs:

- `Pointer::parse(input)`
- `Pointer::parse_uri_fragment(input)`
- `Pointer::to_string()`
- `Pointer::to_uri_fragment()`
- `Pointer::tokens()`
- `Pointer::get(doc)`
- `Pointer::set(doc, value)`
- `Pointer::remove(doc)`

Text transform helpers:

- `pointer_get_json_text(pointer, json_text)`
- `pointer_set_json_text(pointer, value_text, json_text)`
- `pointer_remove_json_text(pointer, json_text)`
- `patch_json_text(patch_text, json_text)`

Documentation and demo data generators:

- `cookbook_markdown()`
- `scenario_catalog_markdown()`
- `operator_reference_markdown()`
- `readiness_matrix_markdown()`
- `submission_evidence_markdown()`
- `longform_handbook()`

## Project Structure

```text
moonjsonpath/
├── moonjsonpath.mbt              # Core Pointer and JSONPath implementation
├── patch.mbt                     # Pointer Patch operations
├── transform.mbt                 # Text-based JSON transform helpers
├── cli_command.mbt               # CLI parser and command execution
├── query_helpers.mbt             # Convenience query APIs
├── explain.mbt                   # JSONPath explain/introspection helpers
├── pointer_uri.mbt               # JSON Pointer URI fragment support
├── cookbook.mbt                  # Runnable cookbook examples
├── *_test.mbt                    # Unit, catalog, conformance, and CLI tests
├── cmd/main/                     # CLI executable entry point
├── docs/                         # Contest proposal and project notes
├── moon.mod                      # MoonBit module metadata
└── moon.pkg                      # Package imports
```

## Testing

Run:

```bash
moon fmt
moon info
moon check
moon test
```

The test suite covers:

- JSON Pointer parsing, escaping, reading, setting, removing, and URI fragments
- JSONPath parsing, selection, filters, formatting, diagnostics, and helpers
- Pointer Patch operations and error reporting
- CLI command parsing and text execution
- RFC-style conformance catalog cases
- Workflow, operator reference, readiness, and submission evidence catalogs

At the time this README was written, the project has 65 passing tests and just
over 7k MoonBit source lines.

## Scope and Non-goals

MoonJSONPath is not a `jq` clone. `jq` is a full JSON programming language with
pipes, functions, object construction, reductions, arithmetic, and many
transformation operators. MoonJSONPath focuses on a compact, testable query and
location layer for MoonBit projects.

Current non-goals:

- full `jq` compatibility
- arbitrary script expressions inside filters
- full RFC 9535 regular-expression predicates
- streaming parser
- direct stdin support before a stable MoonBit API is available
- claiming full RFC 6902 compatibility for the patch layer

## Contest Notes

MoonJSONPath is an original MoonBit implementation inspired by open standards:
JSON Pointer RFC 6901 and the JSONPath RFC 9535 query model. It is not a port
of one upstream repository.

The repository includes runnable examples, focused tests, conformance-style
catalogs, structured documentation generators, and a CLI suitable for local
demonstration during contest review.

## License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE).
