///|
struct PatchCatalogCase {
  name : String
  doc : Json
  ops : Array[@moonjsonpath.PatchOp]
  expected : Json
}

///|
fn patch_catalog_cases() -> Array[PatchCatalogCase] {
  [
    {
      name: "replace scalar field",
      doc: { "name": "Ada", "active": false },
      ops: [@moonjsonpath.PatchOp::replace("/active", true)],
      expected: { "name": "Ada", "active": true },
    },
    {
      name: "add object field",
      doc: { "name": "Ada" },
      ops: [@moonjsonpath.PatchOp::add("/role", "compiler")],
      expected: { "name": "Ada", "role": "compiler" },
    },
    {
      name: "replace nested field",
      doc: { "user": { "name": "Ada", "score": 1 } },
      ops: [@moonjsonpath.PatchOp::replace("/user/score", 2)],
      expected: { "user": { "name": "Ada", "score": 2 } },
    },
    {
      name: "remove nested field",
      doc: { "user": { "name": "Ada", "secret": true } },
      ops: [@moonjsonpath.PatchOp::remove("/user/secret")],
      expected: { "user": { "name": "Ada" } },
    },
    {
      name: "append array element",
      doc: { "items": ["a"] },
      ops: [@moonjsonpath.PatchOp::add("/items/-", "b")],
      expected: { "items": ["a", "b"] },
    },
    {
      name: "insert array element at beginning",
      doc: { "items": ["b", "c"] },
      ops: [@moonjsonpath.PatchOp::add("/items/0", "a")],
      expected: { "items": ["a", "b", "c"] },
    },
    {
      name: "insert array element in middle",
      doc: { "items": ["a", "c"] },
      ops: [@moonjsonpath.PatchOp::add("/items/1", "b")],
      expected: { "items": ["a", "b", "c"] },
    },
    {
      name: "remove array element",
      doc: { "items": ["a", "b", "c"] },
      ops: [@moonjsonpath.PatchOp::remove("/items/1")],
      expected: { "items": ["a", "c"] },
    },
    {
      name: "copy object field",
      doc: { "source": { "name": "Ada" }, "target": {} },
      ops: [@moonjsonpath.PatchOp::copy("/source/name", "/target/name")],
      expected: { "source": { "name": "Ada" }, "target": { "name": "Ada" } },
    },
    {
      name: "move object field",
      doc: { "source": { "name": "Ada" }, "target": {} },
      ops: [@moonjsonpath.PatchOp::move_to("/source/name", "/target/name")],
      expected: { "source": {}, "target": { "name": "Ada" } },
    },
    {
      name: "copy array value",
      doc: { "items": ["a", "b"], "copy": [] },
      ops: [@moonjsonpath.PatchOp::copy("/items/1", "/copy/-")],
      expected: { "items": ["a", "b"], "copy": ["b"] },
    },
    {
      name: "move array value",
      doc: { "items": ["a", "b", "c"], "copy": [] },
      ops: [@moonjsonpath.PatchOp::move_to("/items/1", "/copy/-")],
      expected: { "items": ["a", "c"], "copy": ["b"] },
    },
    {
      name: "test then replace",
      doc: { "state": "draft", "rev": 1 },
      ops: [
        @moonjsonpath.PatchOp::assert_value("/state", "draft"),
        @moonjsonpath.PatchOp::replace("/state", "ready"),
        @moonjsonpath.PatchOp::replace("/rev", 2),
      ],
      expected: { "state": "ready", "rev": 2 },
    },
    {
      name: "replace root",
      doc: { "old": true },
      ops: [@moonjsonpath.PatchOp::add("", { "new": true })],
      expected: { "new": true },
    },
    {
      name: "build object gradually",
      doc: {},
      ops: [
        @moonjsonpath.PatchOp::add("/name", "MoonJSONPath"),
        @moonjsonpath.PatchOp::add("/version", 1),
        @moonjsonpath.PatchOp::add("/features", []),
        @moonjsonpath.PatchOp::add("/features/-", "query"),
        @moonjsonpath.PatchOp::add("/features/-", "patch"),
      ],
      expected: {
        "name": "MoonJSONPath",
        "version": 1,
        "features": ["query", "patch"],
      },
    },
    {
      name: "update contest metadata",
      doc: {
        "project": {
          "name": "MoonJSONPath",
          "status": "draft",
          "scores": [1, 2],
        },
      },
      ops: [
        @moonjsonpath.PatchOp::replace("/project/status", "submitted"),
        @moonjsonpath.PatchOp::add("/project/scores/-", 3),
      ],
      expected: {
        "project": {
          "name": "MoonJSONPath",
          "status": "submitted",
          "scores": [1, 2, 3],
        },
      },
    },
    {
      name: "normalize user fields",
      doc: { "user": { "first": "Ada", "last": "Lovelace", "display": "" } },
      ops: [
        @moonjsonpath.PatchOp::replace("/user/display", "Ada Lovelace"),
        @moonjsonpath.PatchOp::remove("/user/first"),
        @moonjsonpath.PatchOp::remove("/user/last"),
      ],
      expected: { "user": { "display": "Ada Lovelace" } },
    },
    {
      name: "copy before remove keeps copied value",
      doc: { "a": { "x": 1 }, "b": {} },
      ops: [
        @moonjsonpath.PatchOp::copy("/a/x", "/b/x"),
        @moonjsonpath.PatchOp::remove("/a/x"),
      ],
      expected: { "a": {}, "b": { "x": 1 } },
    },
    {
      name: "multiple append order",
      doc: { "events": [] },
      ops: [
        @moonjsonpath.PatchOp::add("/events/-", "created"),
        @moonjsonpath.PatchOp::add("/events/-", "validated"),
        @moonjsonpath.PatchOp::add("/events/-", "stored"),
      ],
      expected: { "events": ["created", "validated", "stored"] },
    },
    {
      name: "array insert preserves following elements",
      doc: { "steps": ["parse", "render"] },
      ops: [@moonjsonpath.PatchOp::add("/steps/1", "query")],
      expected: { "steps": ["parse", "query", "render"] },
    },
    {
      name: "remove first array item",
      doc: { "queue": ["old", "next", "last"] },
      ops: [@moonjsonpath.PatchOp::remove("/queue/0")],
      expected: { "queue": ["next", "last"] },
    },
    {
      name: "remove last array item",
      doc: { "queue": ["first", "last"] },
      ops: [@moonjsonpath.PatchOp::remove("/queue/1")],
      expected: { "queue": ["first"] },
    },
    {
      name: "replace array item",
      doc: { "queue": ["first", "bad", "last"] },
      ops: [@moonjsonpath.PatchOp::replace("/queue/1", "middle")],
      expected: { "queue": ["first", "middle", "last"] },
    },
    {
      name: "patch booleans",
      doc: { "flags": { "a": false, "b": true } },
      ops: [
        @moonjsonpath.PatchOp::replace("/flags/a", true),
        @moonjsonpath.PatchOp::replace("/flags/b", false),
      ],
      expected: { "flags": { "a": true, "b": false } },
    },
    {
      name: "patch null value",
      doc: { "value": 1 },
      ops: [@moonjsonpath.PatchOp::replace("/value", null)],
      expected: { "value": null },
    },
    {
      name: "copy null value",
      doc: { "value": null, "target": {} },
      ops: [@moonjsonpath.PatchOp::copy("/value", "/target/value")],
      expected: { "value": null, "target": { "value": null } },
    },
    {
      name: "move nested object",
      doc: { "a": { "child": { "ok": true } }, "b": {} },
      ops: [@moonjsonpath.PatchOp::move_to("/a/child", "/b/child")],
      expected: { "a": {}, "b": { "child": { "ok": true } } },
    },
    {
      name: "copy nested object",
      doc: { "a": { "child": { "ok": true } }, "b": {} },
      ops: [@moonjsonpath.PatchOp::copy("/a/child", "/b/child")],
      expected: {
        "a": { "child": { "ok": true } },
        "b": { "child": { "ok": true } },
      },
    },
    {
      name: "patch escaped pointer slash",
      doc: { "a/b": 1 },
      ops: [@moonjsonpath.PatchOp::replace("/a~1b", 2)],
      expected: { "a/b": 2 },
    },
    {
      name: "patch escaped pointer tilde",
      doc: { "m~n": 1 },
      ops: [@moonjsonpath.PatchOp::replace("/m~0n", 2)],
      expected: { "m~n": 2 },
    },
  ]
}

///|
test "patch catalog cases apply expected transformations" {
  for case in patch_catalog_cases() {
    inspect(case.name.length() > 0, content="true")
    let result = @moonjsonpath.apply_patch(case.doc, case.ops)
    inspect(result is Ok(_), content="true")
    @json.json_inspect(result.unwrap(), content=case.expected)
  }
}

///|
test "patch catalog error cases include operation indexes" {
  let bad_test = @moonjsonpath.apply_patch({ "x": 1 }, [
    @moonjsonpath.PatchOp::assert_value("/x", 2),
  ])
  inspect(bad_test is Err(_), content="true")
  inspect(bad_test.unwrap_err().index, content="0")

  let bad_second = @moonjsonpath.apply_patch({ "x": 1 }, [
    @moonjsonpath.PatchOp::replace("/x", 2),
    @moonjsonpath.PatchOp::replace("/missing/value", 3),
  ])
  inspect(bad_second is Err(_), content="true")
  inspect(bad_second.unwrap_err().index, content="1")
  inspect(bad_second.unwrap_err().path, content="/missing/value")
}
