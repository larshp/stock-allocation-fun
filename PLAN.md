make a stock allocation solution in ABAP, add one feature at a time, keep improving it. It must integrate into existing SAP system and follow best practices for ABAP development.

use abaplint and transpiler for testing, record bugs and issues in ANOMALIES.md

open-abap does not include the business logic needed, add SAP standard stubs in a separate directory and include it in linting and transpiling. This includes stuff like reading stock and writing stock, reading and writing orders, etc via SAP standard APIs. Eg. database table MARD carries available stock, add it to the stubs for reading stock. All custom code starting with Z must be in the src folder.

keep your notes and progrss in NOTES.md

these abaplint rules also be enabled: modify_only_own_db_tables + align_type_expressions + easy_to_find_messages + max_one_method_parameter_per_line + align_parameters + local_testclass_consistency + allowed_object_naming + line_length

use https://github.com/open-abap/open-abap-core as a dependency in abaplint and the transpiler configurations

---

# Feature roadmap

The requirements above are the original task and stay unchanged. This section is
maintained as features are planned and delivered; the detailed per-feature log,
conventions and toolchain findings live in `NOTES.md` and `ANOMALIES.md`.

## Delivered

| #  | Feature                            | Main artefacts                                        |
| -- | ---------------------------------- | ----------------------------------------------------- |
| 1  | Read stock from MARD               | `zif_stock_reader`, `zcl_stock_reader_mard`            |
| 2  | Allocation engine                  | `zcl_stock_allocator`                                  |
| 3  | Reservation requirement source     | `zcl_requirement_reader_resb`                          |
| 4  | Facade service                     | `zcl_stock_allocation_service`                         |
| 5  | Allocation log                     | `zcl_allocation_writer_db` (`ZSTOCKALLOC`)             |
| 6  | Goods movement posting             | `zcl_allocation_poster_bapi`, `run_with_posting`       |
| 7  | Sales order requirement source     | `zcl_requirement_reader_vbap` (`VBAP`)                 |
| 8  | Batch stock and FEFO               | `zcl_stock_reader_mchb` (`MCHB`/`MCHA`), `use_fefo`    |
| 9  | Unit of measure conversion         | `zcl_uom_converter` (`MARM`)                           |
| 10 | Multi-material run                 | `zcl_stock_alloc_run`                                  |
| 11 | Allocation log reporting           | `zcl_alloc_log_reader`                                 |
| 12 | Whole sales units                  | policy `whole_sales_units`                             |
| 13 | Partial delivery control           | policy `max_picks`                                     |
| 14 | Coverage / shortage report         | `zcl_alloc_shortage_report`                            |
| 15 | Material substitution rules        | `zcl_stock_substitution` (`ZSUBSTITUTE`)               |
| 16 | Run tracking                       | `zcl_alloc_run_header` (`ZSTOCKRUN`)                   |
| 17 | Allocating across substitutes      | `allocate_materials`, `allocate_with_substitution`     |
| 18 | Under-delivery tolerance           | policy `under_tolerance`                               |
| 19 | Tolerance-aware coverage report    | `covered`, `covered_lines`                             |
| 20 | Delivery-date horizon              | policy `horizon_date`                                  |
| 21 | Safety stock (run-wide)            | policy `safety_stock`                                  |
| 22 | Run overview report                | `zcl_alloc_run_report`                                 |
| 23 | Stock commitments                  | `zcl_stock_commitment`, `zcl_stock_reader_reserved`    |
| 24 | Commit in the run flow             | `commit_allocations`, `run_with_commitment`            |
| 25 | Post and commit                    | `run_post_and_commit`                                  |
| 26 | Overview text output               | `to_lines`                                             |
| 27 | Safety stock per storage location   | `zcl_safety_stock` (`ZSAFETYSTK`)                      |
| 28 | Commitment expiry and cleanup       | `purge_before`, `purge_older_than`, `read_expired`      |
| 29 | Package-wise processing             | `run_in_packages`                                      |
| 30 | ALV-style field catalog             | `field_catalog`                                        |
| 31 | Safety stock in substitution report | `io_safety_stock` on `zcl_stock_substitution`            |
| 32 | Cleanup service with simulation     | `zcl_alloc_cleanup` (`run`, `run_before`)               |
| 33 | Request validation in the run       | `ty_stats-skipped`, `is_valid_request`                  |
| 34 | Material overview across runs       | `zcl_alloc_material_report` (`ZSTOCKALLOC`+`ZSTOCKRUN`) |
| 35 | Minimum remaining shelf life        | policy `min_remaining_days`, `reference_date`           |
| 36 | Storage location allow / exclude    | policy `allowed_lgorts`, `excluded_lgorts`              |
| 37 | Replenishment proposals             | `zcl_alloc_replenishment` (rounding, min order)         |
| 38 | Run reversal / audit trail          | `reverse_run`, status `X`, `read_active`, reports skip  |
| 39 | Plant-to-plant transfer proposal    | `zcl_stock_transfer` (`propose`, `available`)           |
| 40 | Allocation result diff              | `zcl_alloc_diff` (added / removed / changed lines)      |
| 41 | Allocation overview JSON export     | `zcl_alloc_export` (`run_overview_json`, material)       |
| 42 | Batch availability inquiry          | `zcl_batch_inquiry` (FEFO order, total, earliest expiry) |
| 43 | Reservation document service        | `zcl_reservation_doc` (create, items, summarize, release)|

## Next

Ordered. Items are chosen so that `npm test` can verify them; steps that need a
GUI or a selection screen cannot be exercised by the transpiler and are kept at
the end on purpose.

| Order | Feature                                          | Notes                                                                |
| ----- | ------------------------------------------------ | -------------------------------------------------------------------- |
| 44    | ALV grid binding and selection-screen wrapper    | GUI layer - NOT verifiable with the transpiler, only on request       |

