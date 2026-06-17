///|
test "pointer converts to and from URI fragments" {
  let pointer = @moonjsonpath.Pointer::parse("/c%d/foo bar/a~1b/m~0n").unwrap()
  inspect(pointer.to_uri_fragment(), content="#/c%25d/foo%20bar/a~1b/m~0n")

  let parsed = @moonjsonpath.Pointer::parse_uri_fragment("#/c%25d/foo%20bar/a~1b/m~0n")
  inspect(parsed is Ok(_), content="true")
  inspect(parsed.unwrap().to_string(), content="/c%d/foo bar/a~1b/m~0n")
}

///|
test "pointer URI fragments support empty root and escaped octets" {
  let root = @moonjsonpath.Pointer::parse_uri_fragment("#")
  inspect(root is Ok(_), content="true")
  inspect(root.unwrap().to_string(), content="")

  let pointer = @moonjsonpath.Pointer::parse_uri_fragment("#/emoji/%E4%B8%AD")
  inspect(pointer is Ok(_), content="true")
  inspect(pointer.unwrap().to_string(), content="/emoji/中")
}

///|
test "pointer URI fragments reject malformed fragments" {
  inspect(@moonjsonpath.Pointer::parse_uri_fragment("/plain") is Err(_), content="true")
  inspect(@moonjsonpath.Pointer::parse_uri_fragment("#/bad%") is Err(_), content="true")
  inspect(@moonjsonpath.Pointer::parse_uri_fragment("#/bad%0") is Err(_), content="true")
  inspect(@moonjsonpath.Pointer::parse_uri_fragment("#/bad%ZZ") is Err(_), content="true")
}
