///|
test "jsonpath filters support or not and grouped boolean expressions" {
  let doc : Json = {
    "users": [
      { "name": "Ada", "age": 36, "active": true, "role": "compiler" },
      { "name": "Grace", "age": 85, "active": false, "role": "runtime" },
      { "name": "Katherine", "age": 18, "active": true, "role": "docs" },
      { "name": "Barbara", "age": 25, "active": false, "role": "compiler" },
    ],
  }
  let senior_or_compiler = @moonjsonpath.Path::compile(
      "$.users[?(@.age >= 80 || @.role == \"compiler\")].name",
    )
    .unwrap()
    .query(doc)
  @json.json_inspect(senior_or_compiler.map(item => item.value), content=[
    "Ada", "Grace", "Barbara",
  ])

  let active_not_docs = @moonjsonpath.Path::compile(
      "$.users[?(@.active == true && !(@.role == \"docs\"))].name",
    )
    .unwrap()
    .query(doc)
  @json.json_inspect(active_not_docs.map(item => item.value), content=["Ada"])

  let grouped = @moonjsonpath.Path::compile(
      "$.users[?((@.active == true || @.age > 80) && @.name != \"Katherine\")].name",
    )
    .unwrap()
    .query(doc)
  @json.json_inspect(grouped.map(item => item.value), content=["Ada", "Grace"])
}

///|
test "jsonpath filters support quoted field names inside current node paths" {
  let doc : Json = {
    "items": [
      { "display name": "MoonBit Guide", "meta": { "build-id": 1 } },
      { "display name": "Draft", "meta": { "build-id": 2 } },
    ],
  }
  let matches = @moonjsonpath.Path::compile(
      "$.items[?(@['display name'] == \"MoonBit Guide\" && @.meta['build-id'] == 1)]",
    )
    .unwrap()
    .query(doc)
  inspect(matches.length(), content="1")
  inspect(matches[0].pointer.to_string(), content="/items/0")
}

///|
test "jsonpath filters support contains starts_with ends_with and length" {
  let doc : Json = {
    "files": [
      { "name": "src/main.mbt", "tags": ["moonbit", "cli"] },
      { "name": "README.mbt.md", "tags": ["docs"] },
      { "name": "src/patch.mbt", "tags": ["moonbit", "json", "patch"] },
      { "name": "notes.txt", "tags": [] },
    ],
  }
  let moonbit_sources = @moonjsonpath.Path::compile(
      "$.files[?(@.name starts_with \"src/\" && @.name ends_with \".mbt\")].name",
    )
    .unwrap()
    .query(doc)
  @json.json_inspect(moonbit_sources.map(item => item.value), content=[
    "src/main.mbt", "src/patch.mbt",
  ])

  let docs_or_patch = @moonjsonpath.Path::compile(
      "$.files[?(@.name contains \"README\" || @.name contains \"patch\")].name",
    )
    .unwrap()
    .query(doc)
  @json.json_inspect(docs_or_patch.map(item => item.value), content=[
    "README.mbt.md", "src/patch.mbt",
  ])

  let many_tags = @moonjsonpath.Path::compile(
      "$.files[?(@.tags.length >= 2)].name",
    )
    .unwrap()
    .query(doc)
  @json.json_inspect(many_tags.map(item => item.value), content=[
    "src/main.mbt", "src/patch.mbt",
  ])
}
