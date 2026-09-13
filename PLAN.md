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
| 43 | Reservation document service        | `zcl_reservation_doc` (create, items, summarize, release)|| 44    | CSV quoting and line builder        | `zcl_alloc_csv` (`quote`, `build_line`)                  |
| 45    | Fixed-width text table renderer     | `zcl_alloc_fixed_width` (`pad`, `build_line`)            |
| 46    | Markdown table for the run overview | `zcl_alloc_markdown` (`run_overview`)                    |
| 47    | HTML table for the run overview     | `zcl_alloc_html` (`run_overview`, `escape`)              |
| 48    | XML document for the run overview   | `zcl_alloc_xml` (`run_overview`, `escape`)               |
| 49    | JSON for the shortage report        | `zcl_alloc_shortage_json` (`build`)                      |
| 50    | JSON for the replenishment proposals| `zcl_alloc_replen_json` (`build`)                        |
| 51    | JSON for the allocation diff        | `zcl_alloc_diff_json` (`build`)                          |
| 52    | CSV for the shortage report         | `zcl_alloc_shortage_csv` (`build`)                       |
| 53    | CSV for the replenishment proposals | `zcl_alloc_replen_csv` (`build`)                         |
| 54    | Number and quantity formatting      | `zcl_alloc_number_format` (`format_qty`, `trim_zeros`)   |
| 55    | Percentage formatting and parsing   | `zcl_alloc_percent` (`ratio`, `apply`, `format`)         |
| 56    | Duration (seconds) formatting       | `zcl_alloc_duration` (`to_text`, `to_seconds`)           |
| 57    | Text alignment and padding          | `zcl_alloc_align` (`left_value`, `right_value`, `center_value`) |
| 58    | Allocation KPI summary              | `zcl_alloc_kpi` (`summarize`)                            |
| 59    | ABC classification of materials     | `zcl_alloc_abc` (`classify`)                             |
| 60    | Top-N materials by allocated quantity| `zcl_alloc_top_n` (`top`)                                |
| 61    | Quantity histogram / buckets         | `zcl_alloc_histogram` (`build`)                          |
| 62    | Demand variance across runs          | `zcl_alloc_demand_variance` (`analyze`)                  |
| 63    | Moving average of allocated quantity | `zcl_alloc_moving_average` (`calculate`)                 |
| 64    | Trend detection (up / down / flat)   | `zcl_alloc_trend` (`analyze`)                            |
| 65    | Simple forecast of the next quantity | `zcl_alloc_forecast` (`next_quantity`)                   |
| 66    | Service level (fill rate) per material| `zcl_alloc_service_level` (`summarize`)                  |
| 67    | Running totals over a result list     | `zcl_alloc_running_total` (`calculate`)                  |
| 68    | Confidence score for an allocation    | `zcl_alloc_confidence` (`assess`)                        |
| 69    | Risk score for a shortage list        | `zcl_alloc_risk` (`assess`)                              |
| 70    | Request validator (material, plant, qty)| `zcl_alloc_request_validator` (`validate`)              |
| 71    | Policy validator                       | `zcl_alloc_policy_validator` (`validate`)                |
| 72    | Allocation consistency check           | `zcl_alloc_consistency` (`check`)                        |
| 73    | Duplicate requirement detection        | `zcl_alloc_duplicate_check` (`find`)                     |
| 74    | Stock row data quality check           | `zcl_alloc_stock_check` (`check`)                        |
| 75    | Negative quantity detector             | `zcl_alloc_negative_check` (`find`)                      |
| 76    | Over-allocation detector               | `zcl_alloc_over_check` (`find`)                          |
| 77    | Missing master data check              | `zcl_alloc_master_check` (`check`)                       |
| 78    | Priority scoring from weighted rules   | `zcl_alloc_priority` (`score`)                           |
| 79    | Stock sequencing (FIFO / LIFO)         | `zcl_alloc_sequence` (`order`)                           |
| 80    | Round-robin fair share                 | `zcl_alloc_round_robin` (`distribute`)                   |
| 81    | Proportional (pro-rata) allocation     | `zcl_alloc_proportional` (`distribute`)                  |
| 82    | Max-min fair allocation                | `zcl_alloc_maxmin` (`allocate`)                          |
| 83    | Capacity-constrained allocation        | `zcl_alloc_capacity` (`allocate`)                        |
| 84    | Load balancing across plants           | `zcl_alloc_load_balance` (`balance`)                     |
| 85    | Requirement merge (same key)           | `zcl_alloc_req_merge` (`merge`)                          |
| 86    | Requirement split by size              | `zcl_alloc_req_split` (`split`)                          |
| 87    | Requirement grouping by material       | `zcl_alloc_req_group` (`group`)                          |
| 88    | Requirement netting against stock      | `zcl_alloc_req_net` (`net`)                              |
| 89    | Reorder point calculation              | `zcl_alloc_reorder_point` (`calculate`)                  |
| 90    | Economic order quantity (EOQ)          | `zcl_alloc_eoq` (`calculate`)                            |
| 91    | Days of supply / stock cover           | `zcl_alloc_days_supply` (`calculate`)                    |
| 92    | Stock turn rate                        | `zcl_alloc_turn_rate` (`calculate`)                      |
| 93    | Inventory value at a price             | `zcl_alloc_inventory_value` (`calculate`)                |
| 94    | Weighted average price                 | `zcl_alloc_avg_price` (`calculate`)                      |
| 95    | Quantity rounding utilities            | `zcl_alloc_rounding` (`round_to`, `round_up_to`, `round_down_to`) |
| 96    | Storage location ranking by quantity   | `zcl_alloc_location_rank` (`rank`)                       |
| 97    | Consolidation (bin emptying) proposal  | `zcl_alloc_consolidation` (`propose`)                    |
| 98    | Pick sequence within a plant           | `zcl_alloc_pick_sequence` (`sequence`)                   |
| 99    | Bin replenishment trigger              | `zcl_alloc_bin_replenish` (`propose`)                    |
| 100   | Picking list from an allocation        | `zcl_alloc_pick_list` (`build`)                          |
| 101   | Picking list confirmation              | `zcl_alloc_pick_confirm` (`confirm`)                     |
| 102   | Location scoring for selection         | `zcl_alloc_location_score` (`score`)                     |
| 103   | Working-day calendar                   | `zcl_alloc_calendar` (`add_working_days`, `is_weekend`)  |
| 104   | Date range splitting                   | `zcl_alloc_date_range` (`split`)                         |
| 105   | Age of stock in days                   | `zcl_alloc_stock_age` (`calculate`)                      |
| 106   | Backlog aging buckets                  | `zcl_alloc_aging` (`bucket`)                             |
| 107   | Time slot assignment                   | `zcl_alloc_slot` (`assign`)                              |
| 108   | Wave planning                          | `zcl_alloc_wave` (`plan`)                                |
| 109   | Material batching for picking          | `zcl_alloc_batching` (`build`)                           |
| 110   | Per-plant report across runs           | `zcl_alloc_plant_report` (`summarize`)                   |
| 111   | Per-day report across runs             | `zcl_alloc_daily_report` (`summarize`)                   |
| 112   | Material x plant pivot                 | `zcl_alloc_pivot` (`build`)                              |
| 113   | Material x run matrix                  | `zcl_alloc_matrix` (`build`)                             |
| 114   | Shipment grouping                      | `zcl_alloc_shipment` (`build`)                           |
| 115   | Delivery split proposal                | `zcl_alloc_delivery_split` (`split`)                     |
| 116   | SLA compliance report                  | `zcl_alloc_sla` (`assess`)                               |
| 117   | Event timeline                         | `zcl_alloc_timeline` (`to_lines`)                        |
| 118   | Search / text filter over overviews    | `zcl_alloc_search` (`filter`)                            |
| 119   | Pagination helper                      | `zcl_alloc_paging` (`page`)                              |
| 120   | Generic sort helper for overviews      | `zcl_alloc_sort` (`sort`)                                |
| 121   | Policy presets                         | `zcl_alloc_policy_preset` (`preset`)                     |
| 122   | Policy merge                           | `zcl_alloc_policy_merge` (`merge`)                       |
| 123   | Policy diff                            | `zcl_alloc_policy_diff` (`compare`)                      |
| 124   | Run comparison summary                 | `zcl_alloc_run_compare` (`compare`)                      |
| 125   | Three-way allocation diff              | `zcl_alloc_diff3` (`compare`)                            |
| 126   | Allocation snapshot and compare        | `zcl_alloc_snapshot` (`take`, `compare`)                 |
| 127   | Checksum of an allocation result       | `zcl_alloc_checksum` (`of_result`)                       |
| 128   | Run / requirement id generator         | `zcl_alloc_id_gen` (`generate`)                          |
| 129   | Run tagging (in-memory)                | `zcl_alloc_tag` (`add`, `of_run`)                        |
| 130   | Annotation store (in-memory)           | `zcl_alloc_annotation` (`add`, `read`)                   |
| 131   | Substitution chain resolver            | `zcl_alloc_subst_chain` (`resolve`)                      |
| 132   | Multi-plant availability aggregation   | `zcl_alloc_multi_plant` (`summarize`)                    |
| 133   | Transport cost comparison              | `zcl_alloc_transport_cost` (`rank`)                      |
| 134   | Cost-based source selection            | `zcl_alloc_cost` (`select`)                              |
| 135   | Footprint estimate for a transfer      | `zcl_alloc_footprint` (`estimate`)                       |
| 136   | Weighted source scoring                | `zcl_alloc_weight` (`score`)                             |
| 137   | Material list from run headers         | `zcl_alloc_material_list` (`build`)                      |
| 138   | Plant list from run headers            | `zcl_alloc_plant_list` (`build`)                         |
| 139   | Storage location list from a result    | `zcl_alloc_lgort_list` (`build`)                         |
| 140   | Quantity bucket helper                 | `zcl_alloc_bucket` (`bucket`)                            |
| 141   | Batch split proposal                   | `zcl_alloc_batch_split` (`split`)                        |
| 142   | Allocation quality grade (A-F)         | `zcl_alloc_grade` (`grade`)                              |
| 144   | CSV of the per-run allocations         | `zcl_alloc_export_alloc` (`build`)                       |
| 145   | CSV of the per-material allocations    | `zcl_alloc_export_alloc_mat` (`build`)                   |
| 146   | JSON of the per-run allocations        | `zcl_alloc_export_alloc_json` (`build`)                  |
| 147   | JSON of the per-material allocations   | `zcl_alloc_export_alloc_mjson` (`build`)                 |
| 148   | XML of the allocations                 | `zcl_alloc_export_alloc_xml` (`build`)                   |
| 149   | Markdown of the allocations            | `zcl_alloc_export_alloc_md` (`build`)                    |
| 150   | HTML of the allocations                | `zcl_alloc_export_alloc_html` (`build`)                  |
| 151   | Fixed-width of the allocations         | `zcl_alloc_export_alloc_fw` (`build`)                    |
| 152   | CSV of the allocation diff             | `zcl_alloc_diff_csv` (`build`)                           |
| 153   | CSV of the run comparison              | `zcl_alloc_run_cmp_csv` (`build`)                        |
| 154   | JSON of the run comparison             | `zcl_alloc_run_cmp_json` (`build`)                       |
| 155   | CSV of the SLA report                  | `zcl_alloc_sla_csv` (`build`)                            |
| 156   | JSON of the SLA report                 | `zcl_alloc_sla_json` (`build`)                           |
| 157   | CSV of the aging report                | `zcl_alloc_aging_csv` (`build`)                          |
| 158   | JSON of the aging report               | `zcl_alloc_aging_json` (`build`)                         |
| 159   | CSV of the plant report                | `zcl_alloc_plant_csv` (`build`)                          |
| 160   | CSV of the daily report                | `zcl_alloc_daily_csv` (`build`)                          |
| 161   | JSON of the plant report               | `zcl_alloc_plant_json` (`build`)                         |
| 162   | JSON of the daily report               | `zcl_alloc_daily_json` (`build`)                         |
| 163   | CSV of the KPI summary                 | `zcl_alloc_kpi_csv` (`build`)                            |
| 164   | JSON of the KPI summary                | `zcl_alloc_kpi_json` (`build`)                           |
| 165   | CSV of the ABC classification          | `zcl_alloc_abc_csv` (`build`)                            |
| 166   | JSON of the ABC classification         | `zcl_alloc_abc_json` (`build`)                           |
| 167   | CSV of the histogram                   | `zcl_alloc_hist_csv` (`build`)                           |
| 168   | JSON of the histogram                  | `zcl_alloc_hist_json` (`build`)                          |
| 169   | CSV of the top-N list                  | `zcl_alloc_topn_csv` (`build`)                           |
| 170   | JSON of the top-N list                 | `zcl_alloc_topn_json` (`build`)                          |
| 171   | CSV of the moving average              | `zcl_alloc_mavg_csv` (`build`)                           |
| 172   | JSON of the moving average             | `zcl_alloc_mavg_json` (`build`)                          |
| 173   | CSV of the trend analysis              | `zcl_alloc_trend_csv` (`build`)                          |
| 174   | JSON of the trend analysis             | `zcl_alloc_trend_json` (`build`)                         |
| 175   | CSV of the forecast                    | `zcl_alloc_forecast_csv` (`build`)                       |
| 176   | JSON of the forecast                   | `zcl_alloc_forecast_json` (`build`)                      |
| 177   | CSV of the service level               | `zcl_alloc_service_csv` (`build`)                        |
| 178   | JSON of the service level              | `zcl_alloc_service_json` (`build`)                       |
| 179   | CSV of the confidence score            | `zcl_alloc_conf_csv` (`build`)                           |
| 180   | JSON of the confidence score           | `zcl_alloc_conf_json` (`build`)                          |
| 181   | CSV of the risk score                  | `zcl_alloc_risk_csv` (`build`)                           |
| 182   | JSON of the risk score                 | `zcl_alloc_risk_json` (`build`)                          |
| 183   | CSV of the request validation          | `zcl_alloc_reqval_csv` (`build`)                         |
| 184   | JSON of the request validation         | `zcl_alloc_reqval_json` (`build`)                        |
| 185   | CSV of the policy validation           | `zcl_alloc_polval_csv` (`build`)                         |
| 186   | JSON of the policy validation          | `zcl_alloc_polval_json` (`build`)                        |
| 187   | CSV of the consistency check           | `zcl_alloc_consist_csv` (`build`)                        |
| 188   | JSON of the consistency check          | `zcl_alloc_consist_json` (`build`)                       |
| 189   | CSV of the duplicate check             | `zcl_alloc_dupc_csv` (`build`)                           |
| 190   | JSON of the duplicate check            | `zcl_alloc_dupc_json` (`build`)                          |
| 191   | CSV of the stock check                 | `zcl_alloc_stockchk_csv` (`build`)                       |
| 192   | JSON of the stock check                | `zcl_alloc_stockchk_json` (`build`)                      |
| 193   | CSV of the negative check              | `zcl_alloc_negchk_csv` (`build`)                         |
| 194   | JSON of the negative check             | `zcl_alloc_negchk_json` (`build`)                        |
| 195   | CSV of the over-allocation check       | `zcl_alloc_overchk_csv` (`build`)                        |
| 196   | JSON of the over-allocation check      | `zcl_alloc_overchk_json` (`build`)                       |
| 197   | CSV of the master data check           | `zcl_alloc_mastchk_csv` (`build`)                        |
| 198   | JSON of the master data check          | `zcl_alloc_mastchk_json` (`build`)                       |
| 199   | CSV of the priority list               | `zcl_alloc_prio_csv` (`build`)                           |
| 200   | JSON of the priority list              | `zcl_alloc_prio_json` (`build`)                          |
| 201   | CSV of the pick list                   | `zcl_alloc_pickl_csv` (`build`)                          |
| 202   | JSON of the pick list                  | `zcl_alloc_pickl_json` (`build`)                         |
| 203   | CSV of the pick confirmation           | `zcl_alloc_pickc_csv` (`build`)                          |
| 204   | JSON of the pick confirmation          | `zcl_alloc_pickc_json` (`build`)                         |
| 205   | CSV of the pick sequence               | `zcl_alloc_picks_csv` (`build`)                          |
| 206   | JSON of the pick sequence              | `zcl_alloc_picks_json` (`build`)                         |
| 207   | CSV of the location ranking            | `zcl_alloc_lrank_csv` (`build`)                          |
| 208   | JSON of the location ranking           | `zcl_alloc_lrank_json` (`build`)                         |
| 209   | CSV of the location score              | `zcl_alloc_lscore_csv` (`build`)                         |
| 210   | JSON of the location score             | `zcl_alloc_lscore_json` (`build`)                        |
| 211   | CSV of the shipments                   | `zcl_alloc_ship_csv` (`build`)                           |
| 212   | JSON of the shipments                  | `zcl_alloc_ship_json` (`build`)                          |
| 213   | CSV of the waves                       | `zcl_alloc_wave_csv` (`build`)                           |
| 214   | JSON of the waves                      | `zcl_alloc_wave_json` (`build`)                          |
| 215   | CSV of the batches                     | `zcl_alloc_batch_csv` (`build`)                          |
| 216   | JSON of the batches                    | `zcl_alloc_batch_json` (`build`)                         |
| 217   | CSV of the tags                        | `zcl_alloc_tag_csv` (`build`)                            |
| 218   | JSON of the tags                       | `zcl_alloc_tag_json` (`build`)                           |
| 219   | CSV of the annotations                 | `zcl_alloc_note_csv` (`build`)                           |
| 220   | JSON of the annotations                | `zcl_alloc_note_json` (`build`)                          |
| 221   | CSV of the timeline                    | `zcl_alloc_timeline_csv` (`build`)                       |
| 222   | JSON of the timeline                   | `zcl_alloc_timeline_json` (`build`)                      |
| 223   | CSV of the snapshot diff               | `zcl_alloc_snap_csv` (`build`)                           |
| 224   | JSON of the snapshot diff              | `zcl_alloc_snap_json` (`build`)                          |
| 225   | CSV of the three-way diff              | `zcl_alloc_diff3_csv` (`build`)                          |
| 226   | JSON of the three-way diff             | `zcl_alloc_diff3_json` (`build`)                         |
| 227   | CSV of the cost selection              | `zcl_alloc_cost_csv` (`build`)                           |
| 228   | JSON of the cost selection             | `zcl_alloc_cost_json` (`build`)                          |
| 229   | CSV of the transport costs             | `zcl_alloc_tcost_csv` (`build`)                          |
| 230   | JSON of the transport costs            | `zcl_alloc_tcost_json` (`build`)                         |
| 231   | CSV of the substitution chain          | `zcl_alloc_subst_csv` (`build`)                          |
| 232   | JSON of the substitution chain         | `zcl_alloc_subst_json` (`build`)                         |
| 233   | CSV of the multi-plant summary         | `zcl_alloc_mplant_csv` (`build`)                         |
| 234   | JSON of the multi-plant summary        | `zcl_alloc_mplant_json` (`build`)                        |
| 235   | CSV of the grade distribution          | `zcl_alloc_grade_csv` (`build`)                          |
| 236   | JSON of the grade distribution         | `zcl_alloc_grade_json` (`build`)                         |
| 237   | CSV of the bucket report               | `zcl_alloc_bucket_csv` (`build`)                         |
| 238   | JSON of the bucket report              | `zcl_alloc_bucket_json` (`build`)                        |
| 239   | Unified export facade                  | `zcl_alloc_export_facade` (`as_csv`, `as_json`)          |
| 240   | Export format registry                 | `zcl_alloc_format_registry` (`add`)                      |
| 241   | Default export format per consumer     | `zcl_alloc_format_default` (`default_for`)               |
| 242   | Export registry lookup by name         | `zcl_alloc_format_lookup` (`lookup`)                     |
| 243   | Export registry listing                | `zcl_alloc_format_list` (`names`, `count`)               |

