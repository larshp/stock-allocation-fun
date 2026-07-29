# Target SAP concurrency verification

This procedure is a required rollout gate because open-abap cannot emulate
separate SAP work-process system fields or the target database's lock behavior.

## Preconditions

1. Use a non-production client and a disposable material/plant with known MARD
   unrestricted stock and at least two open VBEP schedule lines.
2. Grant both test users `Z_SALLOC`, activity `02`, for only the test plant.
3. Run `ZSALLOC_RECONCILE` in write mode and confirm `ZSALLOC_CHECK` reports OK.
4. Record the initial rows in `ZSALLOC_STOCK`, `ZSALLOC_ORDER`, and `ZSALLOC_LOG`.

## Two-session test

1. Open `ZSALLOC_RUN` in two independent SAP GUI sessions using different users.
2. Enter the same material and plant and clear simulation in both sessions.
3. Execute both sessions as closely together as possible. Repeat at least 20 times,
   including cases where each run requests more than half the available stock.
4. After every pair, run `ZSALLOC_CHECK` and `ZSALLOC_LOG`.
5. Before the next pair, release committed test allocations through
   `ZSALLOC_RELEASE` and verify `ZSALLOC_CHECK` is back at the recorded baseline.
   Use fresh eligible schedule lines when needed; otherwise later rounds may only
   test the no-stock path rather than contention.

The test passes only when:

- SAP-confirmed quantity plus `ZSALLOC_STOCK-RESERVED` never exceeds summed
  `MARD-LABST`;
- `ZSALLOC_STOCK-RESERVED` equals summed `ZSALLOC_ORDER-ALLOCATED`;
- each committed per-order allocation has a matching `ZSALLOC_LOG` row;
- a losing request returns a controlled integration error rather than a dump;
- no lost updates or duplicate schedule-line allocations occur.

## Cleanup

Release test allocations through `ZSALLOC_RELEASE`, run reconciliation, and verify
`ZSALLOC_CHECK`. Do not delete ledger rows directly because that bypasses the stock
aggregate and audit log.
