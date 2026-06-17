///|
test "patch add replaces root inserts object fields and appends arrays" {
  let root_op = @moonjsonpath.PatchOp::add("", { "ok": true })
  let root = @moonjsonpath.apply_patch(null, [root_op])
  inspect(root is Ok(_), content="true")
  @json.json_inspect(root.unwrap(), content={ "ok": true })

  let doc : Json = { "name": "Ada", "tags": ["compiler"] }
  let added = @moonjsonpath.apply_patch(doc, [
    @moonjsonpath.PatchOp::add("/active", true),
    @moonjsonpath.PatchOp::add("/tags/-", "runtime"),
  ])
  inspect(added is Ok(_), content="true")
  @json.json_inspect(added.unwrap(), content={
    "name": "Ada",
    "tags": ["compiler", "runtime"],
    "active": true,
  })
}

///|
test "patch replace remove and test compose without mutating input" {
  let doc : Json = {
    "user": { "name": "Ada", "role": "compiler" },
    "active": true,
  }
  let result = @moonjsonpath.apply_patch(doc, [
    @moonjsonpath.PatchOp::assert_value("/active", true),
    @moonjsonpath.PatchOp::replace("/user/name", "Grace"),
    @moonjsonpath.PatchOp::remove("/user/role"),
  ])
  inspect(result is Ok(_), content="true")
  @json.json_inspect(result.unwrap(), content={
    "user": { "name": "Grace" },
    "active": true,
  })
  @json.json_inspect(doc, content={
    "user": { "name": "Ada", "role": "compiler" },
    "active": true,
  })
}

///|
test "patch copy and move reuse pointer selected values" {
  let doc : Json = {
    "source": { "name": "Ada", "score": 9 },
    "target": {},
    "old": ["keep", "move-me"],
  }
  let result = @moonjsonpath.apply_patch(doc, [
    @moonjsonpath.PatchOp::copy("/source/name", "/target/copied"),
    @moonjsonpath.PatchOp::move_to("/old/1", "/target/moved"),
  ])
  inspect(result is Ok(_), content="true")
  @json.json_inspect(result.unwrap(), content={
    "source": { "name": "Ada", "score": 9 },
    "target": { "copied": "Ada", "moved": "move-me" },
    "old": ["keep"],
  })
}

///|
test "patch reports failing operation index and path" {
  let doc : Json = { "active": false }
  let result = @moonjsonpath.apply_patch(doc, [
    @moonjsonpath.PatchOp::assert_value("/active", true),
  ])
  inspect(result is Err(_), content="true")
  let err = result.unwrap_err()
  inspect(err.index, content="0")
  inspect(err.path, content="/active")
  inspect(err.describe(), content="patch operation 0 failed at /active: test operation did not match")
}

///|
test "patch parses json operation documents" {
  let doc : Json = { "items": [{ "name": "Ada" }] }
  let patch_json : Json = [
    { "op": "add", "path": "/items/-", "value": { "name": "Grace" } },
    { "op": "replace", "path": "/items/0/name", "value": "Augusta" },
  ]
  let ops = @moonjsonpath.PatchOp::parse_many(patch_json)
  inspect(ops is Ok(_), content="true")
  let result = @moonjsonpath.apply_patch(doc, ops.unwrap())
  inspect(result is Ok(_), content="true")
  @json.json_inspect(result.unwrap(), content={
    "items": [{ "name": "Augusta" }, { "name": "Grace" }],
  })
}