**Roadmap batch 2 is complete: orders 144-243 (100 features) are all delivered
and verified.** The only unbuilt item across both batches remains 143 (ALV grid
binding + selection screen), which the transpiler cannot exercise.

## Roadmap batch 3 (orders 244-343)

Planned when batch 2 completed, per the standing instruction. The theme is
**SAP integration and operations**: locking, number ranges, change documents,
application log, message and exception handling, BAPI/RFC/IDoc and batch-input
stubs, commit/rollback and retry policies, timers and statistics, execution
context, feature flags and configuration, masking, authorization stubs, caching,
streaming, idempotency and reconciliation. Each item is a new `zcl_alloc_*` class
with a local test class, verified by `npm test`.

| Order | Feature | Owner |
| --- | --- | --- |
| 244 | Lock manager abstraction | `zcl_alloc_lock` |
| 245 | Enqueue wrapper | `zcl_alloc_enqueue` |
| 246 | Dequeue wrapper | `zcl_alloc_dequeue` |
| 247 | Number range interval reader | `zcl_alloc_number_range` |
| 248 | Number range writer (in-memory) | `zcl_alloc_number_range_w` |
| 249 | Change document writer (in-memory) | `zcl_alloc_change_doc` |
| 250 | Change document reader | `zcl_alloc_change_read` |
| 251 | Application log writer | `zcl_alloc_app_log` |
| 252 | Application log reader | `zcl_alloc_app_log_read` |
| 253 | Message collector | `zcl_alloc_messages` |
| 254 | Message formatter | `zcl_alloc_msg_format` |
| 255 | Error handler | `zcl_alloc_error` |
| 256 | Exception mapper | `zcl_alloc_exception_map` |
| 257 | BAPI goods movement wrapper | `zcl_alloc_bapi_gm` |
| 258 | BAPI availability wrapper | `zcl_alloc_bapi_atp` |
| 259 | BAPI material read wrapper | `zcl_alloc_bapi_mat` |
| 260 | BAPI plant read wrapper | `zcl_alloc_bapi_plant` |
| 261 | BAPI caller facade | `zcl_alloc_bapi_facade` |
| 262 | RFC destination stub | `zcl_alloc_rfc` |
| 263 | IDoc writer | `zcl_alloc_idoc_writer` |
| 264 | IDoc reader | `zcl_alloc_idoc_reader` |
| 265 | Batch input session builder | `zcl_alloc_bdc_build` |
| 266 | Batch input session runner (stub) | `zcl_alloc_bdc_run` |
| 267 | Update task stub | `zcl_alloc_update_task` |
| 268 | Commit / rollback wrapper | `zcl_alloc_commit` |
| 269 | Timeout guard | `zcl_alloc_timeout` |
| 270 | Retry policy | `zcl_alloc_retry` |
| 271 | Circuit breaker | `zcl_alloc_breaker` |
| 272 | Rate limiter (in-memory) | `zcl_alloc_rate_limit` |
| 273 | Audit trail | `zcl_alloc_audit` |
| 274 | Operation log | `zcl_alloc_op_log` |
| 275 | Performance timer | `zcl_alloc_timer` |
| 276 | Stopwatch | `zcl_alloc_stopwatch` |
| 277 | Run statistics collector | `zcl_alloc_stats` |
| 278 | Session context | `zcl_alloc_session` |
| 279 | User context | `zcl_alloc_user` |
| 280 | Client context | `zcl_alloc_client` |
| 281 | Environment info | `zcl_alloc_environment` |
| 282 | Feature flag registry | `zcl_alloc_flags` |
| 283 | Configuration reader | `zcl_alloc_config` |
| 284 | Configuration writer (in-memory) | `zcl_alloc_config_w` |
| 285 | Configuration validation | `zcl_alloc_config_val` |
| 286 | Secret masking | `zcl_alloc_secret_mask` |
| 287 | Data masking | `zcl_alloc_mask` |
| 288 | Pseudonymization helper | `zcl_alloc_pseudo` |
| 289 | Archive metadata | `zcl_alloc_archive_meta` |
| 290 | Archive index | `zcl_alloc_archive_idx` |
| 291 | Retention policy | `zcl_alloc_retention` |
| 292 | Deletion policy | `zcl_alloc_deletion` |
| 293 | Tenant isolation helper | `zcl_alloc_tenant` |
| 294 | Multi-client guard | `zcl_alloc_mandt_guard` |
| 295 | Authorization check stub | `zcl_alloc_auth` |
| 296 | Role mapping | `zcl_alloc_role_map` |
| 297 | Permission matrix | `zcl_alloc_permission` |
| 298 | Field-level authorization | `zcl_alloc_field_auth` |
| 299 | Data access log | `zcl_alloc_access_log` |
| 300 | Export audit log | `zcl_alloc_export_audit` |
| 301 | CSV import reader | `zcl_alloc_import_csv` |
| 302 | JSON import reader | `zcl_alloc_import_json` |
| 303 | Import validator | `zcl_alloc_import_val` |
| 304 | Import mapper | `zcl_alloc_import_map` |
| 305 | Bulk loader | `zcl_alloc_bulk_load` |
| 306 | Bulk validity check | `zcl_alloc_bulk_check` |
| 307 | Delta loader | `zcl_alloc_delta_load` |
| 308 | Upsert helper (in-memory) | `zcl_alloc_upsert` |
| 309 | Dedupe key builder | `zcl_alloc_dedupe_key` |
| 310 | Natural key builder | `zcl_alloc_natural_key` |
| 311 | Surrogate key map | `zcl_alloc_surrogate` |
| 312 | Reference data cache | `zcl_alloc_ref_cache` |
| 313 | Cache invalidation policy | `zcl_alloc_cache_policy` |
| 314 | Cache statistics | `zcl_alloc_cache_stats` |
| 315 | Cache warm-up helper | `zcl_alloc_cache_warm` |
| 316 | Lazy loader | `zcl_alloc_lazy` |
| 317 | Pagination cursor | `zcl_alloc_cursor` |
| 318 | Chunked reader | `zcl_alloc_chunk_read` |
| 319 | Chunked writer | `zcl_alloc_chunk_write` |
| 320 | Backpressure helper | `zcl_alloc_backpressure` |
| 321 | Batch size tuner | `zcl_alloc_batch_tune` |
| 322 | Concurrency guard | `zcl_alloc_concurrency` |
| 323 | Idempotency key | `zcl_alloc_idem_key` |
| 324 | Exactly-once guard | `zcl_alloc_once` |
| 325 | Dedupe window | `zcl_alloc_dedupe_win` |
| 326 | Sequential numbering | `zcl_alloc_seq_num` |
| 327 | Gap detection | `zcl_alloc_gap_check` |
| 328 | Sequence validation | `zcl_alloc_seq_check` |
| 329 | Checksum registry | `zcl_alloc_checksum_reg` |
| 330 | Integrity check | `zcl_alloc_integrity` |
| 331 | Reconciliation report | `zcl_alloc_reconcile` |
| 332 | Drift detection | `zcl_alloc_drift` |
| 333 | Heavy snapshot comparison | `zcl_alloc_snap_heavy` |
| 334 | Restore helper | `zcl_alloc_restore` |
| 335 | Migration mapper | `zcl_alloc_migration_map` |
| 336 | Migration validator | `zcl_alloc_migration_val` |
| 337 | Cutover checklist | `zcl_alloc_cutover` |
| 338 | Parallel run comparison | `zcl_alloc_parallel_run` |
| 339 | Data volume estimator | `zcl_alloc_volume` |
| 340 | Load test helper | `zcl_alloc_load_test` |
| 341 | Smoke test runner | `zcl_alloc_smoke` |
| 342 | Health check | `zcl_alloc_health` |
| 343 | Readiness probe | `zcl_alloc_readiness` |

