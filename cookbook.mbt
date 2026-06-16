///|
pub(all) struct CookbookEntry {
  id : String
  title : String
  json_text : String
  path_text : String
  output_mode : OutputMode
  expected : String
  note : String
} derive(Eq, Debug)

///|
pub(all) struct CookbookResult {
  id : String
  title : String
  output : String
  expected : String
  passed : Bool
} derive(Eq, Debug)

///|
pub fn cookbook_entries() -> Array[CookbookEntry] {
  [
    {
      id: "values-basic-members",
      title: "Read all user names",
      json_text: "{\"users\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}]}",
      path_text: "$.users[*].name",
      output_mode: Values,
      expected: "[\"Ada\",\"Grace\"]",
      note: "The common case for extracting a repeated field from an API response.",
    },
    {
      id: "pointers-for-diagnostics",
      title: "Return match locations instead of values",
      json_text: "{\"users\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}]}",
      path_text: "$.users[*].name",
      output_mode: Pointers,
      expected: "[\"/users/0/name\",\"/users/1/name\"]",
      note: "Pointer output is useful when the caller wants to patch or report locations.",
    },
    {
      id: "matches-for-tools",
      title: "Return path and value pairs",
      json_text: "{\"users\":[{\"name\":\"Ada\"},{\"name\":\"Grace\"}]}",
      path_text: "$.users[*].name",
      output_mode: Matches,
      expected: "[{\"path\":\"/users/0/name\",\"value\":\"Ada\"},{\"path\":\"/users/1/name\",\"value\":\"Grace\"}]",
      note: "Match objects are friendlier for tool calling and structured diagnostics.",
    },
    {
      id: "quoted-config-keys",
      title: "Read configuration keys containing punctuation",
      json_text: "{\"compiler.options\":{\"warn-as-error\":true,\"target/backend\":\"wasm-gc\"}}",
      path_text: "$['compiler.options']['target/backend']",
      output_mode: Values,
      expected: "[\"wasm-gc\"]",
      note: "Quoted selectors avoid forcing config authors to avoid punctuation.",
    },
    {
      id: "union-api-summary",
      title: "Collect a small summary from an object",
      json_text: "{\"package\":{\"name\":\"moonjsonpath\",\"version\":\"0.1.0\",\"private\":false}}",
      path_text: "$.package['name','version']",
      output_mode: Values,
      expected: "[\"moonjsonpath\",\"0.1.0\"]",
      note: "Union selectors preserve selector order and are compact in CLI workflows.",
    },
    {
      id: "recursive-error-fields",
      title: "Find nested error messages",
      json_text: "{\"ok\":false,\"errors\":[{\"message\":\"bad token\"},{\"nested\":{\"message\":\"expired\"}}]}",
      path_text: "$..message",
      output_mode: Values,
      expected: "[\"bad token\",\"expired\"]",
      note: "Recursive descent helps when JSON shape varies across providers.",
    },
    {
      id: "slice-pagination-preview",
      title: "Preview the first page of results",
      json_text: "{\"items\":[0,1,2,3,4,5]}",
      path_text: "$.items[:3]",
      output_mode: Values,
      expected: "[0,1,2]",
      note: "Slices are useful for CLI previews and test fixture minimization.",
    },
    {
      id: "step-sampling",
      title: "Sample every other item",
      json_text: "{\"items\":[\"a\",\"b\",\"c\",\"d\",\"e\"]}",
      path_text: "$.items[::2]",
      output_mode: Values,
      expected: "[\"a\",\"c\",\"e\"]",
      note: "Step slices keep the query small when sampling large arrays.",
    },
    {
      id: "reverse-tail",
      title: "Read latest entries first",
      json_text: "{\"events\":[\"old\",\"mid\",\"new\"]}",
      path_text: "$.events[::-1]",
      output_mode: Values,
      expected: "[\"new\",\"mid\",\"old\"]",
      note: "Negative steps make log-like arrays easy to inspect from newest to oldest.",
    },
    {
      id: "filter-existence",
      title: "Keep objects that contain a key",
      json_text: "{\"books\":[{\"title\":\"A\",\"isbn\":\"1\"},{\"title\":\"B\"},{\"title\":\"C\",\"isbn\":\"3\"}]}",
      path_text: "$.books[?(@.isbn)].title",
      output_mode: Values,
      expected: "[\"A\",\"C\"]",
      note: "Existence filters are a compact way to validate optional metadata.",
    },
    {
      id: "filter-conjunction",
      title: "Filter by two fields",
      json_text: "{\"jobs\":[{\"name\":\"lint\",\"ok\":true,\"ms\":120},{\"name\":\"test\",\"ok\":true,\"ms\":900},{\"name\":\"pack\",\"ok\":false,\"ms\":50}]}",
      path_text: "$.jobs[?(@.ok == true && @.ms < 500)].name",
      output_mode: Values,
      expected: "[\"lint\"]",
      note: "Conjunction filters cover many CI and telemetry checks without becoming jq.",
    },
    {
      id: "negative-index",
      title: "Read the last element",
      json_text: "{\"versions\":[\"0.1.0\",\"0.2.0\",\"0.3.0\"]}",
      path_text: "$.versions[-1]",
      output_mode: Values,
      expected: "[\"0.3.0\"]",
      note: "Negative indexes are common in JSONPath implementations and useful in release metadata.",
    },
    {
      id: "pointer-escaped-output",
      title: "Pointers escape slash and tilde",
      json_text: "{\"a/b\":{\"m~n\":1}}",
      path_text: "$['a/b']['m~n']",
      output_mode: Pointers,
      expected: "[\"/a~1b/m~0n\"]",
      note: "Pointer output remains RFC 6901 compatible even for unusual object keys.",
    },
    {
      id: "nested-author-filter",
      title: "Filter through a nested field",
      json_text: "{\"books\":[{\"title\":\"A\",\"author\":{\"name\":\"Ada\"}},{\"title\":\"B\",\"author\":{\"name\":\"Grace\"}}]}",
      path_text: "$.books[?(@.author.name == \"Ada\")].title",
      output_mode: Values,
      expected: "[\"A\"]",
      note: "Nested filters keep the first version useful for real API responses.",
    },
    {
      id: "pretty-match-output",
      title: "Pretty print match objects",
      json_text: "{\"users\":[{\"name\":\"Ada\"}]}",
      path_text: "$.users[*].name",
      output_mode: Matches,
      expected: "[\n  {\n    \"path\": \"/users/0/name\",\n    \"value\": \"Ada\"\n  }\n]",
      note: "Pretty output is intended for humans reading CLI output.",
    },
  ]
}

