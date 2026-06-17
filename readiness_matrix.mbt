///|
pub(all) struct ReadinessItem {
  category : String
  item : String
  status : String
  evidence : String
  next_step : String
} derive(Eq, Debug)

///|
pub fn readiness_matrix() -> Array[ReadinessItem] {
  [
    readiness("JSONPath", "Root selector", "supported", "Path compile and catalog tests", "Keep aligned with RFC examples"),
    readiness("JSONPath", "Dot member selector", "supported", "Unit and catalog tests", "Document identifier rules"),
    readiness("JSONPath", "Quoted member selector", "supported", "Quoted selector tests", "Add more unicode examples later"),
    readiness("JSONPath", "Wildcard selector", "supported", "Array and object wildcard tests", "Document object ordering"),
    readiness("JSONPath", "Recursive descent", "supported", "Recursive member tests", "Consider recursive wildcard later"),
    readiness("JSONPath", "Array index selector", "supported", "Positive index tests", "Keep pointer index behavior separate"),
    readiness("JSONPath", "Negative index selector", "extension", "Negative index tests", "Mark as extension in docs"),
    readiness("JSONPath", "Slice selector", "supported", "Forward slice tests", "Add more RFC table examples"),
    readiness("JSONPath", "Reverse slice selector", "extension", "Reverse slice tests", "Clarify step behavior"),
    readiness("JSONPath", "Union selector", "supported", "Index and member union tests", "Consider mixed nested selectors"),
    readiness("JSONPath", "Existence filter", "supported", "Filter tests", "Document truthiness model"),
    readiness("JSONPath", "Comparison filter", "supported", "Literal comparison tests", "Add exponent number parsing later"),
    readiness("JSONPath", "Boolean and filter", "supported", "Filter expression tests", "Document precedence"),
    readiness("JSONPath", "Boolean or filter", "supported", "Filter expression tests", "Document grouping"),
    readiness("JSONPath", "Negated filter", "supported", "Filter expression tests", "Add examples to README"),
    readiness("JSONPath", "Grouped filter", "supported", "Filter expression tests", "Add nested grouping cases"),
    readiness("JSONPath", "String contains", "extension", "String predicate tests", "Mark as tool-friendly extension"),
    readiness("JSONPath", "String starts_with", "extension", "String predicate tests", "Mark as tool-friendly extension"),
    readiness("JSONPath", "String ends_with", "extension", "String predicate tests", "Mark as tool-friendly extension"),
    readiness("JSONPath", "Length filter", "extension", "Length tests", "Clarify array and string behavior"),
    readiness("JSONPath", "Path explain", "extension", "Explain tests", "Use in diagnostics docs"),
    readiness("JSONPath", "Definite path detection", "extension", "Explain tests", "Use for optimizer notes"),
    readiness("JSONPath", "First helper", "extension", "Query helper tests", "Add file helper variant later"),
    readiness("JSONPath", "Values helper", "extension", "Query helper tests", "Keep JSON return shape stable"),
    readiness("JSONPath", "Pointers helper", "extension", "Query helper tests", "Use in editor integration docs"),
    readiness("JSONPath", "Exists helper", "extension", "Query helper tests", "Use for validation examples"),
    readiness("JSON Pointer", "Root pointer", "supported", "RFC6901 tests", "Document empty string root"),
    readiness("JSON Pointer", "Object token", "supported", "Pointer get tests", "Add large object examples"),
    readiness("JSON Pointer", "Array token", "supported", "Pointer get tests", "Document non-negative index rule"),
    readiness("JSON Pointer", "Slash escape", "supported", "RFC6901 tests", "Keep exact escaping"),
    readiness("JSON Pointer", "Tilde escape", "supported", "RFC6901 tests", "Keep exact escaping"),
    readiness("JSON Pointer", "Set operation", "extension", "Pointer set tests", "Document immutable return"),
    readiness("JSON Pointer", "Remove operation", "extension", "Pointer remove tests", "Document root remove rejection"),
    readiness("JSON Pointer", "URI fragment", "supported", "Pointer URI tests", "Add encode for non-ASCII later"),
    readiness("Patch", "Add object field", "supported", "Patch tests", "Document add semantics"),
    readiness("Patch", "Add array item", "supported", "Patch catalog tests", "Document '-' append token"),
    readiness("Patch", "Replace value", "supported", "Patch tests", "Document missing target errors"),
    readiness("Patch", "Remove value", "supported", "Patch tests", "Document immutable return"),
    readiness("Patch", "Test value", "supported", "Patch tests", "Document equality behavior"),
    readiness("Patch", "Copy value", "supported", "Patch tests", "Document source preservation"),
    readiness("Patch", "Move value", "supported", "Patch tests", "Document remove then add order"),
    readiness("Patch", "Parse operation JSON", "supported", "Patch parse tests", "Document accepted fields"),
    readiness("Patch", "Operation index errors", "supported", "Patch error tests", "Use in CLI errors"),
    readiness("CLI", "Query command", "supported", "CLI parser tests", "Add more shell examples"),
    readiness("CLI", "Legacy query command", "supported", "CLI parser tests", "Preserve compatibility"),
    readiness("CLI", "Values mode", "supported", "Query render tests", "Document default mode"),
    readiness("CLI", "Pointers mode", "supported", "CLI parser tests", "Use for editor workflows"),
    readiness("CLI", "Matches mode", "supported", "CLI parser tests", "Use for audit workflows"),
    readiness("CLI", "Pretty output", "supported", "CLI parser tests", "Document indentation"),
    readiness("CLI", "Get command", "supported", "CLI parser tests", "Add real file smoke tests"),
    readiness("CLI", "Set command", "supported", "CLI parser tests", "Warn value is JSON text"),
    readiness("CLI", "Remove command", "supported", "CLI parser tests", "Add redaction example"),
    readiness("CLI", "Patch command", "supported", "CLI parser tests", "Add batch patch example"),
    readiness("CLI", "Stdin", "future", "Documented limitation", "Explore stable MoonBit stdin API"),
    readiness("Docs", "README", "supported", "README exists", "Refresh after final API changes"),
    readiness("Docs", "Proposal", "supported", "Proposal doc exists", "Refresh LOC and feature list"),
    readiness("Docs", "Cookbook", "supported", "Cookbook tests", "Add generated scenario excerpt"),
    readiness("Docs", "Operator reference", "supported", "Reference tests", "Export to docs if needed"),
    readiness("Docs", "Scenario catalog", "supported", "Scenario tests", "Use in final writeup"),
    readiness("Docs", "Submission evidence", "supported", "Evidence tests", "Use in contest review"),
    readiness("Quality", "moon fmt", "required", "Run before final", "Run after all edits"),
    readiness("Quality", "moon info", "required", "Run before final", "Refresh generated interfaces"),
    readiness("Quality", "moon check", "required", "Run before final", "Fix compiler warnings"),
    readiness("Quality", "moon test", "required", "Run before final", "All tests must pass"),
    readiness("Quality", "Git commits", "supported", "Meaningful commits exist", "Avoid empty commits"),
    readiness("Quality", "License", "supported", "LICENSE exists", "Confirm chosen license in README"),
    readiness("Quality", "No remote configured", "intentional", "User will add remote", "Add remote before submission"),
    readiness("Publishing", "mooncakes namespace", "needs review", "moon.mod has package name", "Set final owner before publish"),
    readiness("Publishing", "Repository URL", "future", "Remote left blank intentionally", "Fill once GitHub repo exists"),
    readiness("Publishing", "Generated mbti", "required", "moon info updates interfaces", "Refresh before final commit"),
    readiness("Compliance", "Original implementation", "supported", "No copied upstream code", "Keep source notes in README"),
    readiness("Compliance", "Generated files", "tracked", "pkg.generated.mbti exists", "Explain generated interfaces"),
    readiness("Compliance", "Fixtures", "safe", "Tests use synthetic JSON data", "Avoid private data"),
    readiness("Scope", "Full jq", "non-goal", "Documented limitation", "Avoid overclaiming"),
    readiness("Scope", "Streaming parser", "future", "Documented limitation", "Consider later if MoonBit API matures"),
    readiness("Scope", "Full RFC6902", "partial", "Patch layer documented", "Do not claim full compatibility"),
  ]
}

///|
fn readiness(
  category : String,
  item : String,
  status : String,
  evidence : String,
  next_step : String,
) -> ReadinessItem {
  { category, item, status, evidence, next_step }
}

///|
pub fn readiness_matrix_markdown() -> String {
  let out = StringBuilder::new()
  out.write_string("# MoonJSONPath Readiness Matrix\n\n")
  for item in readiness_matrix() {
    out.write_string("- ")
    out.write_string(item.category)
    out.write_string(" / ")
    out.write_string(item.item)
    out.write_string(": ")
    out.write_string(item.status)
    out.write_string(" (")
    out.write_string(item.evidence)
    out.write_string(") -> ")
    out.write_string(item.next_step)
    out.write_string("\n")
  }
  out.to_string()
}

///|
pub fn readiness_count_by_status(status : String) -> Int {
  let mut count = 0
  for item in readiness_matrix() {
    if item.status == status {
      count += 1
    }
  }
  count
}
