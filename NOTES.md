# Progress notes

## 2026-07-31

- Established the first vertical slice on the current branch: typed allocation contracts, a deterministic priority allocator, SAP stock and order readers, and a persistence sink.
- Added explicit SAP table stubs for MARD, VBAP, and VBEP so Open ABAP can parse the integration SQL without pretending those tables are application-owned.
- Added the custom ZSTOCKALLOC persistence table and kept all database writes inside the Z-prefixed application boundary.
- Added ABAP Unit coverage for priority ordering, deterministic tie-breaking, and invalid negative stock.
- Added a service-level ABAP Unit test with injected stock, order, and sink doubles; the business orchestration is now verified without SAP database state.
- Added the abapGit XML wrapper and built-in datatype definitions to the standard stubs after the transpiler exposed the required DDIC shape.
- Completed the SAP persistence adapter with a guarded `MODIFY ZSTOCKALLOC` write and added a database-backed ABAP Unit test for it.
- Added a SQLite setup hook for the generated test runner so database-backed adapter tests initialize the same transpiled DDIC schema before execution.
- Added a reservation boundary using `BAPI_RESERVATION_CREATE1` and `BAPI_TRANSACTION_COMMIT`, with explicit storage location, movement type, unit, and quantity inputs.
- Integrated reservation posting into the allocation service: allocated quantity is reserved once per run, the returned document is attached to each allocated demand, and `ZSTOCKALLOC` persists it.
- Added the `ZSTOCK_ALLOCATE` report entry point with material, plant, and storage-location selection parameters.
- Added the VBAK standard stub and header join so the order source only allocates sales-order demand (`VBTYP = 'C'`); the test fixture includes an excluded quotation.
- Corrected the VBEP stub key to include `ETENR` and covered multiple schedule lines for one sales order.
- Kept report imports out of the Open ABAP runtime bootstrap because selection-screen statements are SAP-runtime features; the report remains included in lint/transpile input.
