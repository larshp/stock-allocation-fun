# Anomalies

No confirmed product defects are open.

## Tooling and environment observations

- The open-abap runtime provides an emulated database for unit testing, not SAP locking, update-task, authorization, or BAPI transactional behavior. Productive SAP integration still requires an integration test in the target system.
- The SAP-standard DDIC files under `sap_stubs` intentionally contain only fields used by this feature. They are compilation stubs and must never be imported into SAP.
- Initial local verification pinned transpiler/runtime 2.11.0, whose parser could not resolve the current interface table types. The project now pins 2.13.47; the global tool had masked this mismatch during the first run.
