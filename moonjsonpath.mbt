///|
pub(all) enum PointerErrorKind {
  InvalidSyntax
  MissingKey
  InvalidIndex
  WrongContainer
} derive(Eq, Debug)

///|
pub(all) struct PointerError {
  kind : PointerErrorKind
  path : String
  message : String
} derive(Eq, Debug)

///|
pub(all) struct Pointer {
  parts : Array[String]
} derive(Eq, Debug)

///|
pub fn Pointer::parse(input : String) -> Result[Pointer, PointerError] {
  if input == "" {
    return Ok({ parts: [] })
  }
  if !input.has_prefix("/") {
    return Err(pointer_error(InvalidSyntax, "", "JSON Pointer must be empty or start with '/'"))
  }
  let parts : Array[String] = []
  let mut current = StringBuilder::new()
  let chars = input.to_array()
  let mut i = 1
  while i < chars.length() {
    let ch = chars[i]
    if ch == '/' {
      parts.push(current.to_string())
      current = StringBuilder::new()
      i += 1
      continue
    }
    if ch == '~' {
      if i + 1 >= chars.length() {
        return Err(pointer_error(InvalidSyntax, input, "unfinished '~' escape in JSON Pointer"))
      }
      let next = chars[i + 1]
      match next {
        '0' => current.write_char('~')
        '1' => current.write_char('/')
        _ => return Err(pointer_error(InvalidSyntax, input, "JSON Pointer escape must be '~0' or '~1'"))
      }
      i += 2
    } else {
      current.write_char(ch)
      i += 1
    }
  }
  parts.push(current.to_string())
  Ok({ parts, })
}

///|
pub fn Pointer::tokens(self : Pointer) -> Array[String] {
  self.parts.copy()
}

///|
pub fn Pointer::to_string(self : Pointer) -> String {
  if self.parts.length() == 0 {
    return ""
  }
  let out = StringBuilder::new()
  for part in self.parts {
    out.write_char('/')
    write_pointer_token(out, part)
  }
  out.to_string()
}

///|
pub fn Pointer::get(self : Pointer, doc : Json) -> Result[Json, PointerError] {
  let mut current = doc
  let mut path = ""
  for part in self.parts {
    path = append_pointer_path(path, part)
    match current {
      Object(object) =>
        match object.get(part) {
          Some(value) => current = value
          None => return Err(pointer_error(MissingKey, path, "object key was not found"))
        }
      Array(array) =>
        match parse_array_index(part) {
          Some(index) =>
            match array.get(index) {
              Some(value) => current = value
              None => return Err(pointer_error(InvalidIndex, path, "array index is out of bounds"))
            }
          None => return Err(pointer_error(InvalidIndex, path, "array token is not a non-negative integer"))
        }
      _ => return Err(pointer_error(WrongContainer, path, "cannot descend into a scalar JSON value"))
    }
  }
  Ok(current)
}

///|
fn pointer_error(kind : PointerErrorKind, path : String, message : String) -> PointerError {
  { kind, path, message }
}

///|
fn append_pointer_path(prefix : String, part : String) -> String {
  let out = StringBuilder::new()
  out.write_string(prefix)
  out.write_char('/')
  write_pointer_token(out, part)
  out.to_string()
}

///|
fn write_pointer_token(out : StringBuilder, part : String) -> Unit {
  for ch in part {
    match ch {
      '~' => out.write_string("~0")
      '/' => out.write_string("~1")
      _ => out.write_char(ch)
    }
  }
}

///|
fn parse_array_index(token : String) -> Int? {
  if token == "" {
    return None
  }
  let mut value = 0
  for ch in token {
    if ch < '0' || ch > '9' {
      return None
    }
    value = value * 10 + ch.to_int() - '0'.to_int()
  }
  Some(value)
}
