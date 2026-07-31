# Progress notes

## 2026-07-31

- Established the first vertical slice on the current branch: typed allocation contracts, a deterministic priority allocator, SAP stock and order readers, and a persistence sink.
- Added explicit SAP table stubs for MARD, VBAP, and VBEP so Open ABAP can parse the integration SQL without pretending those tables are application-owned.
- Added the custom ZSTOCKALLOC persistence table and kept all database writes inside the Z-prefixed application boundary.
- Added ABAP Unit coverage for priority ordering, deterministic tie-breaking, and invalid negative stock.
