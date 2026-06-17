///|
test "readiness matrix summarizes supported future and required work" {
  let matrix = @moonjsonpath.readiness_matrix()
  inspect(matrix.length() >= 70, content="true")
  inspect(@moonjsonpath.readiness_count_by_status("supported") >= 45, content="true")
  inspect(@moonjsonpath.readiness_count_by_status("extension") >= 10, content="true")
  inspect(@moonjsonpath.readiness_count_by_status("future") >= 2, content="true")
  inspect(@moonjsonpath.readiness_count_by_status("required") >= 4, content="true")
}

///|
test "readiness matrix markdown contains review-oriented sections" {
  let markdown = @moonjsonpath.readiness_matrix_markdown()
  inspect(markdown.contains("MoonJSONPath Readiness Matrix"), content="true")
  inspect(markdown.contains("JSONPath / Root selector"), content="true")
  inspect(markdown.contains("CLI / Patch command"), content="true")
  inspect(markdown.contains("Quality / moon test"), content="true")
  inspect(markdown.contains("Compliance / Original implementation"), content="true")
}
