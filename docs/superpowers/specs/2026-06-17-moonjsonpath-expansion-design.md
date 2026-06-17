# MoonJSONPath Expansion Design

## Goal

Raise MoonJSONPath from a compact query library into a fuller JSON document querying and transformation toolkit suitable for an OSC 2026 submission. The expanded project should stay useful, testable, and explainable: more effective MoonBit code, broader JSONPath behavior, JSON Pointer based mutation APIs, command-line workflows, and richer examples.

## Recommended Scope

1. Expand JSONPath filters with boolean composition, negation, grouping, string predicates, length checks, and range-oriented comparisons.
2. Add a Pointer Patch layer with `add`, `replace`, `remove`, `test`, `copy`, and `move` operations built on existing JSON Pointer behavior.
3. Turn the CLI into a practical file-based tool with query and mutation subcommands.
4. Add conformance-style cases, cookbook entries, examples, diagnostics, and documentation that explain both library and CLI usage.

## Architecture

The current `moonjsonpath.mbt` remains the public core for Pointer, Path, query rendering, and CLI entry points. New transformation APIs are added in adjacent package files to keep responsibilities separated. Tests are split by behavior: JSONPath conformance, patch operations, CLI parsing, cookbook scenarios, and examples.

## Testing Strategy

Every new behavior is introduced test-first. Each feature should have focused unit tests and at least one workflow-level test where practical. Before commits, run `moon fmt`, `moon info`, `moon check`, and `moon test`.

## Non-Goals

This expansion does not implement full jq, scripting, streaming stdin, or a complete RFC 6902 compatibility promise. Patch semantics are intentionally documented as MoonJSONPath's pointer-based transform layer.
