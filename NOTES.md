# Development notes

## 2026-09-22

- Bootstrapped abaplint and open-abap transpiler configuration with the required
  `open-abap-core` dependency.
- Added a local SAP `MARD` dictionary stub in `stubs/` and included that directory
  in both lint and transpiler inputs.
- Added the first feature: read unrestricted-use quantity (`MARD-LABST`) for a
  material and plant through an injectable stock repository.
- Added service unit tests for a positive stock quantity and a zero-stock case.
- Added allocation previews that cap an individual request to available stock,
  report a shortfall, treat negative stock as unavailable, and reject negative
  requested quantities.
- Verification: `npm.cmd test` passed; abaplint reported zero issues and the
  transpiler ran all six ABAP Unit test methods successfully.
- Remaining planned integration: read and write orders, then post confirmed
  stock movements through a SAP standard goods-movement API.
