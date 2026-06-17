///|
test "pointer text helpers get set and remove JSON documents" {
  let text = "{\"user\":{\"name\":\"Ada\",\"secret\":true},\"tags\":[\"a\",\"b\"]}"
  let got = @moonjsonpath.pointer_get_json_text("/user/name", text)
  inspect(got is Ok(_), content="true")
  inspect(got.unwrap(), content="\"Ada\"")

  let set = @moonjsonpath.pointer_set_json_text(
    "/user/name",
    "\"Grace\"",
    text,
    indent=2,
  )
  inspect(set is Ok(_), content="true")
  inspect(
    set.unwrap(),
    content=(
      #|{
      #|  "user": {
      #|    "name": "Grace",
      #|    "secret": true
      #|  },
      #|  "tags": [
      #|    "a",
      #|    "b"
      #|  ]
      #|}
    ),
  )

  let removed = @moonjsonpath.pointer_remove_json_text("/user/secret", text)
  inspect(removed is Ok(_), content="true")
  inspect(
    removed.unwrap(),
    content="{\"user\":{\"name\":\"Ada\"},\"tags\":[\"a\",\"b\"]}",
  )
}

///|
test "patch text helper applies patch JSON to input JSON" {
  let doc = "{\"items\":[{\"name\":\"Ada\"}],\"active\":false}"
  let patch =
    #|[
    #|  {"op":"test","path":"/active","value":false},
    #|  {"op":"add","path":"/items/-","value":{"name":"Grace"}},
    #|  {"op":"replace","path":"/active","value":true}
    #|]
  let result = @moonjsonpath.patch_json_text(patch, doc)
  inspect(result is Ok(_), content="true")
  inspect(
    result.unwrap(),
    content="{\"items\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}],\"active\":true}",
  )
}

///|
test "transform helpers report parse pointer and patch errors" {
  let bad_json = @moonjsonpath.pointer_get_json_text("/x", "{")
  inspect(bad_json is Err(_), content="true")
  inspect(bad_json.unwrap_err().contains("invalid JSON input"), content="true")

  let bad_pointer = @moonjsonpath.pointer_get_json_text("x", "{}")
  inspect(bad_pointer is Err(_), content="true")
  inspect(bad_pointer.unwrap_err().contains("JSON Pointer"), content="true")

  let bad_patch = @moonjsonpath.patch_json_text(
    "[{\"op\":\"test\",\"path\":\"/x\",\"value\":1}]", "{\"x\":2}",
  )
  inspect(bad_patch is Err(_), content="true")
  inspect(bad_patch.unwrap_err().contains("patch operation 0"), content="true")
}
