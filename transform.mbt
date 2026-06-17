///|
pub fn pointer_get_json_text(
  pointer_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match
    (parse_json_document(json_text), parse_pointer_for_transform(pointer_text)) {
    (Ok(doc), Ok(pointer)) =>
      match pointer.get(doc) {
        Ok(value) => Ok(value.stringify(indent~))
        Err(err) => Err(err.describe())
      }
    (Err(message), _) => Err(message)
    (_, Err(message)) => Err(message)
  }
}

///|
pub fn pointer_set_json_text(
  pointer_text : String,
  value_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match
    (
      parse_json_document(json_text),
      parse_json_value(value_text),
      parse_pointer_for_transform(pointer_text),
    ) {
    (Ok(doc), Ok(value), Ok(pointer)) =>
      match pointer.set(doc, value) {
        Ok(value) => Ok(value.stringify(indent~))
        Err(err) => Err(err.describe())
      }
    (Err(message), _, _) => Err(message)
    (_, Err(message), _) => Err(message)
    (_, _, Err(message)) => Err(message)
  }
}

///|
pub fn pointer_remove_json_text(
  pointer_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match
    (parse_json_document(json_text), parse_pointer_for_transform(pointer_text)) {
    (Ok(doc), Ok(pointer)) =>
      match pointer.remove(doc) {
        Ok(value) => Ok(value.stringify(indent~))
        Err(err) => Err(err.describe())
      }
    (Err(message), _) => Err(message)
    (_, Err(message)) => Err(message)
  }
}

///|
pub fn patch_json_text(
  patch_text : String,
  json_text : String,
  indent? : Int = 0,
) -> Result[String, String] {
  match (parse_json_document(json_text), parse_patch_document(patch_text)) {
    (Ok(doc), Ok(patch_doc)) =>
      match PatchOp::parse_many(patch_doc) {
        Ok(ops) =>
          match apply_patch(doc, ops) {
            Ok(value) => Ok(value.stringify(indent~))
            Err(err) => Err(err.describe())
          }
        Err(message) => Err(message)
      }
    (Err(message), _) => Err(message)
    (_, Err(message)) => Err(message)
  }
}

///|
fn parse_json_document(json_text : String) -> Result[Json, String] {
  let doc = @json.parse(json_text) catch {
    err => return Err("invalid JSON input: \{err}")
  }
  Ok(doc)
}

///|
fn parse_json_value(value_text : String) -> Result[Json, String] {
  let doc = @json.parse(value_text) catch {
    err => return Err("invalid JSON value: \{err}")
  }
  Ok(doc)
}

///|
fn parse_patch_document(patch_text : String) -> Result[Json, String] {
  let doc = @json.parse(patch_text) catch {
    err => return Err("invalid patch JSON: \{err}")
  }
  Ok(doc)
}

///|
fn parse_pointer_for_transform(
  pointer_text : String,
) -> Result[Pointer, String] {
  match Pointer::parse(pointer_text) {
    Ok(pointer) => Ok(pointer)
    Err(err) => Err(err.describe())
  }
}
