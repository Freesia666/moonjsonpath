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
    return Err(
      pointer_error(
        InvalidSyntax,
        "",
        "JSON Pointer must be empty or start with '/'",
      ),
    )
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
        return Err(
          pointer_error(
            InvalidSyntax,
            input,
            "unfinished '~' escape in JSON Pointer",
          ),
        )
      }
      let next = chars[i + 1]
      match next {
        '0' => current.write_char('~')
        '1' => current.write_char('/')
        _ =>
          return Err(
            pointer_error(
              InvalidSyntax,
              input,
              "JSON Pointer escape must be '~0' or '~1'",
            ),
          )
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
          None =>
            return Err(
              pointer_error(MissingKey, path, "object key was not found"),
            )
        }
      Array(array) =>
        match parse_array_index(part) {
          Some(index) =>
            match array.get(index) {
              Some(value) => current = value
              None =>
                return Err(
                  pointer_error(
                    InvalidIndex,
                    path,
                    "array index is out of bounds",
                  ),
                )
            }
          None =>
            return Err(
              pointer_error(
                InvalidIndex,
                path,
                "array token is not a non-negative integer",
              ),
            )
        }
      _ =>
        return Err(
          pointer_error(
            WrongContainer,
            path,
            "cannot descend into a scalar JSON value",
          ),
        )
    }
  }
  Ok(current)
}

///|
pub fn Pointer::set(
  self : Pointer,
  doc : Json,
  value : Json,
) -> Result[Json, PointerError] {
  if self.parts.length() == 0 {
    return Ok(value)
  }
  set_at(doc, self.parts, 0, "", value)
}

///|
pub fn Pointer::remove(
  self : Pointer,
  doc : Json,
) -> Result[Json, PointerError] {
  if self.parts.length() == 0 {
    return Err(
      pointer_error(InvalidSyntax, "", "cannot remove the document root"),
    )
  }
  remove_at(doc, self.parts, 0, "")
}

///|
pub fn PointerError::describe(self : PointerError) -> String {
  "invalid JSON Pointer at \{self.path}: \{self.message}"
}

///|
fn pointer_error(
  kind : PointerErrorKind,
  path : String,
  message : String,
) -> PointerError {
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
  let chars = token.to_array()
  let mut i = 0
  let mut sign = 1
  if chars[0] == '-' {
    sign = -1
    i = 1
  }
  if i >= chars.length() {
    return None
  }
  while i < chars.length() {
    let ch = chars[i]
    if ch < '0' || ch > '9' {
      return None
    }
    value = value * 10 + ch.to_int() - '0'.to_int()
    i += 1
  }
  Some(value * sign)
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
          None =>
            return Err(
              pointer_error(MissingKey, path, "object key was not found"),
            )
        }
      }
      Ok(Json::object(copy))
    }
    Array(array) =>
      match parse_array_index(part) {
        Some(index) =>
          if index < 0 || index >= array.length() {
            Err(
              pointer_error(InvalidIndex, path, "array index is out of bounds"),
            )
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
        None =>
          Err(
            pointer_error(
              InvalidIndex,
              path,
              "array token is not a non-negative integer",
            ),
          )
      }
    _ =>
      Err(
        pointer_error(
          WrongContainer,
          path,
          "cannot descend into a scalar JSON value",
        ),
      )
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
          None =>
            return Err(
              pointer_error(MissingKey, path, "object key was not found"),
            )
        }
      }
      Ok(Json::object(copy))
    }
    Array(array) =>
      match parse_array_index(part) {
        Some(index) =>
          if index < 0 || index >= array.length() {
            Err(
              pointer_error(InvalidIndex, path, "array index is out of bounds"),
            )
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
        None =>
          Err(
            pointer_error(
              InvalidIndex,
              path,
              "array token is not a non-negative integer",
            ),
          )
      }
    _ =>
      Err(
        pointer_error(
          WrongContainer,
          path,
          "cannot descend into a scalar JSON value",
        ),
      )
  }
}

