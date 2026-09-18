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
| 269 | Timeout guard | `zcl_alloc_timeout` (`check`, `is_expired`, `remaining`) |
| 270 | Retry policy | `zcl_alloc_retry` (`plan`, `should_retry`, `backoff`) |
| 271 | Circuit breaker | `zcl_alloc_breaker` (`record_failure`, `probe_half_open`) |
| 272 | Rate limiter (in-memory) | `zcl_alloc_rate_limit` (`consume`, `remaining`, `reset`) |
| 273 | Audit trail | `zcl_alloc_audit` (`add`, `of_run`, `entries`) |
| 274 | Operation log | `zcl_alloc_op_log` (`add`, `errors`, `total_ms`, `slowest`) |
| 275 | Performance timer | `zcl_alloc_timer` (`start`, `stop`, `add_ms`, `summary`) |
| 276 | Stopwatch | `zcl_alloc_stopwatch` (`lap`, `total`, `fastest`, `slowest`) |
| 277 | Run statistics collector | `zcl_alloc_stats` (`note`, `get`, `runs`) |
| 278 | Session context | `zcl_alloc_session` (`open`, `close`, `context`) |
| 279 | User context | `zcl_alloc_user` (`get_user`, `is_system`, `describe`) |
| 280 | Client context | `zcl_alloc_client` (`get_client`, `is_productive`, `label`) |
| 281 | Environment info | `zcl_alloc_environment` (`build`, `is_production`, `describe`) |
| 282 | Feature flag registry | `zcl_alloc_flags` (`set`, `is_enabled`, `enabled_flags`) |
| 283 | Configuration reader | `zcl_alloc_config` (`get`, `has`, `keys`) |
| 284 | Configuration writer (in-memory) | `zcl_alloc_config_w` (`put`, `remove`, `entries`) |
| 285 | Configuration validation | `zcl_alloc_config_val` (`validate`, `is_valid`) |
| 286 | Secret masking | `zcl_alloc_secret_mask` (`mask`, `is_masked`, `mask_all`) |
| 287 | Data masking | `zcl_alloc_mask` (`mask_text`, `mask_email`, `mask_last_digits`) |
| 288 | Pseudonymization helper | `zcl_alloc_pseudo` (`pseudonymize`, `resolve`, `is_pseudonym`) |
| 289 | Archive metadata | `zcl_alloc_archive_meta` (`build`, `is_complete`, `describe`) |
| 290 | Archive index | `zcl_alloc_archive_idx` (`add`, `contains`, `entries`) |
| 291 | Retention policy | `zcl_alloc_retention` (`is_expired`, `days_left`) |
| 292 | Deletion policy | `zcl_alloc_deletion` (`propose`) |
| 293 | Tenant isolation helper | `zcl_alloc_tenant` (`belongs_to`, `is_default`, `qualify`) |
| 294 | Multi-client guard | `zcl_alloc_mandt_guard` (`is_current_allowed`, `check`) |
| 295 | Authorization check stub | `zcl_alloc_auth` (`is_authorized`) |
| 296 | Role mapping | `zcl_alloc_role_map` (`grant`, `has_role`, `roles_of`) |
| 297 | Permission matrix | `zcl_alloc_permission` (`set`, `allows`, `allowed_count`) |
| 298 | Field-level authorization | `zcl_alloc_field_auth` (`is_visible`, `hide`, `visible_count`) |
| 299 | Data access log | `zcl_alloc_access_log` (`log`, `count_of_user`) |
| 300 | Export audit log | `zcl_alloc_export_audit` (`log`, `total_rows`, `format_count`) |
| 301 | CSV import reader | `zcl_alloc_import_csv` (`parse_line`, `count_of`) |
| 302 | JSON import reader | `zcl_alloc_import_json` (`parse`, `count_of`) |
| 303 | Import validator | `zcl_alloc_import_val` (`validate`, `is_valid`) |
| 304 | Import mapper | `zcl_alloc_import_map` (`map`) |
| 305 | Bulk loader | `zcl_alloc_bulk_load` (`stage`, `commit`) |
| 306 | Bulk validity check | `zcl_alloc_bulk_check` (`check`, `is_loadable`) |
| 307 | Delta loader | `zcl_alloc_delta_load` (`compare`) |
| 308 | Upsert helper (in-memory) | `zcl_alloc_upsert` (`upsert`, `entries`) |
| 309 | Dedupe key builder | `zcl_alloc_dedupe_key` (`build`, `parts_of`, `count_of`) |
| 310 | Natural key builder | `zcl_alloc_natural_key` (`compose`, `field_at`, `field_count`) |
| 311 | Surrogate key map | `zcl_alloc_surrogate` (`get_or_create`, `lookup`) |
| 312 | Reference data cache | `zcl_alloc_ref_cache` (`put`, `get`, `reset`) |
| 313 | Cache invalidation policy | `zcl_alloc_cache_policy` (`is_stale`, `is_full`, `describe`) |
| 314 | Cache statistics | `zcl_alloc_cache_stats` (`note_hit`, `hit_rate`, `reset`) |
| 315 | Cache warm-up helper | `zcl_alloc_cache_warm` (`missing`, `cached_count`) |
| 316 | Lazy loader | `zcl_alloc_lazy` (`load`, `get`, `reset`) |
| 317 | Pagination cursor | `zcl_alloc_cursor` (`open`, `next`, `is_last`, `remaining`) |
| 318 | Chunked read over a result | `zcl_alloc_chunk_read` (`read`) |
| 319 | Chunked write into batches | `zcl_alloc_chunk_write` (`write`) |
| 320 | Backpressure decision | `zcl_alloc_backpressure` (`assess`) |
| 321 | Batch size tuner | `zcl_alloc_batch_tune` (`tune`) |
| 322 | Concurrency guard | `zcl_alloc_concurrency` (`acquire`, `release`, `active_count`) |
| 323 | Idempotency key | `zcl_alloc_idem_key` (`build`, `is_valid`, `scope_of`) |
| 324 | Exactly-once guard | `zcl_alloc_once` (`run`, `has_run`, `count`) |
| 325 | Dedupe window | `zcl_alloc_dedupe_win` (`is_duplicate`, `purge_before`) |
| 326 | Sequential numbering | `zcl_alloc_seq_num` (`next`, `current`, `reset`) |
| 327 | Gap detection | `zcl_alloc_gap_check` (`find`) |
| 328 | Sequence validation | `zcl_alloc_seq_check` (`check`) |
| 329 | Checksum registry | `zcl_alloc_checksum_reg` (`register`, `verify`, `checksum_of`) |
| 330 | Integrity check | `zcl_alloc_integrity` (`check`) |
| 331 | Reconciliation report | `zcl_alloc_reconcile` (`compare`, `is_balanced`) |
| 332 | Drift detection | `zcl_alloc_drift` (`detect`) |
| 333 | Heavy snapshot comparison | `zcl_alloc_snap_heavy` (`take`, `compare`) |
| 334 | Restore helper | `zcl_alloc_restore` (`plan`) |
| 335 | Migration mapper | `zcl_alloc_migration_map` (`map`, `is_mapped`) |
| 336 | Migration validator | `zcl_alloc_migration_val` (`validate`, `is_valid`) |
| 337 | Cutover checklist | `zcl_alloc_cutover` (`build`, `open_steps`) |
| 338 | Parallel run comparison | `zcl_alloc_parallel_run` (`compare`, `mismatch_count`) |
| 339 | Data volume estimator | `zcl_alloc_volume` (`estimate`) |
| 340 | Load test helper | `zcl_alloc_load_test` (`plan`) |
| 341 | Smoke test runner | `zcl_alloc_smoke` (`add`, `run`, `failed`, `reset`) |
| 342 | Health check | `zcl_alloc_health` (`check`, `unhealthy_names`) |
| 343 | Readiness probe | `zcl_alloc_readiness` (`probe`) |

