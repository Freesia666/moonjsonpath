// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "Freesia666/moonjsonpath"

version = "0.1.0"

readme = "README.mbt.md"

repository = "https://github.com/Freesia666/moonjsonpath"

license = "Apache-2.0"

keywords = [ "jsonpath", "json-pointer", "json", "query", "moonbit" ]

description = "JSON Pointer and JSONPath query utilities for MoonBit"

import {
  "moonbitlang/x@0.4.45",
}