### Batch 3 delivered so far

| Order | Feature | Owner |
| --- | --- | --- |
| 244 | Lock manager abstraction | `zcl_alloc_lock` (`acquire`, `release`, `is_locked`) |
| 245 | Enqueue wrapper | `zcl_alloc_enqueue` (`enqueue`) |
| 246 | Dequeue wrapper | `zcl_alloc_dequeue` (`dequeue`, `distinct_count`) |
| 247 | Number range interval reader | `zcl_alloc_number_range` (`next`, `in_range`, `remaining`) |
| 248 | Number range writer (in-memory) | `zcl_alloc_number_range_w` (`reserve`, `exhausted`) |
| 249 | Change document writer (in-memory) | `zcl_alloc_change_doc` (`add`) |
| 250 | Change document reader | `zcl_alloc_change_read` (`of_object`, `field_count`) |
| 251 | Application log writer | `zcl_alloc_app_log` (`write`, `count_of_level`) |
| 252 | Application log reader | `zcl_alloc_app_log_read` (`messages`, `has_errors`) |
| 253 | Message collector | `zcl_alloc_messages` (`collect`, `count`) |
| 254 | Message formatter | `zcl_alloc_msg_format` (`format`, `short`) |
| 255 | Error handler | `zcl_alloc_error` (`raise`, `has_any`) |
| 256 | Exception mapper | `zcl_alloc_exception_map` (`map`) |
| 257 | BAPI goods movement wrapper | `zcl_alloc_bapi_gm` (`post`) |
| 258 | BAPI availability wrapper | `zcl_alloc_bapi_atp` (`check`) |
| 259 | BAPI material read wrapper | `zcl_alloc_bapi_mat` (`read`) |
| 260 | BAPI plant read wrapper | `zcl_alloc_bapi_plant` (`read`) |
| 261 | BAPI caller facade | `zcl_alloc_bapi_facade` (`call`) |
| 262 | RFC destination stub | `zcl_alloc_rfc` (`ping`, `describe`) |
| 263 | IDoc writer | `zcl_alloc_idoc_writer` (`create`) |
| 264 | IDoc reader | `zcl_alloc_idoc_reader` (`read`) |
| 265 | Batch input session builder | `zcl_alloc_bdc_build` (`add`) |
| 266 | Batch input session runner (stub) | `zcl_alloc_bdc_run` (`run`) |
| 267 | Update task stub | `zcl_alloc_update_task` (`queue`, `flush`) |
| 268 | Commit / rollback wrapper | `zcl_alloc_commit` (`commit`, `rollback`) |
## Roadmap

