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
