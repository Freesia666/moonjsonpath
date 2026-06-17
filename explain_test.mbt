///|
test "path explain describes segments and definiteness" {
  let definite = @moonjsonpath.Path::compile("$.users[0].name").unwrap()
  inspect(definite.segment_count(), content="3")
  inspect(definite.is_definite(), content="true")
  @json.json_inspect(definite.explain(), content=[
    "member users", "element 0", "member name",
  ])

  let plural = @moonjsonpath.Path::compile(
    "$.users[*][?(@.active == true)].name",
  ).unwrap()
  inspect(plural.segment_count(), content="4")
  inspect(plural.is_definite(), content="false")
  @json.json_inspect(plural.explain(), content=[
    "member users", "wildcard", "filter @.active == true", "member name",
  ])
}

///|
test "path explain covers recursive slice union and extended filters" {
  let path = @moonjsonpath.Path::compile(
    "$..items[1:5:2]['name','title'][?(@.label contains \"Moon\" || !(@.hidden == true))]",
  ).unwrap()
  inspect(path.segment_count(), content="4")
  inspect(path.is_definite(), content="false")
  @json.json_inspect(path.explain(), content=[
    "recursive member items", "slice 1:5:2", "union ['name','title']", "filter @.label contains \"Moon\" || !(@.hidden == true)",
  ])
}
