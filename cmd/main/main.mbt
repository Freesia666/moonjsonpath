///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() == 3 {
    match @moonjsonpath.query_json_file(args[1], args[2]) {
      Ok(output) => println(output)
      Err(message) => {
        println("MoonJSONPath error: \{message}")
        @sys.exit(1)
      }
    }
  } else {
    println("Usage: moonjsonpath <jsonpath> <file>")
    println("Example: moonjsonpath '$.users[*].name' data.json")
  }
}
