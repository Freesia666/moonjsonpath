///|
test "cookbook entries all run successfully" {
  let results = @moonjsonpath.run_cookbook()
  inspect(results.length(), content="15")
  for result in results {
    inspect(result.passed, content="true")
  }
}

///|
test "cookbook markdown includes representative examples" {
  let markdown = @moonjsonpath.cookbook_markdown()
  inspect(markdown.contains("Read all user names"), content="true")
  inspect(markdown.contains("$.users[*].name"), content="true")
  inspect(
    markdown.contains("Pointer output remains RFC 6901 compatible"),
    content="true",
  )
  inspect(markdown.contains("$.events[::-1]"), content="true")
}