**Batch 3 is complete: orders 244-343 (100 features) are all delivered and
verified.** The only unbuilt item across every batch remains 143 (ALV grid
binding + selection screen), which the transpiler cannot exercise.

## Roadmap batch 4 (orders 344-443)

Planned when batch 3 completed, per the standing instruction. The theme is
**optimisation, simulation and planning intelligence**: solvers (objective,
greedy, knapsack, assignment, transport), local search, seeded simulation and
scenario analysis, forecasting and demand classification, MRP and lot sizing,
finite scheduling and capacity, distribution network and routing, KPI /
statistics, report presentation helpers and roll-out governance. Each item is a
new `zcl_alloc_*` class with a local test class, verified by `npm test`.

| Order | Feature | Owner |
| --- | --- | --- |
| 344 | Objective function evaluation | `zcl_alloc_objective` |
| 345 | Greedy allocation solver | `zcl_alloc_greedy` |
| 346 | Cheapest source solver | `zcl_alloc_cheapest` |
| 347 | Knapsack allocation | `zcl_alloc_knapsack` |
| 348 | Bin packing for pallets | `zcl_alloc_bin_pack` |
| 349 | Transportation problem | `zcl_alloc_transport` |
| 350 | Assignment problem | `zcl_alloc_assignment` |
| 351 | Constraint set evaluation | `zcl_alloc_constraint` |
| 352 | Penalty calculator | `zcl_alloc_penalty` |
| 353 | Feasibility check | `zcl_alloc_feasible` |
| 354 | Local search improvement | `zcl_alloc_local_search` |
| 355 | Swap optimisation | `zcl_alloc_swap_opt` |
| 356 | Hill climbing | `zcl_alloc_hill_climb` |
| 357 | Simulated annealing (deterministic) | `zcl_alloc_annealing` |
| 358 | Improvement tracker | `zcl_alloc_improve_log` |
| 359 | Monte Carlo demand sampler | `zcl_alloc_monte_carlo` |
| 360 | Seeded random generator | `zcl_alloc_random` |
| 361 | Scenario definition | `zcl_alloc_scenario` |
| 362 | Scenario comparison | `zcl_alloc_scenario_cmp` |
| 363 | What-if stock shock | `zcl_alloc_shock` |
| 364 | Demand uplift scenario | `zcl_alloc_uplift` |
| 365 | Capacity reduction scenario | `zcl_alloc_capacity_cut` |
| 366 | Stress test ladder | `zcl_alloc_stress` |
| 367 | Sensitivity analysis | `zcl_alloc_sensitivity` |
| 368 | Break-even analysis | `zcl_alloc_breakeven` |
| 369 | Exponential smoothing | `zcl_alloc_exp_smooth` |
| 370 | Holt linear trend | `zcl_alloc_holt` |
| 371 | Seasonal index | `zcl_alloc_seasonal` |
| 372 | Seasonally adjusted forecast | `zcl_alloc_season_forecast` |
| 373 | Mean absolute deviation | `zcl_alloc_mad` |
| 374 | Forecast accuracy (MAPE) | `zcl_alloc_mape` |
| 375 | Forecast bias | `zcl_alloc_bias` |
| 376 | Forecast exception list | `zcl_alloc_forecast_exc` |
| 377 | Demand classification | `zcl_alloc_demand_class` |
| 378 | Intermittent demand (Croston) | `zcl_alloc_croston` |
| 379 | Material requirements planning run | `zcl_alloc_mrp` |
| 380 | MRP net requirements | `zcl_alloc_mrp_net` |
| 381 | Lot sizing: fixed lot | `zcl_alloc_lot_fixed` |
| 382 | Lot sizing: period lot | `zcl_alloc_lot_period` |
| 383 | Lot sizing: least unit cost | `zcl_alloc_lot_luc` |
| 384 | Lot sizing: part period balancing | `zcl_alloc_lot_ppb` |
| 385 | Scheduling: earliest due date | `zcl_alloc_sched_edd` |
| 386 | Scheduling: shortest processing time | `zcl_alloc_sched_spt` |
| 387 | Scheduling: critical ratio | `zcl_alloc_sched_cr` |
| 388 | Capacity levelling | `zcl_alloc_levelling` |
| 389 | Capacity requirement planning | `zcl_alloc_crp` |
| 390 | Work centre load | `zcl_alloc_workload` |
| 391 | Queue estimation | `zcl_alloc_queue` |
| 392 | Rough-cut capacity check | `zcl_alloc_rough_cut` |
| 393 | Distribution network model | `zcl_alloc_network` |
| 394 | Sourcing rule evaluation | `zcl_alloc_sourcing` |
| 395 | Lane cost matrix | `zcl_alloc_lane` |
| 396 | Shortest path over lanes | `zcl_alloc_path` |
| 397 | Multi-stop route builder | `zcl_alloc_route` |
| 398 | Route cost estimate | `zcl_alloc_route_cost` |
| 399 | Milk-run grouping | `zcl_alloc_milk_run` |
| 400 | Cross-dock proposal | `zcl_alloc_crossdock` |
| 401 | Safety stock by service level | `zcl_alloc_safety_level` |
| 402 | Reorder point with variability | `zcl_alloc_rop_var` |
| 403 | Fill rate simulation | `zcl_alloc_fill_sim` |
| 404 | Inventory policy comparison | `zcl_alloc_policy_cmp` |
| 405 | KPI trend over runs | `zcl_alloc_kpi_trend` |
| 406 | Pareto analysis | `zcl_alloc_pareto` |
| 407 | Concentration index (HHI) | `zcl_alloc_hhi` |
| 408 | Gini coefficient | `zcl_alloc_gini` |
| 409 | Lorenz curve points | `zcl_alloc_lorenz` |
| 410 | Correlation of two series | `zcl_alloc_correlation` |
| 411 | Linear regression | `zcl_alloc_regression` |
| 412 | Outlier detection (z-score) | `zcl_alloc_outlier` |
| 413 | Percentile calculation | `zcl_alloc_percentile` |
| 414 | Median and quartiles | `zcl_alloc_quartile` |
| 415 | Standard deviation | `zcl_alloc_stddev` |
| 416 | Coefficient of variation | `zcl_alloc_cv` |
| 417 | Moving range control chart | `zcl_alloc_control_chart` |
| 418 | Benchmark comparison | `zcl_alloc_benchmark` |
| 419 | Scorecard builder | `zcl_alloc_scorecard` |
| 420 | Weighted score model | `zcl_alloc_weighted_score` |
| 421 | Row numbering for reports | `zcl_alloc_row_number` |
| 422 | Column definition builder | `zcl_alloc_columns` |
| 423 | Table of contents for a report | `zcl_alloc_toc` |
| 424 | Report header block | `zcl_alloc_header` |
| 425 | Report footer with totals | `zcl_alloc_footer` |
| 426 | Conditional highlighting rules | `zcl_alloc_highlight` |
| 427 | Traffic-light status | `zcl_alloc_trafficlight` |
| 428 | Unit-aware display | `zcl_alloc_unit_display` |
| 429 | Text wrapping | `zcl_alloc_wrap` |
| 430 | Truncation helper | `zcl_alloc_truncate` |
| 431 | Pluralisation helper | `zcl_alloc_plural` |
| 432 | Digit grouping | `zcl_alloc_grouping` |
| 433 | Column width fitting | `zcl_alloc_colwidth` |
| 434 | Excel-friendly CSV | `zcl_alloc_csv_excel` |
| 435 | Tab-separated export | `zcl_alloc_tsv` |
| 436 | SQL literal escaping | `zcl_alloc_sql_escape` |
| 437 | URL query builder | `zcl_alloc_query` |
| 438 | Deep-link builder | `zcl_alloc_deeplink` |
| 439 | Report signature block | `zcl_alloc_signature` |
| 440 | Print pagination | `zcl_alloc_print_page` |
| 441 | Release note builder | `zcl_alloc_release_notes` |
| 442 | Change request tracker | `zcl_alloc_change_request` |
| 443 | Roll-out wave planner | `zcl_alloc_rollout` |