///|
pub fn CookbookEntry::run(self : CookbookEntry) -> Result[CookbookResult, String] {
  let indent = if self.id == "pretty-match-output" { 2 } else { 0 }
  let output = match query_json_text_with_options(
    self.path_text,
    self.json_text,
    { output: self.output_mode, indent },
  ) {
    Ok(output) => output
    Err(message) => return Err(message)
  }
  Ok({
    id: self.id,
    title: self.title,
    output,
    expected: self.expected,
    passed: output == self.expected,
  })
}

///|
pub fn run_cookbook() -> Array[CookbookResult] {
  cookbook_entries().map(entry =>
    match entry.run() {
      Ok(result) => result
      Err(message) => {
        id: entry.id,
        title: entry.title,
        output: message,
        expected: entry.expected,
        passed: false,
      }
    },
  )
}

///|
pub fn cookbook_markdown() -> String {
  let out = StringBuilder::new()
  out.write_string("# MoonJSONPath Cookbook\n\n")
  for entry in cookbook_entries() {
    out.write_string("## ")
    out.write_string(entry.title)
    out.write_string("\n\n")
    out.write_string(entry.note)
    out.write_string("\n\n")
    out.write_string("```text\n")
    out.write_string(entry.path_text)
    out.write_string("\n```\n\n")
    out.write_string("Expected output:\n\n```json\n")
    out.write_string(entry.expected)
    out.write_string("\n```\n\n")
  }
  out.to_string()
}
