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

`MB_BUS2017` declares the consumed `BAPI_GOODSMVT_CREATE` parameters and minimal
BAPI2017 structures. This stub also always returns an error and never writes stock
or creates a document. Mapping, simulation and error behavior are tested through
an ABAP subclass; one test exercises the real function call against the error stub.
Contract reference: [SAP goods movements with BAPI](https://help.sap.com/docs/SUPPORT_CONTENT/erpscm/3362167803.html?locale=en-US).
