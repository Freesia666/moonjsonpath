///|
pub(all) enum CliCommandKind {
  Query
  PointerGet
  PointerSet
  PointerRemove
  Patch
  Help
} derive(Eq, Debug)

///|
pub(all) struct CliCommand {
  kind : CliCommandKind
  path_text : String
  pointer_text : String
  value_text : String
  patch_file_path : String
  file_path : String
  output : OutputMode
  indent : Int
} derive(Eq, Debug)

///|
pub fn CliCommandKind::to_string(self : CliCommandKind) -> String {
  match self {
    Query => "Query"
    PointerGet => "PointerGet"
    PointerSet => "PointerSet"
    PointerRemove => "PointerRemove"
    Patch => "Patch"
    Help => "Help"
  }
}

///|
pub fn OutputMode::to_string(self : OutputMode) -> String {
  match self {
    Values => "Values"
    Pointers => "Pointers"
    Matches => "Matches"
  }
}

///|
pub fn CliCommand::parse(args : Array[String]) -> Result[CliCommand, String] {
  if args.length() <= 1 {
    return Err("expected a command or JSONPath query")
  }
  let mut output = Values
  let mut indent = 0
  let positional : Array[String] = []
  let mut i = 1
  while i < args.length() {
    let arg = args[i]
    match arg {
      "--help" | "-h" =>
        return Ok(make_help_command())
      "--values" => {
        output = Values
        i += 1
      }
      "--pointers" => {
        output = Pointers
        i += 1
      }
      "--matches" => {
        output = Matches
        i += 1
      }
      "--pretty" => {
        indent = 2
        i += 1
      }
      _ =>
        if arg.has_prefix("-") {
          return Err("unknown option: \{arg}")
        } else {
          positional.push(arg)
          i += 1
        }
    }
  }
  if positional.length() == 0 {
    return Err("expected a command or JSONPath query")
  }
  match positional[0] {
    "query" => parse_query_command(positional, output, indent, offset=1)
    "get" => parse_pointer_get_command(positional, output, indent)
    "set" => parse_pointer_set_command(positional, output, indent)
    "remove" => parse_pointer_remove_command(positional, output, indent)
    "patch" => parse_patch_command(positional, output, indent)
    "help" => Ok(make_help_command())
    other =>
      if other.has_prefix("$") {
        parse_query_command(positional, output, indent, offset=0)
      } else {
        Err("unknown command: \{other}")
      }
  }
}

///|
fn parse_query_command(
  positional : Array[String],
  output : OutputMode,
  indent : Int,
  offset~ : Int,
) -> Result[CliCommand, String] {
  if positional.length() - offset != 2 {
    return Err("query expects <jsonpath> <file>")
  }
  Ok({
    kind: Query,
    path_text: positional[offset],
    pointer_text: "",
    value_text: "",
    patch_file_path: "",
    file_path: positional[offset + 1],
    output,
    indent,
  })
}

///|
fn parse_pointer_get_command(
  positional : Array[String],
  output : OutputMode,
  indent : Int,
) -> Result[CliCommand, String] {
  if positional.length() != 3 {
    return Err("get expects <pointer> <file>")
  }
  Ok({
    kind: PointerGet,
    path_text: "",
    pointer_text: positional[1],
    value_text: "",
    patch_file_path: "",
    file_path: positional[2],
    output,
    indent,
  })
}

///|
fn parse_pointer_set_command(
  positional : Array[String],
  output : OutputMode,
  indent : Int,
) -> Result[CliCommand, String] {
  if positional.length() != 4 {
    return Err("set expects <pointer> <json-value> <file>")
  }
  Ok({
    kind: PointerSet,
    path_text: "",
    pointer_text: positional[1],
    value_text: positional[2],
    patch_file_path: "",
    file_path: positional[3],
    output,
    indent,
  })
}

