# SAP standard stubs

These minimal DDIC definitions represent only the SAP fields consumed by this
library. They are linted and transpiled alongside src but excluded from abapGit
installation. Never import them into SAP or replace SAP standard objects.

MARD supplies unrestricted stock by client, material, plant and storage location;
MARA supplies its base unit. The SQLite test setup provides isolated sample rows.
These definitions do not reproduce SAP business logic, ATP, authorizations or locks.

RESB represents order component requirements. `MB_BUS2093` declares the consumed
subset of `BAPI_RESERVATION_CREATE1` and its BAPI2093 structures. Its implementation
always returns an error, including in test mode. Successful mapping/error handling
tests use a local ABAP subclass; the real function call is tested against this
failing stub. See ANOMALIES.md for the scoped generated-JavaScript RETURN workaround.
