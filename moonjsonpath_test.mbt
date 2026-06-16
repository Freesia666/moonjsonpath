///|
test "pointer parses root and RFC6901 escaped tokens" {
  let root = @moonjsonpath.Pointer::parse("")
  inspect(root is Ok(_), content="true")
  inspect(root.unwrap().to_string(), content="")

  let pointer = @moonjsonpath.Pointer::parse("/foo/0/a~1b/m~0n/")
  inspect(pointer is Ok(_), content="true")
  inspect(pointer.unwrap().to_string(), content="/foo/0/a~1b/m~0n/")
  @json.json_inspect(pointer.unwrap().tokens(), content=["foo", "0", "a/b", "m~n", ""])
}

///|
test "pointer rejects malformed input" {
  inspect(@moonjsonpath.Pointer::parse("foo") is Err(_), content="true")
  inspect(@moonjsonpath.Pointer::parse("/a~2b") is Err(_), content="true")
  inspect(@moonjsonpath.Pointer::parse("/a~") is Err(_), content="true")
}

///|
test "pointer reads object fields and array elements" {
  let doc : Json = {
    "foo": ["bar", "baz"],
    "a/b": 1,
    "m~n": 8,
    "": "empty-key",
  }
  let foo0 = @moonjsonpath.Pointer::parse("/foo/0").unwrap().get(doc)
  inspect(foo0 is Ok(_), content="true")
  @json.json_inspect(foo0.unwrap(), content="bar")

  let slash = @moonjsonpath.Pointer::parse("/a~1b").unwrap().get(doc)
  inspect(slash is Ok(_), content="true")
  @json.json_inspect(slash.unwrap(), content=1)

  let empty = @moonjsonpath.Pointer::parse("/").unwrap().get(doc)
  inspect(empty is Ok(_), content="true")
  @json.json_inspect(empty.unwrap(), content="empty-key")
}

///|
test "pointer reports missing fields and wrong container types" {
  let doc : Json = { "foo": ["bar"] }
  let missing = @moonjsonpath.Pointer::parse("/foo/3").unwrap().get(doc)
  inspect(missing is Err(_), content="true")
  inspect(missing.unwrap_err().path, content="/foo/3")

  let wrong = @moonjsonpath.Pointer::parse("/foo/0/name").unwrap().get(doc)
  inspect(wrong is Err(_), content="true")
  inspect(wrong.unwrap_err().path, content="/foo/0/name")
}