The next 100 features, in build order. Items 44-141 are pure calculation,
formatting, validation, scheduling or in-memory services, so `npm test` can
verify every one of them. The last item needs a GUI and is deliberately kept
last because the transpiler cannot exercise a selection screen.

### Text and export

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 44    | CSV field quoting and line builder     | `zcl_alloc_csv`                        |
| 45    | Fixed-width text table renderer        | `zcl_alloc_fixed_width`                |
| 46    | Markdown table for the run overview    | `zcl_alloc_markdown`                   |
| 47    | HTML table for the run overview        | `zcl_alloc_html`                       |
| 48    | XML document for the run overview      | `zcl_alloc_xml`                        |
| 49    | JSON for the shortage report           | `zcl_alloc_shortage_json`              |
| 50    | JSON for the replenishment proposals   | `zcl_alloc_replen_json`                |
| 51    | JSON for the allocation diff           | `zcl_alloc_diff_json`                  |
| 52    | CSV for the shortage report            | `zcl_alloc_shortage_csv`               |
| 53    | CSV for the replenishment proposals    | `zcl_alloc_replen_csv`                 |
| 54    | Number and quantity formatting         | `zcl_alloc_number_format`              |
| 55    | Percentage formatting and parsing      | `zcl_alloc_percent`                    |
| 56    | Duration (seconds) formatting          | `zcl_alloc_duration`                   |
| 57    | Text alignment and padding             | `zcl_alloc_align`                      |

