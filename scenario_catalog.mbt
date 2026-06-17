///|
pub(all) struct Scenario {
  title : String
  domain : String
  query : String
  pointer : String
  cli : String
  note : String
} derive(Eq, Debug)

///|
pub fn scenario_catalog() -> Array[Scenario] {
  [
    scenario("User names", "identity", "$.users[*].name", "/users/0/name", "moonjsonpath query '$.users[*].name' users.json", "Extract display names from account arrays."),
    scenario("Active users", "identity", "$.users[?(@.active == true)]", "/users/0/active", "moonjsonpath query '$.users[?(@.active == true)]' users.json", "Select enabled accounts for access checks."),
    scenario("Inactive users", "identity", "$.users[?(!(@.active == true))]", "/users/1/active", "moonjsonpath query '$.users[?(!(@.active == true))]' users.json", "Find accounts that need cleanup."),
    scenario("Admin users", "identity", "$.users[?(@.role == \"admin\")]", "/users/0/role", "moonjsonpath query '$.users[?(@.role == \"admin\")]' users.json", "Audit privileged users."),
    scenario("Guest users", "identity", "$.users[?(@.role == \"guest\")]", "/users/2/role", "moonjsonpath query '$.users[?(@.role == \"guest\")]' users.json", "Inspect temporary access."),
    scenario("Senior users", "identity", "$.users[?(@.age >= 65)]", "/users/0/age", "moonjsonpath query '$.users[?(@.age >= 65)]' users.json", "Check numeric comparisons."),
    scenario("Named user", "identity", "$.users[?(@.name == \"Ada\")]", "/users/0/name", "moonjsonpath query '$.users[?(@.name == \"Ada\")]' users.json", "Find exact string matches."),
    scenario("Name prefix", "identity", "$.users[?(@.name starts_with \"A\")]", "/users/0/name", "moonjsonpath query '$.users[?(@.name starts_with \"A\")]' users.json", "Filter by prefix."),
    scenario("Name suffix", "identity", "$.users[?(@.name ends_with \"a\")]", "/users/0/name", "moonjsonpath query '$.users[?(@.name ends_with \"a\")]' users.json", "Filter by suffix."),
    scenario("Name contains", "identity", "$.users[?(@.name contains \"ad\")]", "/users/0/name", "moonjsonpath query '$.users[?(@.name contains \"ad\")]' users.json", "Filter by substring."),
    scenario("Config ports", "configuration", "$.services[*].port", "/services/0/port", "moonjsonpath query '$.services[*].port' config.json", "Extract service ports."),
    scenario("Public services", "configuration", "$.services[?(@.public == true)].name", "/services/0/name", "moonjsonpath query '$.services[?(@.public == true)].name' config.json", "List externally visible services."),
    scenario("Private services", "configuration", "$.services[?(@.public == false)].name", "/services/1/name", "moonjsonpath query '$.services[?(@.public == false)].name' config.json", "List internal services."),
    scenario("HTTP services", "configuration", "$.services[?(@.protocol == \"http\")]", "/services/0/protocol", "moonjsonpath query '$.services[?(@.protocol == \"http\")]' config.json", "Check protocol selection."),
    scenario("TLS services", "configuration", "$.services[?(@.tls == true)]", "/services/0/tls", "moonjsonpath query '$.services[?(@.tls == true)]' config.json", "Find TLS-enabled endpoints."),
    scenario("Missing owner", "configuration", "$.services[?(!(@.owner))]", "/services/0/owner", "moonjsonpath query '$.services[?(!(@.owner))]' config.json", "Find unowned config entries."),
    scenario("Many tags", "configuration", "$.services[?(@.tags.length >= 2)]", "/services/0/tags", "moonjsonpath query '$.services[?(@.tags.length >= 2)]' config.json", "Use array length filters."),
    scenario("First service", "configuration", "$.services[0]", "/services/0", "moonjsonpath query '$.services[0]' config.json", "Select first array item."),
    scenario("Last service", "configuration", "$.services[-1]", "/services/3", "moonjsonpath query '$.services[-1]' config.json", "Select last array item."),
    scenario("Service slice", "configuration", "$.services[1:3]", "/services/1", "moonjsonpath query '$.services[1:3]' config.json", "Select array ranges."),
    scenario("Reverse services", "configuration", "$.services[::-1].name", "/services/3/name", "moonjsonpath query '$.services[::-1].name' config.json", "Reverse traversal."),
    scenario("Every other service", "configuration", "$.services[0:4:2].name", "/services/0/name", "moonjsonpath query '$.services[0:4:2].name' config.json", "Use stepped slices."),
    scenario("Selected fields", "configuration", "$.service['name','port']", "/service/name", "moonjsonpath query '$.service[\\'name\\',\\'port\\']' config.json", "Union object members."),
    scenario("Selected indexes", "configuration", "$.services[0,2].name", "/services/0/name", "moonjsonpath query '$.services[0,2].name' config.json", "Union array indexes."),
    scenario("All prices", "commerce", "$..price", "/items/0/price", "moonjsonpath query '$..price' catalog.json", "Recursive member lookup."),
    scenario("Cheap items", "commerce", "$.items[?(@.price < 10)]", "/items/0/price", "moonjsonpath query '$.items[?(@.price < 10)]' catalog.json", "Numeric less-than filter."),
    scenario("Expensive items", "commerce", "$.items[?(@.price >= 100)]", "/items/0/price", "moonjsonpath query '$.items[?(@.price >= 100)]' catalog.json", "Numeric greater-than filter."),
    scenario("Discounted items", "commerce", "$.items[?(@.discount != null)]", "/items/0/discount", "moonjsonpath query '$.items[?(@.discount != null)]' catalog.json", "Null comparison."),
    scenario("Available stock", "commerce", "$.items[?(@.stock > 0)]", "/items/0/stock", "moonjsonpath query '$.items[?(@.stock > 0)]' catalog.json", "Stock checks."),
    scenario("Out of stock", "commerce", "$.items[?(@.stock == 0)]", "/items/1/stock", "moonjsonpath query '$.items[?(@.stock == 0)]' catalog.json", "Find unavailable products."),
    scenario("Classic books", "commerce", "$.books[?(@.tags.length >= 2 && @.title contains \"Ring\")]", "/books/0/title", "moonjsonpath query '$.books[?(@.tags.length >= 2 && @.title contains \"Ring\")]' books.json", "Combine length and string filters."),
    scenario("Patch status", "workflow", "$.tasks[?(@.status == \"todo\")]", "/tasks/0/status", "moonjsonpath set '/tasks/0/status' '\"done\"' tasks.json", "Update workflow state."),
    scenario("Remove secret", "workflow", "$..secret", "/user/secret", "moonjsonpath remove '/user/secret' user.json", "Remove sensitive fields."),
    scenario("Add label", "workflow", "$.labels[*]", "/labels/-", "moonjsonpath set '/labels/0' '\"stable\"' metadata.json", "Mutate label arrays."),
    scenario("Apply patch", "workflow", "$.changes[*]", "/changes/0", "moonjsonpath patch patch.json data.json", "Run a batch transform."),
    scenario("Pointer get", "workflow", "$.user.name", "/user/name", "moonjsonpath get '/user/name' user.json", "Read one pointer-selected value."),
    scenario("Pointer URI", "workflow", "$.paths[*]", "#/paths/0", "moonjsonpath get '/paths/0' paths.json", "Bridge URI fragment and pointer notation."),
    scenario("LLM tool args", "ai", "$.tool_calls[*].function.arguments", "/tool_calls/0/function/arguments", "moonjsonpath query '$.tool_calls[*].function.arguments' trace.json", "Inspect tool-calling payloads."),
    scenario("LLM tool names", "ai", "$.tool_calls[*].function.name", "/tool_calls/0/function/name", "moonjsonpath query '$.tool_calls[*].function.name' trace.json", "Collect tool names."),
    scenario("LLM errors", "ai", "$.messages[?(@.role == \"tool\" && @.error)]", "/messages/0/error", "moonjsonpath query '$.messages[?(@.role == \"tool\" && @.error)]' trace.json", "Find failed tool results."),
    scenario("Document headings", "docs", "$..heading", "/sections/0/heading", "moonjsonpath query '$..heading' document.json", "Extract nested headings."),
    scenario("Document links", "docs", "$..href", "/sections/0/links/0/href", "moonjsonpath query '$..href' document.json", "Extract hyperlinks."),
    scenario("Long sections", "docs", "$.sections[?(@.paragraphs.length >= 5)]", "/sections/0/paragraphs", "moonjsonpath query '$.sections[?(@.paragraphs.length >= 5)]' document.json", "Find dense content sections."),
    scenario("RFC root", "standard", "$", "", "moonjsonpath query '$' data.json", "Return the whole document."),
    scenario("RFC wildcard", "standard", "$.store.*", "/store/book", "moonjsonpath query '$.store.*' store.json", "Wildcard over object members."),
    scenario("RFC recursive", "standard", "$..author", "/store/book/0/author", "moonjsonpath query '$..author' store.json", "Recursive descent over objects and arrays."),
    scenario("RFC quoted", "standard", "$['store']['book']", "/store/book", "moonjsonpath query '$[\\'store\\'][\\'book\\']' store.json", "Quoted member selectors."),
    scenario("RFC filter", "standard", "$.store.book[?(@.price < 10)]", "/store/book/0", "moonjsonpath query '$.store.book[?(@.price < 10)]' store.json", "Filter selector."),
    scenario("Diagnostics", "debugging", "$.bad[", "/bad", "moonjsonpath query '$.bad[' data.json", "Show syntax diagnostics."),
    scenario("Pointers output", "debugging", "$..name", "/name", "moonjsonpath query --pointers '$..name' data.json", "Return locations instead of values."),
    scenario("Matches output", "debugging", "$..name", "/name", "moonjsonpath query --matches --pretty '$..name' data.json", "Return value-location pairs."),
  ]
}

///|
fn scenario(
  title : String,
  domain : String,
  query : String,
  pointer : String,
  cli : String,
  note : String,
) -> Scenario {
  { title, domain, query, pointer, cli, note }
}

///|
pub fn scenario_catalog_markdown() -> String {
  let out = StringBuilder::new()
  out.write_string("# MoonJSONPath Scenario Catalog\n\n")
  for item in scenario_catalog() {
    out.write_string("## ")
    out.write_string(item.title)
    out.write_string("\n\n")
    out.write_string("- Domain: ")
    out.write_string(item.domain)
    out.write_string("\n")
    out.write_string("- Query: `")
    out.write_string(item.query)
    out.write_string("`\n")
    out.write_string("- Pointer: `")
    out.write_string(item.pointer)
    out.write_string("`\n")
    out.write_string("- CLI: `")
    out.write_string(item.cli)
    out.write_string("`\n")
    out.write_string("- Note: ")
    out.write_string(item.note)
    out.write_string("\n\n")
  }
  out.to_string()
}

///|
pub fn scenario_count_by_domain(domain : String) -> Int {
  let mut count = 0
  for item in scenario_catalog() {
    if item.domain == domain {
      count += 1
    }
  }
  count
}
