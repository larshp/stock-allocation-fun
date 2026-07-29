# stock-allocation-fun

A small, test-driven stock allocation engine in ABAP.

The first feature allocates unrestricted stock to demand in priority and
requirement-date order. Batches are consumed by earliest expiry first. Expired
stock, quality-inspection stock, blocked stock, and safety stock are not
available for allocation. Any unmet demand is returned as a shortage line.

## Layout

- `src/` contains application allocation logic.
- `sap/` contains the SAP business-semantics compatibility layer that is not
  supplied by open-abap. Keeping it separate makes the emulated standard rules
  explicit and replaceable on a real SAP system.
- `test/` contains ABAP Unit tests executed by the transpiler.
- `ANORMALIES.md` records toolchain and runtime discrepancies.

Both `abaplint.jsonc` and `abap_transpile.json` include all three ABAP source
directories.

## Test

```sh
npm install
npm test
```
