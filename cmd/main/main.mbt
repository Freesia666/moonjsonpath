///|
fn main {
  let code = @moonjsonpath.run_cli_command(@sys.get_cli_args())
  if code != 0 {
    @sys.exit(code)
  }
}
