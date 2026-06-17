///|
test "cli command parser supports explicit query and legacy query forms" {
  let explicit = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "query", "--matches", "--pretty", "$.users[*]", "data.json",
  ])
  inspect(explicit is Ok(_), content="true")
  let command = explicit.unwrap()
  inspect(command.kind.to_string(), content="Query")
  inspect(command.path_text, content="$.users[*]")
  inspect(command.file_path, content="data.json")
  inspect(command.indent, content="2")
  inspect(command.output.to_string(), content="Matches")

  let legacy = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "--pointers", "$..name", "data.json",
  ])
  inspect(legacy is Ok(_), content="true")
  inspect(legacy.unwrap().kind.to_string(), content="Query")
  inspect(legacy.unwrap().output.to_string(), content="Pointers")
}

///|
test "cli command parser supports pointer transform subcommands" {
  let get = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "get", "--pretty", "/user/name", "data.json",
  ])
  inspect(get is Ok(_), content="true")
  inspect(get.unwrap().kind.to_string(), content="PointerGet")
  inspect(get.unwrap().pointer_text, content="/user/name")
  inspect(get.unwrap().file_path, content="data.json")
  inspect(get.unwrap().indent, content="2")

  let set = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "set", "/user/name", "\"Grace\"", "data.json",
  ])
  inspect(set is Ok(_), content="true")
  inspect(set.unwrap().kind.to_string(), content="PointerSet")
  inspect(set.unwrap().value_text, content="\"Grace\"")

  let remove = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "remove", "/user/secret", "data.json",
  ])
  inspect(remove is Ok(_), content="true")
  inspect(remove.unwrap().kind.to_string(), content="PointerRemove")
}

///|
test "cli command parser supports patch subcommand and useful errors" {
  let patch = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "patch", "--pretty", "patch.json", "data.json",
  ])
  inspect(patch is Ok(_), content="true")
  inspect(patch.unwrap().kind.to_string(), content="Patch")
  inspect(patch.unwrap().patch_file_path, content="patch.json")
  inspect(patch.unwrap().file_path, content="data.json")

  let missing = @moonjsonpath.CliCommand::parse(["moonjsonpath", "set", "/x"])
  inspect(missing is Err(_), content="true")
  inspect(missing.unwrap_err().contains("set expects"), content="true")

  let unknown = @moonjsonpath.CliCommand::parse(["moonjsonpath", "wat", "x"])
  inspect(unknown is Err(_), content="true")
  inspect(unknown.unwrap_err().contains("unknown command"), content="true")
}

///|
test "cli command executes against provided text inputs" {
  let doc = "{\"users\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}],\"active\":false}"
  let query = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "query", "$.users[*].name", "data.json",
  ]).unwrap()
  inspect(@moonjsonpath.execute_cli_text(query, doc, "").unwrap(), content="[\"Ada\",\"Grace\"]")

  let set = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "set", "/active", "true", "data.json",
  ]).unwrap()
  inspect(@moonjsonpath.execute_cli_text(set, doc, "").unwrap(), content="{\"users\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}],\"active\":true}")

  let patch = @moonjsonpath.CliCommand::parse([
    "moonjsonpath", "patch", "patch.json", "data.json",
  ]).unwrap()
  let patch_text = "[{\"op\":\"remove\",\"path\":\"/users/0\"}]"
  inspect(@moonjsonpath.execute_cli_text(patch, doc, patch_text).unwrap(), content="{\"users\":[{\"name\":\"Grace\"}],\"active\":false}")
}