### Analysis and statistics

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 58    | Allocation KPI summary                 | `zcl_alloc_kpi`                        |
| 59    | ABC classification of materials        | `zcl_alloc_abc`                        |
| 60    | Top-N materials by allocated quantity  | `zcl_alloc_top_n`                      |
| 61    | Quantity histogram / buckets           | `zcl_alloc_histogram`                  |
| 62    | Demand variance across runs            | `zcl_alloc_demand_variance`            |
| 63    | Moving average of allocated quantity   | `zcl_alloc_moving_average`             |
| 64    | Trend detection (up / down / flat)     | `zcl_alloc_trend`                      |
| 65    | Simple forecast of the next quantity   | `zcl_alloc_forecast`                   |
| 66    | Service level (fill rate) per material | `zcl_alloc_service_level`              |
| 67    | Running totals over a result list      | `zcl_alloc_running_total`              |
| 68    | Confidence score for an allocation     | `zcl_alloc_confidence`                 |
| 69    | Risk score for a shortage list         | `zcl_alloc_risk`                       |

### Validation and checks

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 70    | Request validator (material, plant, qty)| `zcl_alloc_request_validator`          |
| 71    | Policy validator                       | `zcl_alloc_policy_validator`           |
| 72    | Allocation consistency check           | `zcl_alloc_consistency`                |
| 73    | Duplicate requirement detection        | `zcl_alloc_duplicate_check`            |
| 74    | Stock row data quality check           | `zcl_alloc_stock_check`                |
| 75    | Negative quantity detector             | `zcl_alloc_negative_check`             |
| 76    | Over-allocation detector               | `zcl_alloc_over_check`                 |
| 77    | Missing master data check              | `zcl_alloc_master_check`               |

