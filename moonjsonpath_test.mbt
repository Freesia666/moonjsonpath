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

///|
test "pointer sets object fields and array elements without mutating input" {
  let doc : Json = { "user": { "name": "Ada" }, "tags": ["old"] }
  let changed = @moonjsonpath.Pointer::parse("/user/name").unwrap().set(doc, "Grace")
  inspect(changed is Ok(_), content="true")
  @json.json_inspect(changed.unwrap(), content={ "user": { "name": "Grace" }, "tags": ["old"] })
  @json.json_inspect(doc, content={ "user": { "name": "Ada" }, "tags": ["old"] })

  let array_changed = @moonjsonpath.Pointer::parse("/tags/0").unwrap().set(doc, "new")
  inspect(array_changed is Ok(_), content="true")
  @json.json_inspect(array_changed.unwrap(), content={ "user": { "name": "Ada" }, "tags": ["new"] })
}

///|
test "pointer removes object fields and array elements" {
  let doc : Json = { "user": { "name": "Ada", "secret": true }, "tags": ["a", "b"] }
  let without_secret = @moonjsonpath.Pointer::parse("/user/secret").unwrap().remove(doc)
  inspect(without_secret is Ok(_), content="true")
  @json.json_inspect(without_secret.unwrap(), content={ "user": { "name": "Ada" }, "tags": ["a", "b"] })

  let without_first = @moonjsonpath.Pointer::parse("/tags/0").unwrap().remove(doc)
  inspect(without_first is Ok(_), content="true")
  @json.json_inspect(without_first.unwrap(), content={ "user": { "name": "Ada", "secret": true }, "tags": ["b"] })
}

///|
test "jsonpath queries dot members and array indexes" {
  let doc : Json = {
    "users": [
      { "name": "Ada", "age": 36 },
      { "name": "Grace", "age": 85 },
    ],
  }
  let path = @moonjsonpath.Path::compile("$.users[1].name")
  inspect(path is Ok(_), content="true")
  let matches = path.unwrap().query(doc)
  inspect(matches.length(), content="1")
  inspect(matches[0].pointer.to_string(), content="/users/1/name")
  @json.json_inspect(matches[0].value, content="Grace")
}

///|
test "jsonpath reports syntax errors with byte position" {
  let path = @moonjsonpath.Path::compile("users[0]")
  inspect(path is Err(_), content="true")
  inspect(path.unwrap_err().position, content="0")
}

///|
test "jsonpath wildcard selects array elements and object members" {
  let doc : Json = {
    "users": [
      { "name": "Ada" },
      { "name": "Grace" },
      { "name": "Katherine" },
    ],
    "meta": { "count": 3, "source": "fixture" },
  }
  let names = @moonjsonpath.Path::compile("$.users[*].name").unwrap().query(doc)
  inspect(names.length(), content="3")
  inspect(names[0].pointer.to_string(), content="/users/0/name")
  inspect(names[2].pointer.to_string(), content="/users/2/name")
  @json.json_inspect(names.map(item => item.value), content=["Ada", "Grace", "Katherine"])

  let meta = @moonjsonpath.Path::compile("$.meta.*").unwrap().query(doc)
  inspect(meta.length(), content="2")
}

///|
test "jsonpath recursive descent finds nested object members" {
  let doc : Json = {
    "name": "root",
    "groups": [
      { "name": "compiler", "members": [{ "name": "Ada" }] },
      { "name": "runtime", "members": [{ "name": "Grace" }] },
    ],
  }
  let names = @moonjsonpath.Path::compile("$..name").unwrap().query(doc)
  inspect(names.length(), content="5")
  inspect(names[0].pointer.to_string(), content="/name")
  inspect(names[4].pointer.to_string(), content="/groups/1/members/0/name")
  @json.json_inspect(names.map(item => item.value), content=[
    "root",
    "compiler",
    "Ada",
    "runtime",
    "Grace",
  ])
}
