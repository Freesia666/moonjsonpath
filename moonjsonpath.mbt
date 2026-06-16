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
pub fn Pointer::set(self : Pointer, doc : Json, value : Json) -> Result[Json, PointerError] {
  if self.parts.length() == 0 {
    return Ok(value)
  }
  set_at(doc, self.parts, 0, "", value)
}

///|
pub fn Pointer::remove(self : Pointer, doc : Json) -> Result[Json, PointerError] {
  if self.parts.length() == 0 {
    return Err(pointer_error(InvalidSyntax, "", "cannot remove the document root"))
  }
  remove_at(doc, self.parts, 0, "")
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

///|
fn set_at(
  current : Json,
  parts : Array[String],
  depth : Int,
  prefix : String,
  value : Json,
) -> Result[Json, PointerError] {
  let part = parts[depth]
  let path = append_pointer_path(prefix, part)
  let last = depth + 1 == parts.length()
  match current {
    Object(object) => {
      if !object.contains(part) {
        return Err(pointer_error(MissingKey, path, "object key was not found"))
      }
      let copy = object.copy()
      if last {
        copy.set(part, value)
      } else {
        match object.get(part) {
          Some(child) =>
            match set_at(child, parts, depth + 1, path, value) {
              Ok(updated) => copy.set(part, updated)
              Err(err) => return Err(err)
            }
          None => return Err(pointer_error(MissingKey, path, "object key was not found"))
        }
      }
      Ok(Json::object(copy))
    }
    Array(array) =>
      match parse_array_index(part) {
        Some(index) =>
          if index < 0 || index >= array.length() {
            Err(pointer_error(InvalidIndex, path, "array index is out of bounds"))
          } else {
            let copy = array.copy()
            if last {
              copy[index] = value
            } else {
              match set_at(array[index], parts, depth + 1, path, value) {
                Ok(updated) => copy[index] = updated
                Err(err) => return Err(err)
              }
            }
            Ok(Json::array(copy))
          }
        None => Err(pointer_error(InvalidIndex, path, "array token is not a non-negative integer"))
      }
    _ => Err(pointer_error(WrongContainer, path, "cannot descend into a scalar JSON value"))
  }
}

///|
fn remove_at(
  current : Json,
  parts : Array[String],
  depth : Int,
  prefix : String,
) -> Result[Json, PointerError] {
  let part = parts[depth]
  let path = append_pointer_path(prefix, part)
  let last = depth + 1 == parts.length()
  match current {
    Object(object) => {
      if !object.contains(part) {
        return Err(pointer_error(MissingKey, path, "object key was not found"))
      }
      let copy = object.copy()
      if last {
        copy.remove(part)
      } else {
        match object.get(part) {
          Some(child) =>
            match remove_at(child, parts, depth + 1, path) {
              Ok(updated) => copy.set(part, updated)
              Err(err) => return Err(err)
            }
          None => return Err(pointer_error(MissingKey, path, "object key was not found"))
        }
      }
      Ok(Json::object(copy))
    }
    Array(array) =>
      match parse_array_index(part) {
        Some(index) =>
          if index < 0 || index >= array.length() {
            Err(pointer_error(InvalidIndex, path, "array index is out of bounds"))
          } else {
            let copy : Array[Json] = []
            for i, item in array {
              if i != index {
                copy.push(item)
              }
            }
            if last {
              Ok(Json::array(copy))
            } else {
              match remove_at(array[index], parts, depth + 1, path) {
                Ok(updated) => {
                  copy[index] = updated
                  Ok(Json::array(copy))
                }
                Err(err) => Err(err)
              }
            }
          }
        None => Err(pointer_error(InvalidIndex, path, "array token is not a non-negative integer"))
      }
    _ => Err(pointer_error(WrongContainer, path, "cannot descend into a scalar JSON value"))
  }
}

///|
pub(all) enum PathSegment {
  Member(String)
  Element(Int)
  Wildcard
  RecursiveMember(String)
  Slice(Int?, Int?)
} derive(Eq, Debug)

///|
pub(all) struct PathError {
  position : Int
  message : String
} derive(Eq, Debug)

///|
pub(all) struct PathMatch {
  value : Json
  pointer : Pointer
} derive(Eq, Debug)

///|
pub(all) struct Path {
  segments : Array[PathSegment]
} derive(Eq, Debug)

///|
pub fn Path::compile(input : String) -> Result[Path, PathError] {
  let chars = input.to_array()
  if chars.length() == 0 || chars[0] != '$' {
    return Err(path_error(0, "JSONPath must start with '$'"))
  }
  let segments : Array[PathSegment] = []
  let mut i = 1
  while i < chars.length() {
    match chars[i] {
      '.' => {
        if i + 1 >= chars.length() {
          return Err(path_error(i, "member name expected after '.'"))
        }
        let start = i + 1
        if chars[start] == '.' {
          let name_start = start + 1
          if name_start >= chars.length() {
            return Err(path_error(i, "member name expected after '..'"))
          }
          let mut end = name_start
          while end < chars.length() && chars[end] != '.' && chars[end] != '[' {
            end += 1
          }
          if end == name_start {
            return Err(path_error(i, "member name expected after '..'"))
          }
          segments.push(RecursiveMember(String::from_array(chars[name_start:end])))
          i = end
          continue
        }
        if chars[start] == '*' {
          segments.push(Wildcard)
          i = start + 1
          continue
        }
        let mut end = start
        while end < chars.length() && chars[end] != '.' && chars[end] != '[' {
          end += 1
        }
        if end == start {
          return Err(path_error(i, "member name expected after '.'"))
        }
        segments.push(Member(String::from_array(chars[start:end])))
        i = end
      }
      '[' => {
        let start = i + 1
        let mut end = start
        while end < chars.length() && chars[end] != ']' {
          end += 1
        }
        if end >= chars.length() {
          return Err(path_error(i, "missing closing ']'"))
        }
        let selector = String::from_array(chars[start:end])
        if selector == "*" {
          segments.push(Wildcard)
        } else if selector.contains(":") {
          match parse_slice_selector(selector) {
            Some((start, end)) => segments.push(Slice(start, end))
            None => return Err(path_error(start, "slice bounds must be non-negative integers"))
          }
        } else {
          match parse_array_index(selector) {
            Some(index) => segments.push(Element(index))
            None => return Err(path_error(start, "array index must be a non-negative integer"))
          }
        }
        i = end + 1
      }
      _ => return Err(path_error(i, "expected '.', '[' or end of input"))
    }
  }
  Ok({ segments, })
}

///|
pub fn Path::query(self : Path, doc : Json) -> Array[PathMatch] {
  let mut current : Array[PathMatch] = [{ value: doc, pointer: { parts: [] } }]
  for segment in self.segments {
    let next : Array[PathMatch] = []
    for item in current {
      match segment {
        Member(key) =>
          if item.value is Object(object) {
            match object.get(key) {
              Some(value) => next.push({
                value,
                pointer: { parts: [..item.pointer.parts, key] },
              })
              None => ()
            }
          }
        Element(index) =>
          if item.value is Array(array) {
            match array.get(index) {
              Some(value) => next.push({
                value,
                pointer: { parts: [..item.pointer.parts, index.to_string()] },
              })
              None => ()
            }
          }
        Wildcard =>
          match item.value {
            Array(array) =>
              for index, value in array {
                next.push({
                  value,
                  pointer: { parts: [..item.pointer.parts, index.to_string()] },
                })
              }
            Object(object) =>
              for key, value in object {
                next.push({
                  value,
                  pointer: { parts: [..item.pointer.parts, key] },
                })
              }
            _ => ()
          }
        RecursiveMember(key) => {
          collect_recursive_member(item.value, item.pointer, key, next)
        }
        Slice(start, end) =>
          if item.value is Array(array) {
            let lo = clamp_index(start.unwrap_or(0), array.length())
            let hi = clamp_index(end.unwrap_or(array.length()), array.length())
            if lo < hi {
              for i = lo; i < hi; i = i + 1 {
                next.push({
                  value: array[i],
                  pointer: { parts: [..item.pointer.parts, i.to_string()] },
                })
              }
            }
          }
      }
    }
    current = next
  }
  current
}

///|
fn path_error(position : Int, message : String) -> PathError {
  { position, message }
}

///|
fn parse_slice_selector(selector : String) -> (Int?, Int?)? {
  let chars = selector.to_array()
  let mut colon = -1
  for i, ch in chars {
    if ch == ':' {
      if colon >= 0 {
        return None
      }
      colon = i
    }
  }
  if colon < 0 {
    return None
  }
  let left = String::from_array(chars[0:colon])
  let right = String::from_array(chars[colon + 1:chars.length()])
  let start = if left == "" { Some(None) } else { parse_array_index(left).map(i => Some(i)) }
  let end = if right == "" { Some(None) } else { parse_array_index(right).map(i => Some(i)) }
  match (start, end) {
    (Some(start), Some(end)) => Some((start, end))
    _ => None
  }
}

///|
fn clamp_index(index : Int, len : Int) -> Int {
  if index < 0 {
    0
  } else if index > len {
    len
  } else {
    index
  }
}

///|
fn collect_recursive_member(
  value : Json,
  pointer : Pointer,
  key : String,
  out : Array[PathMatch],
) -> Unit {
  match value {
    Object(object) => {
      match object.get(key) {
        Some(found) => out.push({
          value: found,
          pointer: { parts: [..pointer.parts, key] },
        })
        None => ()
      }
      for child_key, child in object {
        collect_recursive_member(
          child,
          { parts: [..pointer.parts, child_key] },
          key,
          out,
        )
      }
    }
    Array(array) =>
      for index, child in array {
        collect_recursive_member(
          child,
          { parts: [..pointer.parts, index.to_string()] },
          key,
          out,
        )
      }
    _ => ()
  }
}
