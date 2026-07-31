# Anomalies and known issues

## 2026-07-31

- Resolved: the local DDIC stubs initially omitted the abapGit wrapper and used unresolved SAP data elements. The stubs now use the standard wrapper plus built-in DDIC types and transpile successfully.
- Resolved: Open ABAP does not accept the attempted global SAP class stub in the application input set. The reservation adapter now calls the real SAP function-module names, while the test harness installs isolated FM doubles from `sap_stubs/`.
- Resolved: Open ABAP cannot execute selection-screen `PARAMETERS` in the generated Node harness. `importProg` is disabled for the transpiler bootstrap; the `ZSTOCK_ALLOCATE` report is still linted and transpiled for SAP deployment.
- Resolved: Open ABAP selects map result columns by name in the SQLite runtime. The order-source query now aliases SAP fields such as `LPRIO` and `WMENG` to the application structure names.
- Known limitation: the current reservation contract posts one aggregate reservation per allocation run and associates that document with every allocated line; line-level SAP reservation linkage is not modeled yet.
