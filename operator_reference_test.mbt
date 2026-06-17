///|
test "operator reference covers JSONPath pointer patch and CLI groups" {
  let refs = @moonjsonpath.operator_reference()
  inspect(refs.length() >= 45, content="true")
  inspect(count_group(refs, "filter") >= 10, content="true")
  inspect(count_group(refs, "pointer") >= 6, content="true")
  inspect(count_group(refs, "patch") >= 6, content="true")
  inspect(count_group(refs, "cli") >= 7, content="true")
}

///|
test "operator reference markdown is generated from structured entries" {
  let markdown = @moonjsonpath.operator_reference_markdown()
  inspect(markdown.contains("MoonJSONPath Operator Reference"), content="true")
  inspect(markdown.contains("JSONPath"), content="true")
  inspect(markdown.contains("JSON Pointer"), content="true")
  inspect(markdown.contains("moonjsonpath patch"), content="true")
}

///|
test "operator reference JSONPath examples compile when applicable" {
  for item in @moonjsonpath.operator_reference() {
    if item.example.has_prefix("$") {
      let path = @moonjsonpath.Path::compile(item.example)
      inspect(path is Ok(_), content="true")
    }
  }
}

///|
fn count_group(refs : Array[@moonjsonpath.OperatorReference], group : String) -> Int {
  let mut count = 0
  for item in refs {
    if item.group == group {
      count += 1
    }
  }
  count
}
