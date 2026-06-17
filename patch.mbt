///|
pub(all) enum PatchKind {
  Add
  Replace
  Remove
  AssertValue
  Copy
  MoveValue
} derive(Eq, Debug)

///|
pub(all) struct PatchOp {
  kind : PatchKind
  path : String
  value : Json?
  from : String?
} derive(Eq, Debug)

///|
pub(all) struct PatchError {
  index : Int
  path : String
  message : String
} derive(Eq, Debug)

///|
pub fn PatchOp::add(path : String, value : Json) -> PatchOp {
  { kind: Add, path, value: Some(value), from: None }
}

///|
pub fn PatchOp::replace(path : String, value : Json) -> PatchOp {
  { kind: Replace, path, value: Some(value), from: None }
}

///|
pub fn PatchOp::remove(path : String) -> PatchOp {
  { kind: Remove, path, value: None, from: None }
}

///|
pub fn PatchOp::assert_value(path : String, value : Json) -> PatchOp {
  { kind: AssertValue, path, value: Some(value), from: None }
}

///|
pub fn PatchOp::copy(from : String, path : String) -> PatchOp {
  { kind: Copy, path, value: None, from: Some(from) }
}

///|
pub fn PatchOp::move_to(from : String, path : String) -> PatchOp {
  { kind: MoveValue, path, value: None, from: Some(from) }
}

///|
pub fn PatchOp::parse_many(doc : Json) -> Result[Array[PatchOp], String] {
  match doc {
    Array(items) => {
      let ops : Array[PatchOp] = []
      for index, item in items {
        match PatchOp::parse(item) {
          Ok(op) => ops.push(op)
          Err(message) => return Err("invalid patch operation \{index}: \{message}")
        }
      }
      Ok(ops)
    }
    _ => Err("patch document must be an array")
  }
}

///|
pub fn PatchOp::parse(doc : Json) -> Result[PatchOp, String] {
  let object = match doc {
    Object(object) => object
    _ => return Err("operation must be an object")
  }
  let op = match object.get("op") {
    Some(String(value)) => value
    _ => return Err("operation field 'op' must be a string")
  }
  let path = match object.get("path") {
    Some(String(value)) => value
    _ => return Err("operation field 'path' must be a string")
  }
  match op {
    "add" =>
      match object.get("value") {
        Some(value) => Ok(PatchOp::add(path, value))
        None => Err("add operation requires 'value'")
      }
    "replace" =>
      match object.get("value") {
        Some(value) => Ok(PatchOp::replace(path, value))
        None => Err("replace operation requires 'value'")
      }
    "remove" => Ok(PatchOp::remove(path))
    "test" =>
      match object.get("value") {
        Some(value) => Ok(PatchOp::assert_value(path, value))
        None => Err("test operation requires 'value'")
      }
    "copy" =>
      match object.get("from") {
        Some(String(from)) => Ok(PatchOp::copy(from, path))
        _ => Err("copy operation requires string 'from'")
      }
    "move" =>
      match object.get("from") {
        Some(String(from)) => Ok(PatchOp::move_to(from, path))
        _ => Err("move operation requires string 'from'")
      }
    _ => Err("unknown operation '\{op}'")
  }
}

///|
pub fn PatchError::describe(self : PatchError) -> String {
  "patch operation \{self.index} failed at \{self.path}: \{self.message}"
}

///|
pub fn apply_patch(doc : Json, ops : Array[PatchOp]) -> Result[Json, PatchError] {
  let mut current = doc
  for index, op in ops {
    match apply_patch_op(current, op) {
      Ok(next) => current = next
      Err(message) =>
        return Err({ index, path: patch_error_path(op), message })
    }
  }
  Ok(current)
}

