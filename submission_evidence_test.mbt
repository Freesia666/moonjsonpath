///|
test "submission evidence covers major contest review areas" {
  let evidence = @moonjsonpath.submission_evidence()
  inspect(evidence.length() >= 45, content="true")
  inspect(
    @moonjsonpath.submission_evidence_count("JSONPath") >= 10,
    content="true",
  )
  inspect(
    @moonjsonpath.submission_evidence_count("JSON Pointer") >= 5,
    content="true",
  )
  inspect(@moonjsonpath.submission_evidence_count("Patch") >= 7, content="true")
  inspect(@moonjsonpath.submission_evidence_count("CLI") >= 8, content="true")
  inspect(
    @moonjsonpath.submission_evidence_count("Testing") >= 3,
    content="true",
  )
}

///|
test "submission evidence markdown mentions verification commands" {
  let markdown = @moonjsonpath.submission_evidence_markdown()
  inspect(markdown.contains("MoonJSONPath Submission Evidence"), content="true")
  inspect(markdown.contains("moon test"), content="true")
  inspect(markdown.contains("moon check"), content="true")
  inspect(markdown.contains("moon info"), content="true")
  inspect(markdown.contains("moon run cmd/main"), content="true")
}
