Run all tests for the iOS app.

1. If `project.yml` exists, run `xcodegen generate` first
2. Use XcodeBuildMCP to run the test suite
3. Report test results clearly:
   - Total passed/failed
   - Details on any failures
4. If tests fail, analyze the failures and suggest fixes

Use --quiet flag to minimize output noise.
