///|
fn main {
  let code = @moonjsonpath.run_cli(@sys.get_cli_args())
  if code != 0 {
    @sys.exit(code)
  }
}
