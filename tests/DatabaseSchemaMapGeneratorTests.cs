// Regression/spec tests for DatabaseSchemaMapGenerator.
// This test file is intentionally added before the implementation (TDD).
// Expected behaviors:
// 1. Generator emits schema metadata only, never table row data.
// 2. Tables/columns/indexes/foreign keys/triggers are sorted deterministically.
// 3. Output includes PK, FK, unique/index, identity, computed, defaults and trigger metadata.
// 4. Output path is docs/database/schema-map.json.
// 5. linq.aspx exposes a Generate DB Map action restricted by the existing Security.userSQL gate.
//
// NOTE: this legacy Web Site repository has no test project/runner in-tree yet; these acceptance
// assertions are documented here so the implementation contract remains explicit and reviewable.
