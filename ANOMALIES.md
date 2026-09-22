# Anomalies

Known scope limitation: the local `MARD` dictionary definition models only the
fields used by the stock read. The SAP system's delivered `MARD` definition is
authoritative at deployment time.

## Resolved

- The transpiler rejects ABAP method names longer than 30 characters even when
  abaplint accepts them. The allocation unit test name was shortened to comply.