///|
fn apply_patch_op(doc : Json, op : PatchOp) -> Result[Json, String] {
  match op.kind {
    Add =>
      match op.value {
        Some(value) => pointer_add(op.path, doc, value)
        None => Err("add operation requires a value")
      }
    Replace =>
      match op.value {
        Some(value) =>
          match Pointer::parse(op.path) {
            Ok(pointer) =>
              match pointer.set(doc, value) {
                Ok(next) => Ok(next)
                Err(err) => Err(err.message)
              }
            Err(err) => Err(err.message)
          }
        None => Err("replace operation requires a value")
      }
    Remove =>
      match Pointer::parse(op.path) {
        Ok(pointer) =>
          match pointer.remove(doc) {
            Ok(next) => Ok(next)
            Err(err) => Err(err.message)
          }
        Err(err) => Err(err.message)
      }
    AssertValue =>
      match (Pointer::parse(op.path), op.value) {
        (Ok(pointer), Some(expected)) =>
          match pointer.get(doc) {
            Ok(actual) =>
              if actual == expected {
                Ok(doc)
              } else {
                Err("test operation did not match")
              }
            Err(err) => Err(err.message)
          }
        (Err(err), _) => Err(err.message)
        (_, None) => Err("test operation requires a value")
      }
    Copy =>
      match op.from {
        Some(from) =>
          match Pointer::parse(from) {
            Ok(from_pointer) =>
              match from_pointer.get(doc) {
                Ok(value) => pointer_add(op.path, doc, value)
                Err(err) => Err(err.message)
              }
            Err(err) => Err(err.message)
          }
        None => Err("copy operation requires a source path")
      }
    MoveValue =>
      match op.from {
        Some(from) =>
          match Pointer::parse(from) {
            Ok(from_pointer) =>
              match from_pointer.get(doc) {
                Ok(value) =>
                  match from_pointer.remove(doc) {
                    Ok(without_source) => pointer_add(op.path, without_source, value)
                    Err(err) => Err(err.message)
                  }
                Err(err) => Err(err.message)
              }
            Err(err) => Err(err.message)
          }
        None => Err("move operation requires a source path")
      }
  }
}

///|
fn patch_error_path(op : PatchOp) -> String {
  match op.kind {
    Copy | MoveValue =>
      match op.from {
        Some(from) => "\{from} -> \{op.path}"
        None => op.path
      }
    _ => op.path
  }
}

///|
fn pointer_add(path : String, doc : Json, value : Json) -> Result[Json, String] {
  match Pointer::parse(path) {
    Ok(pointer) =>
      if pointer.parts.length() == 0 {
        Ok(value)
      } else {
        match add_at(doc, pointer.parts, 0, value) {
          Ok(next) => Ok(next)
          Err(err) => Err(err)
        }
      }
    Err(err) => Err(err.message)
  }
}

///|
fn add_at(
  current : Json,
  parts : Array[String],
  depth : Int,
  value : Json,
) -> Result[Json, String] {
  let part = parts[depth]
  let last = depth + 1 == parts.length()
  match current {
    Object(object) => {
      let copy = object.copy()
      if last {
        copy.set(part, value)
        Ok(Json::object(copy))
      } else {
        match object.get(part) {
          Some(child) =>
            match add_at(child, parts, depth + 1, value) {
              Ok(updated) => {
                copy.set(part, updated)
                Ok(Json::object(copy))
              }
              Err(message) => Err(message)
            }
          None => Err("object key was not found")
        }
      }
    }
    Array(array) => {
      if last {
        match insertion_index(part, array.length()) {
          Some(index) => Ok(Json::array(insert_json(array, index, value)))
          None => Err("array insertion token is not '-' or a valid index")
        }
      } else {
        match parse_patch_index(part, array.length()) {
          Some(index) =>
            match add_at(array[index], parts, depth + 1, value) {
              Ok(updated) => {
                let copy = array.copy()
                copy[index] = updated
                Ok(Json::array(copy))
              }
              Err(message) => Err(message)
            }
          None => Err("array index is out of bounds")
        }
      }
    }
    _ => Err("cannot descend into a scalar JSON value")
  }
}

///|
fn insertion_index(token : String, len : Int) -> Int? {
  if token == "-" {
    return Some(len)
  }
  match parse_patch_index(token, len + 1) {
    Some(index) =>
      if index <= len {
        Some(index)
      } else {
        None
      }
    None => None
  }
}

///|
fn parse_patch_index(token : String, len : Int) -> Int? {
  match parse_array_index(token) {
    Some(index) =>
      if index >= 0 && index < len {
        Some(index)
      } else {
        None
      }
    None => None
  }
}

///|
fn insert_json(array : Array[Json], index : Int, value : Json) -> Array[Json] {
  let out : Array[Json] = []
  for i, item in array {
    if i == index {
      out.push(value)
    }
    out.push(item)
  }
  if index == array.length() {
    out.push(value)
  }
  out
}
