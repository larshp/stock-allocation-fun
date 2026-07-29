# Target SAP deployment gate

Local verification proves portable ABAP logic and the SQLite-backed contracts. It
does not approve a target SAP system automatically. Complete and record every gate
below for each landscape.

## Before import

1. Clone/install with abapGit. The repository's `/src/` starting folder imports
   only productive content; `sap-stubs/` remains outside that boundary and must
   never replace SAP standard objects.
2. Confirm the target release accepts the repository's ABAP syntax and DDIC types.
3. Agree the availability policy with SD/MM owners. The supplied adapter is a
   conservative on-hand proxy (`MARD-LABST - eligible VBEP-BMENG - custom
   reservations`), not configured ATP. Replace the stock port with a released,
   site-approved ATP adapter if receipts, checking scopes, batches, or other ATP
   elements are required.
4. Assign a transportable package and transport request through normal governance.

## After import

1. Activate all objects and run target ATC/Code Inspector checks with the site's
   mandatory variants. Resolve findings before release.
2. Restrict direct maintenance of `ZSALLOC_STOCK`, `ZSALLOC_ORDER`, and
   `ZSALLOC_LOG`; application operators should use the reports and `Z_SALLOC`.
3. Grant activity `03` for display/simulation and activity `02` only for approved
   write operators, restricted by plant.
4. Evaluate database access with SQL Monitor/ST05 under representative volume.
   Candidate access paths to assess are `ZSALLOC_ORDER` by material/plant and
   allocation, and `ZSALLOC_LOG` by plant/creation timestamp. Create secondary
   indexes only after target-database evidence and normal DBA review.
5. Run `ZSALLOC_CHECK` on seeded test data, then complete every repetition and
   pass criterion in `SAP_CONCURRENCY_TEST.md`.
6. Schedule the simulation, reconciliation, invariant, log-review, and retention
   controls in `OPERATIONS.md`; verify failed reports trigger job monitoring.

## Release evidence

Retain the ATC result, authorization-role approval, ATP-policy decision, SQL trace
or monitor evidence, concurrency results, initial invariant output, and approved
job variants with the production change record.