### Batch 4 delivered so far

| Order | Feature | Owner |
| --- | --- | --- |
| 344 | Objective function evaluation | `zcl_alloc_objective` (`score`) |
| 345 | Greedy allocation solver | `zcl_alloc_greedy` (`solve`, `total_shortage`) |
| 346 | Cheapest source solver | `zcl_alloc_cheapest` (`solve`) |
| 347 | Knapsack allocation | `zcl_alloc_knapsack` (`solve`) |
| 348 | Bin packing for pallets | `zcl_alloc_bin_pack` (`pack`, `oversized`) |
| 349 | Transportation problem | `zcl_alloc_transport` (`solve`) |
| 350 | Assignment problem | `zcl_alloc_assignment` (`solve`) |
| 351 | Constraint set evaluation | `zcl_alloc_constraint` (`evaluate`, `violated_ids`) |
| 352 | Penalty calculator | `zcl_alloc_penalty` (`calculate`) |
| 353 | Feasibility check | `zcl_alloc_feasible` (`check`) |
| 354 | Local search improvement | `zcl_alloc_local_search` (`improve`) |
| 355 | Swap optimisation | `zcl_alloc_swap_opt` (`improve`) |
| 356 | Hill climbing | `zcl_alloc_hill_climb` (`climb`) |
| 357 | Simulated annealing (deterministic) | `zcl_alloc_annealing` (`anneal`) |
| 358 | Improvement tracker | `zcl_alloc_improve_log` (`add`, `best`, `first`, `gain`) |
| 359 | Monte Carlo demand sampler | `zcl_alloc_monte_carlo` (`simulate`) |
| 360 | Seeded random generator | `zcl_alloc_random` (`next`, `between`, `reset`, `state`) |
| 361 | Scenario definition | `zcl_alloc_scenario` (`define`, `apply`) |
| 362 | Scenario comparison | `zcl_alloc_scenario_cmp` (`compare`) |
| 363 | What-if stock shock | `zcl_alloc_shock` (`apply`, `available_of`) |
| 364 | Demand uplift scenario | `zcl_alloc_uplift` (`apply`, `total_of`) |
| 365 | Capacity reduction scenario | `zcl_alloc_capacity_cut` (`apply`, `total_of`) |
| 366 | Stress test ladder | `zcl_alloc_stress` (`ladder`, `assess`) |
| 367 | Sensitivity analysis | `zcl_alloc_sensitivity` (`analyze`) |
| 368 | Break-even analysis | `zcl_alloc_breakeven` (`solve`) |
| 369 | Exponential smoothing | `zcl_alloc_exp_smooth` (`forecast`) |
| 370 | Holt linear trend | `zcl_alloc_holt` (`forecast`) |
| 371 | Seasonal index | `zcl_alloc_seasonal` (`index`) |
| 372 | Seasonally adjusted forecast | `zcl_alloc_season_forecast` (`forecast`, `baseline_of`) |
| 373 | Mean absolute deviation | `zcl_alloc_mad` (`calculate`, `deviation_of`) |
| 374 | Forecast accuracy (MAPE) | `zcl_alloc_mape` (`calculate`, `percentage_of`) |
| 375 | Forecast bias | `zcl_alloc_bias` (`calculate`, `errors_of`, `direction`) |
| 376 | Forecast exception list | `zcl_alloc_forecast_exc` (`find`) |
| 377 | Demand classification | `zcl_alloc_demand_class` (`classify`) |
| 378 | Intermittent demand (Croston) | `zcl_alloc_croston` (`forecast`) |
| 379 | Material requirements planning run | `zcl_alloc_mrp` (`run`) |
| 380 | MRP net requirements | `zcl_alloc_mrp_net` (`calculate`) |
| 381 | Lot sizing: fixed lot | `zcl_alloc_lot_fixed` (`size`, `lots_of`) |
| 382 | Lot sizing: period lot | `zcl_alloc_lot_period` (`size`) |
| 383 | Lot sizing: least unit cost | `zcl_alloc_lot_luc` (`size`) |
| 384 | Lot sizing: part period balancing | `zcl_alloc_lot_ppb` (`size`) |
| 385 | Scheduling: earliest due date | `zcl_alloc_sched_edd` (`schedule`, `late_count`) |
| 386 | Scheduling: shortest processing time | `zcl_alloc_sched_spt` (`schedule`, `avg_finish`) |
| 387 | Scheduling: critical ratio | `zcl_alloc_sched_cr` (`schedule`, `late_count`) |
| 388 | Capacity levelling | `zcl_alloc_levelling` (`level`) |
| 389 | Capacity requirement planning | `zcl_alloc_crp` (`calculate`, `total_hours`) |
| 390 | Work centre load | `zcl_alloc_workload` (`build`, `overload_count`) |
| 391 | Queue estimation | `zcl_alloc_queue` (`estimate`) |
| 392 | Rough-cut capacity check | `zcl_alloc_rough_cut` (`check`, `is_feasible`, `gap_total`) |
| 393 | Distribution network model | `zcl_alloc_network` (`build`, `connected_count`) |
| 394 | Sourcing rule evaluation | `zcl_alloc_sourcing` (`evaluate`) |
| 395 | Lane cost matrix | `zcl_alloc_lane` (`build`, `cost_of`, `cheapest_lane`) |
| 396 | Shortest path over lanes | `zcl_alloc_path` (`shortest`) |
| 397 | Multi-stop route builder | `zcl_alloc_route` (`build`, `distance_between`) |
| 398 | Route cost estimate | `zcl_alloc_route_cost` (`estimate`) |
| 399 | Milk-run grouping | `zcl_alloc_milk_run` (`group`, `unassigned`) |
| 400 | Cross-dock proposal | `zcl_alloc_crossdock` (`propose`, `shortfall_of`) |
| 401 | Safety stock by service level | `zcl_alloc_safety_level` (`calculate`, `sqrt_of`) |
| 402 | Reorder point with variability | `zcl_alloc_rop_var` (`calculate`) |
| 403 | Fill rate simulation | `zcl_alloc_fill_sim` (`simulate`) |
| 404 | Inventory policy comparison | `zcl_alloc_policy_cmp` (`compare`) |
| 405 | KPI trend over runs | `zcl_alloc_kpi_trend` (`analyze`) |
| 406 | Pareto analysis | `zcl_alloc_pareto` (`build`, `vital_count`, `total_of`) |
| 407 | Concentration index (HHI) | `zcl_alloc_hhi` (`calculate`, `band_of`) |
| 408 | Gini coefficient | `zcl_alloc_gini` (`calculate`) |
| 409 | Lorenz curve points | `zcl_alloc_lorenz` (`build`, `gap_of`) |
| 410 | Correlation of two series | `zcl_alloc_correlation` (`calculate`) |
| 411 | Linear regression | `zcl_alloc_regression` (`fit`) |
| 412 | Outlier detection (z-score) | `zcl_alloc_outlier` (`find`, `mean_of`, `sd_of`) |
| 413 | Percentile calculation | `zcl_alloc_percentile` (`value`, `rank_of`) |
| 414 | Median and quartiles | `zcl_alloc_quartile` (`calculate`) |
| 415 | Standard deviation | `zcl_alloc_stddev` (`calculate`, `mean_of`) |
| 416 | Coefficient of variation | `zcl_alloc_cv` (`calculate`, `band_of`) |
| 417 | Moving range control chart | `zcl_alloc_control_chart` (`build`, `out_of_control`) |
| 418 | Benchmark comparison | `zcl_alloc_benchmark` (`compare`) |
| 419 | Scorecard builder | `zcl_alloc_scorecard` (`build`, `met_count`) |
| 420 | Weighted score model | `zcl_alloc_weighted_score` (`score`, `grade_of`) |
| 421 | Row numbering for reports | `zcl_alloc_row_number` (`apply`, `count_of`) |
| 422 | Column definition builder | `zcl_alloc_columns` (`build`, `total_width`) |
| 423 | Table of contents for a report | `zcl_alloc_toc` (`build`) |
| 424 | Report header block | `zcl_alloc_header` (`build`) |
| 425 | Report footer with totals | `zcl_alloc_footer` (`build`) |
| 426 | Conditional highlighting rules | `zcl_alloc_highlight` (`apply`, `worst_severity`) |
| 427 | Traffic-light status | `zcl_alloc_trafficlight` (`of_value`, `text_of`) |
| 428 | Unit-aware display | `zcl_alloc_unit_display` (`format`) |
| 429 | Text wrapping | `zcl_alloc_text_wrap` (`wrap`) |
| 430 | Text truncation with ellipsis | `zcl_alloc_text_trunc` (`truncate`, `fits`) |
| 431 | CSV export | `zcl_alloc_csv_export` (`render`, `escape`) |
| 432 | TSV export | `zcl_alloc_tsv_export` (`render`, `clean`, `separator`) |
| 433 | Column width fitting | `zcl_alloc_colwidth` (`fit`) |
| 434 | Excel-friendly CSV | `zcl_alloc_csv_excel` (`render`, `separator`, `hint`) |
| 435 | Tab-separated codec | `zcl_alloc_tsv` (`join`, `split`, `cell_count`) |
| 436 | SQL literal escaping | `zcl_alloc_sql_escape` (`escape`, `literal`, `needs_escape`) |
| 437 | URL query builder | `zcl_alloc_query` (`build`, `encode`) |
| 438 | Deep-link builder | `zcl_alloc_deeplink` (`build`, `is_absolute`) |
| 439 | Report signature block | `zcl_alloc_signature` (`build`) |
| 440 | Print pagination | `zcl_alloc_print_page` (`paginate`, `capacity_of`) |
| 441 | Release note builder | `zcl_alloc_release_notes` (`build`, `count_of`, `titles_of`) |
| 442 | Change request tracker | `zcl_alloc_change_request` (`build`, `is_open_status`, `open_count`) |
| 443 | Roll-out wave planner | `zcl_alloc_rollout` (`plan`, `wave_count`) |

