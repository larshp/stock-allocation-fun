# Anomalies and known issues

## 2026-07-31

- The transpiler currently reports the local `ZSTOCKALLOC` DDIC XML as componentless even though abaplint accepts the XML. The SAP sink currently validates the allocation contract only; mapping it to the SAP reservation/BAPI write remains the next integration feature.
