///|
pub fn Path::first(self : Path, doc : Json) -> Json? {
  match self.query(doc).get(0) {
    Some(item) => Some(item.value)
    None => None
  }
}

///|
pub fn Path::exists(self : Path, doc : Json) -> Bool {
  self.query(doc).length() > 0
}

///|
pub fn Path::values(self : Path, doc : Json) -> Json {
  Json::array(self.query(doc).map(item => item.value))
}

///|
pub fn Path::pointers(self : Path, doc : Json) -> Json {
  Json::array(self.query(doc).map(item => item.pointer.to_string().to_json()))
}

///|
pub fn query_first_json_text(
  path_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match parse_query_inputs(path_text, json_text) {
    Ok((path, doc)) =>
      match path.first(doc) {
        Some(value) => Ok(value.stringify(indent=indent))
        None => Ok("null")
      }
    Err(message) => Err(message)
  }
}

///|
pub fn query_values_json_text(
  path_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match parse_query_inputs(path_text, json_text) {
    Ok((path, doc)) => Ok(path.values(doc).stringify(indent=indent))
    Err(message) => Err(message)
  }
}

///|
pub fn query_pointers_json_text(
  path_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match parse_query_inputs(path_text, json_text) {
    Ok((path, doc)) => Ok(path.pointers(doc).stringify(indent=indent))
    Err(message) => Err(message)
  }
}

///|
pub fn query_exists_json_text(
  path_text : String,
  json_text : String,
) -> Result[Bool, String] {
  match parse_query_inputs(path_text, json_text) {
    Ok((path, doc)) => Ok(path.exists(doc))
    Err(message) => Err(message)
  }
}

///|
fn parse_query_inputs(
  path_text : String,
  json_text : String,
) -> Result[(Path, Json), String] {
  let path = match Path::compile(path_text) {
    Ok(path) => path
    Err(err) =>
      return Err("invalid JSONPath at \{err.position}: \{err.message}")
  }
  let doc = @json.parse(json_text) catch {
    err => return Err("invalid JSON input: \{err}")
  }
  Ok((path, doc))
}