**All 443 orders of the roadmap are delivered and verified** (batches 1-4). Every
class has a local test class, abapGit metadata and an entry in `NOTES.md`, and
`npm test` (abaplint + transpile + unit run) is green.

## Batch 5 - verification and hardening (444-449)

The allocation logic, the reporting helpers and the operational tooling are built
and unit tested per class. What is left is the cross-cutting risk: a result that
looks plausible but breaks an invariant the business depends on (over-allocation,
a negative quantity, a stock movement driving a storage location below zero, or a
run that silently changed behaviour). Batch 5 adds the checkers that make those
failures visible, each as a small, separately testable class.

| Order | Feature | Class |
| --- | --- | --- |
| 444 | Allocation invariant check | `zcl_alloc_invariant_check` (`check`, `is_clean`) |
| 445 | Run audit summary | `zcl_alloc_run_audit` (`audit`) |
| 446 | Stock movement guard | `zcl_alloc_stock_guard` (`check`, `first_negative`, `closing_of`) |
| 447 | Regression baseline | `zcl_alloc_regression_baseline` (`capture`, `compare`) |
| 448 | Scenario matrix | `zcl_alloc_scenario_matrix` (`build`) |
| 449 | End-to-end scenario runner | `zcl_alloc_e2e_scenario` (`run`) |