### Allocation strategies

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 78    | Priority scoring from weighted rules   | `zcl_alloc_priority`                   |
| 79    | Stock sequencing (FIFO / LIFO)         | `zcl_alloc_sequence`                   |
| 80    | Round-robin fair share                 | `zcl_alloc_round_robin`                |
| 81    | Proportional (pro-rata) allocation     | `zcl_alloc_proportional`               |
| 82    | Max-min fair allocation                | `zcl_alloc_maxmin`                     |
| 83    | Capacity-constrained allocation        | `zcl_alloc_capacity`                   |
| 84    | Load balancing across plants           | `zcl_alloc_load_balance`               |
| 85    | Requirement merge (same key)           | `zcl_alloc_req_merge`                  |
| 86    | Requirement split by size              | `zcl_alloc_req_split`                  |
| 87    | Requirement grouping by material       | `zcl_alloc_req_group`                  |
| 88    | Requirement netting against stock      | `zcl_alloc_req_net`                    |

### Inventory arithmetic

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 89    | Reorder point calculation              | `zcl_alloc_reorder_point`              |
| 90    | Economic order quantity (EOQ)          | `zcl_alloc_eoq`                        |
| 91    | Days of supply / stock cover           | `zcl_alloc_days_supply`                |
| 92    | Stock turn rate                        | `zcl_alloc_turn_rate`                  |
| 93    | Inventory value at a price             | `zcl_alloc_inventory_value`            |
| 94    | Weighted average price                 | `zcl_alloc_avg_price`                  |
| 95    | Quantity rounding utilities            | `zcl_alloc_rounding`                   |

### Storage locations and picking

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 96    | Storage location ranking by quantity   | `zcl_alloc_location_rank`              |
| 97    | Consolidation (bin emptying) proposal  | `zcl_alloc_consolidation`              |
| 98    | Pick sequence within a plant           | `zcl_alloc_pick_sequence`              |
| 99    | Bin replenishment trigger              | `zcl_alloc_bin_replenish`              |
| 100   | Picking list from an allocation        | `zcl_alloc_pick_list`                  |
| 101   | Picking list confirmation              | `zcl_alloc_pick_confirm`               |
| 102   | Location scoring for selection         | `zcl_alloc_location_score`             |

