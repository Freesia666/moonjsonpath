///|
test "path helper methods expose first values pointers and existence checks" {
  let doc : Json = {
    "users": [
      { "name": "Ada", "active": true },
      { "name": "Grace", "active": false },
    ],
  }
  let names = @moonjsonpath.Path::compile("$.users[*].name").unwrap()
  inspect(names.exists(doc), content="true")
  @json.json_inspect(names.values(doc), content=["Ada", "Grace"])
  @json.json_inspect(names.pointers(doc), content=["/users/0/name", "/users/1/name"])
  @json.json_inspect(names.first(doc).unwrap(), content="Ada")

  let missing = @moonjsonpath.Path::compile("$.users[*].missing").unwrap()
  inspect(missing.exists(doc), content="false")
  inspect(missing.first(doc) is None, content="true")
}

///|
test "text helper methods expose first values pointers and matches" {
  let json_text = "{\"users\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}]}"
  inspect(@moonjsonpath.query_first_json_text("$.users[*].name", json_text).unwrap(), content="\"Ada\"")
  inspect(@moonjsonpath.query_values_json_text("$.users[*].name", json_text).unwrap(), content="[\"Ada\",\"Grace\"]")
  inspect(@moonjsonpath.query_pointers_json_text("$.users[*].name", json_text).unwrap(), content="[\"/users/0/name\",\"/users/1/name\"]")
  inspect(@moonjsonpath.query_exists_json_text("$.users[*].name", json_text).unwrap(), content="true")
  inspect(@moonjsonpath.query_exists_json_text("$.users[*].missing", json_text).unwrap(), content="false")
}