**Batch 5 is complete: orders 444-449 are delivered and verified.**

## Batch 6 - scale safety (450-451)

Batch 5 made failures visible; batch 6 addresses the one class of failure that the
unit tests cannot see at all, because every test uses a handful of rows: an
algorithm whose cost grows with the square of the input. About fifteen classes
aggregate with "read the row, change it, delete it, append it", which scans the
whole table once per input row, so the cost is quadratic in the number of rows.

There is no microsecond clock available here (`sy-uzeit` counts seconds), so the
verification counts **work elements** instead of wall-clock time. That is
deterministic, reproducible, and it is the property that actually matters.

| Order | Feature | Class |
| --- | --- | --- |
| 450 | Scale-safe keyed aggregation | `zcl_alloc_key_agg` (`add`, `sums`, `find`, `visits`) |
| 451 | Growth classifier | `zcl_alloc_scale_guard` (`classify`, `ratio_x100`) |

**Batch 6 is complete: orders 450-451 are delivered and verified.**

## Batch 7 - applying the scale-safe aggregation (452)

Batch 6 found the quadratic read/delete/append aggregation in about fifteen classes
and built the tools; this batch applies them. The enabler is a string-keyed variant
of the aggregator, because the affected keys are material numbers, work centres and
node ids, and it has to preserve the first-appearance order that the existing
classes produce, so that converting a class is a purely internal change.

| Order | Feature | Class |
| --- | --- | --- |
| 452 | Scale-safe string keyed aggregation | `zcl_alloc_key_agg_str` (`add`, `sums`, `visits`) |

Then the quadratic classes are converted one per iteration, using their existing
tests as the regression check: `mrp`, `network`, `crp`, `workload`, `crossdock`,
`sourcing`, `transport`, `local_search`, `toc`, `rollout`, `checksum_reg`,
`concurrency`, `config_w`, `dedupe_win`, `path`.

**Batch 7 is in progress: order 452 is delivered and `zcl_alloc_network` is the
first converted class. The remaining fourteen classes are converted one per
iteration, each verified by its own existing tests.**


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

