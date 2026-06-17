///|
pub fn Pointer::to_uri_fragment(self : Pointer) -> String {
  let pointer_text = self.to_string()
  let out = StringBuilder::new()
  out.write_char('#')
  for ch in pointer_text {
    write_uri_char(out, ch)
  }
  out.to_string()
}

///|
pub fn Pointer::parse_uri_fragment(
  input : String,
) -> Result[Pointer, PointerError] {
  if !input.has_prefix("#") {
    return Err(
      pointer_error(InvalidSyntax, "", "URI fragment must start with '#'"),
    )
  }
  let fragment = input[1:].to_owned()
  match percent_decode_to_string(fragment) {
    Some(pointer_text) => Pointer::parse(pointer_text)
    None =>
      Err(
        pointer_error(
          InvalidSyntax,
          input,
          "URI fragment contains invalid percent encoding",
        ),
      )
  }
}

///|
fn write_uri_char(out : StringBuilder, ch : Char) -> Unit {
  if is_uri_unreserved(ch) || ch == '/' || ch == '~' {
    out.write_char(ch)
  } else if ch == ' ' {
    out.write_string("%20")
  } else if ch == '%' {
    out.write_string("%25")
  } else {
    out.write_char(ch)
  }
}

///|
fn is_uri_unreserved(ch : Char) -> Bool {
  (ch >= 'a' && ch <= 'z') ||
  (ch >= 'A' && ch <= 'Z') ||
  (ch >= '0' && ch <= '9') ||
  ch == '-' ||
  ch == '.' ||
  ch == '_' ||
  ch == '~'
}

///|
fn percent_decode_to_string(input : String) -> String? {
  let bytes : Array[Int] = []
  let chars = input.to_array()
  let mut i = 0
  while i < chars.length() {
    if chars[i] == '%' {
      if i + 2 >= chars.length() {
        return None
      }
      match (hex_value(chars[i + 1]), hex_value(chars[i + 2])) {
        (Some(high), Some(low)) => {
          bytes.push(high * 16 + low)
          i += 3
        }
        _ => return None
      }
    } else {
      bytes.push(chars[i].to_int())
      i += 1
    }
  }
  utf8_bytes_to_string(bytes)
}

///|
fn hex_value(ch : Char) -> Int? {
  if ch >= '0' && ch <= '9' {
    Some(ch.to_int() - '0'.to_int())
  } else if ch >= 'a' && ch <= 'f' {
    Some(10 + ch.to_int() - 'a'.to_int())
  } else if ch >= 'A' && ch <= 'F' {
    Some(10 + ch.to_int() - 'A'.to_int())
  } else {
    None
  }
}

///|
fn utf8_bytes_to_string(bytes : Array[Int]) -> String? {
  let out = StringBuilder::new()
  let mut i = 0
  while i < bytes.length() {
    let first = bytes[i]
    if first < 0x80 {
      out.write_char(Int::unsafe_to_char(first))
      i += 1
    } else if first >= 0xC0 && first < 0xE0 {
      if i + 1 >= bytes.length() || !is_continuation_byte(bytes[i + 1]) {
        return None
      }
      let code = ((first & 0x1F) << 6) | (bytes[i + 1] & 0x3F)
      out.write_char(Int::unsafe_to_char(code))
      i += 2
    } else if first >= 0xE0 && first < 0xF0 {
      if i + 2 >= bytes.length() ||
        !is_continuation_byte(bytes[i + 1]) ||
        !is_continuation_byte(bytes[i + 2]) {
        return None
      }
      let code = ((first & 0x0F) << 12) |
        ((bytes[i + 1] & 0x3F) << 6) |
        (bytes[i + 2] & 0x3F)
      out.write_char(Int::unsafe_to_char(code))
      i += 3
    } else if first >= 0xF0 && first < 0xF8 {
      if i + 3 >= bytes.length() ||
        !is_continuation_byte(bytes[i + 1]) ||
        !is_continuation_byte(bytes[i + 2]) ||
        !is_continuation_byte(bytes[i + 3]) {
        return None
      }
      let code = ((first & 0x07) << 18) |
        ((bytes[i + 1] & 0x3F) << 12) |
        ((bytes[i + 2] & 0x3F) << 6) |
        (bytes[i + 3] & 0x3F)
      out.write_char(Int::unsafe_to_char(code))
      i += 4
    } else {
      return None
    }
  }
  Some(out.to_string())
}

///|
fn is_continuation_byte(value : Int) -> Bool {
  value >= 0x80 && value < 0xC0
}