### Dates, scheduling and aging

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 103   | Working-day calendar                   | `zcl_alloc_calendar`                   |
| 104   | Date range splitting                   | `zcl_alloc_date_range`                 |
| 105   | Age of stock in days                   | `zcl_alloc_stock_age`                  |
| 106   | Backlog aging buckets                  | `zcl_alloc_aging`                      |
| 107   | Time slot assignment                   | `zcl_alloc_slot`                       |
| 108   | Wave planning                          | `zcl_alloc_wave`                       |
| 109   | Material batching for picking          | `zcl_alloc_batching`                   |

### Aggregation and reporting

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 110   | Per-plant report across runs           | `zcl_alloc_plant_report`               |
| 111   | Per-day report across runs             | `zcl_alloc_daily_report`               |
| 112   | Material x plant pivot                 | `zcl_alloc_pivot`                      |
| 113   | Material x run matrix                  | `zcl_alloc_matrix`                     |
| 114   | Shipment grouping                      | `zcl_alloc_shipment`                   |
| 115   | Delivery split proposal                | `zcl_alloc_delivery_split`             |
| 116   | SLA compliance report                  | `zcl_alloc_sla`                        |
| 117   | Event timeline                         | `zcl_alloc_timeline`                   |
| 118   | Search / text filter over overviews    | `zcl_alloc_search`                     |
| 119   | Pagination helper                      | `zcl_alloc_paging`                     |
| 120   | Generic sort helper for overviews      | `zcl_alloc_sort`                       |

### Policy and run management

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 121   | Policy presets                         | `zcl_alloc_policy_preset`              |
| 122   | Policy merge                           | `zcl_alloc_policy_merge`               |
| 123   | Policy diff                            | `zcl_alloc_policy_diff`                |
| 124   | Run comparison summary                 | `zcl_alloc_run_compare`                |
| 125   | Three-way allocation diff              | `zcl_alloc_diff3`                      |
| 126   | Allocation snapshot and compare        | `zcl_alloc_snapshot`                   |
| 127   | Checksum of an allocation result       | `zcl_alloc_checksum`                   |
| 128   | Run / requirement id generator         | `zcl_alloc_id_gen`                     |
| 129   | Run tagging (in-memory)                | `zcl_alloc_tag`                        |
| 130   | Annotation store (in-memory)           | `zcl_alloc_annotation`                 |

### Substitution, substitution chains and transfer

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 131   | Substitution chain resolver            | `zcl_alloc_subst_chain`                |
| 132   | Multi-plant availability aggregation   | `zcl_alloc_multi_plant`                |
| 133   | Transport cost comparison              | `zcl_alloc_transport_cost`             |
| 134   | Cost-based source selection            | `zcl_alloc_cost`                       |
| 135   | Footprint estimate for a transfer      | `zcl_alloc_footprint`                  |
| 136   | Weighted source scoring                | `zcl_alloc_weight`                     |

### Lists and small helpers

| Order | Feature                                | Main artefact                          |
| ----- | -------------------------------------- | -------------------------------------- |
| 137   | Material list from run headers         | `zcl_alloc_material_list`              |
| 138   | Plant list from run headers            | `zcl_alloc_plant_list`                 |
| 139   | Storage location list from a result    | `zcl_alloc_lgort_list`                 |
| 140   | Quantity bucket helper                 | `zcl_alloc_bucket`                     |
| 141   | Batch split proposal                   | `zcl_alloc_batch_split`                |
| 142   | Allocation quality grade (A-F)         | `zcl_alloc_grade`                      |
| 143   | ALV grid binding + selection screen    | GUI layer - NOT transpiler-verifiable   |

## Roadmap batch 2 (orders 144-243)

Planned when the first batch completed, per the standing instruction. The theme is
the complete export surface: every report already built gets its CSV, JSON, XML,
Markdown, HTML and fixed-width rendering, followed by a unified export facade and
a format registry. Each item is a new `zcl_alloc_*` class with a local test class,
verified by `npm test`.

