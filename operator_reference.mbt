///|
pub(all) struct OperatorReference {
  group : String
  syntax : String
  example : String
  description : String
  rfc_note : String
} derive(Eq, Debug)

///|
pub fn operator_reference() -> Array[OperatorReference] {
  [
    ref_item(
      "root",
      "$",
      "$",
      "Selects the whole JSON document as the starting node.",
      "RFC 9535 root selector.",
    ),
    ref_item(
      "member",
      ".name",
      "$.store",
      "Selects an object member using identifier-style dot notation.",
      "Dot member names are convenient for simple identifiers.",
    ),
    ref_item(
      "member",
      "['name']",
      "$['store']",
      "Selects an object member using quoted bracket notation.",
      "Bracket notation is required for spaces and punctuation.",
    ),
    ref_item(
      "member",
      "['display name']",
      "$.items['display name']",
      "Selects a key that contains spaces.",
      "Quoted selectors preserve the exact object key.",
    ),
    ref_item(
      "member",
      "['a/b']",
      "$['a/b']",
      "Selects a key containing a slash without treating it as a pointer.",
      "JSONPath member names and JSON Pointer tokens have different escaping.",
    ),
    ref_item(
      "member",
      "['m~n']",
      "$['m~n']",
      "Selects a key containing a tilde.",
      "The tilde is literal in JSONPath quoted member selectors.",
    ),
    ref_item(
      "array",
      "[0]",
      "$.items[0]",
      "Selects the first array element.",
      "Array indexes are zero-based.",
    ),
    ref_item(
      "array",
      "[-1]",
      "$.items[-1]",
      "Selects the last array element.",
      "Negative indexes are implemented as a practical extension.",
    ),
    ref_item(
      "array",
      "[1]",
      "$.items[1]",
      "Selects the second array element.",
      "Out-of-bounds indexes produce no matches.",
    ),
    ref_item(
      "wildcard",
      "[*]",
      "$.items[*]",
      "Selects every array element.",
      "Wildcard also works over object members.",
    ),
    ref_item(
      "wildcard",
      ".*",
      "$.store.*",
      "Selects every child member of an object.",
      "Object iteration follows MoonBit map iteration order.",
    ),
    ref_item(
      "recursive",
      "..name",
      "$..name",
      "Finds all descendant object members with a given name.",
      "Recursive descent walks both objects and arrays.",
    ),
    ref_item(
      "slice",
      "[1:3]",
      "$.items[1:3]",
      "Selects a half-open range of array elements.",
      "The end bound is excluded.",
    ),
    ref_item(
      "slice",
      "[:2]",
      "$.items[:2]",
      "Selects elements from the beginning to an end bound.",
      "An omitted start defaults to the beginning.",
    ),
    ref_item(
      "slice",
      "[2:]",
      "$.items[2:]",
      "Selects elements from a start bound to the end.",
      "An omitted end defaults to the array length.",
    ),
    ref_item(
      "slice",
      "[::2]",
      "$.items[::2]",
      "Selects every second element.",
      "A positive step walks forward.",
    ),
    ref_item(
      "slice",
      "[::-1]",
      "$.items[::-1]",
      "Selects array elements in reverse order.",
      "A negative step walks backward.",
    ),
    ref_item(
      "union",
      "[0,2]",
      "$.items[0,2]",
      "Selects multiple array indexes.",
      "Union results keep selector order.",
    ),
    ref_item(
      "union",
      "['name','title']",
      "$.item['name','title']",
      "Selects multiple object members.",
      "Quoted member unions are useful for projection-like queries.",
    ),
    ref_item(
      "filter",
      "[?(@.name)]",
      "$.items[?(@.name)]",
      "Selects array items where a member exists.",
      "Existence filters are useful for sparse documents.",
    ),
    ref_item(
      "filter",
      "[?(@.price < 10)]",
      "$.items[?(@.price < 10)]",
      "Selects array items using numeric comparison.",
      "Supported comparisons include <, <=, >, >=, ==, and !=.",
    ),
    ref_item(
      "filter",
      "[?(@.active == true)]",
      "$.users[?(@.active == true)]",
      "Selects array items using boolean comparison.",
      "Boolean literals are parsed as JSON literals.",
    ),
    ref_item(
      "filter",
      "[?(@.deleted == null)]",
      "$.items[?(@.deleted == null)]",
      "Selects array items using null comparison.",
      "Null comparison follows JSON literal equality.",
    ),
    ref_item(
      "filter",
      "[?(@.title contains \"Moon\")]",
      "$.items[?(@.title contains \"Moon\")]",
      "Selects string fields containing a substring.",
      "String predicates are practical extensions for tooling.",
    ),
    ref_item(
      "filter",
      "[?(@.name starts_with \"A\")]",
      "$.users[?(@.name starts_with \"A\")]",
      "Selects string fields with a prefix.",
      "Prefix checks help classify names and paths.",
    ),
    ref_item(
      "filter",
      "[?(@.name ends_with \".mbt\")]",
      "$.files[?(@.name ends_with \".mbt\")]",
      "Selects string fields with a suffix.",
      "Suffix checks are useful for file inventories.",
    ),
    ref_item(
      "filter",
      "[?(@.tags.length >= 2)]",
      "$.items[?(@.tags.length >= 2)]",
      "Selects arrays or strings by length.",
      "Length is exposed as a helper for common validation checks.",
    ),
    ref_item(
      "filter",
      "[?(@.a && @.b)]",
      "$.items[?(@.a && @.b)]",
      "Selects items satisfying both filter expressions.",
      "The boolean and operator has lower precedence than leaf expressions.",
    ),
    ref_item(
      "filter",
      "[?(@.a || @.b)]",
      "$.items[?(@.a || @.b)]",
      "Selects items satisfying either filter expression.",
      "The boolean or operator composes independent checks.",
    ),
    ref_item(
      "filter",
      "[?(!(@.hidden == true))]",
      "$.items[?(!(@.hidden == true))]",
      "Selects items where the nested expression is false.",
      "Negation is represented explicitly in the filter AST.",
    ),
    ref_item(
      "filter",
      "[?((@.a || @.b) && @.c)]",
      "$.items[?((@.a || @.b) && @.c)]",
      "Selects items using grouped boolean logic.",
      "Parentheses make precedence explicit.",
    ),
    ref_item(
      "pointer",
      "",
      "",
      "Selects the whole document in JSON Pointer.",
      "The empty pointer is the document root.",
    ),
    ref_item(
      "pointer",
      "/name",
      "/name",
      "Selects an object member named name.",
      "Pointer tokens are separated by slash.",
    ),
    ref_item(
      "pointer",
      "/items/0",
      "/items/0",
      "Selects the first array item.",
      "Array tokens must be non-negative integers for read/set/remove.",
    ),
    ref_item(
      "pointer",
      "/a~1b",
      "/a~1b",
      "Selects a key containing slash.",
      "~1 decodes to slash.",
    ),
    ref_item(
      "pointer",
      "/m~0n",
      "/m~0n",
      "Selects a key containing tilde.",
      "~0 decodes to tilde.",
    ),
    ref_item(
      "pointer",
      "#/a%20b",
      "#/a%20b",
      "Selects a pointer represented as a URI fragment.",
      "Percent decoding happens before JSON Pointer decoding.",
    ),
    ref_item(
      "patch",
      "add",
      "{\"op\":\"add\",\"path\":\"/name\",\"value\":\"Ada\"}",
      "Adds or replaces an object field, inserts an array element, or replaces root.",
      "MoonJSONPath exposes patch as a transformation layer.",
    ),
    ref_item(
      "patch",
      "replace",
      "{\"op\":\"replace\",\"path\":\"/name\",\"value\":\"Grace\"}",
      "Replaces an existing pointer-selected value.",
      "Replace fails if the target path is missing.",
    ),
    ref_item(
      "patch",
      "remove",
      "{\"op\":\"remove\",\"path\":\"/secret\"}",
      "Removes an existing pointer-selected value.",
      "Removing the document root is rejected.",
    ),
    ref_item(
      "patch",
      "test",
      "{\"op\":\"test\",\"path\":\"/state\",\"value\":\"draft\"}",
      "Checks that a value matches before later operations run.",
      "Failed tests report the operation index.",
    ),
    ref_item(
      "patch",
      "copy",
      "{\"op\":\"copy\",\"from\":\"/a\",\"path\":\"/b\"}",
      "Copies a value from one pointer path to another.",
      "The source value remains in place.",
    ),
    ref_item(
      "patch",
      "move",
      "{\"op\":\"move\",\"from\":\"/a\",\"path\":\"/b\"}",
      "Moves a value from one pointer path to another.",
      "Move reads, removes, then adds the selected value.",
    ),
    ref_item(
      "cli",
      "query",
      "moonjsonpath query '$..name' data.json",
      "Runs a JSONPath query against a file.",
      "The legacy form without the query subcommand is also accepted.",
    ),
    ref_item(
      "cli",
      "--pointers",
      "moonjsonpath query --pointers '$..name' data.json",
      "Prints JSON Pointer locations instead of values.",
      "Useful for diagnostics and editor integrations.",
    ),
    ref_item(
      "cli",
      "--matches",
      "moonjsonpath query --matches '$..name' data.json",
      "Prints value-location pairs.",
      "Useful for auditing where values came from.",
    ),
    ref_item(
      "cli",
      "get",
      "moonjsonpath get '/users/0/name' users.json",
      "Reads one JSON Pointer selected value.",
      "Pointer commands complement JSONPath queries.",
    ),
    ref_item(
      "cli",
      "set",
      "moonjsonpath set '/users/0/name' '\"Ada\"' users.json",
      "Writes a pointer-selected value and prints the changed document.",
      "The value argument is parsed as JSON.",
    ),
    ref_item(
      "cli",
      "remove",
      "moonjsonpath remove '/users/0/secret' users.json",
      "Removes a pointer-selected value and prints the changed document.",
      "This supports redaction workflows.",
    ),
    ref_item(
      "cli",
      "patch",
      "moonjsonpath patch patch.json data.json",
      "Applies a patch file and prints the changed document.",
      "Patch files are arrays of operation objects.",
    ),
  ]
}

///|
fn ref_item(
  group : String,
  syntax : String,
  example : String,
  description : String,
  rfc_note : String,
) -> OperatorReference {
  { group, syntax, example, description, rfc_note }
}

///|
pub fn operator_reference_markdown() -> String {
  let out = StringBuilder::new()
  out.write_string("# MoonJSONPath Operator Reference\n\n")
  for item in operator_reference() {
    out.write_string("## ")
    out.write_string(item.group)
    out.write_string(": ")
    out.write_string(item.syntax)
    out.write_string("\n\n")
    out.write_string(item.description)
    out.write_string("\n\n")
    out.write_string("Example: `")
    out.write_string(item.example)
    out.write_string("`\n\n")
    out.write_string("Note: ")
    out.write_string(item.rfc_note)
    out.write_string("\n\n")
  }
  out.to_string()
}
