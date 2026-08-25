# NOTES

## Iteration 9 (current)

### Fixed
- Unit test assertions compared `condense( |{ qty }| )` (e.g. `5`) against
  transpiled packed output `5.000`. Removed `condense`, compare against
  `'X.000'` strings directly.
- **Bug in `zcl_stub_mard=>insert_row`**: used `MODIFY TABLE gt_mard FROM is_mard`.
  The transpiler runtime does not populate `keyFields` for standard tables
  (`keyFields: []`), so the `FROM`-key lookup matched the *first* row
  unconditionally and overwrote it. Replaced with explicit
  `READ TABLE ... ASSIGNING ... WITH KEY matnr werks lgort` + `APPEND`.
- **Bug in `zcl_stock_allocator=>allocate_material`**: allocated stock was never
  consumed between order items - every item saw the full stock. Added
  `<ls_mard>-labst = <ls_mard>-labst - lv_qty_take` inside the storage location
  loop.
- `fifo_order_respected` test data/expectations were inconsistent; rewritten.

### New features
- `post_allocations( )`: posts allocations - confirms quantities on sales order
  items (`zcl_stub_sales_order=>confirm_quantity`) and reduces unrestricted
  stock (`zcl_stub_mard=>reduce_stock`, new stub method).
- Message logging: `ty_result-messages` (type `zcl_stub_message=>tt_message`).
  Each order item logs S (fully allocated), W (partial), E (no stock) with the
  simulated message class `ZSTOCK_ALLOC`.
- Report `zstock_allocation`: new `p_post` checkbox to post allocations,
  displays messages in the result list. Removed unused `p_test`.

### Test status
- abaplint: 0 issues
- transpiler unit tests: 9/9 pass

## Ideas for next iterations
- Allocation run as a single transaction over several materials with a common
  log (BAL-like), plus display of the log.
- Priority handling: urgent orders (delivery priority / document type) before FIFO.
- Locking/simulation mode: run allocation without posting (what-if).
- Replace stubs with real SAP APIs (BAPI_GOODSMVT_CREATE, BAPI_SALESORDER_CHANGE)
  behind an interface for on-prem usage.