| Order | Feature | Owner |
| --- | --- | --- |
| 144 | CSV of the per-run allocations | `zcl_alloc_export_alloc` |
| 145 | CSV of the per-material allocations | `zcl_alloc_export_alloc_mat` |
| 146 | JSON of the per-run allocations | `zcl_alloc_export_alloc_json` |
| 147 | JSON of the per-material allocations | `zcl_alloc_export_alloc_mjson` |
| 148 | XML of the allocations | `zcl_alloc_export_alloc_xml` |
| 149 | Markdown of the allocations | `zcl_alloc_export_alloc_md` |
| 150 | HTML of the allocations | `zcl_alloc_export_alloc_html` |
| 151 | Fixed-width of the allocations | `zcl_alloc_export_alloc_fw` |
| 152 | CSV of the allocation diff | `zcl_alloc_diff_csv` |
| 153 | CSV of the run comparison | `zcl_alloc_run_cmp_csv` |
| 154 | JSON of the run comparison | `zcl_alloc_run_cmp_json` |
| 155 | CSV of the SLA report | `zcl_alloc_sla_csv` |
| 156 | JSON of the SLA report | `zcl_alloc_sla_json` |
| 157 | CSV of the aging report | `zcl_alloc_aging_csv` |
| 158 | JSON of the aging report | `zcl_alloc_aging_json` |
| 159 | CSV of the plant report | `zcl_alloc_plant_csv` |
| 160 | CSV of the daily report | `zcl_alloc_daily_csv` |
| 161 | JSON of the plant report | `zcl_alloc_plant_json` |
| 162 | JSON of the daily report | `zcl_alloc_daily_json` |
| 163 | CSV of the KPI summary | `zcl_alloc_kpi_csv` |
| 164 | JSON of the KPI summary | `zcl_alloc_kpi_json` |
| 165 | CSV of the ABC classification | `zcl_alloc_abc_csv` |
| 166 | JSON of the ABC classification | `zcl_alloc_abc_json` |
| 167 | CSV of the histogram | `zcl_alloc_hist_csv` |
| 168 | JSON of the histogram | `zcl_alloc_hist_json` |
| 169 | CSV of the top-N list | `zcl_alloc_topn_csv` |
| 170 | JSON of the top-N list | `zcl_alloc_topn_json` |
| 171 | CSV of the moving average | `zcl_alloc_mavg_csv` |
| 172 | JSON of the moving average | `zcl_alloc_mavg_json` |
| 173 | CSV of the trend analysis | `zcl_alloc_trend_csv` |
| 174 | JSON of the trend analysis | `zcl_alloc_trend_json` |
| 175 | CSV of the forecast | `zcl_alloc_forecast_csv` |
| 176 | JSON of the forecast | `zcl_alloc_forecast_json` |
| 177 | CSV of the service level | `zcl_alloc_service_csv` |
| 178 | JSON of the service level | `zcl_alloc_service_json` |
| 179 | CSV of the confidence score | `zcl_alloc_conf_csv` |
| 180 | JSON of the confidence score | `zcl_alloc_conf_json` |
| 181 | CSV of the risk score | `zcl_alloc_risk_csv` |
| 182 | JSON of the risk score | `zcl_alloc_risk_json` |
| 183 | CSV of the request validation | `zcl_alloc_reqval_csv` |
| 184 | JSON of the request validation | `zcl_alloc_reqval_json` |
| 185 | CSV of the policy validation | `zcl_alloc_polval_csv` |
| 186 | JSON of the policy validation | `zcl_alloc_polval_json` |
| 187 | CSV of the consistency check | `zcl_alloc_consist_csv` |
| 188 | JSON of the consistency check | `zcl_alloc_consist_json` |
| 189 | CSV of the duplicate check | `zcl_alloc_dupc_csv` |
| 190 | JSON of the duplicate check | `zcl_alloc_dupc_json` |
| 191 | CSV of the stock check | `zcl_alloc_stockchk_csv` |
| 192 | JSON of the stock check | `zcl_alloc_stockchk_json` |
| 193 | CSV of the negative check | `zcl_alloc_negchk_csv` |
| 194 | JSON of the negative check | `zcl_alloc_negchk_json` |
| 195 | CSV of the over-allocation check | `zcl_alloc_overchk_csv` |
| 196 | JSON of the over-allocation check | `zcl_alloc_overchk_json` |
| 197 | CSV of the master check | `zcl_alloc_mastchk_csv` |
| 198 | JSON of the master check | `zcl_alloc_mastchk_json` |
| 199 | CSV of the priority list | `zcl_alloc_prio_csv` |
| 200 | JSON of the priority list | `zcl_alloc_prio_json` |
| 201 | CSV of the pick list | `zcl_alloc_pickl_csv` |
| 202 | JSON of the pick list | `zcl_alloc_pickl_json` |
| 203 | CSV of the pick confirmation | `zcl_alloc_pickc_csv` |
| 204 | JSON of the pick confirmation | `zcl_alloc_pickc_json` |
| 205 | CSV of the pick sequence | `zcl_alloc_picks_csv` |
| 206 | JSON of the pick sequence | `zcl_alloc_picks_json` |
| 207 | CSV of the location ranking | `zcl_alloc_lrank_csv` |
| 208 | JSON of the location ranking | `zcl_alloc_lrank_json` |
| 209 | CSV of the location score | `zcl_alloc_lscore_csv` |
| 210 | JSON of the location score | `zcl_alloc_lscore_json` |
| 211 | CSV of the shipments | `zcl_alloc_ship_csv` |
| 212 | JSON of the shipments | `zcl_alloc_ship_json` |
| 213 | CSV of the waves | `zcl_alloc_wave_csv` |
| 214 | JSON of the waves | `zcl_alloc_wave_json` |
| 215 | CSV of the batches | `zcl_alloc_batch_csv` |
| 216 | JSON of the batches | `zcl_alloc_batch_json` |
| 217 | CSV of the tags | `zcl_alloc_tag_csv` |
| 218 | JSON of the tags | `zcl_alloc_tag_json` |
| 219 | CSV of the annotations | `zcl_alloc_note_csv` |
| 220 | JSON of the annotations | `zcl_alloc_note_json` |
| 221 | CSV of the timeline | `zcl_alloc_timeline_csv` |
| 222 | JSON of the timeline | `zcl_alloc_timeline_json` |
| 223 | CSV of the snapshot diff | `zcl_alloc_snap_csv` |
| 224 | JSON of the snapshot diff | `zcl_alloc_snap_json` |
| 225 | CSV of the three-way diff | `zcl_alloc_diff3_csv` |
| 226 | JSON of the three-way diff | `zcl_alloc_diff3_json` |
| 227 | CSV of the cost selection | `zcl_alloc_cost_csv` |
| 228 | JSON of the cost selection | `zcl_alloc_cost_json` |
| 229 | CSV of the transport costs | `zcl_alloc_tcost_csv` |
| 230 | JSON of the transport costs | `zcl_alloc_tcost_json` |
| 231 | CSV of the substitution chain | `zcl_alloc_subst_csv` |
| 232 | JSON of the substitution chain | `zcl_alloc_subst_json` |
| 233 | CSV of the multi-plant summary | `zcl_alloc_mplant_csv` |
| 234 | JSON of the multi-plant summary | `zcl_alloc_mplant_json` |
| 235 | CSV of the grade distribution | `zcl_alloc_grade_csv` |
| 236 | JSON of the grade distribution | `zcl_alloc_grade_json` |
| 237 | CSV of the bucket report | `zcl_alloc_bucket_csv` |
| 238 | JSON of the bucket report | `zcl_alloc_bucket_json` |
| 239 | Unified export facade | `zcl_alloc_export_facade` |
| 240 | Export format registry | `zcl_alloc_format_registry` |
| 241 | Default export format per consumer | `zcl_alloc_format_default` |
| 242 | Export registry lookup by name | `zcl_alloc_format_lookup` |
| 243 | Export registry listing | `zcl_alloc_format_list` |

