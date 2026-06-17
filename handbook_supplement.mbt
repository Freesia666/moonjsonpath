///|
pub fn handbook_submission_supplement() -> String {
  (
    #|# Submission Supplement
    #|
    #|## 1. Why this project matters
    #|
    #|- JSONPath gives MoonBit users a standard way to locate structured data.
    #|- JSON Pointer gives MoonBit users a stable way to name exact locations.
    #|- Patch operations turn location support into practical document updates.
    #|- CLI commands make the same behavior useful in scripts and CI jobs.
    #|
    #|## 2. What judges can run
    #|
    #|- `moon check` verifies the package compiles.
    #|- `moon test` verifies query, pointer, patch, CLI, and catalog behavior.
    #|- `moon run cmd/main -- query '$..name' data.json` exercises the query CLI.
    #|- `moon run cmd/main -- get '/path' data.json` exercises pointer reads.
    #|- `moon run cmd/main -- patch patch.json data.json` exercises transforms.
    #|
    #|## 3. What is intentionally not claimed
    #|
    #|- It is not a jq clone.
    #|- It does not claim streaming stdin support yet.
    #|- It does not claim full RFC 6902 compatibility.
    #|- It keeps MoonJSONPath patch semantics explicit and documented.
    #|
    #|## 4. What is original
    #|
    #|- Parser, evaluator, pointer operations, patch operations, and CLI are written for MoonBit.
    #|- Tests use synthetic fixtures created for this project.
    #|- Catalogs are project documentation data, not copied upstream fixtures.
    #|
    #|## 5. What can be extended later
    #|
    #|- More RFC 9535 examples can be imported as explicit conformance cases.
    #|- Stdin support can be added when a stable MoonBit API is available.
    #|- More JSONPath filter functions can be added without changing the public query API.
    #|- Publishing metadata can be finalized after the remote repository is created.
    #|
  )
}