///|
fn parse_pointer_remove_command(
  positional : Array[String],
  output : OutputMode,
  indent : Int,
) -> Result[CliCommand, String] {
  if positional.length() != 3 {
    return Err("remove expects <pointer> <file>")
  }
  Ok({
    kind: PointerRemove,
    path_text: "",
    pointer_text: positional[1],
    value_text: "",
    patch_file_path: "",
    file_path: positional[2],
    output,
    indent,
  })
}

///|
fn parse_patch_command(
  positional : Array[String],
  output : OutputMode,
  indent : Int,
) -> Result[CliCommand, String] {
  if positional.length() != 3 {
    return Err("patch expects <patch-file> <file>")
  }
  Ok({
    kind: Patch,
    path_text: "",
    pointer_text: "",
    value_text: "",
    patch_file_path: positional[1],
    file_path: positional[2],
    output,
    indent,
  })
}

///|
fn make_help_command() -> CliCommand {
  {
    kind: Help,
    path_text: "",
    pointer_text: "",
    value_text: "",
    patch_file_path: "",
    file_path: "",
    output: Values,
    indent: 0,
  }
}

///|
pub fn execute_cli_text(
  command : CliCommand,
  json_text : String,
  patch_text : String,
) -> Result[String, String] {
  match command.kind {
    Query =>
      query_json_text_with_options(
        command.path_text,
        json_text,
        { output: command.output, indent: command.indent },
      )
    PointerGet =>
      pointer_get_json_text(command.pointer_text, json_text, indent=command.indent)
    PointerSet =>
      pointer_set_json_text(
        command.pointer_text,
        command.value_text,
        json_text,
        indent=command.indent,
      )
    PointerRemove =>
      pointer_remove_json_text(command.pointer_text, json_text, indent=command.indent)
    Patch => patch_json_text(patch_text, json_text, indent=command.indent)
    Help => Ok(cli_command_usage())
  }
}

///|
pub fn run_cli_command(args : Array[String]) -> Int {
  match CliCommand::parse(args) {
    Ok(command) =>
      if command.kind == Help {
        println(cli_command_usage())
        0
      } else {
        match execute_cli_files(command) {
          Ok(output) => {
            println(output)
            0
          }
          Err(message) => {
            println("MoonJSONPath error: \{message}")
            1
          }
        }
      }
    Err(message) => {
      println("MoonJSONPath error: \{message}")
      println(cli_command_usage())
      2
    }
  }
}

///|
fn execute_cli_files(command : CliCommand) -> Result[String, String] {
  let json_text = @fs.read_file_to_string(command.file_path) catch {
    _ => return Err("failed to read JSON file '\{command.file_path}'")
  }
  let patch_text = if command.kind == Patch {
    @fs.read_file_to_string(command.patch_file_path) catch {
      _ => return Err("failed to read patch file '\{command.patch_file_path}'")
    }
  } else {
    ""
  }
  execute_cli_text(command, json_text, patch_text)
}

///|
pub fn cli_command_usage() -> String {
  (
    #|Usage:
    #|  moonjsonpath query [--values|--pointers|--matches] [--pretty] <jsonpath> <file>
    #|  moonjsonpath get [--pretty] <pointer> <file>
    #|  moonjsonpath set [--pretty] <pointer> <json-value> <file>
    #|  moonjsonpath remove [--pretty] <pointer> <file>
    #|  moonjsonpath patch [--pretty] <patch-file> <file>
    #|
    #|Legacy:
    #|  moonjsonpath [--values|--pointers|--matches] [--pretty] <jsonpath> <file>
    #|
    #|Examples:
    #|  moonjsonpath query '$.users[*].name' data.json
    #|  moonjsonpath query --matches --pretty '$..name' data.json
    #|  moonjsonpath get '/users/0/name' data.json
    #|  moonjsonpath set '/users/0/active' true data.json
    #|  moonjsonpath patch patch.json data.json
    #|
  )
}
