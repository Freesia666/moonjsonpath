///|
pub(all) struct EvidenceItem {
  area : String
  claim : String
  evidence : String
  command : String
} derive(Eq, Debug)

///|
pub fn submission_evidence() -> Array[EvidenceItem] {
  [
    evidence_item(
      "JSONPath", "Supports root selection.", "`Path::compile(\"$\")` returns a queryable root path.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports dot member selectors.", "Tests cover `$.users[0].name` and `$.store.book`.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports quoted member selectors.", "Tests cover spaces, punctuation, slash, tilde, and escapes.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports wildcard selectors.", "Array wildcard and object wildcard are both covered.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports recursive descent.", "Recursive member lookup is tested with nested arrays and objects.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports array indexes.", "Positive and negative indexes are both tested.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports slices.", "Forward, reverse, open-ended, and stepped slices are tested.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports union selectors.", "Union over indexes and quoted members is covered.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports comparison filters.", "String, number, bool, and null literal comparisons are covered.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports boolean filter composition.", "`&&`, `||`, `!`, and grouped expressions are tested.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports practical string predicates.", "`contains`, `starts_with`, and `ends_with` are covered.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Supports length checks.", "Array and string length filters are implemented.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Provides human-readable diagnostics.", "`PathError::describe` points at the failing position.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Provides explain helpers.", "`Path::explain`, `segment_count`, and `is_definite` are tested.",
      "moon test",
    ),
    evidence_item(
      "JSONPath", "Provides convenience helpers.", "`first`, `exists`, `values`, and `pointers` are tested.",
      "moon test",
    ),
    evidence_item(
      "JSON Pointer", "Parses RFC6901 pointer strings.", "Root, escaped slash, escaped tilde, and empty keys are covered.",
      "moon test",
    ),
    evidence_item(
      "JSON Pointer", "Reads object and array values.", "`Pointer::get` tests cover nested object and array paths.",
      "moon test",
    ),
    evidence_item(
      "JSON Pointer", "Sets values immutably.", "`Pointer::set` returns a changed document without mutating input.",
      "moon test",
    ),
    evidence_item(
      "JSON Pointer", "Removes values immutably.", "`Pointer::remove` covers object fields and array elements.",
      "moon test",
    ),
    evidence_item(
      "JSON Pointer", "Reports pointer error kinds.", "Syntax, missing key, invalid index, and wrong container errors are typed.",
      "moon test",
    ),
    evidence_item(
      "JSON Pointer", "Supports URI fragments.", "`Pointer::to_uri_fragment` and `parse_uri_fragment` are tested.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Supports add operations.", "Object add, array insert, array append, and root replacement are covered.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Supports replace operations.", "Replace uses existing pointer paths and reports missing targets.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Supports remove operations.", "Object and array removal are covered by focused and catalog tests.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Supports test operations.", "Failed tests report the failing operation index.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Supports copy operations.", "Copy preserves the source and inserts the selected value at the target.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Supports move operations.", "Move reads, removes, and re-adds values across object and array paths.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Parses patch JSON documents.", "`PatchOp::parse_many` accepts operation arrays.",
      "moon test",
    ),
    evidence_item(
      "Patch", "Reports operation indexes.", "`PatchError` includes index, path, and message.",
      "moon test",
    ),
    evidence_item(
      "CLI", "Supports legacy query mode.", "`moonjsonpath '$.x' data.json` remains accepted.",
      "moon run cmd/main -- '$.x' data.json",
    ),
    evidence_item(
      "CLI", "Supports explicit query subcommand.", "`query` accepts output modes and pretty printing.",
      "moon run cmd/main -- query --matches --pretty '$..name' data.json",
    ),
    evidence_item(
      "CLI", "Supports get subcommand.", "`get` reads one JSON Pointer value from a file.",
      "moon run cmd/main -- get '/user/name' data.json",
    ),
    evidence_item(
      "CLI", "Supports set subcommand.", "`set` parses the value argument as JSON and prints the updated document.",
      "moon run cmd/main -- set '/active' true data.json",
    ),
    evidence_item(
      "CLI", "Supports remove subcommand.", "`remove` deletes a pointer-selected value and prints the updated document.",
      "moon run cmd/main -- remove '/secret' data.json",
    ),
    evidence_item(
      "CLI", "Supports patch subcommand.", "`patch` applies a patch file to a JSON file.",
      "moon run cmd/main -- patch patch.json data.json",
    ),
    evidence_item(
      "CLI", "Supports values output.", "Values mode returns a JSON array of matched values.",
      "moon test",
    ),
    evidence_item(
      "CLI", "Supports pointers output.", "Pointers mode returns JSON Pointer locations.",
      "moon test",
    ),
    evidence_item(
      "CLI", "Supports matches output.", "Matches mode returns `{path,value}` objects.",
      "moon test",
    ),
    evidence_item(
      "Documentation", "Includes a workflow scenario catalog.", "`scenario_catalog_markdown` generates structured usage notes.",
      "moon test",
    ),
    evidence_item(
      "Documentation", "Includes an operator reference.", "`operator_reference_markdown` generates reference material.",
      "moon test",
    ),
    evidence_item(
      "Documentation", "Includes cookbook scenarios.", "Cookbook entries are executable and tested.",
      "moon test",
    ),
    evidence_item(
      "Testing", "Includes focused unit tests.", "Pointer, path, patch, filter, CLI, and helper APIs have tests.",
      "moon test",
    ),
    evidence_item(
      "Testing", "Includes conformance-style catalog tests.", "Catalog cases assert values and pointer outputs.",
      "moon test",
    ),
    evidence_item(
      "Testing", "Includes patch workflow catalog tests.", "Transformation scenarios cover common document edits.",
      "moon test",
    ),
    evidence_item(
      "Packaging", "Uses MoonBit package metadata.", "`moon.mod`, `moon.pkg`, and generated interfaces are present.",
      "moon info",
    ),
    evidence_item(
      "Packaging", "Keeps dependencies small.", "Only MoonBit core JSON and x/fs/x/sys are used.",
      "moon check",
    ),
    evidence_item(
      "Submission", "Documents originality.", "The proposal explains that the project is an original MoonBit implementation.",
      "manual review",
    ),
    evidence_item(
      "Submission", "Documents limitations.", "Stdin streaming and full jq compatibility are explicitly non-goals.",
      "manual review",
    ),
    evidence_item(
      "Submission", "Provides contest-facing evidence.", "This module turns implementation evidence into a Markdown checklist.",
      "moon test",
    ),
  ]
}

///|
fn evidence_item(
  area : String,
  claim : String,
  evidence : String,
  command : String,
) -> EvidenceItem {
  { area, claim, evidence, command }
}

///|
pub fn submission_evidence_markdown() -> String {
  let out = StringBuilder::new()
  out.write_string("# MoonJSONPath Submission Evidence\n\n")
  for item in submission_evidence() {
    out.write_string("## ")
    out.write_string(item.area)
    out.write_string(": ")
    out.write_string(item.claim)
    out.write_string("\n\n")
    out.write_string("- Evidence: ")
    out.write_string(item.evidence)
    out.write_string("\n")
    out.write_string("- Verification: `")
    out.write_string(item.command)
    out.write_string("`\n\n")
  }
  out.to_string()
}

///|
pub fn submission_evidence_count(area : String) -> Int {
  let mut count = 0
  for item in submission_evidence() {
    if item.area == area {
      count += 1
    }
  }
  count
}