///|
pub(all) enum PathSegment {
  Member(String)
  Element(Int)
  Wildcard
  RecursiveMember(String)
  Slice(Int?, Int?, Int?)
  Filter(FilterExpr)
  Union(Array[PathSegment])
} derive(Eq, Debug)

///|
pub(all) enum CompareOp {
  Eq
  Ne
  Gt
  Ge
  Lt
  Le
} derive(Eq, Debug)

///|
pub(all) enum Literal {
  LString(String)
  LNumber(Double)
  LBool(Bool)
  LNull
} derive(Eq, Debug)

///|
pub(all) enum FilterExpr {
  Exists(Array[String])
  Compare(Array[String], CompareOp, Literal)
  And(FilterExpr, FilterExpr)
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
          segments.push(
            RecursiveMember(String::from_array(chars[name_start:end])),
          )
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
        let end = match find_closing_bracket(chars, i) {
          Some(end) => end
          None => return Err(path_error(i, "missing closing ']'"))
        }
        let selector = String::from_array(chars[start:end])
        if selector == "*" {
          segments.push(Wildcard)
        } else if selector.contains(",") {
          match parse_union_selector(selector) {
            Some(items) => segments.push(Union(items))
            None => return Err(path_error(start, "invalid union selector"))
          }
        } else if is_quoted_selector(selector) {
          match parse_quoted_member(selector) {
            Some(key) => segments.push(Member(key))
            None =>
              return Err(path_error(start, "invalid quoted member selector"))
          }
        } else if selector.has_prefix("?(") && selector.has_suffix(")") {
          let expr = selector[2:selector.length() - 1].to_owned()
          match parse_filter_expr(expr) {
            Some(filter) => segments.push(Filter(filter))
            None =>
              return Err(
                path_error(start, "filter must look like @.field <op> literal"),
              )
          }
        } else if selector.contains(":") {
          match parse_slice_selector(selector) {
            Some((start, end, step)) => segments.push(Slice(start, end, step))
            None =>
              return Err(
                path_error(start, "slice bounds must be non-negative integers"),
              )
          }
        } else {
          match parse_array_index(selector) {
            Some(index) => segments.push(Element(index))
            None =>
              return Err(
                path_error(start, "array index must be a non-negative integer"),
              )
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
fn find_closing_bracket(chars : Array[Char], open : Int) -> Int? {
  let mut i = open + 1
  let mut quote : Char? = None
  let mut escaped = false
  while i < chars.length() {
    let ch = chars[i]
    match quote {
      Some(q) =>
        if escaped {
          escaped = false
        } else if ch == '\\' {
          escaped = true
        } else if ch == q {
          quote = None
        }
      None =>
        if ch == '\'' || ch == '"' {
          quote = Some(ch)
        } else if ch == ']' {
          return Some(i)
        }
    }
    i += 1
  }
  None
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
              Some(value) =>
                next.push({
                  value,
                  pointer: { parts: [..item.pointer.parts, key] },
                })
              None => ()
            }
          }
        Element(raw_index) =>
          if item.value is Array(array) {
            let index = resolve_index(raw_index, array.length())
            match array.get(index) {
              Some(value) =>
                next.push({
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
        RecursiveMember(key) =>
          collect_recursive_member(item.value, item.pointer, key, next)
        Slice(start, end, step) =>
          if item.value is Array(array) {
            append_slice_matches(item.pointer, array, start, end, step, next)
          }
        Filter(filter) =>
          if item.value is Array(array) {
            for index, value in array {
              if filter_matches(value, filter) {
                next.push({
                  value,
                  pointer: { parts: [..item.pointer.parts, index.to_string()] },
                })
              }
            }
          }
        Union(items) =>
          for union_segment in items {
            append_segment_matches(item, union_segment, next)
          }
      }
    }
    current = next
  }
  current
}

///|
pub fn Path::to_string(self : Path) -> String {
  let out = StringBuilder::new()
  out.write_char('$')
  for segment in self.segments {
    write_path_segment(out, segment)
  }
  out.to_string()
}

///|
pub fn PathError::describe(self : PathError, input : String) -> String {
  let out = StringBuilder::new()
  out.write_string("invalid JSONPath at ")
  out.write_object(self.position)
  out.write_string(": ")
  out.write_string(self.message)
  out.write_char('\n')
  out.write_string(input)
  out.write_char('\n')
  let mut i = 0
  while i < self.position {
    out.write_char(' ')
    i += 1
  }
  out.write_char('^')
  out.to_string()
}

///|
fn append_segment_matches(
  item : PathMatch,
  segment : PathSegment,
  next : Array[PathMatch],
) -> Unit {
  match segment {
    Member(key) =>
      if item.value is Object(object) {
        match object.get(key) {
          Some(value) =>
            next.push({ value, pointer: { parts: [..item.pointer.parts, key] } })
          None => ()
        }
      }
    Element(raw_index) =>
      if item.value is Array(array) {
        let index = resolve_index(raw_index, array.length())
        match array.get(index) {
          Some(value) =>
            next.push({
              value,
              pointer: { parts: [..item.pointer.parts, index.to_string()] },
            })
          None => ()
        }
      }
    _ => ()
  }
}

///|
fn parse_union_selector(selector : String) -> Array[PathSegment]? {
  let raw_items = split_selector_top_level(selector, ',')
  if raw_items.length() == 0 {
    return None
  }
  let items : Array[PathSegment] = []
  for raw in raw_items {
    let part = trim_ascii(raw)
    if part == "" {
      return None
    }
    if is_quoted_selector(part) {
      match parse_quoted_member(part) {
        Some(key) => items.push(Member(key))
        None => return None
      }
    } else {
      match parse_array_index(part) {
        Some(index) => items.push(Element(index))
        None => return None
      }
    }
  }
  Some(items)
}

///|
fn split_selector_top_level(input : String, sep : Char) -> Array[String] {
  let out : Array[String] = []
  let chars = input.to_array()
  let mut start = 0
  let mut i = 0
  let mut quote : Char? = None
  let mut escaped = false
  while i < chars.length() {
    let ch = chars[i]
    match quote {
      Some(q) =>
        if escaped {
          escaped = false
        } else if ch == '\\' {
          escaped = true
        } else if ch == q {
          quote = None
        }
      None =>
        if ch == '\'' || ch == '"' {
          quote = Some(ch)
        } else if ch == sep {
          out.push(String::from_array(chars[start:i]))
          start = i + 1
        }
    }
    i += 1
  }
  out.push(String::from_array(chars[start:chars.length()]))
  out
}

///|
fn is_quoted_selector(selector : String) -> Bool {
  selector.length() >= 2 &&
  (
    (selector.has_prefix("'") && selector.has_suffix("'")) ||
    (selector.has_prefix("\"") && selector.has_suffix("\""))
  )
}

///|
fn parse_quoted_member(selector : String) -> String? {
  if !is_quoted_selector(selector) {
    return None
  }
  let chars = selector.to_array()
  let quote = chars[0]
  let out = StringBuilder::new()
  let mut i = 1
  while i < chars.length() - 1 {
    let ch = chars[i]
    if ch == '\\' {
      if i + 1 >= chars.length() - 1 {
        return None
      }
      let next = chars[i + 1]
      match next {
        '\'' => out.write_char('\'')
        '"' => out.write_char('"')
        '\\' => out.write_char('\\')
        '/' => out.write_char('/')
        'n' => out.write_char('\n')
        'r' => out.write_char('\r')
        't' => out.write_char('\t')
        _ => out.write_char(next)
      }
      i += 2
    } else {
      if ch == quote {
        return None
      }
      out.write_char(ch)
      i += 1
    }
  }
  Some(out.to_string())
}

///|
fn path_error(position : Int, message : String) -> PathError {
  { position, message }
}

///|
fn write_path_segment(out : StringBuilder, segment : PathSegment) -> Unit {
  match segment {
    Member(key) => write_member_selector(out, key)
    Element(index) => {
      out.write_char('[')
      out.write_object(index)
      out.write_char(']')
    }
    Wildcard => out.write_string("[*]")
    RecursiveMember(key) => {
      out.write_string("..")
      if is_identifier_name(key) {
        out.write_string(key)
      } else {
        write_quoted_selector(out, key)
      }
    }
    Slice(start, end, step) => {
      out.write_char('[')
      match start {
        Some(start) => out.write_object(start)
        None => ()
      }
      out.write_char(':')
      match end {
        Some(end) => out.write_object(end)
        None => ()
      }
      match step {
        Some(step) => {
          out.write_char(':')
          out.write_object(step)
        }
        None => ()
      }
      out.write_char(']')
    }
    Filter(filter) => {
      out.write_string("[?(")
      write_filter_expr(out, filter)
      out.write_string(")]")
    }
    Union(items) => {
      out.write_char('[')
      for index, item in items {
        if index > 0 {
          out.write_char(',')
        }
        write_union_item(out, item)
      }
      out.write_char(']')
    }
  }
}

///|
fn write_member_selector(out : StringBuilder, key : String) -> Unit {
  if is_identifier_name(key) {
    out.write_char('.')
    out.write_string(key)
  } else {
    write_quoted_selector(out, key)
  }
}

///|
fn write_union_item(out : StringBuilder, item : PathSegment) -> Unit {
  match item {
    Member(key) => write_quoted_member(out, key)
    Element(index) => out.write_object(index)
    _ => write_path_segment(out, item)
  }
}

///|
fn write_quoted_selector(out : StringBuilder, key : String) -> Unit {
  out.write_char('[')
  write_quoted_member(out, key)
  out.write_char(']')
}

///|
fn write_quoted_member(out : StringBuilder, key : String) -> Unit {
  out.write_char('\'')
  for ch in key {
    match ch {
      '\'' => out.write_string("\\'")
      '\\' => out.write_string("\\\\")
      '\n' => out.write_string("\\n")
      '\r' => out.write_string("\\r")
      '\t' => out.write_string("\\t")
      _ => out.write_char(ch)
    }
  }
  out.write_char('\'')
}

///|
fn is_identifier_name(key : String) -> Bool {
  if key == "" {
    return false
  }
  for i, ch in key.to_array() {
    if i == 0 {
      if !is_identifier_start(ch) {
        return false
      }
    } else if !is_identifier_continue(ch) {
      return false
    }
  }
  true
}

///|
fn is_identifier_start(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || ch == '_'
}

///|
fn is_identifier_continue(ch : Char) -> Bool {
  is_identifier_start(ch) || (ch >= '0' && ch <= '9')
}

///|
fn write_filter_expr(out : StringBuilder, filter : FilterExpr) -> Unit {
  match filter {
    Exists(path) => {
      out.write_string("@.")
      write_filter_path(out, path)
    }
    Compare(path, op, literal) => {
      out.write_string("@.")
      write_filter_path(out, path)
      out.write_char(' ')
      out.write_string(compare_op_to_string(op))
      out.write_char(' ')
      write_literal(out, literal)
    }
    And(left, right) => {
      write_filter_expr(out, left)
      out.write_string(" && ")
      write_filter_expr(out, right)
    }
  }
}

///|
fn write_filter_path(out : StringBuilder, path : Array[String]) -> Unit {
  for index, part in path {
    if index > 0 {
      out.write_char('.')
    }
    out.write_string(part)
  }
}

///|
fn compare_op_to_string(op : CompareOp) -> String {
  match op {
    Eq => "=="
    Ne => "!="
    Gt => ">"
    Ge => ">="
    Lt => "<"
    Le => "<="
  }
}

///|
fn write_literal(out : StringBuilder, literal : Literal) -> Unit {
  match literal {
    LString(value) => {
      out.write_char('"')
      for ch in value {
        match ch {
          '"' => out.write_string("\\\"")
          '\\' => out.write_string("\\\\")
          '\n' => out.write_string("\\n")
          '\r' => out.write_string("\\r")
          '\t' => out.write_string("\\t")
          _ => out.write_char(ch)
        }
      }
      out.write_char('"')
    }
    LNumber(value) => out.write_object(value)
    LBool(value) => out.write_string(if value { "true" } else { "false" })
    LNull => out.write_string("null")
  }
}

///|
fn parse_slice_selector(selector : String) -> (Int?, Int?, Int?)? {
  let chars = selector.to_array()
  let colons : Array[Int] = []
  for i, ch in chars {
    if ch == ':' {
      colons.push(i)
    }
  }
  if colons.length() == 0 || colons.length() > 2 {
    return None
  }
  let first = colons[0]
  let second = if colons.length() == 2 { Some(colons[1]) } else { None }
  let left = String::from_array(chars[0:first])
  let right = match second {
    Some(second) => String::from_array(chars[first + 1:second])
    None => String::from_array(chars[first + 1:chars.length()])
  }
  let step_text = match second {
    Some(second) => String::from_array(chars[second + 1:chars.length()])
    None => ""
  }
  let start = if left == "" {
    Some(None)
  } else {
    parse_array_index(left).map(i => Some(i))
  }
  let end = if right == "" {
    Some(None)
  } else {
    parse_array_index(right).map(i => Some(i))
  }
  let step = if step_text == "" {
    Some(None)
  } else {
    parse_array_index(step_text).map(i => Some(i))
  }
  match (start, end, step) {
    (Some(start), Some(end), Some(step)) => Some((start, end, step))
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
fn resolve_index(index : Int, len : Int) -> Int {
  if index < 0 {
    len + index
  } else {
    index
  }
}

///|
fn append_slice_matches(
  pointer : Pointer,
  array : Array[Json],
  start : Int?,
  end : Int?,
  step : Int?,
  next : Array[PathMatch],
) -> Unit {
  let stride = step.unwrap_or(1)
  if stride == 0 {
    return
  }
  let len = array.length()
  if len == 0 {
    return
  }
  if stride > 0 {
    let lo = clamp_slice_bound(start.unwrap_or(0), len)
    let hi = clamp_slice_bound(end.unwrap_or(len), len)
    let mut i = lo
    while i < hi {
      next.push({
        value: array[i],
        pointer: { parts: [..pointer.parts, i.to_string()] },
      })
      i += stride
    }
  } else {
    let lo = clamp_slice_bound(start.unwrap_or(len - 1), len)
    let hi = match end {
      Some(end) => clamp_reverse_end(end, len)
      None => -1
    }
    let mut i = lo
    while i > hi {
      if i >= 0 && i < len {
        next.push({
          value: array[i],
          pointer: { parts: [..pointer.parts, i.to_string()] },
        })
      }
      i += stride
    }
  }
}

///|
fn clamp_slice_bound(index : Int, len : Int) -> Int {
  clamp_index(resolve_index(index, len), len)
}

///|
fn clamp_reverse_end(index : Int, len : Int) -> Int {
  let resolved = resolve_index(index, len)
  if resolved < -1 {
    -1
  } else if resolved >= len {
    len - 1
  } else {
    resolved
  }
}

///|
fn parse_filter_expr(expr : String) -> FilterExpr? {
  match split_filter_and(expr) {
    Some((left, right)) =>
      match (parse_filter_expr(left), parse_filter_expr(right)) {
        (Some(left), Some(right)) => return Some(And(left, right))
        _ => return None
      }
    None => ()
  }
  let ops : Array[(String, CompareOp)] = [
    ("==", Eq),
    ("!=", Ne),
    (">=", Ge),
    ("<=", Le),
    (">", Gt),
    ("<", Lt),
  ]
  for pair in ops {
    let (op_text, op) = pair
    match find_operator(expr, op_text) {
      Some(pos) => {
        let left = trim_ascii(expr[:pos].to_owned())
        let right = trim_ascii(expr[pos + op_text.length():].to_owned())
        if !left.has_prefix("@.") || left.length() <= 2 {
          return None
        }
        let fields = parse_filter_field_path(left[2:].to_owned())
        if fields.length() == 0 {
          return None
        }
        match parse_literal(right) {
          Some(literal) => return Some(Compare(fields, op, literal))
          None => return None
        }
      }
      None => ()
    }
  }
  let trimmed = trim_ascii(expr)
  if trimmed.has_prefix("@.") && trimmed.length() > 2 {
    let fields = parse_filter_field_path(trimmed[2:].to_owned())
    if fields.length() > 0 {
      return Some(Exists(fields))
    }
  }
  None
}

///|
fn split_filter_and(expr : String) -> (String, String)? {
  let chars = expr.to_array()
  let mut quote : Char? = None
  let mut escaped = false
  for i = 0; i + 1 < chars.length(); i = i + 1 {
    let ch = chars[i]
    match quote {
      Some(q) =>
        if escaped {
          escaped = false
        } else if ch == '\\' {
          escaped = true
        } else if ch == q {
          quote = None
        }
      None =>
        if ch == '\'' || ch == '"' {
          quote = Some(ch)
        } else if ch == '&' && chars[i + 1] == '&' {
          return Some(
            (
              trim_ascii(String::from_array(chars[:i])),
              trim_ascii(String::from_array(chars[i + 2:])),
            ),
          )
        }
    }
  }
  None
}

///|
fn parse_filter_field_path(input : String) -> Array[String] {
  let fields : Array[String] = []
  for part in split_simple(input, '.') {
    let trimmed = trim_ascii(part)
    if trimmed == "" {
      return []
    }
    fields.push(trimmed)
  }
  fields
}

///|
fn split_simple(input : String, sep : Char) -> Array[String] {
  let out : Array[String] = []
  let chars = input.to_array()
  let mut start = 0
  for i, ch in chars {
    if ch == sep {
      out.push(String::from_array(chars[start:i]))
      start = i + 1
    }
  }
  out.push(String::from_array(chars[start:chars.length()]))
  out
}

///|
fn find_operator(input : String, op : String) -> Int? {
  let chars = input.to_array()
  let target = op.to_array()
  if target.length() == 0 || target.length() > chars.length() {
    return None
  }
  for i = 0; i <= chars.length() - target.length(); i = i + 1 {
    let mut same = true
    for j = 0; j < target.length(); j = j + 1 {
      if chars[i + j] != target[j] {
        same = false
      }
    }
    if same {
      return Some(i)
    }
  }
  None
}

///|
fn parse_literal(input : String) -> Literal? {
  if input == "true" {
    return Some(LBool(true))
  }
  if input == "false" {
    return Some(LBool(false))
  }
  if input == "null" {
    return Some(LNull)
  }
  if input.length() >= 2 && input.has_prefix("\"") && input.has_suffix("\"") {
    return Some(LString(input[1:input.length() - 1].to_owned()))
  }
  match parse_json_number_literal(input) {
    Some(n) => Some(LNumber(n))
    None => None
  }
}

///|
fn parse_json_number_literal(input : String) -> Double? {
  if input == "" {
    return None
  }
  let chars = input.to_array()
  let mut i = 0
  let mut sign = 1.0
  if chars[0] == '-' {
    sign = -1.0
    i = 1
  }
  if i >= chars.length() {
    return None
  }
  let mut whole = 0.0
  let mut saw_digit = false
  while i < chars.length() && chars[i] >= '0' && chars[i] <= '9' {
    whole = whole * 10.0 + (chars[i].to_int() - '0'.to_int()).to_double()
    saw_digit = true
    i += 1
  }
  let mut frac = 0.0
  if i < chars.length() && chars[i] == '.' {
    i += 1
    let mut scale = 0.1
    let mut saw_frac = false
    while i < chars.length() && chars[i] >= '0' && chars[i] <= '9' {
      frac = frac + (chars[i].to_int() - '0'.to_int()).to_double() * scale
      scale = scale / 10.0
      saw_frac = true
      i += 1
    }
    if !saw_frac {
      return None
    }
  }
  if !saw_digit || i != chars.length() {
    return None
  }
  Some(sign * (whole + frac))
}

///|
fn trim_ascii(input : String) -> String {
  let chars = input.to_array()
  let mut start = 0
  let mut end = chars.length()
  while start < end && is_ascii_space(chars[start]) {
    start += 1
  }
  while end > start && is_ascii_space(chars[end - 1]) {
    end -= 1
  }
  String::from_array(chars[start:end])
}

///|
fn is_ascii_space(ch : Char) -> Bool {
  ch == ' ' || ch == '\n' || ch == '\r' || ch == '\t'
}

///|
fn filter_matches(value : Json, filter : FilterExpr) -> Bool {
  match filter {
    Exists(path) => resolve_filter_path(value, path) is Some(_)
    Compare(path, op, literal) =>
      match resolve_filter_path(value, path) {
        Some(field_value) => compare_json_literal(field_value, op, literal)
        None => false
      }
    And(left, right) =>
      filter_matches(value, left) && filter_matches(value, right)
  }
}

///|
fn resolve_filter_path(value : Json, path : Array[String]) -> Json? {
  let mut current = value
  for key in path {
    match current {
      Object(object) =>
        match object.get(key) {
          Some(next) => current = next
          None => return None
        }
      _ => return None
    }
  }
  Some(current)
}

///|
fn compare_json_literal(
  value : Json,
  op : CompareOp,
  literal : Literal,
) -> Bool {
  match (value, literal) {
    (String(actual), LString(expected)) => compare_string(actual, op, expected)
    (Number(actual, ..), LNumber(expected)) =>
      compare_double(actual, op, expected)
    (True, LBool(expected)) => compare_bool(true, op, expected)
    (False, LBool(expected)) => compare_bool(false, op, expected)
    (Null, LNull) => op == Eq
    (Null, _) => op == Ne
    _ => false
  }
}

///|
fn compare_string(left : String, op : CompareOp, right : String) -> Bool {
  match op {
    Eq => left == right
    Ne => left != right
    Gt | Ge | Lt | Le => false
  }
}

///|
fn compare_bool(left : Bool, op : CompareOp, right : Bool) -> Bool {
  match op {
    Eq => left == right
    Ne => left != right
    Gt | Ge | Lt | Le => false
  }
}

///|
fn compare_double(left : Double, op : CompareOp, right : Double) -> Bool {
  match op {
    Eq => left == right
    Ne => left != right
    Gt => left > right
    Ge => left >= right
    Lt => left < right
    Le => left <= right
  }
}

///|
pub fn query_json_text(
  path_text : String,
  json_text : String,
) -> Result[String, String] {
  query_json_text_with_options(path_text, json_text, QueryOptions::values())
}

///|
pub(all) enum OutputMode {
  Values
  Pointers
  Matches
} derive(Eq, Debug)

///|
pub(all) struct QueryOptions {
  output : OutputMode
  indent : Int
} derive(Eq, Debug)

///|
pub fn QueryOptions::values(indent? : Int = 0) -> QueryOptions {
  { output: Values, indent }
}

///|
pub fn QueryOptions::pointers(indent? : Int = 0) -> QueryOptions {
  { output: Pointers, indent }
}

///|
pub fn QueryOptions::matches(indent? : Int = 0) -> QueryOptions {
  { output: Matches, indent }
}

///|
pub fn query_json_text_with_options(
  path_text : String,
  json_text : String,
  options : QueryOptions,
) -> Result[String, String] {
  let path = match Path::compile(path_text) {
    Ok(path) => path
    Err(err) =>
      return Err("invalid JSONPath at \{err.position}: \{err.message}")
  }
  let doc = @json.parse(json_text) catch {
    err => return Err("invalid JSON input: \{err}")
  }
  let matches = path.query(doc)
  Ok(render_matches(matches, options))
}

///|
pub fn query_json_file(
  path_text : String,
  file_path : String,
) -> Result[String, String] {
  query_json_file_with_options(path_text, file_path, QueryOptions::values())
}

///|
pub fn query_json_file_with_options(
  path_text : String,
  file_path : String,
  options : QueryOptions,
) -> Result[String, String] {
  let json_text = @fs.read_file_to_string(file_path) catch {
    _ => return Err("failed to read JSON file '\{file_path}'")
  }
  query_json_text_with_options(path_text, json_text, options)
}

///|
fn render_matches(matches : Array[PathMatch], options : QueryOptions) -> String {
  let json = match options.output {
    Values => Json::array(matches.map(item => item.value))
    Pointers =>
      Json::array(matches.map(item => item.pointer.to_string().to_json()))
    Matches =>
      Json::array(
        matches.map(item => {
          "path": item.pointer.to_string(),
          "value": item.value,
        }),
      )
  }
  json.stringify(indent=options.indent)
}

///|
pub(all) struct CliConfig {
  path_text : String
  file_path : String
  options : QueryOptions
  show_help : Bool
} derive(Eq, Debug)

///|
pub fn CliConfig::parse(args : Array[String]) -> Result[CliConfig, String] {
  let mut output = Values
  let mut indent = 0
  let mut show_help = false
  let positional : Array[String] = []
  let mut i = 1
  while i < args.length() {
    let arg = args[i]
    match arg {
      "--help" | "-h" => {
        show_help = true
        i += 1
      }
      "--values" => {
        output = Values
        i += 1
      }
      "--pointers" => {
        output = Pointers
        i += 1
      }
      "--matches" => {
        output = Matches
        i += 1
      }
      "--pretty" => {
        indent = 2
        i += 1
      }
      _ =>
        if arg.has_prefix("-") {
          return Err("unknown option: \{arg}")
        } else {
          positional.push(arg)
          i += 1
        }
    }
  }
  if show_help {
    return Ok({
      path_text: "",
      file_path: "",
      options: { output, indent },
      show_help: true,
    })
  }
  if positional.length() != 2 {
    return Err("expected <jsonpath> and <file>")
  }
  Ok({
    path_text: positional[0],
    file_path: positional[1],
    options: { output, indent },
    show_help: false,
  })
}

///|
pub fn cli_usage() -> String {
  (
    #|Usage: moonjsonpath [--values|--pointers|--matches] [--pretty] <jsonpath> <file>
    #|
    #|Examples:
    #|  moonjsonpath '$.users[*].name' data.json
    #|  moonjsonpath --pointers '$..name' data.json
    #|  moonjsonpath --matches --pretty '$.users[?(@.age > 20)]' data.json
    #|
  )
}

///|
pub fn run_cli(args : Array[String]) -> Int {
  match CliConfig::parse(args) {
    Ok(config) =>
      if config.show_help {
        println(cli_usage())
        0
      } else {
        match
          query_json_file_with_options(
            config.path_text,
            config.file_path,
            config.options,
          ) {
          Ok(output) => {
            println(output)
            0
          }
          Err(message) => {
            println("MoonJSONPath error: \{message}")
            1
          }
        }
      }
    Err(message) => {
      println("MoonJSONPath error: \{message}")
      println(cli_usage())
      2
    }
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
        Some(found) =>
          out.push({ value: found, pointer: { parts: [..pointer.parts, key] } })
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
