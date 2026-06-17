///|
test "longform handbook is available as generated project documentation" {
  let handbook = @moonjsonpath.longform_handbook()
  inspect(handbook.contains("MoonJSONPath Longform Handbook"), content="true")
  inspect(handbook.contains("JSONPath filters"), content="true")
  inspect(handbook.contains("Patch workflows"), content="true")
  inspect(handbook.contains("Contest submission"), content="true")
  inspect(
    handbook.contains("avoid claiming full jq compatibility"),
    content="true",
  )
}
