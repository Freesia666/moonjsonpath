///|
fn main {
  let demo_json = "{\"users\":[{\"name\":\"Ada\",\"age\":36},{\"name\":\"Grace\",\"age\":85}]}"
  match @moonjsonpath.query_json_text("$.users[?(@.age > 40)].name", demo_json) {
    Ok(output) => println(output)
    Err(message) => println("MoonJSONPath error: \{message}")
  }
}
