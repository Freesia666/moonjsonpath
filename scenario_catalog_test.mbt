///|
test "scenario catalog exposes many documented workflows" {
  let scenarios = @moonjsonpath.scenario_catalog()
  inspect(scenarios.length() >= 50, content="true")
  inspect(@moonjsonpath.scenario_count_by_domain("identity") >= 10, content="true")
  inspect(@moonjsonpath.scenario_count_by_domain("configuration") >= 10, content="true")
  inspect(@moonjsonpath.scenario_count_by_domain("ai") >= 3, content="true")
}

///|
test "scenario catalog markdown contains representative command families" {
  let markdown = @moonjsonpath.scenario_catalog_markdown()
  inspect(markdown.contains("MoonJSONPath Scenario Catalog"), content="true")
  inspect(markdown.contains("moonjsonpath query"), content="true")
  inspect(markdown.contains("moonjsonpath get"), content="true")
  inspect(markdown.contains("moonjsonpath set"), content="true")
  inspect(markdown.contains("moonjsonpath remove"), content="true")
  inspect(markdown.contains("moonjsonpath patch"), content="true")
}

///|
test "scenario catalog queries are mostly compilable examples" {
  let scenarios = @moonjsonpath.scenario_catalog()
  let mut compilable = 0
  for item in scenarios {
    if item.query != "$.bad[" {
      let path = @moonjsonpath.Path::compile(item.query)
      inspect(path is Ok(_), content="true")
      compilable += 1
    }
  }
  inspect(compilable >= 49, content="true")
}
