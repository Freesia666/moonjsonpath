///|
pub fn Path::segment_count(self : Path) -> Int {
  self.segments.length()
}

///|
pub fn Path::is_definite(self : Path) -> Bool {
  for segment in self.segments {
    match segment {
      Member(_) | Element(_) => ()
      _ => return false
    }
  }
  true
}

///|
pub fn Path::explain(self : Path) -> Array[String] {
  self.segments.map(describe_path_segment)
}

///|
fn describe_path_segment(segment : PathSegment) -> String {
  match segment {
    Member(key) => "member \{key}"
    Element(index) => "element \{index}"
    Wildcard => "wildcard"
    RecursiveMember(key) => "recursive member \{key}"
    Slice(start, end, step) => "slice \{format_optional_int(start)}:\{format_optional_int(end)}\{format_optional_step(step)}"
    Filter(filter) => "filter \{format_filter_for_explain(filter)}"
    Union(items) => "union \{format_union_for_explain(items)}"
  }
}

///|
fn format_optional_int(value : Int?) -> String {
  match value {
    Some(value) => value.to_string()
    None => ""
  }
}

///|
fn format_optional_step(value : Int?) -> String {
  match value {
    Some(value) => ":\{value}"
    None => ""
  }
}

///|
fn format_union_for_explain(items : Array[PathSegment]) -> String {
  let out = StringBuilder::new()
  out.write_char('[')
  for index, item in items {
    if index > 0 {
      out.write_char(',')
    }
    match item {
      Member(key) => write_quoted_member(out, key)
      Element(value) => out.write_object(value)
      _ => {
        let nested = describe_path_segment(item)
        out.write_string(nested)
      }
    }
  }
  out.write_char(']')
  out.to_string()
}

///|
fn format_filter_for_explain(filter : FilterExpr) -> String {
  let out = StringBuilder::new()
  write_filter_expr(out, filter)
  out.to_string()
}
