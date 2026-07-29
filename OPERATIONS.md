# Stock allocation operations

## Required scheduled controls

Create background variants per authorized plant. Keep simulation variants
separate from variants permitted to change the ledger.
Operational reports raise ABAP error messages after writing failure diagnostics,
so configure job monitoring to alert on cancelled/error runs as well as spool text.

1. Run `ZSALLOC_CHECK` after allocation batches and at least daily. Investigate
   any mismatch between stock-ledger reservations and summed order allocations,
   any internally inconsistent order quantity row, or any case where SAP
   confirmations plus reservations exceed physical MARD stock, before running
   further productive allocations.
   Invariant failures raise an error message so a background run is visible as a
   failed job rather than only as text in the spool.
2. Run `ZSALLOC_RECONCILE` in simulation first. Review the release quantity, then
   run the approved productive variant to release reservations unsupported by
   current sales-order schedule lines.
   For a reviewed one-off correction, use simulation-first `ZSALLOC_RELEASE` with
   the full `VBELN + POSNR + ETENR` identity instead of editing ledger tables.
3. Review `ZSALLOC_LOG` for unexpected users, plants, quantities, or event volume.
   Committed events are `ALLOCATE`, `RELEASE`, `RECONCILE`, and `LOG_RETENTION`.
4. Run `ZSALLOC_LOG_CLEANUP` first with `P_SIM = X`. Supply an explicit UTC cutoff
   timestamp derived from the organization's approved retention period. Only then
   execute the change-authorized variant. Cleanup is plant-scoped and leaves a
   retained `LOG_RETENTION` audit row containing the number of deleted records.
   Future or current cutoff timestamps are rejected.

## Alert and incident response

- Stop productive allocation jobs if `ZSALLOC_CHECK` reports an invariant error.
- Preserve the relevant `ZSALLOC_LOG` rows and job logs before corrective work.
- Run reconciliation in simulation and compare its proposed release with the
  affected order schedule lines.
- Do not edit `ZSALLOC_STOCK` or `ZSALLOC_ORDER` directly. Repair through an
  approved application operation or a separately reviewed correction program.
- Treat missing failure rows as expected: failed business LUWs roll back their
  audit inserts. Use background-job logs, dumps, and system monitoring for those
  failures.

## Rollout controls

Complete `SAP_CONCURRENCY_TEST.md` on the target database before production and
after relevant platform changes. Assign `Z_SALLOC` activity `03` to display and
simulation operators; restrict activity `02` to allocation, reconciliation, and
retention operators for their approved plants.
