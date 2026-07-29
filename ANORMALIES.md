# Anomalies

This log records discrepancies found while running the ABAP implementation on
the open-abap toolchain.

## 2026-07-29

- The transpiler fetches `open-abap-core` during a build. In a network-restricted
  environment this fails before source compilation; the build must be run with
  network access or with an already populated dependency cache.
- The ABAP runtime and transpiler publish version `2.13.43`, but
  `@abaplint/database-sqlite` does not. Its corresponding latest published
  version is `2.13.40`, so the development dependencies intentionally use
  different patch versions.
- The transpiled `cl_abap_unit_assert=>assert_equals` reports "Unexpected
  types" when a `decfloat34` actual value is compared with an integer literal.
  Productive SAP ABAP also benefits from keeping expected and actual quantity
  types explicit.
- In the transpiled runtime, the tested `decfloat34` conversion path truncated
  a fractional value: converting 2.5 boxes with a factor of 6 produced 12
  pieces instead of 15. The allocator therefore uses a packed quantity with
  three decimal places, which also more closely matches common SAP `QUAN`
  fields; the fractional case remains in the regression suite.
