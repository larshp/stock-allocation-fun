REPORT zstock_alloc_compare.

PARAMETERS p_matnr TYPE zif_stock_allocation=>ty_material.
PARAMETERS p_omatnr TYPE zif_stock_allocation=>ty_material.
PARAMETERS p_nmatnr TYPE zif_stock_allocation=>ty_material.
PARAMETERS p_werks TYPE zif_stock_allocation=>ty_plant.
PARAMETERS p_owerks TYPE zif_stock_allocation=>ty_plant.
PARAMETERS p_nwerks TYPE zif_stock_allocation=>ty_plant.
PARAMETERS p_lgort TYPE zif_stock_allocation=>ty_storage_location.
PARAMETERS p_olgort TYPE zif_stock_allocation=>ty_storage_location.
PARAMETERS p_nlgort TYPE zif_stock_allocation=>ty_storage_location.
PARAMETERS p_charg TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_obatch TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_nbatch TYPE zif_stock_allocation=>ty_batch.
PARAMETERS p_mvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_omvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_nmvt TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_shelf TYPE i.
PARAMETERS p_oshelf TYPE i.
PARAMETERS p_nshelf TYPE i.
PARAMETERS p_ovrd AS CHECKBOX.
PARAMETERS p_oovrd AS CHECKBOX.
PARAMETERS p_novrd AS CHECKBOX.
PARAMETERS p_odate TYPE d.
PARAMETERS p_reqf TYPE d.
PARAMETERS p_until TYPE d.
PARAMETERS p_oreqf TYPE d.
PARAMETERS p_oreqt TYPE d.
PARAMETERS p_nreqf TYPE d.
PARAMETERS p_nreqt TYPE d.
PARAMETERS p_dead AS CHECKBOX.
PARAMETERS p_odead AS CHECKBOX.
PARAMETERS p_ndead AS CHECKBOX.
PARAMETERS p_odeadf TYPE d.
PARAMETERS p_odeadt TYPE d.
PARAMETERS p_ndeadf TYPE d.
PARAMETERS p_ndeadt TYPE d.
PARAMETERS p_deadf TYPE d.
PARAMETERS p_deadt TYPE d.
PARAMETERS p_dagef TYPE i.
PARAMETERS p_daget TYPE i.
PARAMETERS p_daged TYPE d.
PARAMETERS p_oagef TYPE i.
PARAMETERS p_oaget TYPE i.
PARAMETERS p_nagef TYPE i.
PARAMETERS p_naget TYPE i.
PARAMETERS p_tfrom TYPE i.
PARAMETERS p_tto TYPE i.
PARAMETERS p_otfrom TYPE i.
PARAMETERS p_otto TYPE i.
PARAMETERS p_ntfrom TYPE i.
PARAMETERS p_ntto TYPE i.
PARAMETERS p_avf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_avt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oavf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oavt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_navf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_navt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_meins TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_ounit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_nunit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_rmov TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_ormov TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_nrmov TYPE zif_stock_allocation=>ty_movement_type.
PARAMETERS p_runit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_orunit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_nrunit TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_rsv AS CHECKBOX.
PARAMETERS p_unrsv AS CHECKBOX.
PARAMETERS p_orsv AS CHECKBOX.
PARAMETERS p_nrsv AS CHECKBOX.
PARAMETERS p_oursv AS CHECKBOX.
PARAMETERS p_nursv AS CHECKBOX.
PARAMETERS p_rfrom TYPE d.
PARAMETERS p_rto TYPE d.
PARAMETERS p_orfrom TYPE d.
PARAMETERS p_orto TYPE d.
PARAMETERS p_nrfrom TYPE d.
PARAMETERS p_nrto TYPE d.
PARAMETERS p_rage TYPE i.
PARAMETERS p_rageto TYPE i.
PARAMETERS p_orage TYPE i.
PARAMETERS p_oragto TYPE i.
PARAMETERS p_nrage TYPE i.
PARAMETERS p_nragto TYPE i.
PARAMETERS p_old TYPE zif_stock_allocation=>ty_run_id OBLIGATORY.
PARAMETERS p_new TYPE zif_stock_allocation=>ty_run_id OBLIGATORY.
PARAMETERS p_chg TYPE zif_stock_allocation_compare=>ty_change_type.
PARAMETERS p_reason TYPE zif_stock_allocation_compare=>ty_change_reason.
PARAMETERS p_ost TYPE zif_stock_allocation=>ty_allocation_status.
PARAMETERS p_nst TYPE zif_stock_allocation=>ty_allocation_status.
PARAMETERS p_bklg AS CHECKBOX.
PARAMETERS p_obklg AS CHECKBOX.
PARAMETERS p_nbklg AS CHECKBOX.
PARAMETERS p_shf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_sht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oshf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_osht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_nshf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_nsht TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_covf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_covt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_ocovf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_ocovt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_ncovf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_ncovt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_spt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_ospf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_ospt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_nspf TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_nspt TYPE zif_allocation_audit=>ty_coverage.
PARAMETERS p_qf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_qt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oqf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oqt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_nqf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_nqt TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_af TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_at TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oaf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_oat TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_naf TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_nat TYPE zif_stock_allocation=>ty_quantity.
PARAMETERS p_priof TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_priot TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_opf TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_opt TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_npf TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_npt TYPE zif_stock_allocation=>ty_priority.
PARAMETERS p_sdf TYPE d.
PARAMETERS p_sdt TYPE d.
PARAMETERS p_osdf TYPE d.
PARAMETERS p_osdt TYPE d.
PARAMETERS p_nsdf TYPE d.
PARAMETERS p_nsdt TYPE d.
PARAMETERS p_vbeln TYPE zif_stock_allocation=>ty_sales_document.
PARAMETERS p_ovbeln TYPE zif_stock_allocation=>ty_sales_document.
PARAMETERS p_nvbeln TYPE zif_stock_allocation=>ty_sales_document.
PARAMETERS p_auart TYPE zif_stock_allocation=>ty_sales_document_type.
PARAMETERS p_oauart TYPE zif_stock_allocation=>ty_sales_document_type.
PARAMETERS p_nauart TYPE zif_stock_allocation=>ty_sales_document_type.
PARAMETERS p_posnr TYPE zif_stock_allocation=>ty_sales_item.
PARAMETERS p_oposnr TYPE zif_stock_allocation=>ty_sales_item.
PARAMETERS p_nposnr TYPE zif_stock_allocation=>ty_sales_item.
PARAMETERS p_etenr TYPE zif_stock_allocation=>ty_schedule_line.
PARAMETERS p_oetenr TYPE zif_stock_allocation=>ty_schedule_line.
PARAMETERS p_netenr TYPE zif_stock_allocation=>ty_schedule_line.
PARAMETERS p_ordun TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_oordun TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_nordun TYPE zif_stock_allocation=>ty_unit.
PARAMETERS p_order TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_oorder TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_norder TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_resid TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_oresid TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_nresid TYPE zif_stock_allocation=>ty_order_id.
PARAMETERS p_oast TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_nast TYPE zif_allocation_audit=>ty_run_status.
PARAMETERS p_ostr TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_nstr TYPE zif_allocation_audit=>ty_strategy.
PARAMETERS p_oleg AS CHECKBOX.
PARAMETERS p_nleg AS CHECKBOX.
PARAMETERS p_omsg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_nmsg TYPE zif_allocation_audit=>ty_message.
PARAMETERS p_omonly AS CHECKBOX.
PARAMETERS p_nmonly AS CHECKBOX.
PARAMETERS p_all AS CHECKBOX.
PARAMETERS p_sum AS CHECKBOX.
PARAMETERS p_shrt AS CHECKBOX.
PARAMETERS p_wors AS CHECKBOX.
PARAMETERS p_due AS CHECKBOX.
PARAMETERS p_rdate AS CHECKBOX.
PARAMETERS p_cov AS CHECKBOX.
PARAMETERS p_cw AS CHECKBOX.
PARAMETERS p_spw AS CHECKBOX.
PARAMETERS p_sreg AS CHECKBOX.
PARAMETERS p_qd AS CHECKBOX.
PARAMETERS p_spct AS CHECKBOX.
PARAMETERS p_big AS CHECKBOX.
PARAMETERS p_done AS CHECKBOX.
PARAMETERS p_skip TYPE i.
PARAMETERS p_max TYPE i.
PARAMETERS p_guard AS CHECKBOX.
PARAMETERS p_csv AS CHECKBOX.
PARAMETERS p_json AS CHECKBOX.
PARAMETERS p_meta AS CHECKBOX.
PARAMETERS p_typed AS CHECKBOX.
PARAMETERS p_ndjson AS CHECKBOX.

START-OF-SELECTION.
  DATA lo_sink TYPE REF TO zif_allocation_sink.
  DATA lo_compare TYPE REF TO zif_stock_allocation_compare.
  DATA lo_audit TYPE REF TO zif_allocation_audit.
  DATA lo_authority TYPE REF TO zif_allocation_read_authority.
  DATA lo_missing_run_error TYPE REF TO zcx_stock_allocation.
  DATA lt_old TYPE zif_stock_allocation=>tt_demands.
  DATA lt_new TYPE zif_stock_allocation=>tt_demands.
  DATA lt_old_runs TYPE zif_allocation_audit=>tt_runs.
  DATA lt_new_runs TYPE zif_allocation_audit=>tt_runs.
  DATA ls_old_run TYPE zif_allocation_audit=>ty_run.
  DATA ls_new_run TYPE zif_allocation_audit=>ty_run.
  DATA ls_old_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation.
  DATA lv_old_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA ls_new_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation.
  DATA lv_new_requested_total TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_duration_seconds TYPE i.
  DATA lv_new_duration_seconds TYPE i.
  DATA lv_old_duration_text TYPE string.
  DATA lv_new_duration_text TYPE string.
  DATA lv_old_running_age_seconds TYPE i.
  DATA lv_new_running_age_seconds TYPE i.
  DATA lv_old_running_age_text TYPE string.
  DATA lv_new_running_age_text TYPE string.
  DATA lv_old_running_age_available TYPE abap_bool.
  DATA lv_new_running_age_available TYPE abap_bool.
  DATA ls_old_running_age TYPE zif_stock_allocation_compare=>ty_running_age.
  DATA ls_new_running_age TYPE zif_stock_allocation_compare=>ty_running_age.
  DATA lv_old_audit_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_audit_coverage TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_audit_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_audit_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_audit_coverage_text TYPE string.
  DATA lv_new_audit_coverage_text TYPE string.
  DATA lv_old_audit_shortage_pct_text TYPE string.
  DATA lv_new_audit_shortage_pct_text TYPE string.
  DATA lv_old_snapshot_coverage_text TYPE string.
  DATA lv_new_snapshot_coverage_text TYPE string.
  DATA lv_old_snap_shrt_pct_text TYPE string.
  DATA lv_new_snap_shrt_pct_text TYPE string.
  DATA lv_snap_cov_delta_text TYPE string.
  DATA lv_snap_shrt_delta_text TYPE string.
  DATA lv_sum_old_cov_text TYPE string.
  DATA lv_sum_new_cov_text TYPE string.
  DATA lv_sum_cov_delta_text TYPE string.
  DATA lv_sum_old_shrt_text TYPE string.
  DATA lv_sum_new_shrt_text TYPE string.
  DATA lv_sum_shrt_delta_text TYPE string.
  DATA lv_deadline_reference_date TYPE d.
  DATA lv_old_deadline_age_days TYPE i.
  DATA lv_new_deadline_age_days TYPE i.
  DATA lv_deadline_age_delta_days TYPE i.
  DATA lv_old_deadline_age_text TYPE string.
  DATA lv_new_deadline_age_text TYPE string.
  DATA lv_deadline_age_delta_text TYPE string.
  DATA lv_audit_units_match TYPE abap_bool.
  DATA lv_audit_horizon_changed TYPE abap_bool.
  DATA lv_audit_status_changed TYPE abap_bool.
  DATA lv_audit_strategy_changed TYPE abap_bool.
  DATA lv_audit_running_changed TYPE abap_bool.
  DATA lv_aud_dur_delta_secs TYPE i.
  DATA lv_aud_start_delta_secs TYPE i.
  DATA lv_aud_finish_delta_secs TYPE i.
  DATA lv_audit_requested_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_available_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_allocated_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_shortage_delta TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_audit_coverage_delta TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_audit_shortage_pct_delta TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_audit_allocated_delta_text TYPE string.
  DATA lv_audit_shortage_delta_text TYPE string.
  DATA lv_audit_coverage_delta_text TYPE string.
  DATA lv_aud_shrt_pct_delta_text TYPE string.
  DATA lv_audit_requested_delta_text TYPE string.
  DATA lv_audit_available_delta_text TYPE string.
  DATA lv_audit_duration_delta_text TYPE string.
  DATA lv_audit_running_age_delta TYPE i.
  DATA lv_aud_run_age_delta_text TYPE string.
  DATA lv_aud_run_age_trend TYPE string.
  DATA lv_audit_start_delta_text TYPE string.
  DATA lv_audit_finish_delta_text TYPE string.
  DATA lv_old_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation_status.
  DATA lv_new_reconciliation TYPE zif_stock_allocation_compare=>ty_reconciliation_status.
  DATA lv_recon_status_changed TYPE abap_bool.
  DATA lv_recon_both_ok TYPE abap_bool.
  DATA lv_recon_transition TYPE string.
  DATA lv_audit_meta_changed TYPE abap_bool.
  DATA lv_audit_meta_reasons TYPE string.
  DATA lv_audit_demand_delta TYPE i.
  DATA lv_audit_full_delta TYPE i.
  DATA lv_audit_partial_delta TYPE i.
  DATA lv_audit_unallocated_delta TYPE i.
  DATA lt_changes TYPE zif_stock_allocation_compare=>tt_changes.
  DATA ls_summary TYPE zif_stock_allocation_compare=>ty_summary.
  DATA lt_csv_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_summary_json_fields TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lt_filter_value_fields TYPE zcl_stock_json=>tt_strings.
  DATA lv_csv_line TYPE string.
  DATA lv_json_line TYPE string.
  DATA lv_json_fields TYPE string.
  DATA lv_summary_json_fields TYPE string.
  DATA lv_filter_value_body TYPE string.
  DATA lv_filter_values_json TYPE string.
  DATA lv_error_message TYPE string.
  DATA lv_first TYPE abap_bool.
  DATA lv_total_rows TYPE i.
  DATA lv_has_more TYPE abap_bool.
  DATA lv_next_offset TYPE i.
  DATA lv_next_offset_text TYPE string.
  DATA lv_has_previous TYPE abap_bool.
  DATA lv_previous_offset TYPE i.
  DATA lv_previous_offset_text TYPE string.
  DATA lv_page_number TYPE i.
  DATA lv_page_number_text TYPE string.
  DATA lv_page_count TYPE i.
  DATA lv_page_count_text TYPE string.
  DATA lv_last_offset TYPE i.
  DATA lv_last_offset_text TYPE string.
  DATA lv_compare_offset TYPE i.
  DATA lv_compare_max_rows TYPE i.
  DATA lv_sort_start TYPE i.
  DATA lv_filters_applied TYPE abap_bool.
  DATA lt_filter_names TYPE STANDARD TABLE OF string WITH EMPTY KEY.
  DATA lv_filter_names_text TYPE string.
  DATA lv_sort_mode TYPE string.
  DATA lv_movement_filter TYPE string.
  DATA lv_old_movement_type TYPE zif_stock_allocation=>ty_movement_type.
  DATA lv_new_movement_type TYPE zif_stock_allocation=>ty_movement_type.
  DATA lv_old_movement_filter TYPE string.
  DATA lv_new_movement_filter TYPE string.
  DATA lv_min_shelf_filter TYPE string.
  DATA lv_old_shelf_life TYPE i.
  DATA lv_new_shelf_life TYPE i.
  DATA lv_old_shelf_filter TYPE string.
  DATA lv_new_shelf_filter TYPE string.
  DATA lv_old_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_new_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_old_unit_filter TYPE string.
  DATA lv_new_unit_filter TYPE string.
  DATA lv_reservation_movement_filter TYPE string.
  DATA lv_old_reservation_movement TYPE zif_stock_allocation=>ty_movement_type.
  DATA lv_new_reservation_movement TYPE zif_stock_allocation=>ty_movement_type.
  DATA lv_old_rmov_filter TYPE string.
  DATA lv_new_rmov_filter TYPE string.
  DATA lv_reservation_unit_filter TYPE string.
  DATA lv_old_reservation_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_new_reservation_unit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_old_runit_filter TYPE string.
  DATA lv_new_runit_filter TYPE string.
  DATA lv_old_reserved_only TYPE abap_bool.
  DATA lv_new_reserved_only TYPE abap_bool.
  DATA lv_old_unreserved_only TYPE abap_bool.
  DATA lv_new_unreserved_only TYPE abap_bool.
  DATA lv_old_shortage_only TYPE abap_bool.
  DATA lv_new_shortage_only TYPE abap_bool.
  DATA lv_shortage_from_filter TYPE string.
  DATA lv_shortage_to_filter TYPE string.
  DATA lv_old_shortage_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_shortage_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_shortage_from_filter TYPE string.
  DATA lv_old_shortage_to_filter TYPE string.
  DATA lv_new_shortage_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_shortage_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_shortage_from_filter TYPE string.
  DATA lv_new_shortage_to_filter TYPE string.
  DATA lv_old_coverage_from TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_coverage_to TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_coverage_from_filter TYPE string.
  DATA lv_old_coverage_to_filter TYPE string.
  DATA lv_new_coverage_from TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_coverage_to TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_coverage_from_filter TYPE string.
  DATA lv_new_coverage_to_filter TYPE string.
  DATA lv_old_shortage_pct_from TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_shortage_pct_to TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_old_sp_from_txt TYPE string.
  DATA lv_old_sp_to_txt TYPE string.
  DATA lv_new_shortage_pct_from TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_shortage_pct_to TYPE zif_allocation_audit=>ty_coverage.
  DATA lv_new_sp_from_txt TYPE string.
  DATA lv_new_sp_to_txt TYPE string.
  DATA lv_coverage_from_filter TYPE string.
  DATA lv_coverage_to_filter TYPE string.
  DATA lv_shortage_pct_from_filter TYPE string.
  DATA lv_shortage_pct_to_filter TYPE string.
  DATA lv_req_qty_from_txt TYPE string.
  DATA lv_req_qty_to_txt TYPE string.
  DATA lv_old_req_qty_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_req_qty_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_req_qty_from_txt TYPE string.
  DATA lv_old_req_qty_to_txt TYPE string.
  DATA lv_new_req_qty_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_req_qty_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_req_qty_from_txt TYPE string.
  DATA lv_new_req_qty_to_txt TYPE string.
  DATA lv_allocated_from_filter TYPE string.
  DATA lv_allocated_to_filter TYPE string.
  DATA lv_old_allocated_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_allocated_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_allocated_from_txt TYPE string.
  DATA lv_old_allocated_to_txt TYPE string.
  DATA lv_new_allocated_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_allocated_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_allocated_from_txt TYPE string.
  DATA lv_new_allocated_to_txt TYPE string.
  DATA lv_priority_from_txt TYPE string.
  DATA lv_priority_to_txt TYPE string.
  DATA lv_old_priority_from TYPE zif_stock_allocation=>ty_priority.
  DATA lv_old_priority_to TYPE zif_stock_allocation=>ty_priority.
  DATA lv_old_priority_from_txt TYPE string.
  DATA lv_old_priority_to_txt TYPE string.
  DATA lv_new_priority_from TYPE zif_stock_allocation=>ty_priority.
  DATA lv_new_priority_to TYPE zif_stock_allocation=>ty_priority.
  DATA lv_new_priority_from_txt TYPE string.
  DATA lv_new_priority_to_txt TYPE string.
  DATA lv_snapshot_from_filter TYPE c LENGTH 10.
  DATA lv_snapshot_to_filter TYPE c LENGTH 10.
  DATA lv_old_snapshot_from TYPE d.
  DATA lv_old_snapshot_to TYPE d.
  DATA lv_old_snapshot_from_filter TYPE c LENGTH 10.
  DATA lv_old_snapshot_to_filter TYPE c LENGTH 10.
  DATA lv_new_snapshot_from TYPE d.
  DATA lv_new_snapshot_to TYPE d.
  DATA lv_new_snapshot_from_filter TYPE c LENGTH 10.
  DATA lv_new_snapshot_to_filter TYPE c LENGTH 10.
  DATA lv_sales_document_filter TYPE string.
  DATA lv_old_sales_document_filter TYPE string.
  DATA lv_new_sales_document_filter TYPE string.
  DATA lv_old_sales_document TYPE zif_stock_allocation=>ty_sales_document.
  DATA lv_new_sales_document TYPE zif_stock_allocation=>ty_sales_document.
  DATA lv_auart_filter TYPE string.
  DATA lv_old_auart_filter TYPE string.
  DATA lv_new_auart_filter TYPE string.
  DATA lv_old_auart TYPE zif_stock_allocation=>ty_sales_document_type.
  DATA lv_new_auart TYPE zif_stock_allocation=>ty_sales_document_type.
  DATA lv_posnr_filter TYPE string.
  DATA lv_old_posnr_filter TYPE string.
  DATA lv_new_posnr_filter TYPE string.
  DATA lv_old_posnr TYPE zif_stock_allocation=>ty_sales_item.
  DATA lv_new_posnr TYPE zif_stock_allocation=>ty_sales_item.
  DATA lv_etenr_filter TYPE string.
  DATA lv_old_etenr_filter TYPE string.
  DATA lv_new_etenr_filter TYPE string.
  DATA lv_old_etenr TYPE zif_stock_allocation=>ty_schedule_line.
  DATA lv_new_etenr TYPE zif_stock_allocation=>ty_schedule_line.
  DATA lv_ordunit_filter TYPE string.
  DATA lv_old_ordunit_filter TYPE string.
  DATA lv_new_ordunit_filter TYPE string.
  DATA lv_old_ordunit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_new_ordunit TYPE zif_stock_allocation=>ty_unit.
  DATA lv_order_filter TYPE string.
  DATA lv_old_order_filter TYPE string.
  DATA lv_new_order_filter TYPE string.
  DATA lv_old_order TYPE zif_stock_allocation=>ty_order_id.
  DATA lv_new_order TYPE zif_stock_allocation=>ty_order_id.
  DATA lv_resid_filter TYPE string.
  DATA lv_old_resid_filter TYPE string.
  DATA lv_new_resid_filter TYPE string.
  DATA lv_old_resid TYPE zif_stock_allocation=>ty_order_id.
  DATA lv_new_resid TYPE zif_stock_allocation=>ty_order_id.
  DATA lv_batch_filter TYPE string.
  DATA lv_old_batch_filter TYPE string.
  DATA lv_new_batch_filter TYPE string.
  DATA lv_old_batch TYPE zif_stock_allocation=>ty_batch.
  DATA lv_new_batch TYPE zif_stock_allocation=>ty_batch.
  DATA lv_storage_location_filter TYPE string.
  DATA lv_old_storage_location_filter TYPE string.
  DATA lv_new_storage_location_filter TYPE string.
  DATA lv_old_storage_location TYPE zif_stock_allocation=>ty_storage_location.
  DATA lv_new_storage_location TYPE zif_stock_allocation=>ty_storage_location.
  DATA lv_material_filter TYPE string.
  DATA lv_old_material_filter TYPE string.
  DATA lv_new_material_filter TYPE string.
  DATA lv_old_material TYPE zif_stock_allocation=>ty_material.
  DATA lv_new_material TYPE zif_stock_allocation=>ty_material.
  DATA lv_plant_filter TYPE string.
  DATA lv_old_plant_filter TYPE string.
  DATA lv_new_plant_filter TYPE string.
  DATA lv_old_plant TYPE zif_stock_allocation=>ty_plant.
  DATA lv_new_plant TYPE zif_stock_allocation=>ty_plant.
  DATA lv_rdate_from_filter TYPE c LENGTH 10.
  DATA lv_rdate_to_filter TYPE c LENGTH 10.
  DATA lv_old_rdate_from_filter TYPE c LENGTH 10.
  DATA lv_old_rdate_to_filter TYPE c LENGTH 10.
  DATA lv_new_rdate_from_filter TYPE c LENGTH 10.
  DATA lv_new_rdate_to_filter TYPE c LENGTH 10.
  DATA lv_old_rdate_from TYPE d.
  DATA lv_old_rdate_to TYPE d.
  DATA lv_new_rdate_from TYPE d.
  DATA lv_new_rdate_to TYPE d.
  DATA lv_rage_filter TYPE string.
  DATA lv_rageto_filter TYPE string.
  DATA lv_old_rage TYPE i.
  DATA lv_old_rageto TYPE i.
  DATA lv_new_rage TYPE i.
  DATA lv_new_rageto TYPE i.
  DATA lv_old_rage_filter TYPE string.
  DATA lv_old_rageto_filter TYPE string.
  DATA lv_new_rage_filter TYPE string.
  DATA lv_new_rageto_filter TYPE string.
  DATA lv_old_audit_status_filter TYPE string.
  DATA lv_new_audit_status_filter TYPE string.
  DATA lv_old_strategy_filter TYPE string.
  DATA lv_new_strategy_filter TYPE string.
  DATA lv_old_legacy_strategy_filter TYPE string.
  DATA lv_new_legacy_strategy_filter TYPE string.
  DATA lv_old_message_filter TYPE string.
  DATA lv_new_message_filter TYPE string.
  DATA lv_old_message_only_text TYPE string.
  DATA lv_new_message_only_text TYPE string.
  DATA lv_overdue_as_of_filter TYPE c LENGTH 10.
  DATA lv_requested_from_filter TYPE c LENGTH 10.
  DATA lv_requested_to_filter TYPE c LENGTH 10.
  DATA lv_old_requested_from_filter TYPE c LENGTH 10.
  DATA lv_old_requested_to_filter TYPE c LENGTH 10.
  DATA lv_new_requested_from_filter TYPE c LENGTH 10.
  DATA lv_new_requested_to_filter TYPE c LENGTH 10.
  DATA lv_old_requested_from TYPE d.
  DATA lv_old_requested_to TYPE d.
  DATA lv_new_requested_from TYPE d.
  DATA lv_new_requested_to TYPE d.
  DATA lv_old_deadline_only TYPE abap_bool.
  DATA lv_new_deadline_only TYPE abap_bool.
  DATA lv_old_deadline_only_filter TYPE string.
  DATA lv_new_deadline_only_filter TYPE string.
  DATA lv_old_overdue_only TYPE abap_bool.
  DATA lv_new_overdue_only TYPE abap_bool.
  DATA lv_old_overdue_only_filter TYPE string.
  DATA lv_new_overdue_only_filter TYPE string.
  DATA lv_deadline_from_filter TYPE c LENGTH 10.
  DATA lv_deadline_to_filter TYPE c LENGTH 10.
  DATA lv_old_deadline_from TYPE d.
  DATA lv_old_deadline_to TYPE d.
  DATA lv_new_deadline_from TYPE d.
  DATA lv_new_deadline_to TYPE d.
  DATA lv_old_deadline_from_filter TYPE c LENGTH 10.
  DATA lv_old_deadline_to_filter TYPE c LENGTH 10.
  DATA lv_new_deadline_from_filter TYPE c LENGTH 10.
  DATA lv_new_deadline_to_filter TYPE c LENGTH 10.
  DATA lv_deadline_age_from_filter TYPE string.
  DATA lv_deadline_age_to_filter TYPE string.
  DATA lv_deadline_age_date_filter TYPE c LENGTH 10.
  DATA lv_old_deadline_age_from TYPE i.
  DATA lv_old_deadline_age_to TYPE i.
  DATA lv_new_deadline_age_from TYPE i.
  DATA lv_new_deadline_age_to TYPE i.
  DATA lv_old_age_from_txt TYPE string.
  DATA lv_old_age_to_txt TYPE string.
  DATA lv_new_age_from_txt TYPE string.
  DATA lv_new_age_to_txt TYPE string.
  DATA lv_duration_from_filter TYPE string.
  DATA lv_duration_to_filter TYPE string.
  DATA lv_old_duration_from TYPE i.
  DATA lv_old_duration_to TYPE i.
  DATA lv_new_duration_from TYPE i.
  DATA lv_new_duration_to TYPE i.
  DATA lv_old_duration_from_filter TYPE string.
  DATA lv_old_duration_to_filter TYPE string.
  DATA lv_new_duration_from_filter TYPE string.
  DATA lv_new_duration_to_filter TYPE string.
  DATA lv_available_from_filter TYPE string.
  DATA lv_available_to_filter TYPE string.
  DATA lv_old_available_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_available_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_old_available_from_filter TYPE string.
  DATA lv_old_available_to_filter TYPE string.
  DATA lv_new_available_from TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_available_to TYPE zif_stock_allocation=>ty_quantity.
  DATA lv_new_available_from_filter TYPE string.
  DATA lv_new_available_to_filter TYPE string.
  FIELD-SYMBOLS <ls_change> TYPE zif_stock_allocation_compare=>ty_change.

  lv_material_filter = p_matnr.
  IF lv_material_filter IS INITIAL.
    lv_material_filter = 'n/a'.
  ENDIF.
  IF p_omatnr IS INITIAL.
    lv_old_material = p_matnr.
    lv_old_material_filter = lv_material_filter.
  ELSE.
    lv_old_material = p_omatnr.
    lv_old_material_filter = p_omatnr.
  ENDIF.
  IF p_nmatnr IS INITIAL.
    lv_new_material = p_matnr.
    lv_new_material_filter = lv_material_filter.
  ELSE.
    lv_new_material = p_nmatnr.
    lv_new_material_filter = p_nmatnr.
  ENDIF.
  lv_plant_filter = p_werks.
  IF lv_plant_filter IS INITIAL.
    lv_plant_filter = 'n/a'.
  ENDIF.
  IF p_owerks IS INITIAL.
    lv_old_plant = p_werks.
    lv_old_plant_filter = lv_plant_filter.
  ELSE.
    lv_old_plant = p_owerks.
    lv_old_plant_filter = p_owerks.
  ENDIF.
  IF p_nwerks IS INITIAL.
    lv_new_plant = p_werks.
    lv_new_plant_filter = lv_plant_filter.
  ELSE.
    lv_new_plant = p_nwerks.
    lv_new_plant_filter = p_nwerks.
  ENDIF.

  lv_storage_location_filter = p_lgort.
  IF lv_storage_location_filter IS INITIAL.
    lv_storage_location_filter = 'n/a'.
  ENDIF.
  IF p_olgort IS INITIAL.
    lv_old_storage_location = p_lgort.
    lv_old_storage_location_filter = lv_storage_location_filter.
  ELSE.
    lv_old_storage_location = p_olgort.
    lv_old_storage_location_filter = p_olgort.
  ENDIF.
  IF p_nlgort IS INITIAL.
    lv_new_storage_location = p_lgort.
    lv_new_storage_location_filter = lv_storage_location_filter.
  ELSE.
    lv_new_storage_location = p_nlgort.
    lv_new_storage_location_filter = p_nlgort.
  ENDIF.

  lv_batch_filter = p_charg.
  IF lv_batch_filter IS INITIAL.
    lv_batch_filter = 'n/a'.
  ENDIF.
  IF p_obatch IS INITIAL.
    lv_old_batch = p_charg.
    lv_old_batch_filter = lv_batch_filter.
  ELSE.
    lv_old_batch = p_obatch.
    lv_old_batch_filter = p_obatch.
  ENDIF.
  IF p_nbatch IS INITIAL.
    lv_new_batch = p_charg.
    lv_new_batch_filter = lv_batch_filter.
  ELSE.
    lv_new_batch = p_nbatch.
    lv_new_batch_filter = p_nbatch.
  ENDIF.

  TRANSLATE p_mvt TO UPPER CASE.
  TRANSLATE p_omvt TO UPPER CASE.
  TRANSLATE p_nmvt TO UPPER CASE.
  TRANSLATE p_meins TO UPPER CASE.
  TRANSLATE p_ounit TO UPPER CASE.
  TRANSLATE p_nunit TO UPPER CASE.
  TRANSLATE p_ordun TO UPPER CASE.
  TRANSLATE p_oordun TO UPPER CASE.
  TRANSLATE p_nordun TO UPPER CASE.
  TRANSLATE p_rmov TO UPPER CASE.
  TRANSLATE p_ormov TO UPPER CASE.
  TRANSLATE p_nrmov TO UPPER CASE.
  TRANSLATE p_runit TO UPPER CASE.
  TRANSLATE p_orunit TO UPPER CASE.
  TRANSLATE p_nrunit TO UPPER CASE.
  TRANSLATE p_reason TO LOWER CASE.
  TRANSLATE p_ost TO UPPER CASE.
  TRANSLATE p_nst TO UPPER CASE.
  TRANSLATE p_oast TO UPPER CASE.
  TRANSLATE p_nast TO UPPER CASE.
  TRANSLATE p_ostr TO UPPER CASE.
  TRANSLATE p_nstr TO UPPER CASE.
  lv_movement_filter = p_mvt.
  IF lv_movement_filter IS INITIAL.
    lv_movement_filter = 'n/a'.
  ENDIF.
  IF p_omvt IS INITIAL.
    lv_old_movement_type = p_mvt.
    lv_old_movement_filter = lv_movement_filter.
  ELSE.
    lv_old_movement_type = p_omvt.
    lv_old_movement_filter = p_omvt.
  ENDIF.
  IF p_nmvt IS INITIAL.
    lv_new_movement_type = p_mvt.
    lv_new_movement_filter = lv_movement_filter.
  ELSE.
    lv_new_movement_type = p_nmvt.
    lv_new_movement_filter = p_nmvt.
  ENDIF.
  IF p_shelf IS INITIAL.
    lv_min_shelf_filter = 'n/a'.
  ELSE.
    lv_min_shelf_filter = zcl_stock_csv=>number( p_shelf ).
  ENDIF.
  IF p_oshelf IS INITIAL.
    lv_old_shelf_life = p_shelf.
    lv_old_shelf_filter = lv_min_shelf_filter.
  ELSE.
    lv_old_shelf_life = p_oshelf.
    lv_old_shelf_filter = zcl_stock_csv=>number( p_oshelf ).
  ENDIF.
  IF p_nshelf IS INITIAL.
    lv_new_shelf_life = p_shelf.
    lv_new_shelf_filter = lv_min_shelf_filter.
  ELSE.
    lv_new_shelf_life = p_nshelf.
    lv_new_shelf_filter = zcl_stock_csv=>number( p_nshelf ).
  ENDIF.
  IF p_ounit IS INITIAL.
    lv_old_unit = p_meins.
  ELSE.
    lv_old_unit = p_ounit.
  ENDIF.
  lv_old_unit_filter = lv_old_unit.
  IF lv_old_unit_filter IS INITIAL.
    lv_old_unit_filter = 'n/a'.
  ENDIF.
  IF p_nunit IS INITIAL.
    lv_new_unit = p_meins.
  ELSE.
    lv_new_unit = p_nunit.
  ENDIF.
  lv_new_unit_filter = lv_new_unit.
  IF lv_new_unit_filter IS INITIAL.
    lv_new_unit_filter = 'n/a'.
  ENDIF.
  lv_reservation_movement_filter = p_rmov.
  IF lv_reservation_movement_filter IS INITIAL.
    lv_reservation_movement_filter = 'n/a'.
  ENDIF.
  IF p_ormov IS INITIAL.
    lv_old_reservation_movement = p_rmov.
    lv_old_rmov_filter = lv_reservation_movement_filter.
  ELSE.
    lv_old_reservation_movement = p_ormov.
    lv_old_rmov_filter = p_ormov.
  ENDIF.
  IF p_nrmov IS INITIAL.
    lv_new_reservation_movement = p_rmov.
    lv_new_rmov_filter = lv_reservation_movement_filter.
  ELSE.
    lv_new_reservation_movement = p_nrmov.
    lv_new_rmov_filter = p_nrmov.
  ENDIF.
  lv_reservation_unit_filter = p_runit.
  IF lv_reservation_unit_filter IS INITIAL.
    lv_reservation_unit_filter = 'n/a'.
  ENDIF.
  IF p_orunit IS INITIAL.
    lv_old_reservation_unit = p_runit.
    lv_old_runit_filter = lv_reservation_unit_filter.
  ELSE.
    lv_old_reservation_unit = p_orunit.
    lv_old_runit_filter = p_orunit.
  ENDIF.
  IF p_nrunit IS INITIAL.
    lv_new_reservation_unit = p_runit.
    lv_new_runit_filter = lv_reservation_unit_filter.
  ELSE.
    lv_new_reservation_unit = p_nrunit.
    lv_new_runit_filter = p_nrunit.
  ENDIF.
  lv_old_reserved_only = p_rsv.
  IF p_orsv = abap_true.
    lv_old_reserved_only = abap_true.
  ENDIF.
  lv_new_reserved_only = p_rsv.
  IF p_nrsv = abap_true.
    lv_new_reserved_only = abap_true.
  ENDIF.
  lv_old_unreserved_only = p_unrsv.
  IF p_oursv = abap_true.
    lv_old_unreserved_only = abap_true.
  ENDIF.
  lv_new_unreserved_only = p_unrsv.
  IF p_nursv = abap_true.
    lv_new_unreserved_only = abap_true.
  ENDIF.
  lv_old_shortage_only = p_bklg.
  IF p_obklg = abap_true.
    lv_old_shortage_only = abap_true.
  ENDIF.
  lv_new_shortage_only = p_bklg.
  IF p_nbklg = abap_true.
    lv_new_shortage_only = abap_true.
  ENDIF.
  IF p_shf IS INITIAL.
    lv_shortage_from_filter = 'n/a'.
  ELSE.
    lv_shortage_from_filter = zcl_stock_csv=>number( p_shf ).
  ENDIF.
  IF p_sht IS INITIAL.
    lv_shortage_to_filter = 'n/a'.
  ELSE.
    lv_shortage_to_filter = zcl_stock_csv=>number( p_sht ).
  ENDIF.
  IF p_oshf IS INITIAL.
    lv_old_shortage_from = p_shf.
    lv_old_shortage_from_filter = lv_shortage_from_filter.
  ELSE.
    lv_old_shortage_from = p_oshf.
    lv_old_shortage_from_filter = zcl_stock_csv=>number( p_oshf ).
  ENDIF.
  IF p_osht IS INITIAL.
    lv_old_shortage_to = p_sht.
    lv_old_shortage_to_filter = lv_shortage_to_filter.
  ELSE.
    lv_old_shortage_to = p_osht.
    lv_old_shortage_to_filter = zcl_stock_csv=>number( p_osht ).
  ENDIF.
  IF p_nshf IS INITIAL.
    lv_new_shortage_from = p_shf.
    lv_new_shortage_from_filter = lv_shortage_from_filter.
  ELSE.
    lv_new_shortage_from = p_nshf.
    lv_new_shortage_from_filter = zcl_stock_csv=>number( p_nshf ).
  ENDIF.
  IF p_nsht IS INITIAL.
    lv_new_shortage_to = p_sht.
    lv_new_shortage_to_filter = lv_shortage_to_filter.
  ELSE.
    lv_new_shortage_to = p_nsht.
    lv_new_shortage_to_filter = zcl_stock_csv=>number( p_nsht ).
  ENDIF.
  IF p_covf IS INITIAL.
    lv_coverage_from_filter = 'n/a'.
  ELSE.
    lv_coverage_from_filter = zcl_stock_csv=>number( p_covf ).
  ENDIF.
  IF p_covt IS INITIAL.
    lv_coverage_to_filter = 'n/a'.
  ELSE.
    lv_coverage_to_filter = zcl_stock_csv=>number( p_covt ).
  ENDIF.
  IF p_ocovf IS INITIAL.
    lv_old_coverage_from = p_covf.
    lv_old_coverage_from_filter = lv_coverage_from_filter.
  ELSE.
    lv_old_coverage_from = p_ocovf.
    lv_old_coverage_from_filter = zcl_stock_csv=>number( p_ocovf ).
  ENDIF.
  IF p_ocovt IS INITIAL.
    lv_old_coverage_to = p_covt.
    lv_old_coverage_to_filter = lv_coverage_to_filter.
  ELSE.
    lv_old_coverage_to = p_ocovt.
    lv_old_coverage_to_filter = zcl_stock_csv=>number( p_ocovt ).
  ENDIF.
  IF p_ncovf IS INITIAL.
    lv_new_coverage_from = p_covf.
    lv_new_coverage_from_filter = lv_coverage_from_filter.
  ELSE.
    lv_new_coverage_from = p_ncovf.
    lv_new_coverage_from_filter = zcl_stock_csv=>number( p_ncovf ).
  ENDIF.
  IF p_ncovt IS INITIAL.
    lv_new_coverage_to = p_covt.
    lv_new_coverage_to_filter = lv_coverage_to_filter.
  ELSE.
    lv_new_coverage_to = p_ncovt.
    lv_new_coverage_to_filter = zcl_stock_csv=>number( p_ncovt ).
  ENDIF.
  IF p_spf IS INITIAL.
    lv_shortage_pct_from_filter = 'n/a'.
  ELSE.
    lv_shortage_pct_from_filter = zcl_stock_csv=>number( p_spf ).
  ENDIF.
  IF p_spt IS INITIAL.
    lv_shortage_pct_to_filter = 'n/a'.
  ELSE.
    lv_shortage_pct_to_filter = zcl_stock_csv=>number( p_spt ).
  ENDIF.
  IF p_ospf IS INITIAL.
    lv_old_shortage_pct_from = p_spf.
    lv_old_sp_from_txt = lv_shortage_pct_from_filter.
  ELSE.
    lv_old_shortage_pct_from = p_ospf.
    lv_old_sp_from_txt = zcl_stock_csv=>number( p_ospf ).
  ENDIF.
  IF p_ospt IS INITIAL.
    lv_old_shortage_pct_to = p_spt.
    lv_old_sp_to_txt = lv_shortage_pct_to_filter.
  ELSE.
    lv_old_shortage_pct_to = p_ospt.
    lv_old_sp_to_txt = zcl_stock_csv=>number( p_ospt ).
  ENDIF.
  IF p_nspf IS INITIAL.
    lv_new_shortage_pct_from = p_spf.
    lv_new_sp_from_txt = lv_shortage_pct_from_filter.
  ELSE.
    lv_new_shortage_pct_from = p_nspf.
    lv_new_sp_from_txt = zcl_stock_csv=>number( p_nspf ).
  ENDIF.
  IF p_nspt IS INITIAL.
    lv_new_shortage_pct_to = p_spt.
    lv_new_sp_to_txt = lv_shortage_pct_to_filter.
  ELSE.
    lv_new_shortage_pct_to = p_nspt.
    lv_new_sp_to_txt = zcl_stock_csv=>number( p_nspt ).
  ENDIF.
  IF p_qf IS INITIAL.
    lv_req_qty_from_txt = 'n/a'.
  ELSE.
    lv_req_qty_from_txt = zcl_stock_csv=>number( p_qf ).
  ENDIF.
  IF p_qt IS INITIAL.
    lv_req_qty_to_txt = 'n/a'.
  ELSE.
    lv_req_qty_to_txt = zcl_stock_csv=>number( p_qt ).
  ENDIF.
  IF p_oqf IS INITIAL.
    lv_old_req_qty_from = p_qf.
    lv_old_req_qty_from_txt = lv_req_qty_from_txt.
  ELSE.
    lv_old_req_qty_from = p_oqf.
    lv_old_req_qty_from_txt = zcl_stock_csv=>number( p_oqf ).
  ENDIF.
  IF p_oqt IS INITIAL.
    lv_old_req_qty_to = p_qt.
    lv_old_req_qty_to_txt = lv_req_qty_to_txt.
  ELSE.
    lv_old_req_qty_to = p_oqt.
    lv_old_req_qty_to_txt = zcl_stock_csv=>number( p_oqt ).
  ENDIF.
  IF p_nqf IS INITIAL.
    lv_new_req_qty_from = p_qf.
    lv_new_req_qty_from_txt = lv_req_qty_from_txt.
  ELSE.
    lv_new_req_qty_from = p_nqf.
    lv_new_req_qty_from_txt = zcl_stock_csv=>number( p_nqf ).
  ENDIF.
  IF p_nqt IS INITIAL.
    lv_new_req_qty_to = p_qt.
    lv_new_req_qty_to_txt = lv_req_qty_to_txt.
  ELSE.
    lv_new_req_qty_to = p_nqt.
    lv_new_req_qty_to_txt = zcl_stock_csv=>number( p_nqt ).
  ENDIF.
  IF p_af IS INITIAL.
    lv_allocated_from_filter = 'n/a'.
  ELSE.
    lv_allocated_from_filter = zcl_stock_csv=>number( p_af ).
  ENDIF.
  IF p_at IS INITIAL.
    lv_allocated_to_filter = 'n/a'.
  ELSE.
    lv_allocated_to_filter = zcl_stock_csv=>number( p_at ).
  ENDIF.
  IF p_oaf IS INITIAL.
    lv_old_allocated_from = p_af.
    lv_old_allocated_from_txt = lv_allocated_from_filter.
  ELSE.
    lv_old_allocated_from = p_oaf.
    lv_old_allocated_from_txt = zcl_stock_csv=>number( p_oaf ).
  ENDIF.
  IF p_oat IS INITIAL.
    lv_old_allocated_to = p_at.
    lv_old_allocated_to_txt = lv_allocated_to_filter.
  ELSE.
    lv_old_allocated_to = p_oat.
    lv_old_allocated_to_txt = zcl_stock_csv=>number( p_oat ).
  ENDIF.
  IF p_naf IS INITIAL.
    lv_new_allocated_from = p_af.
    lv_new_allocated_from_txt = lv_allocated_from_filter.
  ELSE.
    lv_new_allocated_from = p_naf.
    lv_new_allocated_from_txt = zcl_stock_csv=>number( p_naf ).
  ENDIF.
  IF p_nat IS INITIAL.
    lv_new_allocated_to = p_at.
    lv_new_allocated_to_txt = lv_allocated_to_filter.
  ELSE.
    lv_new_allocated_to = p_nat.
    lv_new_allocated_to_txt = zcl_stock_csv=>number( p_nat ).
  ENDIF.
  IF p_priof IS INITIAL.
    lv_priority_from_txt = 'n/a'.
  ELSE.
    lv_priority_from_txt = zcl_stock_csv=>number( p_priof ).
  ENDIF.
  IF p_priot IS INITIAL.
    lv_priority_to_txt = 'n/a'.
  ELSE.
    lv_priority_to_txt = zcl_stock_csv=>number( p_priot ).
  ENDIF.
  IF p_opf IS INITIAL.
    lv_old_priority_from = p_priof.
    lv_old_priority_from_txt = lv_priority_from_txt.
  ELSE.
    lv_old_priority_from = p_opf.
    lv_old_priority_from_txt = zcl_stock_csv=>number( p_opf ).
  ENDIF.
  IF p_opt IS INITIAL.
    lv_old_priority_to = p_priot.
    lv_old_priority_to_txt = lv_priority_to_txt.
  ELSE.
    lv_old_priority_to = p_opt.
    lv_old_priority_to_txt = zcl_stock_csv=>number( p_opt ).
  ENDIF.
  IF p_npf IS INITIAL.
    lv_new_priority_from = p_priof.
    lv_new_priority_from_txt = lv_priority_from_txt.
  ELSE.
    lv_new_priority_from = p_npf.
    lv_new_priority_from_txt = zcl_stock_csv=>number( p_npf ).
  ENDIF.
  IF p_npt IS INITIAL.
    lv_new_priority_to = p_priot.
    lv_new_priority_to_txt = lv_priority_to_txt.
  ELSE.
    lv_new_priority_to = p_npt.
    lv_new_priority_to_txt = zcl_stock_csv=>number( p_npt ).
  ENDIF.
  IF p_sdf IS INITIAL.
    lv_snapshot_from_filter = 'n/a'.
  ELSE.
    lv_snapshot_from_filter = p_sdf.
  ENDIF.
  IF p_sdt IS INITIAL.
    lv_snapshot_to_filter = 'n/a'.
  ELSE.
    lv_snapshot_to_filter = p_sdt.
  ENDIF.
  IF p_osdf IS INITIAL.
    lv_old_snapshot_from = p_sdf.
    lv_old_snapshot_from_filter = lv_snapshot_from_filter.
  ELSE.
    lv_old_snapshot_from = p_osdf.
    lv_old_snapshot_from_filter = p_osdf.
  ENDIF.
  IF p_osdt IS INITIAL.
    lv_old_snapshot_to = p_sdt.
    lv_old_snapshot_to_filter = lv_snapshot_to_filter.
  ELSE.
    lv_old_snapshot_to = p_osdt.
    lv_old_snapshot_to_filter = p_osdt.
  ENDIF.
  IF p_nsdf IS INITIAL.
    lv_new_snapshot_from = p_sdf.
    lv_new_snapshot_from_filter = lv_snapshot_from_filter.
  ELSE.
    lv_new_snapshot_from = p_nsdf.
    lv_new_snapshot_from_filter = p_nsdf.
  ENDIF.
  IF p_nsdt IS INITIAL.
    lv_new_snapshot_to = p_sdt.
    lv_new_snapshot_to_filter = lv_snapshot_to_filter.
  ELSE.
    lv_new_snapshot_to = p_nsdt.
    lv_new_snapshot_to_filter = p_nsdt.
  ENDIF.
  IF p_vbeln IS INITIAL.
    lv_sales_document_filter = 'n/a'.
  ELSE.
    lv_sales_document_filter = p_vbeln.
  ENDIF.
  IF p_ovbeln IS INITIAL.
    lv_old_sales_document = p_vbeln.
    lv_old_sales_document_filter = lv_sales_document_filter.
  ELSE.
    lv_old_sales_document = p_ovbeln.
    lv_old_sales_document_filter = p_ovbeln.
  ENDIF.
  IF p_nvbeln IS INITIAL.
    lv_new_sales_document = p_vbeln.
    lv_new_sales_document_filter = lv_sales_document_filter.
  ELSE.
    lv_new_sales_document = p_nvbeln.
    lv_new_sales_document_filter = p_nvbeln.
  ENDIF.
  IF p_auart IS INITIAL.
    lv_auart_filter = 'n/a'.
  ELSE.
    lv_auart_filter = p_auart.
  ENDIF.
  IF p_oauart IS INITIAL.
    lv_old_auart = p_auart.
    lv_old_auart_filter = lv_auart_filter.
  ELSE.
    lv_old_auart = p_oauart.
    lv_old_auart_filter = p_oauart.
  ENDIF.
  IF p_nauart IS INITIAL.
    lv_new_auart = p_auart.
    lv_new_auart_filter = lv_auart_filter.
  ELSE.
    lv_new_auart = p_nauart.
    lv_new_auart_filter = p_nauart.
  ENDIF.
  IF p_posnr IS INITIAL.
    lv_posnr_filter = 'n/a'.
  ELSE.
    lv_posnr_filter = p_posnr.
  ENDIF.
  IF p_oposnr IS INITIAL.
    lv_old_posnr = p_posnr.
    lv_old_posnr_filter = lv_posnr_filter.
  ELSE.
    lv_old_posnr = p_oposnr.
    lv_old_posnr_filter = p_oposnr.
  ENDIF.
  IF p_nposnr IS INITIAL.
    lv_new_posnr = p_posnr.
    lv_new_posnr_filter = lv_posnr_filter.
  ELSE.
    lv_new_posnr = p_nposnr.
    lv_new_posnr_filter = p_nposnr.
  ENDIF.
  IF p_etenr IS INITIAL.
    lv_etenr_filter = 'n/a'.
  ELSE.
    lv_etenr_filter = p_etenr.
  ENDIF.
  IF p_oetenr IS INITIAL.
    lv_old_etenr = p_etenr.
    lv_old_etenr_filter = lv_etenr_filter.
  ELSE.
    lv_old_etenr = p_oetenr.
    lv_old_etenr_filter = p_oetenr.
  ENDIF.
  IF p_netenr IS INITIAL.
    lv_new_etenr = p_etenr.
    lv_new_etenr_filter = lv_etenr_filter.
  ELSE.
    lv_new_etenr = p_netenr.
    lv_new_etenr_filter = p_netenr.
  ENDIF.
  IF p_ordun IS INITIAL.
    lv_ordunit_filter = 'n/a'.
  ELSE.
    lv_ordunit_filter = p_ordun.
  ENDIF.
  IF p_oordun IS INITIAL.
    lv_old_ordunit = p_ordun.
    lv_old_ordunit_filter = lv_ordunit_filter.
  ELSE.
    lv_old_ordunit = p_oordun.
    lv_old_ordunit_filter = p_oordun.
  ENDIF.
  IF p_nordun IS INITIAL.
    lv_new_ordunit = p_ordun.
    lv_new_ordunit_filter = lv_ordunit_filter.
  ELSE.
    lv_new_ordunit = p_nordun.
    lv_new_ordunit_filter = p_nordun.
  ENDIF.
  IF p_order IS INITIAL.
    lv_order_filter = 'n/a'.
  ELSE.
    lv_order_filter = p_order.
  ENDIF.
  IF p_oorder IS INITIAL.
    lv_old_order = p_order.
    lv_old_order_filter = lv_order_filter.
  ELSE.
    lv_old_order = p_oorder.
    lv_old_order_filter = p_oorder.
  ENDIF.
  IF p_norder IS INITIAL.
    lv_new_order = p_order.
    lv_new_order_filter = lv_order_filter.
  ELSE.
    lv_new_order = p_norder.
    lv_new_order_filter = p_norder.
  ENDIF.
  IF p_resid IS INITIAL.
    lv_resid_filter = 'n/a'.
  ELSE.
    lv_resid_filter = p_resid.
  ENDIF.
  IF p_oresid IS INITIAL.
    lv_old_resid = p_resid.
    lv_old_resid_filter = lv_resid_filter.
  ELSE.
    lv_old_resid = p_oresid.
    lv_old_resid_filter = p_oresid.
  ENDIF.
  IF p_nresid IS INITIAL.
    lv_new_resid = p_resid.
    lv_new_resid_filter = lv_resid_filter.
  ELSE.
    lv_new_resid = p_nresid.
    lv_new_resid_filter = p_nresid.
  ENDIF.
  IF p_rfrom IS INITIAL.
    lv_rdate_from_filter = 'n/a'.
  ELSE.
    lv_rdate_from_filter = p_rfrom.
  ENDIF.
  IF p_rto IS INITIAL.
    lv_rdate_to_filter = 'n/a'.
  ELSE.
    lv_rdate_to_filter = p_rto.
  ENDIF.
  IF p_orfrom IS INITIAL.
    lv_old_rdate_from = p_rfrom.
    lv_old_rdate_from_filter = lv_rdate_from_filter.
  ELSE.
    lv_old_rdate_from = p_orfrom.
    lv_old_rdate_from_filter = p_orfrom.
  ENDIF.
  IF p_orto IS INITIAL.
    lv_old_rdate_to = p_rto.
    lv_old_rdate_to_filter = lv_rdate_to_filter.
  ELSE.
    lv_old_rdate_to = p_orto.
    lv_old_rdate_to_filter = p_orto.
  ENDIF.
  IF p_nrfrom IS INITIAL.
    lv_new_rdate_from = p_rfrom.
    lv_new_rdate_from_filter = lv_rdate_from_filter.
  ELSE.
    lv_new_rdate_from = p_nrfrom.
    lv_new_rdate_from_filter = p_nrfrom.
  ENDIF.
  IF p_nrto IS INITIAL.
    lv_new_rdate_to = p_rto.
    lv_new_rdate_to_filter = lv_rdate_to_filter.
  ELSE.
    lv_new_rdate_to = p_nrto.
    lv_new_rdate_to_filter = p_nrto.
  ENDIF.
  IF p_rage IS INITIAL.
    lv_rage_filter = 'n/a'.
  ELSE.
    lv_rage_filter = zcl_stock_csv=>number( p_rage ).
  ENDIF.
  IF p_rageto IS INITIAL.
    lv_rageto_filter = 'n/a'.
  ELSE.
    lv_rageto_filter = zcl_stock_csv=>number( p_rageto ).
  ENDIF.
  IF p_orage IS INITIAL.
    lv_old_rage = p_rage.
    lv_old_rage_filter = lv_rage_filter.
  ELSE.
    lv_old_rage = p_orage.
    lv_old_rage_filter = zcl_stock_csv=>number( p_orage ).
  ENDIF.
  IF p_oragto IS INITIAL.
    lv_old_rageto = p_rageto.
    lv_old_rageto_filter = lv_rageto_filter.
  ELSE.
    lv_old_rageto = p_oragto.
    lv_old_rageto_filter = zcl_stock_csv=>number( p_oragto ).
  ENDIF.
  IF p_nrage IS INITIAL.
    lv_new_rage = p_rage.
    lv_new_rage_filter = lv_rage_filter.
  ELSE.
    lv_new_rage = p_nrage.
    lv_new_rage_filter = zcl_stock_csv=>number( p_nrage ).
  ENDIF.
  IF p_nragto IS INITIAL.
    lv_new_rageto = p_rageto.
    lv_new_rageto_filter = lv_rageto_filter.
  ELSE.
    lv_new_rageto = p_nragto.
    lv_new_rageto_filter = zcl_stock_csv=>number( p_nragto ).
  ENDIF.
  lv_old_audit_status_filter = p_oast.
  IF lv_old_audit_status_filter IS INITIAL.
    lv_old_audit_status_filter = 'n/a'.
  ENDIF.
  lv_new_audit_status_filter = p_nast.
  IF lv_new_audit_status_filter IS INITIAL.
    lv_new_audit_status_filter = 'n/a'.
  ENDIF.
  lv_old_strategy_filter = p_ostr.
  IF lv_old_strategy_filter IS INITIAL.
    lv_old_strategy_filter = 'n/a'.
  ENDIF.
  lv_new_strategy_filter = p_nstr.
  IF lv_new_strategy_filter IS INITIAL.
    lv_new_strategy_filter = 'n/a'.
  ENDIF.
  IF p_oleg = abap_true.
    lv_old_legacy_strategy_filter = 'true'.
  ELSE.
    lv_old_legacy_strategy_filter = 'false'.
  ENDIF.
  IF p_nleg = abap_true.
    lv_new_legacy_strategy_filter = 'true'.
  ELSE.
    lv_new_legacy_strategy_filter = 'false'.
  ENDIF.
  lv_old_message_filter = p_omsg.
  IF lv_old_message_filter IS INITIAL.
    lv_old_message_filter = 'n/a'.
  ENDIF.
  lv_new_message_filter = p_nmsg.
  IF lv_new_message_filter IS INITIAL.
    lv_new_message_filter = 'n/a'.
  ENDIF.
  IF p_omonly = abap_true.
    lv_old_message_only_text = 'true'.
  ELSE.
    lv_old_message_only_text = 'false'.
  ENDIF.
  IF p_nmonly = abap_true.
    lv_new_message_only_text = 'true'.
  ELSE.
    lv_new_message_only_text = 'false'.
  ENDIF.
  IF p_odate IS INITIAL.
    lv_overdue_as_of_filter = 'n/a'.
    lv_deadline_reference_date = sy-datum.
  ELSE.
    lv_overdue_as_of_filter = p_odate.
    lv_deadline_reference_date = p_odate.
  ENDIF.
  IF p_reqf IS INITIAL.
    lv_requested_from_filter = 'n/a'.
  ELSE.
    lv_requested_from_filter = p_reqf.
  ENDIF.
  IF p_until IS INITIAL.
    lv_requested_to_filter = 'n/a'.
  ELSE.
    lv_requested_to_filter = p_until.
  ENDIF.
  IF p_oreqf IS INITIAL.
    lv_old_requested_from = p_reqf.
    lv_old_requested_from_filter = lv_requested_from_filter.
  ELSE.
    lv_old_requested_from = p_oreqf.
    lv_old_requested_from_filter = p_oreqf.
  ENDIF.
  IF p_oreqt IS INITIAL.
    lv_old_requested_to = p_until.
    lv_old_requested_to_filter = lv_requested_to_filter.
  ELSE.
    lv_old_requested_to = p_oreqt.
    lv_old_requested_to_filter = p_oreqt.
  ENDIF.
  IF p_nreqf IS INITIAL.
    lv_new_requested_from = p_reqf.
    lv_new_requested_from_filter = lv_requested_from_filter.
  ELSE.
    lv_new_requested_from = p_nreqf.
    lv_new_requested_from_filter = p_nreqf.
  ENDIF.
  IF p_nreqt IS INITIAL.
    lv_new_requested_to = p_until.
    lv_new_requested_to_filter = lv_requested_to_filter.
  ELSE.
    lv_new_requested_to = p_nreqt.
    lv_new_requested_to_filter = p_nreqt.
  ENDIF.
  IF p_odead = abap_true.
    lv_old_deadline_only = abap_true.
  ELSE.
    lv_old_deadline_only = p_dead.
  ENDIF.
  IF p_ndead = abap_true.
    lv_new_deadline_only = abap_true.
  ELSE.
    lv_new_deadline_only = p_dead.
  ENDIF.
  IF lv_old_deadline_only = abap_true.
    lv_old_deadline_only_filter = 'true'.
  ELSE.
    lv_old_deadline_only_filter = 'false'.
  ENDIF.
  IF lv_new_deadline_only = abap_true.
    lv_new_deadline_only_filter = 'true'.
  ELSE.
    lv_new_deadline_only_filter = 'false'.
  ENDIF.
  IF p_deadf IS INITIAL.
    lv_deadline_from_filter = 'n/a'.
  ELSE.
    lv_deadline_from_filter = p_deadf.
  ENDIF.
  IF p_deadt IS INITIAL.
    lv_deadline_to_filter = 'n/a'.
  ELSE.
    lv_deadline_to_filter = p_deadt.
  ENDIF.
  IF p_odeadf IS INITIAL.
    lv_old_deadline_from = p_deadf.
    lv_old_deadline_from_filter = lv_deadline_from_filter.
  ELSE.
    lv_old_deadline_from = p_odeadf.
    lv_old_deadline_from_filter = p_odeadf.
  ENDIF.
  IF p_odeadt IS INITIAL.
    lv_old_deadline_to = p_deadt.
    lv_old_deadline_to_filter = lv_deadline_to_filter.
  ELSE.
    lv_old_deadline_to = p_odeadt.
    lv_old_deadline_to_filter = p_odeadt.
  ENDIF.
  IF p_ndeadf IS INITIAL.
    lv_new_deadline_from = p_deadf.
    lv_new_deadline_from_filter = lv_deadline_from_filter.
  ELSE.
    lv_new_deadline_from = p_ndeadf.
    lv_new_deadline_from_filter = p_ndeadf.
  ENDIF.
  IF p_ndeadt IS INITIAL.
    lv_new_deadline_to = p_deadt.
    lv_new_deadline_to_filter = lv_deadline_to_filter.
  ELSE.
    lv_new_deadline_to = p_ndeadt.
    lv_new_deadline_to_filter = p_ndeadt.
  ENDIF.
  IF p_dagef IS INITIAL.
    lv_deadline_age_from_filter = 'n/a'.
  ELSE.
    lv_deadline_age_from_filter = zcl_stock_csv=>number( p_dagef ).
  ENDIF.
  IF p_daget IS INITIAL.
    lv_deadline_age_to_filter = 'n/a'.
  ELSE.
    lv_deadline_age_to_filter = zcl_stock_csv=>number( p_daget ).
  ENDIF.
  IF p_daged IS INITIAL.
    lv_deadline_age_date_filter = 'n/a'.
  ELSE.
    lv_deadline_age_date_filter = p_daged.
    lv_deadline_reference_date = p_daged.
  ENDIF.
  IF p_oagef IS INITIAL.
    lv_old_deadline_age_from = p_dagef.
    lv_old_age_from_txt = lv_deadline_age_from_filter.
  ELSE.
    lv_old_deadline_age_from = p_oagef.
    lv_old_age_from_txt = zcl_stock_csv=>number( p_oagef ).
  ENDIF.
  IF p_oaget IS INITIAL.
    lv_old_deadline_age_to = p_daget.
    lv_old_age_to_txt = lv_deadline_age_to_filter.
  ELSE.
    lv_old_deadline_age_to = p_oaget.
    lv_old_age_to_txt = zcl_stock_csv=>number( p_oaget ).
  ENDIF.
  IF p_nagef IS INITIAL.
    lv_new_deadline_age_from = p_dagef.
    lv_new_age_from_txt = lv_deadline_age_from_filter.
  ELSE.
    lv_new_deadline_age_from = p_nagef.
    lv_new_age_from_txt = zcl_stock_csv=>number( p_nagef ).
  ENDIF.
  IF p_naget IS INITIAL.
    lv_new_deadline_age_to = p_daget.
    lv_new_age_to_txt = lv_deadline_age_to_filter.
  ELSE.
    lv_new_deadline_age_to = p_naget.
    lv_new_age_to_txt = zcl_stock_csv=>number( p_naget ).
  ENDIF.
  IF p_tfrom IS INITIAL.
    lv_duration_from_filter = 'n/a'.
  ELSE.
    lv_duration_from_filter = zcl_stock_csv=>number( p_tfrom ).
  ENDIF.
  IF p_tto IS INITIAL.
    lv_duration_to_filter = 'n/a'.
  ELSE.
    lv_duration_to_filter = zcl_stock_csv=>number( p_tto ).
  ENDIF.
  IF p_otfrom IS INITIAL.
    lv_old_duration_from = p_tfrom.
    lv_old_duration_from_filter = lv_duration_from_filter.
  ELSE.
    lv_old_duration_from = p_otfrom.
    lv_old_duration_from_filter = zcl_stock_csv=>number( p_otfrom ).
  ENDIF.
  IF p_otto IS INITIAL.
    lv_old_duration_to = p_tto.
    lv_old_duration_to_filter = lv_duration_to_filter.
  ELSE.
    lv_old_duration_to = p_otto.
    lv_old_duration_to_filter = zcl_stock_csv=>number( p_otto ).
  ENDIF.
  IF p_ntfrom IS INITIAL.
    lv_new_duration_from = p_tfrom.
    lv_new_duration_from_filter = lv_duration_from_filter.
  ELSE.
    lv_new_duration_from = p_ntfrom.
    lv_new_duration_from_filter = zcl_stock_csv=>number( p_ntfrom ).
  ENDIF.
  IF p_ntto IS INITIAL.
    lv_new_duration_to = p_tto.
    lv_new_duration_to_filter = lv_duration_to_filter.
  ELSE.
    lv_new_duration_to = p_ntto.
    lv_new_duration_to_filter = zcl_stock_csv=>number( p_ntto ).
  ENDIF.
  IF p_avf IS INITIAL.
    lv_available_from_filter = 'n/a'.
  ELSE.
    lv_available_from_filter = zcl_stock_csv=>number( p_avf ).
  ENDIF.
  IF p_avt IS INITIAL.
    lv_available_to_filter = 'n/a'.
  ELSE.
    lv_available_to_filter = zcl_stock_csv=>number( p_avt ).
  ENDIF.
  IF p_oavf IS INITIAL.
    lv_old_available_from = p_avf.
    lv_old_available_from_filter = lv_available_from_filter.
  ELSE.
    lv_old_available_from = p_oavf.
    lv_old_available_from_filter = zcl_stock_csv=>number( p_oavf ).
  ENDIF.
  IF p_oavt IS INITIAL.
    lv_old_available_to = p_avt.
    lv_old_available_to_filter = lv_available_to_filter.
  ELSE.
    lv_old_available_to = p_oavt.
    lv_old_available_to_filter = zcl_stock_csv=>number( p_oavt ).
  ENDIF.
  IF p_navf IS INITIAL.
    lv_new_available_from = p_avf.
    lv_new_available_from_filter = lv_available_from_filter.
  ELSE.
    lv_new_available_from = p_navf.
    lv_new_available_from_filter = zcl_stock_csv=>number( p_navf ).
  ENDIF.
  IF p_navt IS INITIAL.
    lv_new_available_to = p_avt.
    lv_new_available_to_filter = lv_available_to_filter.
  ELSE.
    lv_new_available_to = p_navt.
    lv_new_available_to_filter = zcl_stock_csv=>number( p_navt ).
  ENDIF.
  IF p_oovrd = abap_true.
    lv_old_overdue_only = abap_true.
  ELSE.
    lv_old_overdue_only = p_ovrd.
  ENDIF.
  IF p_novrd = abap_true.
    lv_new_overdue_only = abap_true.
  ELSE.
    lv_new_overdue_only = p_ovrd.
  ENDIF.
  IF lv_old_overdue_only = abap_true.
    lv_old_overdue_only_filter = 'true'.
  ELSE.
    lv_old_overdue_only_filter = 'false'.
  ENDIF.
  IF lv_new_overdue_only = abap_true.
    lv_new_overdue_only_filter = 'true'.
  ELSE.
    lv_new_overdue_only_filter = 'false'.
  ENDIF.
  IF p_old = p_new.
    lv_error_message = 'Old and new allocation run IDs must be different'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_csv = abap_true AND p_json = abap_true.
    WRITE: / zcl_stock_json=>error(
      'CSV and JSON output cannot be selected together' ).
    RETURN.
  ENDIF.
  IF p_typed = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = 'Typed output requires JSON mode' ).
    ELSE.
      WRITE: / 'Typed output requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_meta = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = 'Comparison metadata requires JSON mode' ).
    ELSE.
      WRITE: / 'Comparison metadata requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_json = abap_false.
    IF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = 'NDJSON output requires JSON mode' ).
    ELSE.
      WRITE: / 'NDJSON output requires JSON mode.'.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_meta = abap_true.
    WRITE: / zcl_stock_json=>error(
      'NDJSON output cannot be combined with metadata output' ).
    RETURN.
  ENDIF.
  IF p_ndjson = abap_true AND p_sum = abap_true.
    WRITE: / zcl_stock_json=>error(
      'NDJSON output cannot be combined with summary mode' ).
    RETURN.
  ENDIF.
  IF p_chg IS NOT INITIAL
      AND p_chg <> 'A'
      AND p_chg <> 'R'
      AND p_chg <> 'C'
      AND p_chg <> 'U'.
    lv_error_message = 'Comparison change type is invalid'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_skip < 0 OR p_max < 0.
    lv_error_message = 'Comparison pagination is invalid'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shelf < 0.
    lv_error_message = 'Minimum shelf-life filter must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_oshelf < 0 OR p_nshelf < 0.
    lv_error_message = 'Side-specific shelf-life filters must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shelf IS NOT INITIAL
      AND ( p_oshelf IS NOT INITIAL OR p_nshelf IS NOT INITIAL ).
    lv_error_message =
      'Common and side-specific shelf-life filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_meins IS NOT INITIAL
      AND ( p_ounit IS NOT INITIAL OR p_nunit IS NOT INITIAL ).
    lv_error_message =
      'Common and side-specific unit filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF ( p_rmov IS NOT INITIAL AND p_rmov CN '0123456789' )
      OR ( p_ormov IS NOT INITIAL AND p_ormov CN '0123456789' )
      OR ( p_nrmov IS NOT INITIAL AND p_nrmov CN '0123456789' ).
    lv_error_message = 'Reservation movement type filter is invalid'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_rmov IS NOT INITIAL
      AND ( p_ormov IS NOT INITIAL OR p_nrmov IS NOT INITIAL ).
    lv_error_message =
      'Common and side-specific reservation movement filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_runit IS NOT INITIAL
      AND ( p_orunit IS NOT INITIAL OR p_nrunit IS NOT INITIAL ).
    lv_error_message =
      'Common and side-specific reservation unit filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_rsv = abap_true AND p_unrsv = abap_true.
    lv_error_message = 'Common reservation filters conflict'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_orsv = abap_true AND p_oursv = abap_true.
    lv_error_message = 'Old reservation filters conflict'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nrsv = abap_true AND p_nursv = abap_true.
    lv_error_message = 'New reservation filters conflict'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF ( p_rsv = abap_true OR p_unrsv = abap_true )
      AND ( p_orsv = abap_true OR p_nrsv = abap_true
        OR p_oursv = abap_true OR p_nursv = abap_true ).
    lv_error_message =
      'Common and side-specific reservation filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_bklg = abap_true
      AND ( p_obklg = abap_true OR p_nbklg = abap_true ).
    lv_error_message =
      'Common and side-specific shortage filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shf < 0 OR p_sht < 0 OR p_oshf < 0 OR p_osht < 0
      OR p_nshf < 0 OR p_nsht < 0.
    lv_error_message = 'Shortage bounds must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shf IS NOT INITIAL AND p_sht IS NOT INITIAL
      AND p_shf > p_sht.
    lv_error_message =
      'The common shortage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_oshf IS NOT INITIAL AND p_osht IS NOT INITIAL
      AND p_oshf > p_osht.
    lv_error_message =
      'The old shortage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nshf IS NOT INITIAL AND p_nsht IS NOT INITIAL
      AND p_nshf > p_nsht.
    lv_error_message =
      'The new shortage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_shf IS NOT INITIAL OR p_sht IS NOT INITIAL.
    IF p_oshf IS NOT INITIAL OR p_osht IS NOT INITIAL
        OR p_nshf IS NOT INITIAL OR p_nsht IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific shortage ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_covf < 0 OR p_covf > 100 OR p_covt < 0 OR p_covt > 100
      OR p_ocovf < 0 OR p_ocovf > 100 OR p_ocovt < 0 OR p_ocovt > 100
      OR p_ncovf < 0 OR p_ncovf > 100 OR p_ncovt < 0 OR p_ncovt > 100
      OR p_spf < 0 OR p_spf > 100 OR p_spt < 0 OR p_spt > 100
      OR p_ospf < 0 OR p_ospf > 100 OR p_ospt < 0 OR p_ospt > 100
      OR p_nspf < 0 OR p_nspf > 100 OR p_nspt < 0 OR p_nspt > 100.
    lv_error_message = 'Percentage bounds must be between 0 and 100'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_covf IS NOT INITIAL AND p_covt IS NOT INITIAL
      AND p_covf > p_covt.
    lv_error_message = 'The common coverage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ocovf IS NOT INITIAL AND p_ocovt IS NOT INITIAL
      AND p_ocovf > p_ocovt.
    lv_error_message = 'The old coverage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ncovf IS NOT INITIAL AND p_ncovt IS NOT INITIAL
      AND p_ncovf > p_ncovt.
    lv_error_message = 'The new coverage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_spf IS NOT INITIAL AND p_spt IS NOT INITIAL
      AND p_spf > p_spt.
    lv_error_message =
      'The common shortage percentage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ospf IS NOT INITIAL AND p_ospt IS NOT INITIAL
      AND p_ospf > p_ospt.
    lv_error_message =
      'The old shortage percentage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nspf IS NOT INITIAL AND p_nspt IS NOT INITIAL
      AND p_nspf > p_nspt.
    lv_error_message =
      'The new shortage percentage start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_covf IS NOT INITIAL OR p_covt IS NOT INITIAL.
    IF p_ocovf IS NOT INITIAL OR p_ocovt IS NOT INITIAL
        OR p_ncovf IS NOT INITIAL OR p_ncovt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific coverage ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_spf IS NOT INITIAL OR p_spt IS NOT INITIAL.
    IF p_ospf IS NOT INITIAL OR p_ospt IS NOT INITIAL
        OR p_nspf IS NOT INITIAL OR p_nspt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific shortage percentage ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_qf < 0 OR p_qt < 0 OR p_oqf < 0 OR p_oqt < 0
      OR p_nqf < 0 OR p_nqt < 0 OR p_af < 0 OR p_at < 0
      OR p_oaf < 0 OR p_oat < 0 OR p_naf < 0 OR p_nat < 0.
    lv_error_message = 'Quantity bounds must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_qf IS NOT INITIAL AND p_qt IS NOT INITIAL AND p_qf > p_qt
      OR p_oqf IS NOT INITIAL AND p_oqt IS NOT INITIAL AND p_oqf > p_oqt
      OR p_nqf IS NOT INITIAL AND p_nqt IS NOT INITIAL AND p_nqf > p_nqt
      OR p_af IS NOT INITIAL AND p_at IS NOT INITIAL AND p_af > p_at
      OR p_oaf IS NOT INITIAL AND p_oat IS NOT INITIAL AND p_oaf > p_oat
      OR p_naf IS NOT INITIAL AND p_nat IS NOT INITIAL AND p_naf > p_nat.
    lv_error_message = 'Quantity range start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_qf IS NOT INITIAL OR p_qt IS NOT INITIAL.
    IF p_oqf IS NOT INITIAL OR p_oqt IS NOT INITIAL
        OR p_nqf IS NOT INITIAL OR p_nqt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific requested quantity ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_af IS NOT INITIAL OR p_at IS NOT INITIAL.
    IF p_oaf IS NOT INITIAL OR p_oat IS NOT INITIAL
        OR p_naf IS NOT INITIAL OR p_nat IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific allocated quantity ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_priof < 0 OR p_priot < 0 OR p_opf < 0 OR p_opt < 0
      OR p_npf < 0 OR p_npt < 0.
    lv_error_message = 'Priority bounds must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_priof IS NOT INITIAL AND p_priot IS NOT INITIAL
      AND p_priof > p_priot
      OR p_opf IS NOT INITIAL AND p_opt IS NOT INITIAL AND p_opf > p_opt
      OR p_npf IS NOT INITIAL AND p_npt IS NOT INITIAL AND p_npf > p_npt.
    lv_error_message = 'Priority range start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_priof IS NOT INITIAL OR p_priot IS NOT INITIAL.
    IF p_opf IS NOT INITIAL OR p_opt IS NOT INITIAL
        OR p_npf IS NOT INITIAL OR p_npt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific priority ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_sdf IS NOT INITIAL AND p_sdt IS NOT INITIAL
      AND p_sdf > p_sdt
      OR p_osdf IS NOT INITIAL AND p_osdt IS NOT INITIAL
        AND p_osdf > p_osdt
      OR p_nsdf IS NOT INITIAL AND p_nsdt IS NOT INITIAL
        AND p_nsdf > p_nsdt.
    lv_error_message =
      'Snapshot requested-date range start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_sdf IS NOT INITIAL OR p_sdt IS NOT INITIAL.
    IF p_osdf IS NOT INITIAL OR p_osdt IS NOT INITIAL
        OR p_nsdf IS NOT INITIAL OR p_nsdt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific snapshot date ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_vbeln IS NOT INITIAL.
    IF p_ovbeln IS NOT INITIAL OR p_nvbeln IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific sales-document filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_auart IS NOT INITIAL.
    IF p_oauart IS NOT INITIAL OR p_nauart IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific sales-document-type filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_posnr IS NOT INITIAL.
    IF p_oposnr IS NOT INITIAL OR p_nposnr IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific sales-item filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_etenr IS NOT INITIAL.
    IF p_oetenr IS NOT INITIAL OR p_netenr IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific schedule-line filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_ordun IS NOT INITIAL.
    IF p_oordun IS NOT INITIAL OR p_nordun IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific order-unit filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_order IS NOT INITIAL.
    IF p_oorder IS NOT INITIAL OR p_norder IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific order-ID filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_resid IS NOT INITIAL.
    IF p_oresid IS NOT INITIAL OR p_nresid IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific reservation-ID filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_charg IS NOT INITIAL.
    IF p_obatch IS NOT INITIAL OR p_nbatch IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific batch filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ELSEIF p_obatch IS INITIAL OR p_nbatch IS INITIAL.
    lv_error_message =
      'Batch requires a common value or both old and new values'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_lgort IS NOT INITIAL.
    IF p_olgort IS NOT INITIAL OR p_nlgort IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific storage-location filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ELSEIF p_olgort IS INITIAL OR p_nlgort IS INITIAL.
    lv_error_message =
      'Storage location requires a common value or both old and new values'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_matnr IS NOT INITIAL.
    IF p_omatnr IS NOT INITIAL OR p_nmatnr IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific material filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ELSEIF p_omatnr IS INITIAL OR p_nmatnr IS INITIAL.
    lv_error_message =
      'Material requires a common value or both old and new values'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_werks IS NOT INITIAL.
    IF p_owerks IS NOT INITIAL OR p_nwerks IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific plant filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ELSEIF p_owerks IS INITIAL OR p_nwerks IS INITIAL.
    lv_error_message =
      'Plant requires a common value or both old and new values'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ostr IS NOT INITIAL
      AND p_ostr <> 'P'
      AND p_ostr <> 'F'
      AND p_ostr <> 'N'
      AND p_ostr <> 'S'
      AND p_ostr <> 'L'
      AND p_ostr <> 'B'
      AND p_ostr <> 'E'
      AND p_ostr <> 'A'
      AND p_ostr <> 'W'.
    lv_error_message = 'Old strategy filter must be P, F, N, S, L, B, E, A, or W'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nstr IS NOT INITIAL
      AND p_nstr <> 'P'
      AND p_nstr <> 'F'
      AND p_nstr <> 'N'
      AND p_nstr <> 'S'
      AND p_nstr <> 'L'
      AND p_nstr <> 'B'
      AND p_nstr <> 'E'
      AND p_nstr <> 'A'
      AND p_nstr <> 'W'.
    lv_error_message = 'New strategy filter must be P, F, N, S, L, B, E, A, or W'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_oleg = abap_true AND p_ostr IS NOT INITIAL.
    lv_error_message = 'Old strategy filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nleg = abap_true AND p_nstr IS NOT INITIAL.
    lv_error_message = 'New strategy filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_mvt IS NOT INITIAL
      AND ( p_omvt IS NOT INITIAL OR p_nmvt IS NOT INITIAL ).
    lv_error_message =
      'Common and side-specific movement filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ovrd = abap_true
      AND ( p_oovrd = abap_true OR p_novrd = abap_true ).
    lv_error_message =
      'Common and side-specific overdue filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_odate IS NOT INITIAL AND p_ovrd = abap_false.
    IF p_oovrd = abap_false AND p_novrd = abap_false.
    lv_error_message =
      'Overdue as-of date requires overdue-only filtering'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
    ENDIF.
  ENDIF.
  IF p_reqf IS NOT INITIAL AND p_until IS NOT INITIAL AND p_reqf > p_until.
    lv_error_message =
      'The requested horizon start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_oreqf IS NOT INITIAL AND p_oreqt IS NOT INITIAL
      AND p_oreqf > p_oreqt.
    lv_error_message =
      'The old requested horizon start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nreqf IS NOT INITIAL AND p_nreqt IS NOT INITIAL
      AND p_nreqf > p_nreqt.
    lv_error_message =
      'The new requested horizon start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL.
    IF p_oreqf IS NOT INITIAL OR p_oreqt IS NOT INITIAL
        OR p_nreqf IS NOT INITIAL OR p_nreqt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific requested horizons cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_rfrom IS NOT INITIAL AND p_rto IS NOT INITIAL
      AND p_rfrom > p_rto.
    lv_error_message =
      'The reservation date start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_orfrom IS NOT INITIAL AND p_orto IS NOT INITIAL
      AND p_orfrom > p_orto.
    lv_error_message =
      'The old reservation date start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nrfrom IS NOT INITIAL AND p_nrto IS NOT INITIAL
      AND p_nrfrom > p_nrto.
    lv_error_message =
      'The new reservation date start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_rfrom IS NOT INITIAL OR p_rto IS NOT INITIAL.
    IF p_orfrom IS NOT INITIAL OR p_orto IS NOT INITIAL
        OR p_nrfrom IS NOT INITIAL OR p_nrto IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific reservation date ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_rage < 0 OR p_rageto < 0.
    lv_error_message = 'Reservation age filters must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_orage < 0 OR p_oragto < 0 OR p_nrage < 0 OR p_nragto < 0.
    lv_error_message =
      'Side-specific reservation age filters must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_rage IS NOT INITIAL OR p_rageto IS NOT INITIAL.
    IF p_orage IS NOT INITIAL OR p_oragto IS NOT INITIAL
        OR p_nrage IS NOT INITIAL OR p_nragto IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific reservation age filters cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_rage IS NOT INITIAL AND p_rageto IS NOT INITIAL
      AND p_rage > p_rageto.
    lv_error_message =
      'The common reservation age start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_orage IS NOT INITIAL AND p_oragto IS NOT INITIAL
      AND p_orage > p_oragto.
    lv_error_message =
      'The old reservation age start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nrage IS NOT INITIAL AND p_nragto IS NOT INITIAL
      AND p_nrage > p_nragto.
    lv_error_message =
      'The new reservation age start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dead = abap_true
      AND ( p_odead = abap_true OR p_ndead = abap_true ).
    lv_error_message =
      'Common and side-specific deadline filters cannot be combined'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_deadf IS NOT INITIAL AND p_deadt IS NOT INITIAL
      AND p_deadf > p_deadt.
    lv_error_message =
      'The requested deadline start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_odeadf IS NOT INITIAL AND p_odeadt IS NOT INITIAL
      AND p_odeadf > p_odeadt.
    lv_error_message =
      'The old requested deadline start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ndeadf IS NOT INITIAL AND p_ndeadt IS NOT INITIAL
      AND p_ndeadf > p_ndeadt.
    lv_error_message =
      'The new requested deadline start must not be after the end date'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL.
    IF p_odeadf IS NOT INITIAL OR p_odeadt IS NOT INITIAL
        OR p_ndeadf IS NOT INITIAL OR p_ndeadt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific deadline ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_dagef IS NOT INITIAL AND p_daget IS NOT INITIAL
      AND p_dagef > p_daget.
    lv_error_message =
      'The deadline age start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_oagef IS NOT INITIAL AND p_oaget IS NOT INITIAL
      AND p_oagef > p_oaget.
    lv_error_message =
      'The old deadline age start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_nagef IS NOT INITIAL AND p_naget IS NOT INITIAL
      AND p_nagef > p_naget.
    lv_error_message =
      'The new deadline age start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL.
    IF p_oagef IS NOT INITIAL OR p_oaget IS NOT INITIAL
        OR p_nagef IS NOT INITIAL OR p_naget IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific deadline ages cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_daged IS NOT INITIAL
      AND p_dagef IS INITIAL AND p_daget IS INITIAL
      AND p_oagef IS INITIAL AND p_oaget IS INITIAL
      AND p_nagef IS INITIAL AND p_naget IS INITIAL.
    lv_error_message = 'Deadline age date requires an age range'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_tfrom < 0 OR p_tto < 0
      OR p_otfrom < 0 OR p_otto < 0
      OR p_ntfrom < 0 OR p_ntto < 0.
    lv_error_message = 'Audit-duration bounds must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_tfrom IS NOT INITIAL AND p_tto IS NOT INITIAL
      AND p_tfrom > p_tto.
    lv_error_message =
      'The audit-duration start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_otfrom IS NOT INITIAL AND p_otto IS NOT INITIAL
      AND p_otfrom > p_otto.
    lv_error_message =
      'The old audit-duration start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_ntfrom IS NOT INITIAL AND p_ntto IS NOT INITIAL
      AND p_ntfrom > p_ntto.
    lv_error_message =
      'The new audit-duration start must not be after the end value'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_tfrom IS NOT INITIAL OR p_tto IS NOT INITIAL.
    IF p_otfrom IS NOT INITIAL OR p_otto IS NOT INITIAL
        OR p_ntfrom IS NOT INITIAL OR p_ntto IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific audit-duration ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF p_avf < 0 OR p_avt < 0
      OR p_oavf < 0 OR p_oavt < 0
      OR p_navf < 0 OR p_navt < 0.
    lv_error_message = 'Available-stock bounds must not be negative'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_avf IS NOT INITIAL AND p_avt IS NOT INITIAL
      AND p_avf > p_avt.
    lv_error_message =
      'The common available-stock start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_oavf IS NOT INITIAL AND p_oavt IS NOT INITIAL
      AND p_oavf > p_oavt.
    lv_error_message =
      'The old available-stock start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_navf IS NOT INITIAL AND p_navt IS NOT INITIAL
      AND p_navf > p_navt.
    lv_error_message =
      'The new available-stock start must not be after the end'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_avf IS NOT INITIAL OR p_avt IS NOT INITIAL.
    IF p_oavf IS NOT INITIAL OR p_oavt IS NOT INITIAL
        OR p_navf IS NOT INITIAL OR p_navt IS NOT INITIAL.
      lv_error_message =
        'Common and side-specific available-stock ranges cannot be combined'.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
    ENDIF.
  ENDIF.
  IF ( p_ovrd = abap_true OR p_oovrd = abap_true OR p_novrd = abap_true )
      AND p_guard = abap_true.
    lv_error_message =
      'Overdue-only comparison cannot be combined with reconciliation guard'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.
  IF p_dead = abap_true AND p_guard = abap_true.
    lv_error_message =
      'Requested-deadline-only comparison cannot be combined with reconciliation guard'.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.

  CLEAR lt_filter_names.
  IF p_charg IS NOT INITIAL.
    APPEND 'batch' TO lt_filter_names.
  ENDIF.
  IF p_obatch IS NOT INITIAL.
    APPEND 'old_batch' TO lt_filter_names.
  ENDIF.
  IF p_nbatch IS NOT INITIAL.
    APPEND 'new_batch' TO lt_filter_names.
  ENDIF.
  IF p_olgort IS NOT INITIAL.
    APPEND 'old_storage_location' TO lt_filter_names.
  ENDIF.
  IF p_nlgort IS NOT INITIAL.
    APPEND 'new_storage_location' TO lt_filter_names.
  ENDIF.
  IF p_omatnr IS NOT INITIAL.
    APPEND 'old_material' TO lt_filter_names.
  ENDIF.
  IF p_nmatnr IS NOT INITIAL.
    APPEND 'new_material' TO lt_filter_names.
  ENDIF.
  IF p_owerks IS NOT INITIAL.
    APPEND 'old_plant' TO lt_filter_names.
  ENDIF.
  IF p_nwerks IS NOT INITIAL.
    APPEND 'new_plant' TO lt_filter_names.
  ENDIF.
  IF p_meins IS NOT INITIAL.
    APPEND 'unit' TO lt_filter_names.
  ENDIF.
  IF p_ounit IS NOT INITIAL.
    APPEND 'old_unit' TO lt_filter_names.
  ENDIF.
  IF p_nunit IS NOT INITIAL.
    APPEND 'new_unit' TO lt_filter_names.
  ENDIF.
  IF p_rmov IS NOT INITIAL.
    APPEND 'reservation_movement_type' TO lt_filter_names.
  ENDIF.
  IF p_ormov IS NOT INITIAL.
    APPEND 'old_reservation_movement_type' TO lt_filter_names.
  ENDIF.
  IF p_nrmov IS NOT INITIAL.
    APPEND 'new_reservation_movement_type' TO lt_filter_names.
  ENDIF.
  IF p_runit IS NOT INITIAL.
    APPEND 'reservation_unit' TO lt_filter_names.
  ENDIF.
  IF p_orunit IS NOT INITIAL.
    APPEND 'old_reservation_unit' TO lt_filter_names.
  ENDIF.
  IF p_nrunit IS NOT INITIAL.
    APPEND 'new_reservation_unit' TO lt_filter_names.
  ENDIF.
  IF p_rsv = abap_true.
    APPEND 'reserved_only' TO lt_filter_names.
  ENDIF.
  IF p_unrsv = abap_true.
    APPEND 'unreserved_only' TO lt_filter_names.
  ENDIF.
  IF p_orsv = abap_true.
    APPEND 'old_reserved_only' TO lt_filter_names.
  ENDIF.
  IF p_nrsv = abap_true.
    APPEND 'new_reserved_only' TO lt_filter_names.
  ENDIF.
  IF p_oursv = abap_true.
    APPEND 'old_unreserved_only' TO lt_filter_names.
  ENDIF.
  IF p_nursv = abap_true.
    APPEND 'new_unreserved_only' TO lt_filter_names.
  ENDIF.
  IF p_bklg = abap_true.
    APPEND 'shortage_only' TO lt_filter_names.
  ENDIF.
  IF p_obklg = abap_true.
    APPEND 'old_shortage_only' TO lt_filter_names.
  ENDIF.
  IF p_nbklg = abap_true.
    APPEND 'new_shortage_only' TO lt_filter_names.
  ENDIF.
  IF p_shf IS NOT INITIAL OR p_sht IS NOT INITIAL.
    APPEND 'shortage_range' TO lt_filter_names.
  ENDIF.
  IF p_oshf IS NOT INITIAL OR p_osht IS NOT INITIAL.
    APPEND 'old_shortage_range' TO lt_filter_names.
  ENDIF.
  IF p_nshf IS NOT INITIAL OR p_nsht IS NOT INITIAL.
    APPEND 'new_shortage_range' TO lt_filter_names.
  ENDIF.
  IF p_covf IS NOT INITIAL OR p_covt IS NOT INITIAL.
    APPEND 'coverage_range' TO lt_filter_names.
  ENDIF.
  IF p_ocovf IS NOT INITIAL OR p_ocovt IS NOT INITIAL.
    APPEND 'old_coverage_range' TO lt_filter_names.
  ENDIF.
  IF p_ncovf IS NOT INITIAL OR p_ncovt IS NOT INITIAL.
    APPEND 'new_coverage_range' TO lt_filter_names.
  ENDIF.
  IF p_spf IS NOT INITIAL OR p_spt IS NOT INITIAL.
    APPEND 'shortage_percentage_range' TO lt_filter_names.
  ENDIF.
  IF p_ospf IS NOT INITIAL OR p_ospt IS NOT INITIAL.
    APPEND 'old_shortage_percentage_range' TO lt_filter_names.
  ENDIF.
  IF p_nspf IS NOT INITIAL OR p_nspt IS NOT INITIAL.
    APPEND 'new_shortage_percentage_range' TO lt_filter_names.
  ENDIF.
  IF p_qf IS NOT INITIAL OR p_qt IS NOT INITIAL.
    APPEND 'requested_quantity_range' TO lt_filter_names.
  ENDIF.
  IF p_oqf IS NOT INITIAL OR p_oqt IS NOT INITIAL.
    APPEND 'old_requested_quantity_range' TO lt_filter_names.
  ENDIF.
  IF p_nqf IS NOT INITIAL OR p_nqt IS NOT INITIAL.
    APPEND 'new_requested_quantity_range' TO lt_filter_names.
  ENDIF.
  IF p_af IS NOT INITIAL OR p_at IS NOT INITIAL.
    APPEND 'allocated_quantity_range' TO lt_filter_names.
  ENDIF.
  IF p_oaf IS NOT INITIAL OR p_oat IS NOT INITIAL.
    APPEND 'old_allocated_quantity_range' TO lt_filter_names.
  ENDIF.
  IF p_naf IS NOT INITIAL OR p_nat IS NOT INITIAL.
    APPEND 'new_allocated_quantity_range' TO lt_filter_names.
  ENDIF.
  IF p_priof IS NOT INITIAL OR p_priot IS NOT INITIAL.
    APPEND 'priority_range' TO lt_filter_names.
  ENDIF.
  IF p_opf IS NOT INITIAL OR p_opt IS NOT INITIAL.
    APPEND 'old_priority_range' TO lt_filter_names.
  ENDIF.
  IF p_npf IS NOT INITIAL OR p_npt IS NOT INITIAL.
    APPEND 'new_priority_range' TO lt_filter_names.
  ENDIF.
  IF p_sdf IS NOT INITIAL OR p_sdt IS NOT INITIAL.
    APPEND 'snapshot_requested_date_range' TO lt_filter_names.
  ENDIF.
  IF p_osdf IS NOT INITIAL OR p_osdt IS NOT INITIAL.
    APPEND 'old_snapshot_requested_date_range' TO lt_filter_names.
  ENDIF.
  IF p_nsdf IS NOT INITIAL OR p_nsdt IS NOT INITIAL.
    APPEND 'new_snapshot_requested_date_range' TO lt_filter_names.
  ENDIF.
  IF p_vbeln IS NOT INITIAL.
    APPEND 'sales_document' TO lt_filter_names.
  ENDIF.
  IF p_ovbeln IS NOT INITIAL.
    APPEND 'old_sales_document' TO lt_filter_names.
  ENDIF.
  IF p_nvbeln IS NOT INITIAL.
    APPEND 'new_sales_document' TO lt_filter_names.
  ENDIF.
  IF p_auart IS NOT INITIAL.
    APPEND 'sales_document_type' TO lt_filter_names.
  ENDIF.
  IF p_oauart IS NOT INITIAL.
    APPEND 'old_sales_document_type' TO lt_filter_names.
  ENDIF.
  IF p_nauart IS NOT INITIAL.
    APPEND 'new_sales_document_type' TO lt_filter_names.
  ENDIF.
  IF p_posnr IS NOT INITIAL.
    APPEND 'sales_item' TO lt_filter_names.
  ENDIF.
  IF p_oposnr IS NOT INITIAL.
    APPEND 'old_sales_item' TO lt_filter_names.
  ENDIF.
  IF p_nposnr IS NOT INITIAL.
    APPEND 'new_sales_item' TO lt_filter_names.
  ENDIF.
  IF p_etenr IS NOT INITIAL.
    APPEND 'schedule_line' TO lt_filter_names.
  ENDIF.
  IF p_oetenr IS NOT INITIAL.
    APPEND 'old_schedule_line' TO lt_filter_names.
  ENDIF.
  IF p_netenr IS NOT INITIAL.
    APPEND 'new_schedule_line' TO lt_filter_names.
  ENDIF.
  IF p_ordun IS NOT INITIAL.
    APPEND 'order_unit' TO lt_filter_names.
  ENDIF.
  IF p_oordun IS NOT INITIAL.
    APPEND 'old_order_unit' TO lt_filter_names.
  ENDIF.
  IF p_nordun IS NOT INITIAL.
    APPEND 'new_order_unit' TO lt_filter_names.
  ENDIF.
  IF p_order IS NOT INITIAL.
    APPEND 'order_id' TO lt_filter_names.
  ENDIF.
  IF p_oorder IS NOT INITIAL.
    APPEND 'old_order_id' TO lt_filter_names.
  ENDIF.
  IF p_norder IS NOT INITIAL.
    APPEND 'new_order_id' TO lt_filter_names.
  ENDIF.
  IF p_resid IS NOT INITIAL.
    APPEND 'reservation_id' TO lt_filter_names.
  ENDIF.
  IF p_oresid IS NOT INITIAL.
    APPEND 'old_reservation_id' TO lt_filter_names.
  ENDIF.
  IF p_nresid IS NOT INITIAL.
    APPEND 'new_reservation_id' TO lt_filter_names.
  ENDIF.
  IF p_rfrom IS NOT INITIAL.
    APPEND 'reservation_date_from' TO lt_filter_names.
  ENDIF.
  IF p_rto IS NOT INITIAL.
    APPEND 'reservation_date_to' TO lt_filter_names.
  ENDIF.
  IF p_orfrom IS NOT INITIAL.
    APPEND 'old_reservation_date_from' TO lt_filter_names.
  ENDIF.
  IF p_orto IS NOT INITIAL.
    APPEND 'old_reservation_date_to' TO lt_filter_names.
  ENDIF.
  IF p_nrfrom IS NOT INITIAL.
    APPEND 'new_reservation_date_from' TO lt_filter_names.
  ENDIF.
  IF p_nrto IS NOT INITIAL.
    APPEND 'new_reservation_date_to' TO lt_filter_names.
  ENDIF.
  IF p_rage IS NOT INITIAL OR p_rageto IS NOT INITIAL.
    APPEND 'reservation_age' TO lt_filter_names.
  ENDIF.
  IF p_orage IS NOT INITIAL OR p_oragto IS NOT INITIAL.
    APPEND 'old_reservation_age' TO lt_filter_names.
  ENDIF.
  IF p_nrage IS NOT INITIAL OR p_nragto IS NOT INITIAL.
    APPEND 'new_reservation_age' TO lt_filter_names.
  ENDIF.
  IF p_mvt IS NOT INITIAL.
    APPEND 'movement_type' TO lt_filter_names.
  ENDIF.
  IF p_omvt IS NOT INITIAL.
    APPEND 'old_movement_type' TO lt_filter_names.
  ENDIF.
  IF p_nmvt IS NOT INITIAL.
    APPEND 'new_movement_type' TO lt_filter_names.
  ENDIF.
  IF p_shelf IS NOT INITIAL.
    APPEND 'minimum_shelf_life' TO lt_filter_names.
  ENDIF.
  IF p_oshelf IS NOT INITIAL.
    APPEND 'old_minimum_shelf_life' TO lt_filter_names.
  ENDIF.
  IF p_nshelf IS NOT INITIAL.
    APPEND 'new_minimum_shelf_life' TO lt_filter_names.
  ENDIF.
  IF p_ovrd = abap_true.
    APPEND 'overdue_only' TO lt_filter_names.
  ENDIF.
  IF p_oovrd = abap_true.
    APPEND 'old_overdue_only' TO lt_filter_names.
  ENDIF.
  IF p_novrd = abap_true.
    APPEND 'new_overdue_only' TO lt_filter_names.
  ENDIF.
  IF p_odate IS NOT INITIAL.
    APPEND 'requested_overdue_as_of' TO lt_filter_names.
  ENDIF.
  IF p_reqf IS NOT INITIAL.
    APPEND 'requested_on_from' TO lt_filter_names.
  ENDIF.
  IF p_until IS NOT INITIAL.
    APPEND 'requested_on_to' TO lt_filter_names.
  ENDIF.
  IF p_oreqf IS NOT INITIAL.
    APPEND 'old_requested_on_from' TO lt_filter_names.
  ENDIF.
  IF p_oreqt IS NOT INITIAL.
    APPEND 'old_requested_on_to' TO lt_filter_names.
  ENDIF.
  IF p_nreqf IS NOT INITIAL.
    APPEND 'new_requested_on_from' TO lt_filter_names.
  ENDIF.
  IF p_nreqt IS NOT INITIAL.
    APPEND 'new_requested_on_to' TO lt_filter_names.
  ENDIF.
  IF p_dead = abap_true.
    APPEND 'requested_deadline_only' TO lt_filter_names.
  ENDIF.
  IF p_odead = abap_true.
    APPEND 'old_requested_deadline_only' TO lt_filter_names.
  ENDIF.
  IF p_ndead = abap_true.
    APPEND 'new_requested_deadline_only' TO lt_filter_names.
  ENDIF.
  IF p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL.
    APPEND 'requested_deadline_range' TO lt_filter_names.
  ENDIF.
  IF p_odeadf IS NOT INITIAL.
    APPEND 'old_requested_deadline_from' TO lt_filter_names.
  ENDIF.
  IF p_odeadt IS NOT INITIAL.
    APPEND 'old_requested_deadline_to' TO lt_filter_names.
  ENDIF.
  IF p_ndeadf IS NOT INITIAL.
    APPEND 'new_requested_deadline_from' TO lt_filter_names.
  ENDIF.
  IF p_ndeadt IS NOT INITIAL.
    APPEND 'new_requested_deadline_to' TO lt_filter_names.
  ENDIF.
  IF p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL
      OR p_daged IS NOT INITIAL.
    APPEND 'deadline_age_range' TO lt_filter_names.
  ENDIF.
  IF p_oagef IS NOT INITIAL.
    APPEND 'old_deadline_age_from' TO lt_filter_names.
  ENDIF.
  IF p_oaget IS NOT INITIAL.
    APPEND 'old_deadline_age_to' TO lt_filter_names.
  ENDIF.
  IF p_nagef IS NOT INITIAL.
    APPEND 'new_deadline_age_from' TO lt_filter_names.
  ENDIF.
  IF p_naget IS NOT INITIAL.
    APPEND 'new_deadline_age_to' TO lt_filter_names.
  ENDIF.
  IF p_tfrom IS NOT INITIAL OR p_tto IS NOT INITIAL.
    APPEND 'audit_duration_range' TO lt_filter_names.
  ENDIF.
  IF p_otfrom IS NOT INITIAL OR p_otto IS NOT INITIAL.
    APPEND 'old_audit_duration_range' TO lt_filter_names.
  ENDIF.
  IF p_ntfrom IS NOT INITIAL OR p_ntto IS NOT INITIAL.
    APPEND 'new_audit_duration_range' TO lt_filter_names.
  ENDIF.
  IF p_avf IS NOT INITIAL OR p_avt IS NOT INITIAL.
    APPEND 'available_stock_range' TO lt_filter_names.
  ENDIF.
  IF p_oavf IS NOT INITIAL OR p_oavt IS NOT INITIAL.
    APPEND 'old_available_stock_range' TO lt_filter_names.
  ENDIF.
  IF p_navf IS NOT INITIAL OR p_navt IS NOT INITIAL.
    APPEND 'new_available_stock_range' TO lt_filter_names.
  ENDIF.
  IF p_chg IS NOT INITIAL.
    APPEND 'change_type' TO lt_filter_names.
  ENDIF.
  IF p_reason IS NOT INITIAL.
    APPEND 'reason' TO lt_filter_names.
  ENDIF.
  IF p_ost IS NOT INITIAL.
    APPEND 'old_allocation_status' TO lt_filter_names.
  ENDIF.
  IF p_nst IS NOT INITIAL.
    APPEND 'new_allocation_status' TO lt_filter_names.
  ENDIF.
  IF p_oast IS NOT INITIAL.
    APPEND 'old_audit_status' TO lt_filter_names.
  ENDIF.
  IF p_nast IS NOT INITIAL.
    APPEND 'new_audit_status' TO lt_filter_names.
  ENDIF.
  IF p_ostr IS NOT INITIAL.
    APPEND 'old_strategy' TO lt_filter_names.
  ENDIF.
  IF p_nstr IS NOT INITIAL.
    APPEND 'new_strategy' TO lt_filter_names.
  ENDIF.
  IF p_oleg = abap_true.
    APPEND 'old_legacy_strategy' TO lt_filter_names.
  ENDIF.
  IF p_nleg = abap_true.
    APPEND 'new_legacy_strategy' TO lt_filter_names.
  ENDIF.
  IF p_omsg IS NOT INITIAL.
    APPEND 'old_message' TO lt_filter_names.
  ENDIF.
  IF p_nmsg IS NOT INITIAL.
    APPEND 'new_message' TO lt_filter_names.
  ENDIF.
  IF p_omonly = abap_true.
    APPEND 'old_message_only' TO lt_filter_names.
  ENDIF.
  IF p_nmonly = abap_true.
    APPEND 'new_message_only' TO lt_filter_names.
  ENDIF.
  IF p_all = abap_true.
    APPEND 'include_unchanged' TO lt_filter_names.
  ENDIF.
  IF p_guard = abap_true.
    APPEND 'reconciliation_guard' TO lt_filter_names.
  ENDIF.
  IF p_skip IS NOT INITIAL.
    APPEND 'offset' TO lt_filter_names.
  ENDIF.
  IF p_max IS NOT INITIAL.
    APPEND 'max_rows' TO lt_filter_names.
  ENDIF.
  IF lines( lt_filter_names ) > 0.
    lv_filters_applied = abap_true.
    CONCATENATE LINES OF lt_filter_names INTO lv_filter_names_text
      SEPARATED BY '|'.
  ELSE.
    lv_filters_applied = abap_false.
    lv_filter_names_text = 'n/a'.
  ENDIF.
  IF p_wors = abap_true.
    lv_sort_mode = 'shortage_worsening'.
  ELSEIF p_cw = abap_true.
    lv_sort_mode = 'coverage_worsening'.
  ELSEIF p_spw = abap_true.
    lv_sort_mode = 'shortage_percentage_worsening'.
  ELSEIF p_sreg = abap_true.
    lv_sort_mode = 'status_regression'.
  ELSEIF p_qd = abap_true.
    lv_sort_mode = 'requested_delta'.
  ELSEIF p_cov = abap_true.
    lv_sort_mode = 'coverage'.
  ELSEIF p_spct = abap_true.
    lv_sort_mode = 'shortage_percentage'.
  ELSEIF p_big = abap_true.
    lv_sort_mode = 'requested_quantity'.
  ELSEIF p_done = abap_true.
    lv_sort_mode = 'allocated_quantity'.
  ELSEIF p_due = abap_true.
    lv_sort_mode = 'requested_date'.
  ELSEIF p_rdate = abap_true.
    lv_sort_mode = 'reservation_date'.
  ELSEIF p_shrt = abap_true.
    lv_sort_mode = 'shortage'.
  ELSE.
    lv_sort_mode = 'key'.
  ENDIF.
  lv_compare_offset = p_skip.
  lv_compare_max_rows = p_max.
  IF p_wors = abap_true OR p_cw = abap_true OR p_spw = abap_true
      OR p_sreg = abap_true
      OR p_qd = abap_true
      OR p_cov = abap_true
      OR p_spct = abap_true
      OR p_big = abap_true OR p_done = abap_true
      OR p_due = abap_true OR p_rdate = abap_true
      OR p_shrt = abap_true.
    CLEAR: lv_compare_offset, lv_compare_max_rows.
  ENDIF.

  CLEAR lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'material'
    iv_value = lv_material_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_material'
    iv_value = lv_old_material_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_material'
    iv_value = lv_new_material_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'plant'
    iv_value = lv_plant_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_plant'
    iv_value = lv_old_plant_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_plant'
    iv_value = lv_new_plant_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'storage_location'
    iv_value = lv_storage_location_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_storage_location'
    iv_value = lv_old_storage_location_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_storage_location'
    iv_value = lv_new_storage_location_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'batch'
    iv_value = lv_batch_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_batch'
    iv_value = lv_old_batch_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_batch'
    iv_value = lv_new_batch_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'movement_type'
    iv_value = p_mvt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_movement_type'
    iv_value = lv_old_movement_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_movement_type'
    iv_value = lv_new_movement_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'unit'
    iv_value = p_meins ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_unit'
    iv_value = lv_old_unit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_unit'
    iv_value = lv_new_unit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'reservation_movement_type'
    iv_value = p_rmov ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_reservation_movement_type'
    iv_value = lv_old_rmov_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_reservation_movement_type'
    iv_value = lv_new_rmov_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'reservation_unit'
    iv_value = p_runit ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_reservation_unit'
    iv_value = lv_old_runit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_reservation_unit'
    iv_value = lv_new_runit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'reserved_only'
    iv_value = p_rsv ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'unreserved_only'
    iv_value = p_unrsv ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_reserved_only'
    iv_value = lv_old_reserved_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_reserved_only'
    iv_value = lv_new_reserved_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_unreserved_only'
    iv_value = lv_old_unreserved_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_unreserved_only'
    iv_value = lv_new_unreserved_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'shortage_only'
    iv_value = p_bklg ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_shortage_only'
    iv_value = lv_old_shortage_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_shortage_only'
    iv_value = lv_new_shortage_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shortage'
    iv_value   = p_shf
    iv_text    = lv_shortage_from_filter
    iv_present = xsdbool( p_shf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_shortage'
    iv_value   = p_sht
    iv_text    = lv_shortage_to_filter
    iv_present = xsdbool( p_sht IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_shortage'
    iv_value   = lv_old_shortage_from
    iv_text    = lv_old_shortage_from_filter
    iv_present = xsdbool( p_oshf IS NOT INITIAL OR p_shf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_shortage'
    iv_value   = lv_old_shortage_to
    iv_text    = lv_old_shortage_to_filter
    iv_present = xsdbool( p_osht IS NOT INITIAL OR p_sht IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_shortage'
    iv_value   = lv_new_shortage_from
    iv_text    = lv_new_shortage_from_filter
    iv_present = xsdbool( p_nshf IS NOT INITIAL OR p_shf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_shortage'
    iv_value   = lv_new_shortage_to
    iv_text    = lv_new_shortage_to_filter
    iv_present = xsdbool( p_nsht IS NOT INITIAL OR p_sht IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_coverage'
    iv_value   = p_covf
    iv_text    = lv_coverage_from_filter
    iv_present = xsdbool( p_covf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_coverage'
    iv_value   = p_covt
    iv_text    = lv_coverage_to_filter
    iv_present = xsdbool( p_covt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_coverage'
    iv_value   = lv_old_coverage_from
    iv_text    = lv_old_coverage_from_filter
    iv_present = xsdbool( p_ocovf IS NOT INITIAL OR p_covf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_coverage'
    iv_value   = lv_old_coverage_to
    iv_text    = lv_old_coverage_to_filter
    iv_present = xsdbool( p_ocovt IS NOT INITIAL OR p_covt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_coverage'
    iv_value   = lv_new_coverage_from
    iv_text    = lv_new_coverage_from_filter
    iv_present = xsdbool( p_ncovf IS NOT INITIAL OR p_covf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_coverage'
    iv_value   = lv_new_coverage_to
    iv_text    = lv_new_coverage_to_filter
    iv_present = xsdbool( p_ncovt IS NOT INITIAL OR p_covt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shortage_pct'
    iv_value   = p_spf
    iv_text    = lv_shortage_pct_from_filter
    iv_present = xsdbool( p_spf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_shortage_pct'
    iv_value   = p_spt
    iv_text    = lv_shortage_pct_to_filter
    iv_present = xsdbool( p_spt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_shortage_pct'
    iv_value   = lv_old_shortage_pct_from
    iv_text    = lv_old_sp_from_txt
    iv_present = xsdbool( p_ospf IS NOT INITIAL OR p_spf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_shortage_pct'
    iv_value   = lv_old_shortage_pct_to
    iv_text    = lv_old_sp_to_txt
    iv_present = xsdbool( p_ospt IS NOT INITIAL OR p_spt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_shortage_pct'
    iv_value   = lv_new_shortage_pct_from
    iv_text    = lv_new_sp_from_txt
    iv_present = xsdbool( p_nspf IS NOT INITIAL OR p_spf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_shortage_pct'
    iv_value   = lv_new_shortage_pct_to
    iv_text    = lv_new_sp_to_txt
    iv_present = xsdbool( p_nspt IS NOT INITIAL OR p_spt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_requested_quantity'
    iv_value   = p_qf
    iv_text    = lv_req_qty_from_txt
    iv_present = xsdbool( p_qf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_requested_quantity'
    iv_value   = p_qt
    iv_text    = lv_req_qty_to_txt
    iv_present = xsdbool( p_qt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_requested_quantity'
    iv_value   = lv_old_req_qty_from
    iv_text    = lv_old_req_qty_from_txt
    iv_present = xsdbool( p_oqf IS NOT INITIAL OR p_qf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_requested_quantity'
    iv_value   = lv_old_req_qty_to
    iv_text    = lv_old_req_qty_to_txt
    iv_present = xsdbool( p_oqt IS NOT INITIAL OR p_qt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_requested_quantity'
    iv_value   = lv_new_req_qty_from
    iv_text    = lv_new_req_qty_from_txt
    iv_present = xsdbool( p_nqf IS NOT INITIAL OR p_qf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_requested_quantity'
    iv_value   = lv_new_req_qty_to
    iv_text    = lv_new_req_qty_to_txt
    iv_present = xsdbool( p_nqt IS NOT INITIAL OR p_qt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_allocated_quantity'
    iv_value   = p_af
    iv_text    = lv_allocated_from_filter
    iv_present = xsdbool( p_af IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_allocated_quantity'
    iv_value   = p_at
    iv_text    = lv_allocated_to_filter
    iv_present = xsdbool( p_at IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_allocated_quantity'
    iv_value   = lv_old_allocated_from
    iv_text    = lv_old_allocated_from_txt
    iv_present = xsdbool( p_oaf IS NOT INITIAL OR p_af IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_allocated_quantity'
    iv_value   = lv_old_allocated_to
    iv_text    = lv_old_allocated_to_txt
    iv_present = xsdbool( p_oat IS NOT INITIAL OR p_at IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_allocated_quantity'
    iv_value   = lv_new_allocated_from
    iv_text    = lv_new_allocated_from_txt
    iv_present = xsdbool( p_naf IS NOT INITIAL OR p_af IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_allocated_quantity'
    iv_value   = lv_new_allocated_to
    iv_text    = lv_new_allocated_to_txt
    iv_present = xsdbool( p_nat IS NOT INITIAL OR p_at IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_priority'
    iv_value   = p_priof
    iv_text    = lv_priority_from_txt
    iv_present = xsdbool( p_priof IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_priority'
    iv_value   = p_priot
    iv_text    = lv_priority_to_txt
    iv_present = xsdbool( p_priot IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_priority'
    iv_value   = lv_old_priority_from
    iv_text    = lv_old_priority_from_txt
    iv_present = xsdbool( p_opf IS NOT INITIAL OR p_priof IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_priority'
    iv_value   = lv_old_priority_to
    iv_text    = lv_old_priority_to_txt
    iv_present = xsdbool( p_opt IS NOT INITIAL OR p_priot IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_priority'
    iv_value   = lv_new_priority_from
    iv_text    = lv_new_priority_from_txt
    iv_present = xsdbool( p_npf IS NOT INITIAL OR p_priof IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_priority'
    iv_value   = lv_new_priority_to
    iv_text    = lv_new_priority_to_txt
    iv_present = xsdbool( p_npt IS NOT INITIAL OR p_priot IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_snapshot_date_from'
    iv_value = lv_snapshot_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_snapshot_date_to'
    iv_value = lv_snapshot_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_requested_snapshot_date_from'
    iv_value = lv_old_snapshot_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_requested_snapshot_date_to'
    iv_value = lv_old_snapshot_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_requested_snapshot_date_from'
    iv_value = lv_new_snapshot_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_requested_snapshot_date_to'
    iv_value = lv_new_snapshot_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'sales_document'
    iv_value = lv_sales_document_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_sales_document'
    iv_value = lv_old_sales_document_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_sales_document'
    iv_value = lv_new_sales_document_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'sales_document_type'
    iv_value = lv_auart_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_sales_document_type'
    iv_value = lv_old_auart_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_sales_document_type'
    iv_value = lv_new_auart_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'sales_item'
    iv_value = lv_posnr_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_sales_item'
    iv_value = lv_old_posnr_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_sales_item'
    iv_value = lv_new_posnr_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'schedule_line'
    iv_value = lv_etenr_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_schedule_line'
    iv_value = lv_old_etenr_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_schedule_line'
    iv_value = lv_new_etenr_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'order_unit'
    iv_value = lv_ordunit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_order_unit'
    iv_value = lv_old_ordunit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_order_unit'
    iv_value = lv_new_ordunit_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'order_id'
    iv_value = lv_order_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_order_id'
    iv_value = lv_old_order_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_order_id'
    iv_value = lv_new_order_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'reservation_id'
    iv_value = lv_resid_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_reservation_id'
    iv_value = lv_old_resid_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_reservation_id'
    iv_value = lv_new_resid_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'reservation_date_from'
    iv_value = lv_rdate_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'reservation_date_to'
    iv_value = lv_rdate_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_reservation_date_from'
    iv_value = lv_old_rdate_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_reservation_date_to'
    iv_value = lv_old_rdate_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_reservation_date_from'
    iv_value = lv_new_rdate_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_reservation_date_to'
    iv_value = lv_new_rdate_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'reservation_age'
    iv_value   = p_rage
    iv_text    = lv_rage_filter
    iv_present = xsdbool( p_rage IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_reservation_age'
    iv_value   = p_rageto
    iv_text    = lv_rageto_filter
    iv_present = xsdbool( p_rageto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_reservation_age'
    iv_value   = lv_old_rage
    iv_text    = lv_old_rage_filter
    iv_present = xsdbool( p_orage IS NOT INITIAL OR p_rage IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_reservation_age'
    iv_value   = lv_old_rageto
    iv_text    = lv_old_rageto_filter
    iv_present = xsdbool( p_oragto IS NOT INITIAL OR p_rageto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_reservation_age'
    iv_value   = lv_new_rage
    iv_text    = lv_new_rage_filter
    iv_present = xsdbool( p_nrage IS NOT INITIAL OR p_rage IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_reservation_age'
    iv_value   = lv_new_rageto
    iv_text    = lv_new_rageto_filter
    iv_present = xsdbool( p_nragto IS NOT INITIAL OR p_rageto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_allocation_status'
    iv_value = p_ost ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_allocation_status'
    iv_value = p_nst ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_audit_status'
    iv_value = p_oast ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_audit_status'
    iv_value = p_nast ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_strategy'
    iv_value = p_ostr ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_strategy'
    iv_value = p_nstr ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_legacy_strategy'
    iv_value = p_oleg ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_legacy_strategy'
    iv_value = p_nleg ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_message'
    iv_value = lv_old_message_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_message'
    iv_value = lv_new_message_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_message_only'
    iv_value = p_omonly ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_message_only'
    iv_value = p_nmonly ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_shelf_life'
    iv_value   = p_shelf
    iv_text    = 'n/a'
    iv_present = xsdbool( p_shelf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_shelf_life'
    iv_value   = lv_old_shelf_life
    iv_text    = lv_old_shelf_filter
    iv_present = xsdbool( p_oshelf IS NOT INITIAL OR p_shelf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_shelf_life'
    iv_value   = lv_new_shelf_life
    iv_text    = lv_new_shelf_filter
    iv_present = xsdbool( p_nshelf IS NOT INITIAL OR p_shelf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'overdue_only'
    iv_value = p_ovrd ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_overdue_only'
    iv_value = lv_old_overdue_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_overdue_only'
    iv_value = lv_new_overdue_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'requested_deadline_only'
    iv_value = p_dead ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'old_requested_deadline_only'
    iv_value = lv_old_deadline_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>boolean_property(
    iv_name  = 'new_requested_deadline_only'
    iv_value = lv_new_deadline_only ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_deadline_from'
    iv_value = lv_deadline_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_deadline_to'
    iv_value = lv_deadline_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_requested_deadline_from'
    iv_value = lv_old_deadline_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_requested_deadline_to'
    iv_value = lv_old_deadline_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_requested_deadline_from'
    iv_value = lv_new_deadline_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_requested_deadline_to'
    iv_value = lv_new_deadline_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_deadline_age_days'
    iv_value   = p_dagef
    iv_text    = lv_deadline_age_from_filter
    iv_present = xsdbool( p_dagef IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_deadline_age_days'
    iv_value   = p_daget
    iv_text    = lv_deadline_age_to_filter
    iv_present = xsdbool( p_daget IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'deadline_age_as_of'
    iv_value = lv_deadline_age_date_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_deadline_age_from'
    iv_value = lv_old_age_from_txt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_deadline_age_to'
    iv_value = lv_old_age_to_txt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_deadline_age_from'
    iv_value = lv_new_age_from_txt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_deadline_age_to'
    iv_value = lv_new_age_to_txt ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_audit_duration_seconds'
    iv_value   = p_tfrom
    iv_text    = lv_duration_from_filter
    iv_present = xsdbool( p_tfrom IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_audit_duration_seconds'
    iv_value   = p_tto
    iv_text    = lv_duration_to_filter
    iv_present = xsdbool( p_tto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_audit_duration_seconds'
    iv_value   = lv_old_duration_from
    iv_text    = lv_old_duration_from_filter
    iv_present = xsdbool( p_otfrom IS NOT INITIAL OR p_tfrom IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_audit_duration_seconds'
    iv_value   = lv_old_duration_to
    iv_text    = lv_old_duration_to_filter
    iv_present = xsdbool( p_otto IS NOT INITIAL OR p_tto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_audit_duration_seconds'
    iv_value   = lv_new_duration_from
    iv_text    = lv_new_duration_from_filter
    iv_present = xsdbool( p_ntfrom IS NOT INITIAL OR p_tfrom IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_audit_duration_seconds'
    iv_value   = lv_new_duration_to
    iv_text    = lv_new_duration_to_filter
    iv_present = xsdbool( p_ntto IS NOT INITIAL OR p_tto IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'minimum_available_stock'
    iv_value   = p_avf
    iv_text    = lv_available_from_filter
    iv_present = xsdbool( p_avf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'maximum_available_stock'
    iv_value   = p_avt
    iv_text    = lv_available_to_filter
    iv_present = xsdbool( p_avt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_minimum_available_stock'
    iv_value   = lv_old_available_from
    iv_text    = lv_old_available_from_filter
    iv_present = xsdbool( p_oavf IS NOT INITIAL OR p_avf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'old_maximum_available_stock'
    iv_value   = lv_old_available_to
    iv_text    = lv_old_available_to_filter
    iv_present = xsdbool( p_oavt IS NOT INITIAL OR p_avt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_minimum_available_stock'
    iv_value   = lv_new_available_from
    iv_text    = lv_new_available_from_filter
    iv_present = xsdbool( p_navf IS NOT INITIAL OR p_avf IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'new_maximum_available_stock'
    iv_value   = lv_new_available_to
    iv_text    = lv_new_available_to_filter
    iv_present = xsdbool( p_navt IS NOT INITIAL OR p_avt IS NOT INITIAL )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_overdue_as_of'
    iv_value = lv_overdue_as_of_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_on_from'
    iv_value = lv_requested_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'requested_on_to'
    iv_value = lv_requested_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_requested_on_from'
    iv_value = lv_old_requested_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'old_requested_on_to'
    iv_value = lv_old_requested_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_requested_on_from'
    iv_value = lv_new_requested_from_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>property(
    iv_name  = 'new_requested_on_to'
    iv_value = lv_new_requested_to_filter ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>number_property(
    iv_name  = 'offset'
    iv_value = p_skip ) TO lt_filter_value_fields.
  APPEND zcl_stock_json=>filter_number_property(
    iv_name    = 'max_rows'
    iv_value   = p_max
    iv_text    = 'n/a'
    iv_present = xsdbool( p_max > 0 )
    iv_typed   = abap_true ) TO lt_filter_value_fields.
  CONCATENATE LINES OF lt_filter_value_fields INTO lv_filter_value_body
    SEPARATED BY ','.
  CONCATENATE '{' lv_filter_value_body '}' INTO lv_filter_values_json.

  CREATE OBJECT lo_authority TYPE zcl_allocation_read_auth_sap.
  CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap
    EXPORTING
      io_read_authority = lo_authority.
  CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap
    EXPORTING
      io_read_authority = lo_authority.
  TRY.
      lt_old = lo_sink->get_allocations(
          iv_material                = lv_old_material
          iv_plant                   = lv_old_plant
          iv_storage_location        = lv_old_storage_location
          iv_batch                   = lv_old_batch
          iv_unit                    = lv_old_unit
          iv_sales_document          = lv_old_sales_document
          iv_sales_document_type     = lv_old_auart
          iv_sales_item              = lv_old_posnr
          iv_schedule_line           = lv_old_etenr
          iv_order_unit              = lv_old_ordunit
          iv_order_id                = lv_old_order
          iv_reservation_id          = lv_old_resid
          iv_movement_type           = lv_old_reservation_movement
          iv_reservation_unit        = lv_old_reservation_unit
          iv_reserved_only           = lv_old_reserved_only
          iv_unreserved_only         = lv_old_unreserved_only
          iv_shortage_only           = lv_old_shortage_only
          iv_shortage_from           = lv_old_shortage_from
          iv_shortage_to             = lv_old_shortage_to
          iv_priority_from           = lv_old_priority_from
          iv_priority_to             = lv_old_priority_to
          iv_coverage_from           = lv_old_coverage_from
          iv_coverage_to             = lv_old_coverage_to
          iv_shortage_pct_from       = lv_old_shortage_pct_from
          iv_shortage_pct_to         = lv_old_shortage_pct_to
          iv_requested_quantity_from = lv_old_req_qty_from
          iv_requested_quantity_to   = lv_old_req_qty_to
          iv_allocated_quantity_from = lv_old_allocated_from
          iv_allocated_quantity_to   = lv_old_allocated_to
          iv_requested_on_from       = lv_old_snapshot_from
          iv_requested_on_to         = lv_old_snapshot_to
          iv_reservation_date_from   = lv_old_rdate_from
          iv_reservation_date_to     = lv_old_rdate_to
          iv_reservation_age_from    = lv_old_rage
          iv_reservation_age_to      = lv_old_rageto
          iv_overdue_only            = lv_old_overdue_only
          iv_overdue_date            = p_odate
          iv_deadline_only           = lv_old_deadline_only
          iv_run_deadline_from       = lv_old_deadline_from
          iv_run_deadline_to         = lv_old_deadline_to
          iv_run_deadline_age_from   = lv_old_deadline_age_from
          iv_run_deadline_age_to     = lv_old_deadline_age_to
          iv_run_deadline_age_date   = p_daged
          iv_run_duration_from       = lv_old_duration_from
          iv_run_duration_to         = lv_old_duration_to
          iv_run_available_from      = lv_old_available_from
          iv_run_available_to        = lv_old_available_to
          iv_run_status              = p_oast
          iv_strategy                = p_ostr
          iv_legacy_strategy         = p_oleg
          iv_run_message_contains    = p_omsg
          iv_run_message_only        = p_omonly
          iv_run_id                  = p_old ).
      lt_new = lo_sink->get_allocations(
          iv_material                = lv_new_material
          iv_plant                   = lv_new_plant
          iv_storage_location        = lv_new_storage_location
          iv_batch                   = lv_new_batch
          iv_unit                    = lv_new_unit
          iv_sales_document          = lv_new_sales_document
          iv_sales_document_type     = lv_new_auart
          iv_sales_item              = lv_new_posnr
          iv_schedule_line           = lv_new_etenr
          iv_order_unit              = lv_new_ordunit
          iv_order_id                = lv_new_order
          iv_reservation_id          = lv_new_resid
          iv_movement_type           = lv_new_reservation_movement
          iv_reservation_unit        = lv_new_reservation_unit
          iv_reserved_only           = lv_new_reserved_only
          iv_unreserved_only         = lv_new_unreserved_only
          iv_shortage_only           = lv_new_shortage_only
          iv_shortage_from           = lv_new_shortage_from
          iv_shortage_to             = lv_new_shortage_to
          iv_priority_from           = lv_new_priority_from
          iv_priority_to             = lv_new_priority_to
          iv_coverage_from           = lv_new_coverage_from
          iv_coverage_to             = lv_new_coverage_to
          iv_shortage_pct_from       = lv_new_shortage_pct_from
          iv_shortage_pct_to         = lv_new_shortage_pct_to
          iv_requested_quantity_from = lv_new_req_qty_from
          iv_requested_quantity_to   = lv_new_req_qty_to
          iv_allocated_quantity_from = lv_new_allocated_from
          iv_allocated_quantity_to   = lv_new_allocated_to
          iv_requested_on_from       = lv_new_snapshot_from
          iv_requested_on_to         = lv_new_snapshot_to
          iv_reservation_date_from   = lv_new_rdate_from
          iv_reservation_date_to     = lv_new_rdate_to
          iv_reservation_age_from    = lv_new_rage
          iv_reservation_age_to      = lv_new_rageto
          iv_overdue_only            = lv_new_overdue_only
          iv_overdue_date            = p_odate
          iv_deadline_only           = lv_new_deadline_only
          iv_run_deadline_from       = lv_new_deadline_from
          iv_run_deadline_to         = lv_new_deadline_to
          iv_run_deadline_age_from   = lv_new_deadline_age_from
          iv_run_deadline_age_to     = lv_new_deadline_age_to
          iv_run_deadline_age_date   = p_daged
          iv_run_duration_from       = lv_new_duration_from
          iv_run_duration_to         = lv_new_duration_to
          iv_run_available_from      = lv_new_available_from
          iv_run_available_to        = lv_new_available_to
          iv_run_status              = p_nast
          iv_strategy                = p_nstr
          iv_legacy_strategy         = p_nleg
          iv_run_message_contains    = p_nmsg
          iv_run_message_only        = p_nmonly
          iv_run_id                  = p_new ).
      lt_old_runs = lo_audit->get_runs(
        iv_material          = lv_old_material
        iv_plant             = lv_old_plant
        iv_storage_location  = lv_old_storage_location
        iv_batch             = lv_old_batch
        iv_unit              = lv_old_unit
        iv_movement_type     = lv_old_movement_type
        iv_min_shelf_life    = lv_old_shelf_life
        iv_status            = p_oast
        iv_strategy          = p_ostr
        iv_legacy_strategy   = p_oleg
        iv_message_contains  = p_omsg
        iv_message_only      = p_omonly
        iv_requested_overdue = lv_old_overdue_only
        iv_overdue_date      = p_odate
        iv_deadline_only     = lv_old_deadline_only
        iv_deadline_from     = lv_old_deadline_from
        iv_deadline_to       = lv_old_deadline_to
        iv_deadline_age_from = lv_old_deadline_age_from
        iv_deadline_age_to   = lv_old_deadline_age_to
        iv_deadline_age_date = p_daged
        iv_duration_from     = lv_old_duration_from
        iv_duration_to       = lv_old_duration_to
        iv_available_from    = lv_old_available_from
        iv_available_to      = lv_old_available_to
        iv_requested_on_from = lv_old_requested_from
        iv_requested_on_to   = lv_old_requested_to
        iv_run_id            = p_old ).
      lt_new_runs = lo_audit->get_runs(
        iv_material          = lv_new_material
        iv_plant             = lv_new_plant
        iv_storage_location  = lv_new_storage_location
        iv_batch             = lv_new_batch
        iv_unit              = lv_new_unit
        iv_movement_type     = lv_new_movement_type
        iv_min_shelf_life    = lv_new_shelf_life
        iv_status            = p_nast
        iv_strategy          = p_nstr
        iv_legacy_strategy   = p_nleg
        iv_message_contains  = p_nmsg
        iv_message_only      = p_nmonly
        iv_requested_overdue = lv_new_overdue_only
        iv_overdue_date      = p_odate
        iv_deadline_only     = lv_new_deadline_only
        iv_deadline_from     = lv_new_deadline_from
        iv_deadline_to       = lv_new_deadline_to
        iv_deadline_age_from = lv_new_deadline_age_from
        iv_deadline_age_to   = lv_new_deadline_age_to
        iv_deadline_age_date = p_daged
        iv_duration_from     = lv_new_duration_from
        iv_duration_to       = lv_new_duration_to
        iv_available_from    = lv_new_available_from
        iv_available_to      = lv_new_available_to
        iv_requested_on_from = lv_new_requested_from
        iv_requested_on_to   = lv_new_requested_to
        iv_run_id            = p_new ).
      READ TABLE lt_old_runs INTO ls_old_run INDEX 1.
      IF sy-subrc <> 0.
        CREATE OBJECT lo_missing_run_error.
        IF p_meins IS NOT INITIAL OR p_ounit IS NOT INITIAL OR p_nunit IS NOT INITIAL
            OR p_rmov IS NOT INITIAL OR p_ormov IS NOT INITIAL OR p_nrmov IS NOT INITIAL
            OR p_runit IS NOT INITIAL OR p_orunit IS NOT INITIAL OR p_nrunit IS NOT INITIAL
            OR p_rsv = abap_true OR p_unrsv = abap_true
            OR p_orsv = abap_true OR p_nrsv = abap_true
            OR p_oursv = abap_true OR p_nursv = abap_true
            OR p_bklg = abap_true OR p_obklg = abap_true
            OR p_nbklg = abap_true
            OR p_shf IS NOT INITIAL OR p_sht IS NOT INITIAL
            OR p_oshf IS NOT INITIAL OR p_osht IS NOT INITIAL
            OR p_nshf IS NOT INITIAL OR p_nsht IS NOT INITIAL
            OR p_covf IS NOT INITIAL OR p_covt IS NOT INITIAL
            OR p_ocovf IS NOT INITIAL OR p_ocovt IS NOT INITIAL
            OR p_ncovf IS NOT INITIAL OR p_ncovt IS NOT INITIAL
            OR p_spf IS NOT INITIAL OR p_spt IS NOT INITIAL
            OR p_ospf IS NOT INITIAL OR p_ospt IS NOT INITIAL
            OR p_nspf IS NOT INITIAL OR p_nspt IS NOT INITIAL
            OR p_qf IS NOT INITIAL OR p_qt IS NOT INITIAL
            OR p_oqf IS NOT INITIAL OR p_oqt IS NOT INITIAL
            OR p_nqf IS NOT INITIAL OR p_nqt IS NOT INITIAL
            OR p_af IS NOT INITIAL OR p_at IS NOT INITIAL
            OR p_oaf IS NOT INITIAL OR p_oat IS NOT INITIAL
            OR p_naf IS NOT INITIAL OR p_nat IS NOT INITIAL
            OR p_priof IS NOT INITIAL OR p_priot IS NOT INITIAL
            OR p_opf IS NOT INITIAL OR p_opt IS NOT INITIAL
            OR p_npf IS NOT INITIAL OR p_npt IS NOT INITIAL
            OR p_sdf IS NOT INITIAL OR p_sdt IS NOT INITIAL
            OR p_osdf IS NOT INITIAL OR p_osdt IS NOT INITIAL
            OR p_nsdf IS NOT INITIAL OR p_nsdt IS NOT INITIAL
             OR p_vbeln IS NOT INITIAL OR p_ovbeln IS NOT INITIAL
             OR p_nvbeln IS NOT INITIAL
             OR p_auart IS NOT INITIAL OR p_oauart IS NOT INITIAL
             OR p_nauart IS NOT INITIAL
             OR p_posnr IS NOT INITIAL OR p_oposnr IS NOT INITIAL
             OR p_nposnr IS NOT INITIAL
             OR p_etenr IS NOT INITIAL OR p_oetenr IS NOT INITIAL
             OR p_netenr IS NOT INITIAL
             OR p_ordun IS NOT INITIAL OR p_oordun IS NOT INITIAL
             OR p_nordun IS NOT INITIAL
             OR p_order IS NOT INITIAL OR p_oorder IS NOT INITIAL
             OR p_norder IS NOT INITIAL
             OR p_resid IS NOT INITIAL OR p_oresid IS NOT INITIAL
             OR p_nresid IS NOT INITIAL
             OR p_obatch IS NOT INITIAL OR p_nbatch IS NOT INITIAL
             OR p_olgort IS NOT INITIAL OR p_nlgort IS NOT INITIAL
             OR p_omatnr IS NOT INITIAL OR p_nmatnr IS NOT INITIAL
             OR p_owerks IS NOT INITIAL OR p_nwerks IS NOT INITIAL
            OR p_rfrom IS NOT INITIAL OR p_rto IS NOT INITIAL
            OR p_orfrom IS NOT INITIAL OR p_orto IS NOT INITIAL
            OR p_nrfrom IS NOT INITIAL OR p_nrto IS NOT INITIAL
            OR p_rage IS NOT INITIAL OR p_rageto IS NOT INITIAL
            OR p_orage IS NOT INITIAL OR p_oragto IS NOT INITIAL
            OR p_nrage IS NOT INITIAL OR p_nragto IS NOT INITIAL
            OR p_tfrom IS NOT INITIAL OR p_tto IS NOT INITIAL
            OR p_otfrom IS NOT INITIAL OR p_otto IS NOT INITIAL
            OR p_ntfrom IS NOT INITIAL OR p_ntto IS NOT INITIAL
            OR p_avf IS NOT INITIAL OR p_avt IS NOT INITIAL
            OR p_oavf IS NOT INITIAL OR p_oavt IS NOT INITIAL
            OR p_navf IS NOT INITIAL OR p_navt IS NOT INITIAL
            OR p_mvt IS NOT INITIAL OR p_omvt IS NOT INITIAL OR p_nmvt IS NOT INITIAL
            OR p_shelf IS NOT INITIAL OR p_oshelf IS NOT INITIAL
            OR p_nshelf IS NOT INITIAL
            OR p_oast IS NOT INITIAL OR p_nast IS NOT INITIAL
            OR p_ostr IS NOT INITIAL OR p_nstr IS NOT INITIAL
            OR p_oleg = abap_true OR p_nleg = abap_true
            OR p_omsg IS NOT INITIAL OR p_nmsg IS NOT INITIAL
            OR p_omonly = abap_true OR p_nmonly = abap_true
            OR p_ovrd = abap_true OR p_oovrd = abap_true OR p_novrd = abap_true
            OR p_dead = abap_true
            OR p_odead = abap_true OR p_ndead = abap_true
            OR p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL
            OR p_odeadf IS NOT INITIAL OR p_odeadt IS NOT INITIAL
            OR p_ndeadf IS NOT INITIAL OR p_ndeadt IS NOT INITIAL
            OR p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL
            OR p_daged IS NOT INITIAL
            OR p_oagef IS NOT INITIAL OR p_oaget IS NOT INITIAL
            OR p_nagef IS NOT INITIAL OR p_naget IS NOT INITIAL
            OR p_tfrom IS NOT INITIAL OR p_tto IS NOT INITIAL
            OR p_otfrom IS NOT INITIAL OR p_otto IS NOT INITIAL
            OR p_ntfrom IS NOT INITIAL OR p_ntto IS NOT INITIAL
            OR p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL
            OR p_oreqf IS NOT INITIAL OR p_oreqt IS NOT INITIAL
            OR p_nreqf IS NOT INITIAL OR p_nreqt IS NOT INITIAL.
          lo_missing_run_error->message =
            'Old allocation run does not match the policy filters'.
        ELSE.
          lo_missing_run_error->message = 'Old allocation run was not found'.
        ENDIF.
        RAISE EXCEPTION lo_missing_run_error.
      ENDIF.
      READ TABLE lt_new_runs INTO ls_new_run INDEX 1.
      IF sy-subrc <> 0.
        CREATE OBJECT lo_missing_run_error.
        IF p_meins IS NOT INITIAL OR p_ounit IS NOT INITIAL OR p_nunit IS NOT INITIAL
            OR p_rmov IS NOT INITIAL OR p_ormov IS NOT INITIAL OR p_nrmov IS NOT INITIAL
            OR p_runit IS NOT INITIAL OR p_orunit IS NOT INITIAL OR p_nrunit IS NOT INITIAL
            OR p_rsv = abap_true OR p_unrsv = abap_true
            OR p_orsv = abap_true OR p_nrsv = abap_true
            OR p_oursv = abap_true OR p_nursv = abap_true
            OR p_bklg = abap_true OR p_obklg = abap_true
            OR p_nbklg = abap_true
            OR p_shf IS NOT INITIAL OR p_sht IS NOT INITIAL
            OR p_oshf IS NOT INITIAL OR p_osht IS NOT INITIAL
            OR p_nshf IS NOT INITIAL OR p_nsht IS NOT INITIAL
            OR p_covf IS NOT INITIAL OR p_covt IS NOT INITIAL
            OR p_ocovf IS NOT INITIAL OR p_ocovt IS NOT INITIAL
            OR p_ncovf IS NOT INITIAL OR p_ncovt IS NOT INITIAL
            OR p_spf IS NOT INITIAL OR p_spt IS NOT INITIAL
            OR p_ospf IS NOT INITIAL OR p_ospt IS NOT INITIAL
            OR p_nspf IS NOT INITIAL OR p_nspt IS NOT INITIAL
            OR p_qf IS NOT INITIAL OR p_qt IS NOT INITIAL
            OR p_oqf IS NOT INITIAL OR p_oqt IS NOT INITIAL
            OR p_nqf IS NOT INITIAL OR p_nqt IS NOT INITIAL
            OR p_af IS NOT INITIAL OR p_at IS NOT INITIAL
            OR p_oaf IS NOT INITIAL OR p_oat IS NOT INITIAL
            OR p_naf IS NOT INITIAL OR p_nat IS NOT INITIAL
            OR p_priof IS NOT INITIAL OR p_priot IS NOT INITIAL
            OR p_opf IS NOT INITIAL OR p_opt IS NOT INITIAL
            OR p_npf IS NOT INITIAL OR p_npt IS NOT INITIAL
            OR p_sdf IS NOT INITIAL OR p_sdt IS NOT INITIAL
            OR p_osdf IS NOT INITIAL OR p_osdt IS NOT INITIAL
            OR p_nsdf IS NOT INITIAL OR p_nsdt IS NOT INITIAL
             OR p_vbeln IS NOT INITIAL OR p_ovbeln IS NOT INITIAL
             OR p_nvbeln IS NOT INITIAL
             OR p_auart IS NOT INITIAL OR p_oauart IS NOT INITIAL
             OR p_nauart IS NOT INITIAL
             OR p_posnr IS NOT INITIAL OR p_oposnr IS NOT INITIAL
             OR p_nposnr IS NOT INITIAL
             OR p_etenr IS NOT INITIAL OR p_oetenr IS NOT INITIAL
             OR p_netenr IS NOT INITIAL
             OR p_ordun IS NOT INITIAL OR p_oordun IS NOT INITIAL
             OR p_nordun IS NOT INITIAL
             OR p_order IS NOT INITIAL OR p_oorder IS NOT INITIAL
             OR p_norder IS NOT INITIAL
             OR p_resid IS NOT INITIAL OR p_oresid IS NOT INITIAL
             OR p_nresid IS NOT INITIAL
             OR p_obatch IS NOT INITIAL OR p_nbatch IS NOT INITIAL
             OR p_olgort IS NOT INITIAL OR p_nlgort IS NOT INITIAL
             OR p_omatnr IS NOT INITIAL OR p_nmatnr IS NOT INITIAL
             OR p_owerks IS NOT INITIAL OR p_nwerks IS NOT INITIAL
            OR p_rfrom IS NOT INITIAL OR p_rto IS NOT INITIAL
            OR p_orfrom IS NOT INITIAL OR p_orto IS NOT INITIAL
            OR p_nrfrom IS NOT INITIAL OR p_nrto IS NOT INITIAL
            OR p_rage IS NOT INITIAL OR p_rageto IS NOT INITIAL
            OR p_orage IS NOT INITIAL OR p_oragto IS NOT INITIAL
            OR p_nrage IS NOT INITIAL OR p_nragto IS NOT INITIAL
            OR p_mvt IS NOT INITIAL OR p_omvt IS NOT INITIAL OR p_nmvt IS NOT INITIAL
            OR p_shelf IS NOT INITIAL OR p_oshelf IS NOT INITIAL
            OR p_nshelf IS NOT INITIAL
            OR p_oast IS NOT INITIAL OR p_nast IS NOT INITIAL
            OR p_ostr IS NOT INITIAL OR p_nstr IS NOT INITIAL
            OR p_oleg = abap_true OR p_nleg = abap_true
            OR p_omsg IS NOT INITIAL OR p_nmsg IS NOT INITIAL
            OR p_omonly = abap_true OR p_nmonly = abap_true
            OR p_ovrd = abap_true OR p_oovrd = abap_true OR p_novrd = abap_true
            OR p_dead = abap_true
            OR p_odead = abap_true OR p_ndead = abap_true
            OR p_deadf IS NOT INITIAL OR p_deadt IS NOT INITIAL
            OR p_odeadf IS NOT INITIAL OR p_odeadt IS NOT INITIAL
            OR p_ndeadf IS NOT INITIAL OR p_ndeadt IS NOT INITIAL
            OR p_dagef IS NOT INITIAL OR p_daget IS NOT INITIAL
            OR p_daged IS NOT INITIAL
            OR p_oagef IS NOT INITIAL OR p_oaget IS NOT INITIAL
            OR p_nagef IS NOT INITIAL OR p_naget IS NOT INITIAL
            OR p_reqf IS NOT INITIAL OR p_until IS NOT INITIAL
            OR p_oreqf IS NOT INITIAL OR p_oreqt IS NOT INITIAL
            OR p_nreqf IS NOT INITIAL OR p_nreqt IS NOT INITIAL.
          lo_missing_run_error->message =
            'New allocation run does not match the policy filters'.
        ELSE.
          lo_missing_run_error->message = 'New allocation run was not found'.
        ENDIF.
        RAISE EXCEPTION lo_missing_run_error.
      ENDIF.
    CATCH zcx_stock_allocation INTO DATA(lo_read_error).
      IF lo_read_error->message IS INITIAL.
        lv_error_message = 'Allocation snapshots are unavailable'.
      ELSE.
        lv_error_message = lo_read_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / 'Allocation snapshots are unavailable:', lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF ls_old_run-requested_deadline IS INITIAL.
    lv_old_deadline_age_text = 'n/a'.
  ELSE.
    lv_old_deadline_age_days = lv_deadline_reference_date
      - ls_old_run-requested_deadline.
    lv_old_deadline_age_text = zcl_stock_csv=>number(
      lv_old_deadline_age_days ).
  ENDIF.
  IF ls_new_run-requested_deadline IS INITIAL.
    lv_new_deadline_age_text = 'n/a'.
  ELSE.
    lv_new_deadline_age_days = lv_deadline_reference_date
      - ls_new_run-requested_deadline.
    lv_new_deadline_age_text = zcl_stock_csv=>number(
      lv_new_deadline_age_days ).
  ENDIF.
  IF ls_old_run-requested_deadline IS NOT INITIAL
      AND ls_new_run-requested_deadline IS NOT INITIAL.
    lv_deadline_age_delta_days = lv_new_deadline_age_days
      - lv_old_deadline_age_days.
    lv_deadline_age_delta_text = zcl_stock_csv=>number(
      lv_deadline_age_delta_days ).
  ELSE.
    lv_deadline_age_delta_text = 'n/a'.
  ENDIF.

  CREATE OBJECT lo_compare TYPE zcl_stock_allocation_compare.
  TRY.
      lt_changes = lo_compare->compare(
        EXPORTING
          it_old               = lt_old
          it_new               = lt_new
          iv_change_type       = p_chg
          iv_reason            = p_reason
          iv_old_status        = p_ost
          iv_new_status        = p_nst
          iv_include_unchanged = p_all
          iv_offset            = lv_compare_offset
          iv_max_rows          = lv_compare_max_rows
        IMPORTING
          es_summary           = ls_summary
          ev_total_rows        = lv_total_rows ).
    CATCH zcx_stock_allocation INTO DATA(lo_compare_error).
      IF lo_compare_error->message IS INITIAL.
        lv_error_message = 'Allocation snapshots cannot be compared'.
      ELSE.
        lv_error_message = lo_compare_error->message.
      ENDIF.
      IF p_json = abap_true.
        WRITE: / zcl_stock_json=>error( lv_error_message ).
      ELSEIF p_csv = abap_true.
        WRITE: / 'mode;status;message'.
        WRITE: / zcl_stock_csv=>error(
          iv_mode    = 'zstock_alloc_compare'
          iv_message = lv_error_message ).
      ELSE.
        WRITE: / lv_error_message.
      ENDIF.
      RETURN.
  ENDTRY.

  IF p_wors = abap_true.
    lt_changes = lo_compare->sort_by_shortage_worsening( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_cw = abap_true.
    lt_changes = lo_compare->sort_by_coverage_worsening( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_spw = abap_true.
    lt_changes = lo_compare->sort_by_spct_worsening(
      lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_sreg = abap_true.
    lt_changes = lo_compare->sort_by_status_regression( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_qd = abap_true.
    lt_changes = lo_compare->sort_by_requested_delta( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_cov = abap_true.
    lt_changes = lo_compare->sort_by_coverage( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_spct = abap_true.
    lt_changes = lo_compare->sort_by_shortage_percentage( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_big = abap_true.
    lt_changes = lo_compare->sort_by_requested_quantity( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_done = abap_true.
    lt_changes = lo_compare->sort_by_allocated_quantity( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_due = abap_true.
    lt_changes = lo_compare->sort_by_requested_date( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_rdate = abap_true.
    lt_changes = lo_compare->sort_by_reservation_date( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ELSEIF p_shrt = abap_true.
    lt_changes = lo_compare->sort_by_shortage( lt_changes ).
    lv_sort_start = 0.
    IF p_skip > 0.
      IF p_skip >= lines( lt_changes ).
        CLEAR lt_changes.
      ELSE.
        DELETE lt_changes FROM 1 TO p_skip.
      ENDIF.
    ENDIF.
    IF p_max > 0 AND lines( lt_changes ) > p_max.
      lv_sort_start = p_max + 1.
      DELETE lt_changes FROM lv_sort_start.
    ENDIF.
  ENDIF.

  IF p_max > 0 AND p_skip + lines( lt_changes ) < lv_total_rows.
    lv_has_more = abap_true.
    lv_next_offset = p_skip + lines( lt_changes ).
    lv_next_offset_text = zcl_stock_csv=>number( lv_next_offset ).
  ELSE.
    lv_has_more = abap_false.
    lv_next_offset = 0.
    lv_next_offset_text = 'n/a'.
  ENDIF.
  IF p_max > 0.
    lv_page_number = p_skip DIV p_max + 1.
    lv_page_number_text = zcl_stock_csv=>number( lv_page_number ).
    IF p_skip > 0.
      lv_has_previous = abap_true.
      IF p_skip >= p_max.
        lv_previous_offset = p_skip - p_max.
      ELSE.
        lv_previous_offset = 0.
      ENDIF.
      lv_previous_offset_text = zcl_stock_csv=>number(
        lv_previous_offset ).
    ELSE.
      lv_has_previous = abap_false.
      lv_previous_offset = 0.
      lv_previous_offset_text = 'n/a'.
    ENDIF.
  ELSE.
    lv_has_previous = abap_false.
    lv_previous_offset = 0.
    lv_previous_offset_text = 'n/a'.
    lv_page_number = 0.
    lv_page_number_text = 'n/a'.
  ENDIF.
  IF p_max > 0.
    lv_page_count = ( lv_total_rows + p_max - 1 ) DIV p_max.
    lv_page_count_text = zcl_stock_csv=>number( lv_page_count ).
    IF lv_page_count > 0.
      lv_last_offset = ( lv_page_count - 1 ) * p_max.
    ELSE.
      lv_last_offset = 0.
    ENDIF.
    lv_last_offset_text = zcl_stock_csv=>number( lv_last_offset ).
  ELSE.
    lv_page_count = 0.
    lv_page_count_text = 'n/a'.
    lv_last_offset = 0.
    lv_last_offset_text = 'n/a'.
  ENDIF.

  ls_old_reconciliation = lo_compare->reconcile(
    it_snapshot = lt_old
    is_audit    = ls_old_run ).
  ls_new_reconciliation = lo_compare->reconcile(
    it_snapshot = lt_new
    is_audit    = ls_new_run ).
  IF p_ovrd = abap_true.
    "The snapshot is intentionally a subset of the persisted audit run.
    "Keep its metrics for comparison, but do not present full-run checks as
    "a data-integrity mismatch.
    lv_old_reconciliation = 'FILTERED'.
    lv_new_reconciliation = 'FILTERED'.
    ls_old_reconciliation-mismatch_fields = 'filtered'.
    ls_new_reconciliation-mismatch_fields = 'filtered'.
  ELSE.
    lv_old_reconciliation = ls_old_reconciliation-status.
    lv_new_reconciliation = ls_new_reconciliation-status.
  ENDIF.
  IF lv_old_reconciliation <> lv_new_reconciliation.
    lv_recon_status_changed = abap_true.
  ELSE.
    lv_recon_status_changed = abap_false.
  ENDIF.
  lv_recon_transition = lo_compare->get_reconciliation_transition(
    iv_old_status = lv_old_reconciliation
    iv_new_status = lv_new_reconciliation ).
  IF lv_recon_transition = 'both_ok'.
    lv_recon_both_ok = abap_true.
  ELSE.
    lv_recon_both_ok = abap_false.
  ENDIF.
  lv_audit_demand_delta = ls_new_run-demand_count -
    ls_old_run-demand_count.
  lv_audit_full_delta = ls_new_run-full_count - ls_old_run-full_count.
  lv_audit_partial_delta = ls_new_run-partial_count -
    ls_old_run-partial_count.
  lv_audit_unallocated_delta = ls_new_run-unallocated_count -
    ls_old_run-unallocated_count.
  lv_old_requested_total = ls_old_reconciliation-snapshot_requested.
  lv_new_requested_total = ls_new_reconciliation-snapshot_requested.

  IF ls_old_run-finish_date IS INITIAL.
    lv_old_duration_text = 'n/a'.
  ELSE.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_old_run-finish_date
        time1    = ls_old_run-finish_time
        date2    = ls_old_run-start_date
        time2    = ls_old_run-start_time
      IMPORTING
        res_secs = lv_old_duration_seconds ).
    lv_old_duration_text = zcl_stock_csv=>number(
      lv_old_duration_seconds ).
  ENDIF.
  IF ls_new_run-finish_date IS INITIAL.
    lv_new_duration_text = 'n/a'.
  ELSE.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_new_run-finish_date
        time1    = ls_new_run-finish_time
        date2    = ls_new_run-start_date
        time2    = ls_new_run-start_time
      IMPORTING
        res_secs = lv_new_duration_seconds ).
    lv_new_duration_text = zcl_stock_csv=>number(
      lv_new_duration_seconds ).
  ENDIF.

  ls_old_running_age = lo_audit->get_running_age( ls_old_run ).
  ls_new_running_age = lo_audit->get_running_age( ls_new_run ).
  lv_old_running_age_seconds = ls_old_running_age-seconds.
  lv_new_running_age_seconds = ls_new_running_age-seconds.
  lv_old_running_age_available = ls_old_running_age-available.
  lv_new_running_age_available = ls_new_running_age-available.
  lv_old_running_age_text = 'n/a'.
  lv_new_running_age_text = 'n/a'.
  IF lv_old_running_age_available = abap_true.
    lv_old_running_age_text = zcl_stock_csv=>number(
      lv_old_running_age_seconds ).
  ENDIF.
  IF lv_new_running_age_available = abap_true.
    lv_new_running_age_text = zcl_stock_csv=>number(
      lv_new_running_age_seconds ).
  ENDIF.
  IF lv_old_running_age_available = abap_true
      AND lv_new_running_age_available = abap_true.
    lv_audit_running_age_delta = lv_new_running_age_seconds -
      lv_old_running_age_seconds.
    lv_aud_run_age_delta_text = zcl_stock_csv=>number(
      lv_audit_running_age_delta ).
  ELSE.
    lv_aud_run_age_delta_text = 'n/a'.
  ENDIF.
  lv_aud_run_age_trend = lo_compare->get_running_age_trend(
    is_old_age = ls_old_running_age
    is_new_age = ls_new_running_age ).

  IF ls_old_run-requested > 0.
    lv_old_audit_coverage = ls_old_run-allocated * 100 /
      ls_old_run-requested.
    lv_old_audit_shortage_pct = ls_old_run-shortage * 100 /
      ls_old_run-requested.
    lv_old_audit_coverage_text = zcl_stock_csv=>number(
      lv_old_audit_coverage ).
    lv_old_audit_shortage_pct_text = zcl_stock_csv=>number(
      lv_old_audit_shortage_pct ).
  ELSE.
    lv_old_audit_coverage_text = 'n/a'.
    lv_old_audit_shortage_pct_text = 'n/a'.
  ENDIF.
  IF ls_new_run-requested > 0.
    lv_new_audit_coverage = ls_new_run-allocated * 100 /
      ls_new_run-requested.
    lv_new_audit_shortage_pct = ls_new_run-shortage * 100 /
      ls_new_run-requested.
    lv_new_audit_coverage_text = zcl_stock_csv=>number(
      lv_new_audit_coverage ).
    lv_new_audit_shortage_pct_text = zcl_stock_csv=>number(
      lv_new_audit_shortage_pct ).
  ELSE.
    lv_new_audit_coverage_text = 'n/a'.
    lv_new_audit_shortage_pct_text = 'n/a'.
  ENDIF.

  IF ls_old_run-unit IS NOT INITIAL
      AND ls_old_run-unit = ls_new_run-unit.
    lv_audit_units_match = abap_true.
    lv_audit_requested_delta = ls_new_run-requested - ls_old_run-requested.
    lv_audit_available_delta = ls_new_run-available - ls_old_run-available.
    lv_audit_requested_delta_text = zcl_stock_csv=>number(
      lv_audit_requested_delta ).
    lv_audit_available_delta_text = zcl_stock_csv=>number(
      lv_audit_available_delta ).
    lv_audit_allocated_delta = ls_new_run-allocated - ls_old_run-allocated.
    lv_audit_shortage_delta = ls_new_run-shortage - ls_old_run-shortage.
    lv_audit_allocated_delta_text = zcl_stock_csv=>number(
      lv_audit_allocated_delta ).
    lv_audit_shortage_delta_text = zcl_stock_csv=>number(
      lv_audit_shortage_delta ).
    IF ls_old_run-requested > 0 AND ls_new_run-requested > 0.
      lv_audit_coverage_delta = lv_new_audit_coverage -
        lv_old_audit_coverage.
      lv_audit_shortage_pct_delta = lv_new_audit_shortage_pct -
        lv_old_audit_shortage_pct.
      lv_audit_coverage_delta_text = zcl_stock_csv=>number(
        lv_audit_coverage_delta ).
      lv_aud_shrt_pct_delta_text = zcl_stock_csv=>number(
        lv_audit_shortage_pct_delta ).
    ELSE.
      lv_audit_coverage_delta_text = 'n/a'.
      lv_aud_shrt_pct_delta_text = 'n/a'.
    ENDIF.
  ELSE.
    lv_audit_units_match = abap_false.
    lv_audit_requested_delta_text = 'n/a'.
    lv_audit_available_delta_text = 'n/a'.
    lv_audit_allocated_delta_text = 'n/a'.
    lv_audit_shortage_delta_text = 'n/a'.
    lv_audit_coverage_delta_text = 'n/a'.
    lv_aud_shrt_pct_delta_text = 'n/a'.
  ENDIF.

  IF ls_old_run-requested_on_from <> ls_new_run-requested_on_from
      OR ls_old_run-requested_on_to <> ls_new_run-requested_on_to.
    lv_audit_horizon_changed = abap_true.
  ELSE.
    lv_audit_horizon_changed = abap_false.
  ENDIF.
  IF ls_old_run-status <> ls_new_run-status.
    lv_audit_status_changed = abap_true.
  ELSE.
    lv_audit_status_changed = abap_false.
  ENDIF.
  IF ls_old_run-strategy <> ls_new_run-strategy.
    lv_audit_strategy_changed = abap_true.
  ELSE.
    lv_audit_strategy_changed = abap_false.
  ENDIF.
  IF ( ls_old_run-finish_date IS INITIAL
      AND ls_new_run-finish_date IS NOT INITIAL )
      OR ( ls_old_run-finish_date IS NOT INITIAL
      AND ls_new_run-finish_date IS INITIAL ).
    lv_audit_running_changed = abap_true.
  ELSE.
    lv_audit_running_changed = abap_false.
  ENDIF.
  IF ls_old_run-finish_date IS NOT INITIAL
      AND ls_new_run-finish_date IS NOT INITIAL.
    lv_aud_dur_delta_secs = lv_new_duration_seconds -
      lv_old_duration_seconds.
    lv_audit_duration_delta_text = zcl_stock_csv=>number(
      lv_aud_dur_delta_secs ).
  ELSE.
    lv_audit_duration_delta_text = 'n/a'.
  ENDIF.
  IF ls_old_run-start_date IS NOT INITIAL
      AND ls_new_run-start_date IS NOT INITIAL.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_new_run-start_date
        time1    = ls_new_run-start_time
        date2    = ls_old_run-start_date
        time2    = ls_old_run-start_time
      IMPORTING
        res_secs = lv_aud_start_delta_secs ).
    lv_audit_start_delta_text = zcl_stock_csv=>number(
      lv_aud_start_delta_secs ).
  ELSE.
    lv_audit_start_delta_text = 'n/a'.
  ENDIF.
  IF ls_old_run-finish_date IS NOT INITIAL
      AND ls_new_run-finish_date IS NOT INITIAL.
    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = ls_new_run-finish_date
        time1    = ls_new_run-finish_time
        date2    = ls_old_run-finish_date
        time2    = ls_old_run-finish_time
      IMPORTING
        res_secs = lv_aud_finish_delta_secs ).
    lv_audit_finish_delta_text = zcl_stock_csv=>number(
      lv_aud_finish_delta_secs ).
  ELSE.
    lv_audit_finish_delta_text = 'n/a'.
  ENDIF.

  lv_audit_meta_reasons = lo_compare->get_audit_metadata_reasons(
    iv_old_run = ls_old_run
    iv_new_run = ls_new_run ).
  IF lv_audit_meta_reasons IS INITIAL.
    lv_audit_meta_changed = abap_false.
  ELSE.
    lv_audit_meta_changed = abap_true.
  ENDIF.

  IF p_guard = abap_true
      AND ( lv_old_reconciliation = 'MISMATCH'
        OR lv_new_reconciliation = 'MISMATCH' ).
    CONCATENATE 'Snapshot-to-audit reconciliation failed:'
      'old=' ls_old_reconciliation-mismatch_fields
      'new=' ls_new_reconciliation-mismatch_fields
      INTO lv_error_message SEPARATED BY space.
    IF p_json = abap_true.
      WRITE: / zcl_stock_json=>error( lv_error_message ).
    ELSEIF p_csv = abap_true.
      WRITE: / 'mode;status;message'.
      WRITE: / zcl_stock_csv=>error(
        iv_mode    = 'zstock_alloc_compare'
        iv_message = lv_error_message ).
    ELSE.
      WRITE: / lv_error_message.
    ENDIF.
    RETURN.
  ENDIF.

  IF p_sum = abap_true.
    lv_sum_old_cov_text = 'n/a'.
    lv_sum_new_cov_text = 'n/a'.
    lv_sum_cov_delta_text = 'n/a'.
    lv_sum_old_shrt_text = 'n/a'.
    lv_sum_new_shrt_text = 'n/a'.
    lv_sum_shrt_delta_text = 'n/a'.
    IF ls_summary-old_coverage_available = abap_true.
      lv_sum_old_cov_text = zcl_stock_csv=>number(
        ls_summary-old_coverage ).
    ENDIF.
    IF ls_summary-new_coverage_available = abap_true.
      lv_sum_new_cov_text = zcl_stock_csv=>number(
        ls_summary-new_coverage ).
    ENDIF.
    IF ls_summary-coverage_delta_available = abap_true.
      lv_sum_cov_delta_text = zcl_stock_csv=>number(
        ls_summary-coverage_delta ).
    ENDIF.
    IF ls_summary-old_shortage_pct_available = abap_true.
      lv_sum_old_shrt_text = zcl_stock_csv=>number(
        ls_summary-old_shortage_pct ).
    ENDIF.
    IF ls_summary-new_shortage_pct_available = abap_true.
      lv_sum_new_shrt_text = zcl_stock_csv=>number(
        ls_summary-new_shortage_pct ).
    ENDIF.
    IF ls_summary-shortage_pct_delta_available = abap_true.
      lv_sum_shrt_delta_text = zcl_stock_csv=>number(
        ls_summary-shortage_pct_delta ).
    ENDIF.
    IF p_csv = abap_true.
      WRITE: / 'schema_version;generated_date;generated_time;old_run;new_run;'
        && 'material;old_material_filter;new_material_filter;plant;'
        && 'old_plant_filter;new_plant_filter;'
        && 'storage_location;old_storage_location_filter;'
        && 'new_storage_location_filter;batch;old_batch_filter;new_batch_filter;'
        && 'unit;old_unit_filter;new_unit_filter;'
        && 'reservation_movement_type_filter;old_reservation_movement_type_filter;'
        && 'new_reservation_movement_type_filter;'
        && 'reservation_unit_filter;old_reservation_unit_filter;'
        && 'new_reservation_unit_filter;'
        && 'reserved_only;unreserved_only;old_reserved_only;new_reserved_only;'
        && 'old_unreserved_only;new_unreserved_only;'
        && 'shortage_only;old_shortage_only;new_shortage_only;'
        && 'minimum_shortage_filter;maximum_shortage_filter;'
        && 'old_minimum_shortage_filter;old_maximum_shortage_filter;'
        && 'new_minimum_shortage_filter;new_maximum_shortage_filter;'
        && 'minimum_coverage_filter;maximum_coverage_filter;'
        && 'old_minimum_coverage_filter;old_maximum_coverage_filter;'
        && 'new_minimum_coverage_filter;new_maximum_coverage_filter;'
        && 'minimum_shortage_pct_filter;maximum_shortage_pct_filter;'
        && 'old_minimum_shortage_pct_filter;old_maximum_shortage_pct_filter;'
        && 'new_minimum_shortage_pct_filter;new_maximum_shortage_pct_filter;'
        && 'minimum_requested_quantity_filter;maximum_requested_quantity_filter;'
        && 'old_minimum_requested_quantity_filter;old_maximum_requested_quantity_filter;'
        && 'new_minimum_requested_quantity_filter;new_maximum_requested_quantity_filter;'
        && 'minimum_allocated_quantity_filter;maximum_allocated_quantity_filter;'
        && 'old_minimum_allocated_quantity_filter;old_maximum_allocated_quantity_filter;'
        && 'new_minimum_allocated_quantity_filter;new_maximum_allocated_quantity_filter;'
        && 'minimum_priority_filter;maximum_priority_filter;'
        && 'old_minimum_priority_filter;old_maximum_priority_filter;'
        && 'new_minimum_priority_filter;new_maximum_priority_filter;'
        && 'snapshot_requested_date_from_filter;snapshot_requested_date_to_filter;'
        && 'old_snapshot_requested_date_from_filter;old_snapshot_requested_date_to_filter;'
         && 'new_snapshot_requested_date_from_filter;new_snapshot_requested_date_to_filter;'
         && 'sales_document_filter;old_sales_document_filter;new_sales_document_filter;'
         && 'sales_document_type_filter;old_sales_document_type_filter;'
         && 'new_sales_document_type_filter;'
         && 'sales_item_filter;old_sales_item_filter;new_sales_item_filter;'
         && 'schedule_line_filter;old_schedule_line_filter;new_schedule_line_filter;'
         && 'order_unit_filter;old_order_unit_filter;new_order_unit_filter;'
         && 'order_id_filter;old_order_id_filter;new_order_id_filter;'
         && 'reservation_id_filter;old_reservation_id_filter;new_reservation_id_filter;'
        && 'reservation_date_from_filter;reservation_date_to_filter;'
        && 'old_reservation_date_from_filter;old_reservation_date_to_filter;'
        && 'new_reservation_date_from_filter;new_reservation_date_to_filter;'
        && 'reservation_age_filter;maximum_reservation_age_filter;'
        && 'old_reservation_age_filter;old_maximum_reservation_age_filter;'
        && 'new_reservation_age_filter;new_maximum_reservation_age_filter;'
        && 'filters_applied;filters;sort_mode;'
        && 'movement_type_filter;old_movement_type_filter;new_movement_type_filter;'
        && 'minimum_shelf_life_filter;old_minimum_shelf_life_filter;'
        && 'new_minimum_shelf_life_filter;overdue_only;'
        && 'old_overdue_only;new_overdue_only;requested_overdue_as_of_filter;'
        && 'requested_on_from_filter;'
        && 'requested_on_to_filter;old_requested_on_from_filter;old_requested_on_to_filter;'
        && 'new_requested_on_from_filter;new_requested_on_to_filter;'
        && 'requested_deadline_only;old_requested_deadline_only;new_requested_deadline_only;'
        && 'requested_deadline_from_filter;requested_deadline_to_filter;'
        && 'old_requested_deadline_from_filter;old_requested_deadline_to_filter;'
        && 'new_requested_deadline_from_filter;new_requested_deadline_to_filter;'
        && 'deadline_age_from_filter;deadline_age_to_filter;'
        && 'old_deadline_age_from_filter;old_deadline_age_to_filter;'
        && 'new_deadline_age_from_filter;new_deadline_age_to_filter;'
        && 'deadline_age_date_filter;'
        && 'audit_duration_from_filter;audit_duration_to_filter;'
        && 'old_audit_duration_from_filter;old_audit_duration_to_filter;'
        && 'new_audit_duration_from_filter;new_audit_duration_to_filter;'
        && 'available_stock_from_filter;available_stock_to_filter;'
        && 'old_available_stock_from_filter;old_available_stock_to_filter;'
        && 'new_available_stock_from_filter;new_available_stock_to_filter;'
        && 'change_type;reason_filter;old_status_filter;new_status_filter;'
        && 'old_audit_status_filter;new_audit_status_filter;old_strategy_filter;'
        && 'new_strategy_filter;old_legacy_strategy_filter;new_legacy_strategy_filter;'
        && 'old_message_filter;'
        && 'new_message_filter;old_message_only;new_message_only;'
        && 'include_unchanged;'
        && 'reconciliation_guard;old_run_status;new_run_status;old_run_strategy;new_run_strategy;old_movement_type;'
        && 'new_movement_type;old_min_shelf_life;new_min_shelf_life;old_safety_stock;new_safety_stock;old_start_date;'
        && 'new_start_date;old_start_time;new_start_time;old_finish_date;new_finish_date;old_finish_time;'
        && 'new_finish_time;old_requested_on_from;new_requested_on_from;old_requested_on_to;new_requested_on_to;'
        && 'old_requested_deadline;new_requested_deadline;'
        && 'old_deadline_age_days;new_deadline_age_days;deadline_age_delta_days;'
        && 'deadline_age_reference_date;'
        && 'old_available;new_available;old_duration_seconds;new_duration_seconds;old_running_age_seconds;'
        && 'new_running_age_seconds;audit_running_age_delta_seconds;audit_running_age_trend;old_message;new_message;'
        && 'old_reconciliation;new_reconciliation;audit_reconciliation_changed;audit_reconciliation_ok;'
        && 'audit_reconciliation_transition;audit_metadata_changed;audit_metadata_change_reasons;'
        && 'old_reconciliation_fields;new_reconciliation_fields;old_audit_unit;new_audit_unit;audit_units_match;'
        && 'audit_horizon_changed;audit_status_changed;audit_strategy_changed;audit_running_changed;'
        && 'audit_duration_delta_seconds;audit_start_delta_seconds;audit_finish_delta_seconds;old_audit_demand_count;'
        && 'new_audit_demand_count;old_audit_full_rows;new_audit_full_rows;old_audit_partial_rows;'
        && 'new_audit_partial_rows;old_audit_unallocated_rows;new_audit_unallocated_rows;audit_demand_count_delta;'
        && 'audit_full_rows_delta;audit_partial_rows_delta;audit_unallocated_rows_delta;old_audit_requested;'
        && 'new_audit_requested;old_audit_allocated;new_audit_allocated;old_audit_shortage;new_audit_shortage;'
        && 'old_audit_coverage_pct;new_audit_coverage_pct;old_audit_shortage_pct;new_audit_shortage_pct;'
        && 'audit_requested_delta;audit_available_delta;audit_allocated_delta;audit_shortage_delta;'
        && 'audit_coverage_delta_pct;audit_shortage_pct_delta;old_snapshot_rows;new_snapshot_rows;'
        && 'old_snapshot_requested;new_snapshot_requested;old_snapshot_full_rows;new_snapshot_full_rows;'
        && 'old_snapshot_partial_rows;new_snapshot_partial_rows;old_snapshot_unallocated_rows;'
        && 'new_snapshot_unallocated_rows;old_snapshot_allocated;new_snapshot_allocated;old_snapshot_shortage;'
        && 'new_snapshot_shortage;unit;mixed_units;total_rows;returned_rows;offset;max_rows;added_rows;removed_rows;'
        && 'changed_rows;unchanged_rows;old_requested;new_requested;delta_requested;old_allocated;new_allocated;'
        && 'delta_allocated;old_shortage;new_shortage;delta_shortage;old_coverage_pct;'
        && 'new_coverage_pct;coverage_delta_pct;old_shortage_pct;new_shortage_pct;'
        && 'shortage_pct_delta;filter_values;has_more;next_offset;'
        && 'has_previous;previous_offset;page_number;page_count;last_offset'.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>number( 95 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_old ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_new ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_material_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_material_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_plant_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_plant_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_storage_location_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_storage_location_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_batch_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_batch_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_unit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_unit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_reservation_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rmov_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rmov_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_reservation_unit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_runit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_runit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_rsv ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_unrsv ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_reserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_reserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_unreserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_unreserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_bklg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shortage_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shortage_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shortage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shortage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shortage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shortage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_coverage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_coverage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_coverage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_coverage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_coverage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_coverage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_pct_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_pct_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_sp_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_sp_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_sp_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_sp_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_req_qty_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_req_qty_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_req_qty_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_req_qty_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_req_qty_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_req_qty_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_allocated_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_allocated_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_allocated_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_allocated_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_allocated_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_allocated_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_priority_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_priority_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_priority_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_priority_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_priority_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_priority_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_snapshot_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_snapshot_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_snapshot_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_snapshot_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_snapshot_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_snapshot_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_sales_document_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_sales_document_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_sales_document_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_auart_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_auart_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_auart_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_posnr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_posnr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_posnr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_etenr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_etenr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_etenr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_ordunit_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_ordunit_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_ordunit_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_order_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_order_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_order_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_resid_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_resid_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_resid_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rdate_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rdate_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rdate_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rdate_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rdate_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rdate_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rageto_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rageto_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rageto_filter ) TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_filter_names_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_sort_mode ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_overdue_only_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_overdue_only_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_overdue_as_of_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_requested_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_requested_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_requested_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_requested_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_dead ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_deadline_only_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_deadline_only_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_deadline_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_deadline_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_deadline_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_deadline_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_age_from_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_age_to_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_age_from_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_age_to_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_date_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_duration_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_duration_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_duration_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_available_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_available_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_available_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_available_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_available_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_available_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_chg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ost ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_nst ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_audit_status_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_audit_status_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_legacy_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_legacy_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_message_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_message_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_message_only_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_message_only_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_all ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_guard ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-min_shelf_life ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-min_shelf_life ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-safety_stock ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-safety_stock ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_deadline ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_deadline ) TO lt_csv_fields.
      APPEND lv_old_deadline_age_text TO lt_csv_fields.
      APPEND lv_new_deadline_age_text TO lt_csv_fields.
      APPEND lv_deadline_age_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_reference_date )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-available ) TO lt_csv_fields.
      APPEND lv_old_duration_text TO lt_csv_fields.
      APPEND lv_new_duration_text TO lt_csv_fields.
      APPEND lv_old_running_age_text TO lt_csv_fields.
      APPEND lv_new_running_age_text TO lt_csv_fields.
      APPEND lv_aud_run_age_delta_text TO lt_csv_fields.
      APPEND lv_aud_run_age_trend TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_both_ok ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_transition ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_reasons ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_old_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_new_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_units_match ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_horizon_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_strategy_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_running_changed ) TO lt_csv_fields.
      APPEND lv_audit_duration_delta_text TO lt_csv_fields.
      APPEND lv_audit_start_delta_text TO lt_csv_fields.
      APPEND lv_audit_finish_delta_text TO lt_csv_fields.
      APPEND lv_audit_requested_delta_text TO lt_csv_fields.
      APPEND lv_audit_available_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_demand_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_full_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_partial_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_unallocated_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-shortage ) TO lt_csv_fields.
      APPEND lv_old_audit_coverage_text TO lt_csv_fields.
      APPEND lv_new_audit_coverage_text TO lt_csv_fields.
      APPEND lv_old_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_new_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_audit_allocated_delta_text TO lt_csv_fields.
      APPEND lv_audit_shortage_delta_text TO lt_csv_fields.
      APPEND lv_audit_coverage_delta_text TO lt_csv_fields.
      APPEND lv_aud_shrt_pct_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_old ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_new ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_old_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_new_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      IF ls_summary-mixed_units = abap_true.
        APPEND zcl_stock_csv=>quote( 'mixed' ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>quote( ls_summary-unit ) TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( ls_summary-mixed_units ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-total_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_changes ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_filter_values_json ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_has_more ) TO lt_csv_fields.
      APPEND lv_next_offset_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_has_previous ) TO lt_csv_fields.
      APPEND lv_previous_offset_text TO lt_csv_fields.
      APPEND lv_page_number_text TO lt_csv_fields.
      APPEND lv_page_count_text TO lt_csv_fields.
      APPEND lv_last_offset_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-added_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-removed_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-changed_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_summary-unchanged_rows ) TO lt_csv_fields.
      IF ls_summary-mixed_units = abap_true.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>quote( 'n/a' ) TO lt_csv_fields.
      ELSE.
        APPEND zcl_stock_csv=>number( ls_summary-old_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-new_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-delta_requested ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-old_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-new_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-delta_allocated ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-old_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-new_shortage ) TO lt_csv_fields.
        APPEND zcl_stock_csv=>number( ls_summary-delta_shortage ) TO lt_csv_fields.
      ENDIF.
      APPEND lv_sum_old_cov_text TO lt_csv_fields.
      APPEND lv_sum_new_cov_text TO lt_csv_fields.
      APPEND lv_sum_cov_delta_text TO lt_csv_fields.
      APPEND lv_sum_old_shrt_text TO lt_csv_fields.
      APPEND lv_sum_new_shrt_text TO lt_csv_fields.
      APPEND lv_sum_shrt_delta_text TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
      RETURN.
    ENDIF.

    IF p_json = abap_true.
      CLEAR lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'total_rows'
        iv_value = ls_summary-total_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'added_rows'
        iv_value = ls_summary-added_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'removed_rows'
        iv_value = ls_summary-removed_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'changed_rows'
        iv_value = ls_summary-changed_rows ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'unchanged_rows'
        iv_value = ls_summary-unchanged_rows ) TO lt_summary_json_fields.
      IF ls_summary-mixed_units = abap_true.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = 'mixed' ) TO lt_summary_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'unit'
          iv_value = ls_summary-unit ) TO lt_summary_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'mixed_units'
        iv_value = ls_summary-mixed_units ) TO lt_summary_json_fields.
      IF ls_summary-mixed_units = abap_true.
        IF p_typed = abap_true.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'old_requested' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'new_requested' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'delta_requested' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'old_allocated' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'new_allocated' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'delta_allocated' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'old_shortage' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'new_shortage' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>null_property(
            iv_name = 'delta_shortage' ) TO lt_summary_json_fields.
        ELSE.
          APPEND zcl_stock_json=>property(
            iv_name  = 'old_requested'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'new_requested'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'delta_requested'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'old_allocated'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'new_allocated'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'delta_allocated'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'old_shortage'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'new_shortage'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
          APPEND zcl_stock_json=>property(
            iv_name  = 'delta_shortage'
            iv_value = 'n/a' ) TO lt_summary_json_fields.
        ENDIF.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_requested'
          iv_value = ls_summary-old_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_requested'
          iv_value = ls_summary-new_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_requested'
          iv_value = ls_summary-delta_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_allocated'
          iv_value = ls_summary-old_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_allocated'
          iv_value = ls_summary-new_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_allocated'
          iv_value = ls_summary-delta_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_shortage'
          iv_value = ls_summary-old_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_shortage'
          iv_value = ls_summary-new_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_shortage'
          iv_value = ls_summary-delta_shortage ) TO lt_summary_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_requested'
          iv_value = ls_summary-old_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_requested'
          iv_value = ls_summary-new_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_requested'
          iv_value = ls_summary-delta_requested ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_allocated'
          iv_value = ls_summary-old_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_allocated'
          iv_value = ls_summary-new_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_allocated'
          iv_value = ls_summary-delta_allocated ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_shortage'
          iv_value = ls_summary-old_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_shortage'
          iv_value = ls_summary-new_shortage ) TO lt_summary_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_shortage'
          iv_value = ls_summary-delta_shortage ) TO lt_summary_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_coverage_pct'
        iv_value   = ls_summary-old_coverage
        iv_text    = lv_sum_old_cov_text
        iv_present = ls_summary-old_coverage_available
        iv_typed   = p_typed ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_coverage_pct'
        iv_value   = ls_summary-new_coverage
        iv_text    = lv_sum_new_cov_text
        iv_present = ls_summary-new_coverage_available
        iv_typed   = p_typed ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'coverage_delta_pct'
        iv_value   = ls_summary-coverage_delta
        iv_text    = lv_sum_cov_delta_text
        iv_present = ls_summary-coverage_delta_available
        iv_typed   = p_typed ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_shortage_pct'
        iv_value   = ls_summary-old_shortage_pct
        iv_text    = lv_sum_old_shrt_text
        iv_present = ls_summary-old_shortage_pct_available
        iv_typed   = p_typed ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_shortage_pct'
        iv_value   = ls_summary-new_shortage_pct
        iv_text    = lv_sum_new_shrt_text
        iv_present = ls_summary-new_shortage_pct_available
        iv_typed   = p_typed ) TO lt_summary_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'shortage_pct_delta'
        iv_value   = ls_summary-shortage_pct_delta
        iv_text    = lv_sum_shrt_delta_text
        iv_present = ls_summary-shortage_pct_delta_available
        iv_typed   = p_typed ) TO lt_summary_json_fields.

      CLEAR lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 95 ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = abap_true ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_reference_date'
        iv_value = lv_deadline_reference_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_run'
        iv_value = p_old ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_run'
        iv_value = p_new ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = p_matnr ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_material_filter'
        iv_value = lv_old_material_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_material_filter'
        iv_value = lv_new_material_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = p_werks ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_plant_filter'
        iv_value = lv_old_plant_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_plant_filter'
        iv_value = lv_new_plant_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = p_lgort ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_storage_location_filter'
        iv_value = lv_old_storage_location_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_storage_location_filter'
        iv_value = lv_new_storage_location_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = p_charg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_batch_filter'
        iv_value = lv_old_batch_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_batch_filter'
        iv_value = lv_new_batch_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = p_meins ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_unit_filter'
        iv_value = lv_old_unit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_unit_filter'
        iv_value = lv_new_unit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_movement_type_filter'
        iv_value = lv_reservation_movement_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_movement_type_filter'
        iv_value = lv_old_rmov_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_movement_type_filter'
        iv_value = lv_new_rmov_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_unit_filter'
        iv_value = lv_reservation_unit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_unit_filter'
        iv_value = lv_old_runit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_unit_filter'
        iv_value = lv_new_runit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'reserved_only'
        iv_value = p_rsv ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'unreserved_only'
        iv_value = p_unrsv ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_reserved_only'
        iv_value = lv_old_reserved_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_reserved_only'
        iv_value = lv_new_reserved_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_unreserved_only'
        iv_value = lv_old_unreserved_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_unreserved_only'
        iv_value = lv_new_unreserved_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'shortage_only'
        iv_value = p_bklg ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_shortage_only'
        iv_value = lv_old_shortage_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_shortage_only'
        iv_value = lv_new_shortage_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage_filter'
        iv_value   = p_shf
        iv_text    = lv_shortage_from_filter
        iv_present = xsdbool( p_shf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_shortage_filter'
        iv_value   = p_sht
        iv_text    = lv_shortage_to_filter
        iv_present = xsdbool( p_sht IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_shortage_filter'
        iv_value   = lv_old_shortage_from
        iv_text    = lv_old_shortage_from_filter
        iv_present = xsdbool( p_oshf IS NOT INITIAL OR p_shf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_shortage_filter'
        iv_value   = lv_old_shortage_to
        iv_text    = lv_old_shortage_to_filter
        iv_present = xsdbool( p_osht IS NOT INITIAL OR p_sht IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_shortage_filter'
        iv_value   = lv_new_shortage_from
        iv_text    = lv_new_shortage_from_filter
        iv_present = xsdbool( p_nshf IS NOT INITIAL OR p_shf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_shortage_filter'
        iv_value   = lv_new_shortage_to
        iv_text    = lv_new_shortage_to_filter
        iv_present = xsdbool( p_nsht IS NOT INITIAL OR p_sht IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_coverage_filter'
        iv_value   = p_covf
        iv_text    = lv_coverage_from_filter
        iv_present = xsdbool( p_covf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_coverage_filter'
        iv_value   = p_covt
        iv_text    = lv_coverage_to_filter
        iv_present = xsdbool( p_covt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_coverage_filter'
        iv_value   = lv_old_coverage_from
        iv_text    = lv_old_coverage_from_filter
        iv_present = xsdbool( p_ocovf IS NOT INITIAL OR p_covf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_coverage_filter'
        iv_value   = lv_old_coverage_to
        iv_text    = lv_old_coverage_to_filter
        iv_present = xsdbool( p_ocovt IS NOT INITIAL OR p_covt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_coverage_filter'
        iv_value   = lv_new_coverage_from
        iv_text    = lv_new_coverage_from_filter
        iv_present = xsdbool( p_ncovf IS NOT INITIAL OR p_covf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_coverage_filter'
        iv_value   = lv_new_coverage_to
        iv_text    = lv_new_coverage_to_filter
        iv_present = xsdbool( p_ncovt IS NOT INITIAL OR p_covt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage_pct_filter'
        iv_value   = p_spf
        iv_text    = lv_shortage_pct_from_filter
        iv_present = xsdbool( p_spf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_shortage_pct_filter'
        iv_value   = p_spt
        iv_text    = lv_shortage_pct_to_filter
        iv_present = xsdbool( p_spt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_shortage_pct_filter'
        iv_value   = lv_old_shortage_pct_from
        iv_text    = lv_old_sp_from_txt
        iv_present = xsdbool( p_ospf IS NOT INITIAL OR p_spf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_shortage_pct_filter'
        iv_value   = lv_old_shortage_pct_to
        iv_text    = lv_old_sp_to_txt
        iv_present = xsdbool( p_ospt IS NOT INITIAL OR p_spt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_shortage_pct_filter'
        iv_value   = lv_new_shortage_pct_from
        iv_text    = lv_new_sp_from_txt
        iv_present = xsdbool( p_nspf IS NOT INITIAL OR p_spf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_shortage_pct_filter'
        iv_value   = lv_new_shortage_pct_to
        iv_text    = lv_new_sp_to_txt
        iv_present = xsdbool( p_nspt IS NOT INITIAL OR p_spt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_requested_quantity_filter'
        iv_value   = p_qf
        iv_text    = lv_req_qty_from_txt
        iv_present = xsdbool( p_qf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_requested_quantity_filter'
        iv_value   = p_qt
        iv_text    = lv_req_qty_to_txt
        iv_present = xsdbool( p_qt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_requested_quantity_filter'
        iv_value   = lv_old_req_qty_from
        iv_text    = lv_old_req_qty_from_txt
        iv_present = xsdbool( p_oqf IS NOT INITIAL OR p_qf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_requested_quantity_filter'
        iv_value   = lv_old_req_qty_to
        iv_text    = lv_old_req_qty_to_txt
        iv_present = xsdbool( p_oqt IS NOT INITIAL OR p_qt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_requested_quantity_filter'
        iv_value   = lv_new_req_qty_from
        iv_text    = lv_new_req_qty_from_txt
        iv_present = xsdbool( p_nqf IS NOT INITIAL OR p_qf IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_requested_quantity_filter'
        iv_value   = lv_new_req_qty_to
        iv_text    = lv_new_req_qty_to_txt
        iv_present = xsdbool( p_nqt IS NOT INITIAL OR p_qt IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_allocated_quantity_filter'
        iv_value   = p_af
        iv_text    = lv_allocated_from_filter
        iv_present = xsdbool( p_af IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_allocated_quantity_filter'
        iv_value   = p_at
        iv_text    = lv_allocated_to_filter
        iv_present = xsdbool( p_at IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_allocated_quantity_filter'
        iv_value   = lv_old_allocated_from
        iv_text    = lv_old_allocated_from_txt
        iv_present = xsdbool( p_oaf IS NOT INITIAL OR p_af IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_allocated_quantity_filter'
        iv_value   = lv_old_allocated_to
        iv_text    = lv_old_allocated_to_txt
        iv_present = xsdbool( p_oat IS NOT INITIAL OR p_at IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_allocated_quantity_filter'
        iv_value   = lv_new_allocated_from
        iv_text    = lv_new_allocated_from_txt
        iv_present = xsdbool( p_naf IS NOT INITIAL OR p_af IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_allocated_quantity_filter'
        iv_value   = lv_new_allocated_to
        iv_text    = lv_new_allocated_to_txt
        iv_present = xsdbool( p_nat IS NOT INITIAL OR p_at IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_priority_filter'
        iv_value   = p_priof
        iv_text    = lv_priority_from_txt
        iv_present = xsdbool( p_priof IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_priority_filter'
        iv_value   = p_priot
        iv_text    = lv_priority_to_txt
        iv_present = xsdbool( p_priot IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_priority_filter'
        iv_value   = lv_old_priority_from
        iv_text    = lv_old_priority_from_txt
        iv_present = xsdbool( p_opf IS NOT INITIAL OR p_priof IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_priority_filter'
        iv_value   = lv_old_priority_to
        iv_text    = lv_old_priority_to_txt
        iv_present = xsdbool( p_opt IS NOT INITIAL OR p_priot IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_priority_filter'
        iv_value   = lv_new_priority_from
        iv_text    = lv_new_priority_from_txt
        iv_present = xsdbool( p_npf IS NOT INITIAL OR p_priof IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_priority_filter'
        iv_value   = lv_new_priority_to
        iv_text    = lv_new_priority_to_txt
        iv_present = xsdbool( p_npt IS NOT INITIAL OR p_priot IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'snapshot_requested_date_from_filter'
        iv_value = lv_snapshot_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'snapshot_requested_date_to_filter'
        iv_value = lv_snapshot_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_snapshot_requested_date_from_filter'
        iv_value = lv_old_snapshot_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_snapshot_requested_date_to_filter'
        iv_value = lv_old_snapshot_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_snapshot_requested_date_from_filter'
        iv_value = lv_new_snapshot_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_snapshot_requested_date_to_filter'
        iv_value = lv_new_snapshot_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sales_document_filter'
        iv_value = lv_sales_document_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_document_filter'
        iv_value = lv_old_sales_document_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_document_filter'
        iv_value = lv_new_sales_document_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sales_document_type_filter'
        iv_value = lv_auart_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_document_type_filter'
        iv_value = lv_old_auart_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_document_type_filter'
        iv_value = lv_new_auart_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sales_item_filter'
        iv_value = lv_posnr_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_item_filter'
        iv_value = lv_old_posnr_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_item_filter'
        iv_value = lv_new_posnr_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'schedule_line_filter'
        iv_value = lv_etenr_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_schedule_line_filter'
        iv_value = lv_old_etenr_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_schedule_line_filter'
        iv_value = lv_new_etenr_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'order_unit_filter'
        iv_value = lv_ordunit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_order_unit_filter'
        iv_value = lv_old_ordunit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_order_unit_filter'
        iv_value = lv_new_ordunit_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'order_id_filter'
        iv_value = lv_order_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_order_id_filter'
        iv_value = lv_old_order_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_order_id_filter'
        iv_value = lv_new_order_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_id_filter'
        iv_value = lv_resid_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_id_filter'
        iv_value = lv_old_resid_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_id_filter'
        iv_value = lv_new_resid_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_date_from_filter'
        iv_value = lv_rdate_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reservation_date_to_filter'
        iv_value = lv_rdate_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_date_from_filter'
        iv_value = lv_old_rdate_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_date_to_filter'
        iv_value = lv_old_rdate_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_date_from_filter'
        iv_value = lv_new_rdate_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_date_to_filter'
        iv_value = lv_new_rdate_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'reservation_age_filter'
        iv_value   = p_rage
        iv_text    = lv_rage_filter
        iv_present = xsdbool( p_rage IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_reservation_age_filter'
        iv_value   = p_rageto
        iv_text    = lv_rageto_filter
        iv_present = xsdbool( p_rageto IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_reservation_age_filter'
        iv_value   = lv_old_rage
        iv_text    = lv_old_rage_filter
        iv_present = xsdbool( p_orage IS NOT INITIAL OR p_rage IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_reservation_age_filter'
        iv_value   = lv_old_rageto
        iv_text    = lv_old_rageto_filter
        iv_present = xsdbool( p_oragto IS NOT INITIAL OR p_rageto IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_reservation_age_filter'
        iv_value   = lv_new_rage
        iv_text    = lv_new_rage_filter
        iv_present = xsdbool( p_nrage IS NOT INITIAL OR p_rage IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_reservation_age_filter'
        iv_value   = lv_new_rageto
        iv_text    = lv_new_rageto_filter
        iv_present = xsdbool( p_nragto IS NOT INITIAL OR p_rageto IS NOT INITIAL )
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'filters_applied'
        iv_value = lv_filters_applied ) TO lt_json_fields.
      APPEND zcl_stock_json=>string_array_property(
        iv_name   = 'filters'
        it_values = lt_filter_names ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'sort_mode'
        iv_value = lv_sort_mode ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'movement_type_filter'
        iv_value = lv_movement_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_movement_type_filter'
        iv_value = lv_old_movement_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_movement_type_filter'
        iv_value = lv_new_movement_filter ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'old_minimum_shelf_life_filter'
          iv_value   = lv_old_shelf_life
          iv_text    = lv_old_shelf_filter
          iv_present = xsdbool( p_oshelf IS NOT INITIAL OR p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) TO lt_json_fields.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'new_minimum_shelf_life_filter'
          iv_value   = lv_new_shelf_life
          iv_text    = lv_new_shelf_filter
          iv_present = xsdbool( p_nshelf IS NOT INITIAL OR p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_minimum_shelf_life_filter'
          iv_value = lv_old_shelf_filter ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_minimum_shelf_life_filter'
          iv_value = lv_new_shelf_filter ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shelf_life_filter'
          iv_value   = p_shelf
          iv_text    = lv_min_shelf_filter
          iv_present = xsdbool( p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'minimum_shelf_life_filter'
          iv_value = lv_min_shelf_filter ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'overdue_only'
        iv_value = p_ovrd ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_overdue_only'
        iv_value = lv_old_overdue_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_overdue_only'
        iv_value = lv_new_overdue_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_overdue_as_of_filter'
        iv_value = lv_overdue_as_of_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_from_filter'
        iv_value = lv_requested_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_on_to_filter'
        iv_value = lv_requested_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on_from_filter'
        iv_value = lv_old_requested_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on_to_filter'
        iv_value = lv_old_requested_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on_from_filter'
        iv_value = lv_new_requested_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on_to_filter'
        iv_value = lv_new_requested_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'requested_deadline_only'
        iv_value = p_dead ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_requested_deadline_only'
        iv_value = lv_old_deadline_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_requested_deadline_only'
        iv_value = lv_new_deadline_only ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_deadline_from_filter'
        iv_value = lv_deadline_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'requested_deadline_to_filter'
        iv_value = lv_deadline_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_deadline_from_filter'
        iv_value = lv_old_deadline_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_deadline_to_filter'
        iv_value = lv_old_deadline_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_deadline_from_filter'
        iv_value = lv_new_deadline_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_deadline_to_filter'
        iv_value = lv_new_deadline_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_from_filter'
        iv_value = lv_deadline_age_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_to_filter'
        iv_value = lv_deadline_age_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_deadline_age_from_filter'
        iv_value = lv_old_age_from_txt ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_deadline_age_to_filter'
        iv_value = lv_old_age_to_txt ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_deadline_age_from_filter'
        iv_value = lv_new_age_from_txt ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_deadline_age_to_filter'
        iv_value = lv_new_age_to_txt ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'deadline_age_date_filter'
        iv_value = lv_deadline_age_date_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_duration_from_filter'
        iv_value = lv_duration_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_duration_to_filter'
        iv_value = lv_duration_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_audit_duration_from_filter'
        iv_value = lv_old_duration_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_audit_duration_to_filter'
        iv_value = lv_old_duration_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_audit_duration_from_filter'
        iv_value = lv_new_duration_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_audit_duration_to_filter'
        iv_value = lv_new_duration_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'available_stock_from_filter'
        iv_value = lv_available_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'available_stock_to_filter'
        iv_value = lv_available_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_available_stock_from_filter'
        iv_value = lv_old_available_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_available_stock_to_filter'
        iv_value = lv_old_available_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_available_stock_from_filter'
        iv_value = lv_new_available_from_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_available_stock_to_filter'
        iv_value = lv_new_available_to_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'change_type'
        iv_value = p_chg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'reason_filter'
        iv_value = p_reason ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_status_filter'
        iv_value = p_ost ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_status_filter'
        iv_value = p_nst ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_audit_status_filter'
        iv_value = lv_old_audit_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_audit_status_filter'
        iv_value = lv_new_audit_status_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_strategy_filter'
        iv_value = lv_old_strategy_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_strategy_filter'
        iv_value = lv_new_strategy_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_legacy_strategy_filter'
        iv_value = p_oleg ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_legacy_strategy_filter'
        iv_value = p_nleg ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_message_filter'
        iv_value = lv_old_message_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_message_filter'
        iv_value = lv_new_message_filter ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'old_message_only'
        iv_value = p_omonly ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'new_message_only'
        iv_value = p_nmonly ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'include_unchanged'
        iv_value = p_all ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'reconciliation_guard'
        iv_value = p_guard ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_run_status'
        iv_value = ls_old_run-status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_run_status'
        iv_value = ls_new_run-status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_run_strategy'
        iv_value = ls_old_run-strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_run_strategy'
        iv_value = ls_new_run-strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_movement_type'
        iv_value = ls_old_run-movement_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_movement_type'
        iv_value = ls_new_run-movement_type ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_min_shelf_life'
          iv_value = ls_old_run-min_shelf_life ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_min_shelf_life'
          iv_value = ls_new_run-min_shelf_life ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_safety_stock'
          iv_value = ls_old_run-safety_stock ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_safety_stock'
          iv_value = ls_new_run-safety_stock ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_min_shelf_life'
          iv_value = ls_old_run-min_shelf_life ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_min_shelf_life'
          iv_value = ls_new_run-min_shelf_life ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_safety_stock'
          iv_value = ls_old_run-safety_stock ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_safety_stock'
          iv_value = ls_new_run-safety_stock ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_start_date'
        iv_value = ls_old_run-start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_start_date'
        iv_value = ls_new_run-start_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_start_time'
        iv_value = ls_old_run-start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_start_time'
        iv_value = ls_new_run-start_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_finish_date'
        iv_value = ls_old_run-finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_finish_date'
        iv_value = ls_new_run-finish_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_finish_time'
        iv_value = ls_old_run-finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_finish_time'
        iv_value = ls_new_run-finish_time ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on_from'
        iv_value = ls_old_run-requested_on_from ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on_from'
        iv_value = ls_new_run-requested_on_from ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on_to'
        iv_value = ls_old_run-requested_on_to ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on_to'
        iv_value = ls_new_run-requested_on_to ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_deadline'
        iv_value = ls_old_run-requested_deadline ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_deadline'
        iv_value = ls_new_run-requested_deadline ) TO lt_json_fields.
      IF p_typed = abap_true AND ls_old_run-requested_deadline IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_deadline_age_days'
          iv_value = lv_old_deadline_age_days ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_deadline_age_days' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_deadline_age_days'
          iv_value = lv_old_deadline_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND ls_new_run-requested_deadline IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_deadline_age_days'
          iv_value = lv_new_deadline_age_days ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_deadline_age_days' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_deadline_age_days'
          iv_value = lv_new_deadline_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_deadline_age_delta_text <> 'n/a'.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'deadline_age_delta_days'
          iv_value = lv_deadline_age_delta_days ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'deadline_age_delta_days' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'deadline_age_delta_days'
          iv_value = lv_deadline_age_delta_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_available'
        iv_value = ls_old_run-available ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_available'
        iv_value = ls_new_run-available ) TO lt_json_fields.
      IF p_typed = abap_true AND ls_old_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_duration_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND ls_new_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_duration_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_running_age_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND lv_new_running_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_seconds ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_running_age_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true
          AND lv_new_running_age_available = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_audit_running_age_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_running_age_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_aud_run_age_delta_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_running_age_trend'
        iv_value = lv_aud_run_age_trend ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_message'
        iv_value = ls_old_run-message ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_message'
        iv_value = ls_new_run-message ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reconciliation_fields'
        iv_value = ls_old_reconciliation-mismatch_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reconciliation_fields'
        iv_value = ls_new_reconciliation-mismatch_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reconciliation'
        iv_value = lv_old_reconciliation ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reconciliation'
        iv_value = lv_new_reconciliation ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_changed'
        iv_value = lv_recon_status_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_ok'
        iv_value = lv_recon_both_ok ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_reconciliation_transition'
        iv_value = lv_recon_transition ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_metadata_changed'
        iv_value = lv_audit_meta_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'audit_metadata_change_reasons'
        iv_value = lv_audit_meta_reasons ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_audit_unit'
        iv_value = ls_old_run-unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_audit_unit'
        iv_value = ls_new_run-unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_demand_count'
        iv_value = ls_old_run-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_demand_count'
        iv_value = ls_new_run-demand_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_full_rows'
        iv_value = ls_old_run-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_full_rows'
        iv_value = ls_new_run-full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_partial_rows'
        iv_value = ls_old_run-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_partial_rows'
        iv_value = ls_new_run-partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_unallocated_rows'
        iv_value = ls_old_run-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_unallocated_rows'
        iv_value = ls_new_run-unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_demand_count_delta'
        iv_value = lv_audit_demand_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_full_rows_delta'
        iv_value = lv_audit_full_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_partial_rows_delta'
        iv_value = lv_audit_partial_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'audit_unallocated_rows_delta'
        iv_value = lv_audit_unallocated_delta ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_requested'
        iv_value = ls_old_run-requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_requested'
        iv_value = ls_new_run-requested ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_allocated'
        iv_value = ls_old_run-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_allocated'
        iv_value = ls_new_run-allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_audit_shortage'
        iv_value = ls_old_run-shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_audit_shortage'
        iv_value = ls_new_run-shortage ) TO lt_json_fields.
      IF p_typed = abap_true AND ls_old_run-requested > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_audit_coverage_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'old_audit_shortage_pct' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND ls_new_run-requested > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_audit_coverage_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'new_audit_shortage_pct' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_units_match'
        iv_value = lv_audit_units_match ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_horizon_changed'
        iv_value = lv_audit_horizon_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_status_changed'
        iv_value = lv_audit_status_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_strategy_changed'
        iv_value = lv_audit_strategy_changed ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'audit_running_changed'
        iv_value = lv_audit_running_changed ) TO lt_json_fields.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_aud_dur_delta_secs ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_duration_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_audit_duration_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND ls_old_run-start_date IS NOT INITIAL
          AND ls_new_run-start_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_aud_start_delta_secs ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_start_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_audit_start_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_aud_finish_delta_secs ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_finish_delta_seconds' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_audit_finish_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_requested_delta' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_available_delta' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_allocated_delta' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_delta' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta_text ) TO lt_json_fields.
      ENDIF.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true
          AND ls_old_run-requested > 0 AND ls_new_run-requested > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_audit_shortage_pct_delta ) TO lt_json_fields.
      ELSEIF p_typed = abap_true.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_coverage_delta_pct' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_pct_delta' ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta_text ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_aud_shrt_pct_delta_text ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_rows'
        iv_value = lines( lt_old ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_rows'
        iv_value = lines( lt_new ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_requested'
        iv_value = lv_old_requested_total ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_requested'
        iv_value = lv_new_requested_total ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_full_rows'
        iv_value = ls_old_reconciliation-snapshot_full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_full_rows'
        iv_value = ls_new_reconciliation-snapshot_full_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_partial_rows'
        iv_value = ls_old_reconciliation-snapshot_partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_partial_rows'
        iv_value = ls_new_reconciliation-snapshot_partial_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_unallocated_rows'
        iv_value = ls_old_reconciliation-snapshot_unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_unallocated_rows'
        iv_value = ls_new_reconciliation-snapshot_unallocated_count ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_allocated'
        iv_value = ls_old_reconciliation-snapshot_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_allocated'
        iv_value = ls_new_reconciliation-snapshot_allocated ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_shortage'
        iv_value = ls_old_reconciliation-snapshot_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_shortage'
        iv_value = ls_new_reconciliation-snapshot_shortage ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'returned_rows'
        iv_value = lines( lt_changes ) ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'offset'
        iv_value = p_skip ) TO lt_json_fields.
      APPEND zcl_stock_json=>number_property(
        iv_name  = 'max_rows'
        iv_value = p_max ) TO lt_json_fields.
      APPEND zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_filter_value_fields ) TO lt_json_fields.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'has_more'
        iv_value = lv_has_more ) TO lt_json_fields.
      IF lv_has_more = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'next_offset'
          iv_value = lv_next_offset ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'next_offset' ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>boolean_property(
        iv_name  = 'has_previous'
        iv_value = lv_has_previous ) TO lt_json_fields.
      IF lv_has_previous = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'previous_offset'
          iv_value = lv_previous_offset ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'previous_offset' ) TO lt_json_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'page_number'
          iv_value = lv_page_number ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'page_number' ) TO lt_json_fields.
      ENDIF.
      IF p_max > 0.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'page_count'
          iv_value = lv_page_count ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'last_offset'
          iv_value = lv_last_offset ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'page_count' ) TO lt_json_fields.
        APPEND zcl_stock_json=>null_property(
          iv_name = 'last_offset' ) TO lt_json_fields.
      ENDIF.
      CONCATENATE LINES OF lt_summary_json_fields INTO lv_summary_json_fields
        SEPARATED BY ','.
      IF p_meta = abap_true.
        CONCATENATE '"summary":{' lv_summary_json_fields '}'
          INTO lv_json_line.
        APPEND lv_json_line TO lt_json_fields.
      ELSE.
        APPEND LINES OF lt_summary_json_fields TO lt_json_fields.
      ENDIF.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_fields
        SEPARATED BY ','.
      WRITE: / '{' NO-GAP.
      WRITE: / lv_json_fields NO-GAP.
      WRITE: / '}' NO-GAP.
      RETURN.
    ENDIF.
  ENDIF.

  IF p_csv = abap_true.
    WRITE: / 'schema_version;generated_date;generated_time;change_type;change_reasons;allocation_unit;order_id;'
      && 'old_allocation_strategy;new_allocation_strategy;old_sales_document;new_sales_document;'
      && 'old_sales_document_type;new_sales_document_type;old_sales_item;new_sales_item;old_schedule_line;'
      && 'new_schedule_line;old_order_unit;new_order_unit;old_requested_on;new_requested_on;old_priority;'
      && 'new_priority;old_status;new_status;old_requested;new_requested;delta_requested;old_allocated;'
      && 'new_allocated;delta_allocated;old_shortage;new_shortage;delta_shortage;'
      && 'old_snapshot_coverage_pct;new_snapshot_coverage_pct;'
      && 'old_snapshot_shortage_pct;new_snapshot_shortage_pct;'
      && 'snapshot_coverage_delta_pct;snapshot_shortage_pct_delta;old_reservation_id;'
      && 'new_reservation_id;old_reservation_date;new_reservation_date;old_reservation_movement_type;'
      && 'new_reservation_movement_type;old_reservation_unit;new_reservation_unit;old_run_status;new_run_status;'
      && 'old_run_strategy;new_run_strategy;old_movement_type;new_movement_type;old_min_shelf_life;'
      && 'new_min_shelf_life;old_safety_stock;new_safety_stock;old_start_date;'
      && 'new_start_date;old_start_time;new_start_time;'
      && 'old_finish_date;new_finish_date;old_requested_on_from;new_requested_on_from;old_requested_on_to;'
      && 'new_requested_on_to;old_requested_deadline;new_requested_deadline;'
      && 'old_deadline_age_days;new_deadline_age_days;deadline_age_delta_days;'
      && 'deadline_age_reference_date;'
      && 'old_available;new_available;'
      && 'old_running_age_seconds;new_running_age_seconds;audit_running_age_delta_seconds;audit_running_age_trend;'
      && 'old_message;new_message;old_reconciliation;new_reconciliation;audit_reconciliation_changed;'
      && 'audit_reconciliation_ok;audit_reconciliation_transition;audit_metadata_changed;'
      && 'audit_metadata_change_reasons;old_reconciliation_fields;new_reconciliation_fields;old_audit_unit;'
      && 'new_audit_unit;audit_units_match;audit_horizon_changed;audit_status_changed;audit_strategy_changed;'
      && 'audit_running_changed;audit_duration_delta_seconds;audit_start_delta_seconds;audit_finish_delta_seconds;'
      && 'old_audit_demand_count;new_audit_demand_count;old_audit_full_rows;new_audit_full_rows;'
      && 'old_audit_partial_rows;new_audit_partial_rows;old_audit_unallocated_rows;new_audit_unallocated_rows;'
      && 'audit_demand_count_delta;audit_full_rows_delta;audit_partial_rows_delta;audit_unallocated_rows_delta;'
      && 'old_audit_requested;new_audit_requested;old_audit_allocated;new_audit_allocated;old_audit_shortage;'
      && 'new_audit_shortage;old_audit_coverage_pct;new_audit_coverage_pct;old_audit_shortage_pct;'
      && 'new_audit_shortage_pct;audit_requested_delta;audit_available_delta;audit_allocated_delta;'
      && 'audit_shortage_delta;audit_coverage_delta_pct;audit_shortage_pct_delta;old_snapshot_rows;'
      && 'new_snapshot_rows;old_snapshot_requested;new_snapshot_requested;old_snapshot_full_rows;'
      && 'new_snapshot_full_rows;old_snapshot_partial_rows;new_snapshot_partial_rows;old_snapshot_unallocated_rows;'
      && 'new_snapshot_unallocated_rows;old_snapshot_allocated;new_snapshot_allocated;old_snapshot_shortage;'
      && 'new_snapshot_shortage;reconciliation_guard;reason_filter;'
      && 'old_status_filter;new_status_filter;'
      && 'old_audit_status_filter;new_audit_status_filter;old_strategy_filter;'
      && 'new_strategy_filter;old_legacy_strategy_filter;new_legacy_strategy_filter;'
      && 'old_message_filter;'
      && 'new_message_filter;old_message_only;new_message_only;'
      && 'material;old_material_filter;new_material_filter;plant;'
      && 'old_plant_filter;new_plant_filter;'
      && 'storage_location;old_storage_location_filter;'
      && 'new_storage_location_filter;batch;old_batch_filter;new_batch_filter;'
      && 'unit;old_unit_filter;new_unit_filter;'
      && 'reservation_movement_type_filter;old_reservation_movement_type_filter;'
      && 'new_reservation_movement_type_filter;'
      && 'reservation_unit_filter;old_reservation_unit_filter;'
      && 'new_reservation_unit_filter;'
      && 'reserved_only;unreserved_only;old_reserved_only;new_reserved_only;'
      && 'old_unreserved_only;new_unreserved_only;'
      && 'shortage_only;old_shortage_only;new_shortage_only;'
      && 'minimum_shortage_filter;maximum_shortage_filter;'
      && 'old_minimum_shortage_filter;old_maximum_shortage_filter;'
      && 'new_minimum_shortage_filter;new_maximum_shortage_filter;'
      && 'minimum_coverage_filter;maximum_coverage_filter;'
      && 'old_minimum_coverage_filter;old_maximum_coverage_filter;'
      && 'new_minimum_coverage_filter;new_maximum_coverage_filter;'
      && 'minimum_shortage_pct_filter;maximum_shortage_pct_filter;'
      && 'old_minimum_shortage_pct_filter;old_maximum_shortage_pct_filter;'
      && 'new_minimum_shortage_pct_filter;new_maximum_shortage_pct_filter;'
      && 'minimum_requested_quantity_filter;maximum_requested_quantity_filter;'
      && 'old_minimum_requested_quantity_filter;old_maximum_requested_quantity_filter;'
      && 'new_minimum_requested_quantity_filter;new_maximum_requested_quantity_filter;'
      && 'minimum_allocated_quantity_filter;maximum_allocated_quantity_filter;'
      && 'old_minimum_allocated_quantity_filter;old_maximum_allocated_quantity_filter;'
      && 'new_minimum_allocated_quantity_filter;new_maximum_allocated_quantity_filter;'
      && 'minimum_priority_filter;maximum_priority_filter;'
      && 'old_minimum_priority_filter;old_maximum_priority_filter;'
      && 'new_minimum_priority_filter;new_maximum_priority_filter;'
       && 'snapshot_requested_date_from_filter;snapshot_requested_date_to_filter;'
       && 'old_snapshot_requested_date_from_filter;old_snapshot_requested_date_to_filter;'
       && 'new_snapshot_requested_date_from_filter;new_snapshot_requested_date_to_filter;'
       && 'sales_document_filter;old_sales_document_filter;new_sales_document_filter;'
       && 'sales_document_type_filter;old_sales_document_type_filter;'
       && 'new_sales_document_type_filter;'
       && 'sales_item_filter;old_sales_item_filter;new_sales_item_filter;'
       && 'schedule_line_filter;old_schedule_line_filter;new_schedule_line_filter;'
       && 'order_unit_filter;old_order_unit_filter;new_order_unit_filter;'
       && 'order_id_filter;old_order_id_filter;new_order_id_filter;'
       && 'reservation_id_filter;old_reservation_id_filter;new_reservation_id_filter;'
      && 'reservation_date_from_filter;reservation_date_to_filter;'
      && 'old_reservation_date_from_filter;old_reservation_date_to_filter;'
      && 'new_reservation_date_from_filter;new_reservation_date_to_filter;'
      && 'reservation_age_filter;maximum_reservation_age_filter;'
      && 'old_reservation_age_filter;old_maximum_reservation_age_filter;'
      && 'new_reservation_age_filter;new_maximum_reservation_age_filter;'
      && 'filters_applied;filters;sort_mode;'
      && 'movement_type_filter;old_movement_type_filter;new_movement_type_filter;'
      && 'minimum_shelf_life_filter;old_minimum_shelf_life_filter;'
      && 'new_minimum_shelf_life_filter;overdue_only;'
      && 'old_overdue_only;new_overdue_only;requested_overdue_as_of_filter;'
      && 'requested_on_from_filter;'
      && 'requested_on_to_filter;old_requested_on_from_filter;old_requested_on_to_filter;'
      && 'new_requested_on_from_filter;new_requested_on_to_filter;'
      && 'requested_deadline_only;old_requested_deadline_only;new_requested_deadline_only;'
      && 'requested_deadline_from_filter;requested_deadline_to_filter;'
      && 'old_requested_deadline_from_filter;old_requested_deadline_to_filter;'
      && 'new_requested_deadline_from_filter;new_requested_deadline_to_filter;'
      && 'deadline_age_from_filter;deadline_age_to_filter;'
      && 'old_deadline_age_from_filter;old_deadline_age_to_filter;'
      && 'new_deadline_age_from_filter;new_deadline_age_to_filter;'
      && 'deadline_age_date_filter;'
      && 'audit_duration_from_filter;audit_duration_to_filter;'
      && 'old_audit_duration_from_filter;old_audit_duration_to_filter;'
      && 'new_audit_duration_from_filter;new_audit_duration_to_filter;'
      && 'available_stock_from_filter;available_stock_to_filter;'
      && 'old_available_stock_from_filter;old_available_stock_to_filter;'
      && 'new_available_stock_from_filter;new_available_stock_to_filter;'
      && 'total_rows;offset;max_rows;filter_values;has_more;next_offset;'
      && 'has_previous;previous_offset;page_number;page_count;last_offset'.
    LOOP AT lt_changes ASSIGNING <ls_change>.
      CLEAR lt_csv_fields.
      APPEND zcl_stock_csv=>number( 95 ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-datum ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( sy-uzeit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-change_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-change_reasons ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-allocation_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-order_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_allocation_strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_allocation_strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_sales_document ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_sales_document ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_sales_document_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_sales_document_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_sales_item ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_sales_item ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_schedule_line ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_schedule_line ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_order_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_order_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-old_requested_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-new_requested_on ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_priority ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_priority ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-old_status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-new_status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-delta_requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-delta_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-old_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-new_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( <ls_change>-delta_shortage ) TO lt_csv_fields.
      lv_old_snapshot_coverage_text = 'n/a'.
      lv_new_snapshot_coverage_text = 'n/a'.
      lv_old_snap_shrt_pct_text = 'n/a'.
      lv_new_snap_shrt_pct_text = 'n/a'.
      IF <ls_change>-old_coverage_available = abap_true.
        lv_old_snapshot_coverage_text = zcl_stock_csv=>number(
          <ls_change>-old_coverage ).
      ENDIF.
      IF <ls_change>-new_coverage_available = abap_true.
        lv_new_snapshot_coverage_text = zcl_stock_csv=>number(
          <ls_change>-new_coverage ).
      ENDIF.
      IF <ls_change>-old_shortage_pct_available = abap_true.
        lv_old_snap_shrt_pct_text = zcl_stock_csv=>number(
          <ls_change>-old_shortage_pct ).
      ENDIF.
      IF <ls_change>-new_shortage_pct_available = abap_true.
        lv_new_snap_shrt_pct_text = zcl_stock_csv=>number(
          <ls_change>-new_shortage_pct ).
      ENDIF.
      APPEND lv_old_snapshot_coverage_text TO lt_csv_fields.
      APPEND lv_new_snapshot_coverage_text TO lt_csv_fields.
      APPEND lv_old_snap_shrt_pct_text TO lt_csv_fields.
      APPEND lv_new_snap_shrt_pct_text TO lt_csv_fields.
      IF <ls_change>-coverage_delta_available = abap_true.
        lv_snap_cov_delta_text = zcl_stock_csv=>number(
          <ls_change>-coverage_delta ).
      ELSE.
        lv_snap_cov_delta_text = 'n/a'.
      ENDIF.
      IF <ls_change>-shortage_pct_delta_available = abap_true.
        lv_snap_shrt_delta_text = zcl_stock_csv=>number(
          <ls_change>-shortage_pct_delta ).
      ELSE.
        lv_snap_shrt_delta_text = 'n/a'.
      ENDIF.
      APPEND lv_snap_cov_delta_text TO lt_csv_fields.
      APPEND lv_snap_shrt_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-old_reservation_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( <ls_change>-new_reservation_id ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_reservation_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_reservation_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_reservation_movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_reservation_movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-old_reservation_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        <ls_change>-new_reservation_unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-status ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-strategy ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-movement_type ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-min_shelf_life ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-min_shelf_life ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-safety_stock ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-safety_stock ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-start_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_date ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-finish_time ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_from ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_on_to ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-requested_deadline ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-requested_deadline ) TO lt_csv_fields.
      APPEND lv_old_deadline_age_text TO lt_csv_fields.
      APPEND lv_new_deadline_age_text TO lt_csv_fields.
      APPEND lv_deadline_age_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_reference_date )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-available ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-available ) TO lt_csv_fields.
      APPEND lv_old_duration_text TO lt_csv_fields.
      APPEND lv_new_duration_text TO lt_csv_fields.
      APPEND lv_old_running_age_text TO lt_csv_fields.
      APPEND lv_new_running_age_text TO lt_csv_fields.
      APPEND lv_aud_run_age_delta_text TO lt_csv_fields.
      APPEND lv_aud_run_age_trend TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-message ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_reconciliation ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_both_ok ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_recon_transition ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_meta_reasons ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_old_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote(
        ls_new_reconciliation-mismatch_fields ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_old_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( ls_new_run-unit ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_units_match ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_horizon_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_status_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_strategy_changed ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_audit_running_changed ) TO lt_csv_fields.
      APPEND lv_audit_duration_delta_text TO lt_csv_fields.
      APPEND lv_audit_start_delta_text TO lt_csv_fields.
      APPEND lv_audit_finish_delta_text TO lt_csv_fields.
      APPEND lv_audit_requested_delta_text TO lt_csv_fields.
      APPEND lv_audit_available_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-demand_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_demand_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_full_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_partial_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_audit_unallocated_delta ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-requested ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_old_run-shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( ls_new_run-shortage ) TO lt_csv_fields.
      APPEND lv_old_audit_coverage_text TO lt_csv_fields.
      APPEND lv_new_audit_coverage_text TO lt_csv_fields.
      APPEND lv_old_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_new_audit_shortage_pct_text TO lt_csv_fields.
      APPEND lv_audit_allocated_delta_text TO lt_csv_fields.
      APPEND lv_audit_shortage_delta_text TO lt_csv_fields.
      APPEND lv_audit_coverage_delta_text TO lt_csv_fields.
      APPEND lv_aud_shrt_pct_delta_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_old ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lines( lt_new ) ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_old_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_new_requested_total ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_full_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_partial_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_unallocated_count ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_allocated ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_old_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number(
        ls_new_reconciliation-snapshot_shortage ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_guard ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_reason ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ost ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_nst ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_audit_status_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_audit_status_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_legacy_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_legacy_strategy_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_message_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_message_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_message_only_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_message_only_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_matnr ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_material_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_material_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_werks ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_plant_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_plant_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_lgort ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_storage_location_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_storage_location_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_charg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_batch_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_batch_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_meins ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_unit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_unit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_reservation_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rmov_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rmov_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_reservation_unit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_runit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_runit_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_rsv ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_unrsv ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_reserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_reserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_unreserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_unreserved_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_bklg ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shortage_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shortage_only ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shortage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shortage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shortage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shortage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_coverage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_coverage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_coverage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_coverage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_coverage_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_coverage_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_pct_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_shortage_pct_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_sp_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_sp_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_sp_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_sp_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_req_qty_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_req_qty_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_req_qty_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_req_qty_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_req_qty_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_req_qty_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_allocated_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_allocated_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_allocated_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_allocated_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_allocated_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_allocated_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_priority_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_priority_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_priority_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_priority_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_priority_from_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_priority_to_txt ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_snapshot_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_snapshot_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_snapshot_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_snapshot_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_snapshot_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_snapshot_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_sales_document_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_sales_document_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_sales_document_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_auart_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_auart_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_auart_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_posnr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_posnr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_posnr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_etenr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_etenr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_etenr_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_ordunit_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_ordunit_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_ordunit_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_order_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_order_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_order_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_resid_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_old_resid_filter ) TO lt_csv_fields.
       APPEND zcl_stock_csv=>quote( lv_new_resid_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rdate_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rdate_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rdate_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rdate_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rdate_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rdate_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_rageto_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_rageto_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rage_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_rageto_filter ) TO lt_csv_fields.
      IF lv_filters_applied = abap_true.
        APPEND 'true' TO lt_csv_fields.
      ELSE.
        APPEND 'false' TO lt_csv_fields.
      ENDIF.
      APPEND zcl_stock_csv=>quote( lv_filter_names_text ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_sort_mode ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_movement_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_min_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_shelf_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_ovrd ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_overdue_only_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_overdue_only_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_overdue_as_of_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_requested_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_requested_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_requested_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_requested_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_requested_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( p_dead ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_deadline_only_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_deadline_only_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_deadline_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_deadline_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_deadline_from_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_deadline_to_filter )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_age_from_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_age_to_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_age_from_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_age_to_txt )
        TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_deadline_age_date_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_duration_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_duration_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_duration_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_duration_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_available_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_available_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_available_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_old_available_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_available_from_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_new_available_to_filter ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( lv_total_rows ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_skip ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>number( p_max ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_filter_values_json ) TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_has_more ) TO lt_csv_fields.
      APPEND lv_next_offset_text TO lt_csv_fields.
      APPEND zcl_stock_csv=>quote( lv_has_previous ) TO lt_csv_fields.
      APPEND lv_previous_offset_text TO lt_csv_fields.
      APPEND lv_page_number_text TO lt_csv_fields.
      APPEND lv_page_count_text TO lt_csv_fields.
      APPEND lv_last_offset_text TO lt_csv_fields.
      CONCATENATE LINES OF lt_csv_fields INTO lv_csv_line SEPARATED BY ';'.
      WRITE: / lv_csv_line.
    ENDLOOP.
    RETURN.
  ENDIF.

  IF p_json = abap_true.
    IF p_ndjson = abap_false AND p_meta = abap_true.
      WRITE: / '{' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'schema_version'
        iv_value = 95 ) NO-GAP.
      IF p_typed = abap_true.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = abap_true ) NO-GAP.
      ENDIF.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'generated_date'
        iv_value = sy-datum ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'generated_time'
        iv_value = sy-uzeit ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'deadline_age_reference_date'
        iv_value = lv_deadline_reference_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'total_rows'
        iv_value = lv_total_rows ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'offset'
        iv_value = p_skip ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'max_rows'
        iv_value = p_max ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>object_property(
        iv_name   = 'filter_values'
        it_fields = lt_filter_value_fields ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'filters_applied'
        iv_value = lv_filters_applied ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>string_array_property(
        iv_name   = 'filters'
        it_values = lt_filter_names ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'sort_mode'
        iv_value = lv_sort_mode ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'movement_type_filter'
        iv_value = lv_movement_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_movement_type_filter'
        iv_value = lv_old_movement_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_movement_type_filter'
        iv_value = lv_new_movement_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true.
        WRITE: / zcl_stock_json=>filter_number_property(
          iv_name    = 'old_minimum_shelf_life_filter'
          iv_value   = lv_old_shelf_life
          iv_text    = lv_old_shelf_filter
          iv_present = xsdbool( p_oshelf IS NOT INITIAL OR p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>filter_number_property(
          iv_name    = 'new_minimum_shelf_life_filter'
          iv_value   = lv_new_shelf_life
          iv_text    = lv_new_shelf_filter
          iv_present = xsdbool( p_nshelf IS NOT INITIAL OR p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_minimum_shelf_life_filter'
          iv_value = lv_old_shelf_filter ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_minimum_shelf_life_filter'
          iv_value = lv_new_shelf_filter ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true.
        WRITE: / zcl_stock_json=>filter_number_property(
          iv_name    = 'minimum_shelf_life_filter'
          iv_value   = p_shelf
          iv_text    = lv_min_shelf_filter
          iv_present = xsdbool( p_shelf IS NOT INITIAL )
          iv_typed   = abap_true ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'minimum_shelf_life_filter'
          iv_value = lv_min_shelf_filter ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'overdue_only'
        iv_value = p_ovrd ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_overdue_only'
        iv_value = lv_old_overdue_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_overdue_only'
        iv_value = lv_new_overdue_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'requested_overdue_as_of_filter'
        iv_value = lv_overdue_as_of_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'requested_on_from_filter'
        iv_value = lv_requested_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'requested_on_to_filter'
        iv_value = lv_requested_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_on_from_filter'
        iv_value = lv_old_requested_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_on_to_filter'
        iv_value = lv_old_requested_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_on_from_filter'
        iv_value = lv_new_requested_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_on_to_filter'
        iv_value = lv_new_requested_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'requested_deadline_only'
        iv_value = p_dead ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_requested_deadline_only'
        iv_value = lv_old_deadline_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_requested_deadline_only'
        iv_value = lv_new_deadline_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'requested_deadline_from_filter'
        iv_value = lv_deadline_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'requested_deadline_to_filter'
        iv_value = lv_deadline_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_deadline_from_filter'
        iv_value = lv_old_deadline_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_deadline_to_filter'
        iv_value = lv_old_deadline_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_deadline_from_filter'
        iv_value = lv_new_deadline_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_deadline_to_filter'
        iv_value = lv_new_deadline_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'deadline_age_from_filter'
        iv_value = lv_deadline_age_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'deadline_age_to_filter'
        iv_value = lv_deadline_age_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_deadline_age_from_filter'
        iv_value = lv_old_age_from_txt ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_deadline_age_to_filter'
        iv_value = lv_old_age_to_txt ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_deadline_age_from_filter'
        iv_value = lv_new_age_from_txt ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_deadline_age_to_filter'
        iv_value = lv_new_age_to_txt ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'deadline_age_date_filter'
        iv_value = lv_deadline_age_date_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_duration_from_filter'
        iv_value = lv_duration_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_duration_to_filter'
        iv_value = lv_duration_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_audit_duration_from_filter'
        iv_value = lv_old_duration_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_audit_duration_to_filter'
        iv_value = lv_old_duration_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_audit_duration_from_filter'
        iv_value = lv_new_duration_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_audit_duration_to_filter'
        iv_value = lv_new_duration_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'available_stock_from_filter'
        iv_value = lv_available_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'available_stock_to_filter'
        iv_value = lv_available_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_available_stock_from_filter'
        iv_value = lv_old_available_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_available_stock_to_filter'
        iv_value = lv_old_available_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_available_stock_from_filter'
        iv_value = lv_new_available_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_available_stock_to_filter'
        iv_value = lv_new_available_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'has_more'
        iv_value = lv_has_more ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF lv_has_more = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'next_offset'
          iv_value = lv_next_offset ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'next_offset' ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'has_previous'
        iv_value = lv_has_previous ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF lv_has_previous = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'previous_offset'
          iv_value = lv_previous_offset ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'previous_offset' ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_max > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'page_number'
          iv_value = lv_page_number ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'page_number' ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_max > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'page_count'
          iv_value = lv_page_count ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'page_count' ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_max > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'last_offset'
          iv_value = lv_last_offset ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'last_offset' ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_run'
        iv_value = p_old ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_run'
        iv_value = p_new ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'material'
        iv_value = p_matnr ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_material_filter'
        iv_value = lv_old_material_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_material_filter'
        iv_value = lv_new_material_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'plant'
        iv_value = p_werks ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_plant_filter'
        iv_value = lv_old_plant_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_plant_filter'
        iv_value = lv_new_plant_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'storage_location'
        iv_value = p_lgort ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_storage_location_filter'
        iv_value = lv_old_storage_location_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_storage_location_filter'
        iv_value = lv_new_storage_location_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'batch'
        iv_value = p_charg ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_batch_filter'
        iv_value = lv_old_batch_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_batch_filter'
        iv_value = lv_new_batch_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'unit'
        iv_value = p_meins ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_unit_filter'
        iv_value = lv_old_unit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_unit_filter'
        iv_value = lv_new_unit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reservation_movement_type_filter'
        iv_value = lv_reservation_movement_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reservation_movement_type_filter'
        iv_value = lv_old_rmov_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reservation_movement_type_filter'
        iv_value = lv_new_rmov_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reservation_unit_filter'
        iv_value = lv_reservation_unit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reservation_unit_filter'
        iv_value = lv_old_runit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reservation_unit_filter'
        iv_value = lv_new_runit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'reserved_only'
        iv_value = p_rsv ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'unreserved_only'
        iv_value = p_unrsv ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_reserved_only'
        iv_value = lv_old_reserved_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_reserved_only'
        iv_value = lv_new_reserved_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_unreserved_only'
        iv_value = lv_old_unreserved_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_unreserved_only'
        iv_value = lv_new_unreserved_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'shortage_only'
        iv_value = p_bklg ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_shortage_only'
        iv_value = lv_old_shortage_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_shortage_only'
        iv_value = lv_new_shortage_only ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage_filter'
        iv_value   = p_shf
        iv_text    = lv_shortage_from_filter
        iv_present = xsdbool( p_shf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_shortage_filter'
        iv_value   = p_sht
        iv_text    = lv_shortage_to_filter
        iv_present = xsdbool( p_sht IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_shortage_filter'
        iv_value   = lv_old_shortage_from
        iv_text    = lv_old_shortage_from_filter
        iv_present = xsdbool( p_oshf IS NOT INITIAL OR p_shf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_shortage_filter'
        iv_value   = lv_old_shortage_to
        iv_text    = lv_old_shortage_to_filter
        iv_present = xsdbool( p_osht IS NOT INITIAL OR p_sht IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_shortage_filter'
        iv_value   = lv_new_shortage_from
        iv_text    = lv_new_shortage_from_filter
        iv_present = xsdbool( p_nshf IS NOT INITIAL OR p_shf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_shortage_filter'
        iv_value   = lv_new_shortage_to
        iv_text    = lv_new_shortage_to_filter
        iv_present = xsdbool( p_nsht IS NOT INITIAL OR p_sht IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_coverage_filter'
        iv_value   = p_covf
        iv_text    = lv_coverage_from_filter
        iv_present = xsdbool( p_covf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_coverage_filter'
        iv_value   = p_covt
        iv_text    = lv_coverage_to_filter
        iv_present = xsdbool( p_covt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_coverage_filter'
        iv_value   = lv_old_coverage_from
        iv_text    = lv_old_coverage_from_filter
        iv_present = xsdbool( p_ocovf IS NOT INITIAL OR p_covf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_coverage_filter'
        iv_value   = lv_old_coverage_to
        iv_text    = lv_old_coverage_to_filter
        iv_present = xsdbool( p_ocovt IS NOT INITIAL OR p_covt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_coverage_filter'
        iv_value   = lv_new_coverage_from
        iv_text    = lv_new_coverage_from_filter
        iv_present = xsdbool( p_ncovf IS NOT INITIAL OR p_covf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_coverage_filter'
        iv_value   = lv_new_coverage_to
        iv_text    = lv_new_coverage_to_filter
        iv_present = xsdbool( p_ncovt IS NOT INITIAL OR p_covt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_shortage_pct_filter'
        iv_value   = p_spf
        iv_text    = lv_shortage_pct_from_filter
        iv_present = xsdbool( p_spf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_shortage_pct_filter'
        iv_value   = p_spt
        iv_text    = lv_shortage_pct_to_filter
        iv_present = xsdbool( p_spt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_shortage_pct_filter'
        iv_value   = lv_old_shortage_pct_from
        iv_text    = lv_old_sp_from_txt
        iv_present = xsdbool( p_ospf IS NOT INITIAL OR p_spf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_shortage_pct_filter'
        iv_value   = lv_old_shortage_pct_to
        iv_text    = lv_old_sp_to_txt
        iv_present = xsdbool( p_ospt IS NOT INITIAL OR p_spt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_shortage_pct_filter'
        iv_value   = lv_new_shortage_pct_from
        iv_text    = lv_new_sp_from_txt
        iv_present = xsdbool( p_nspf IS NOT INITIAL OR p_spf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_shortage_pct_filter'
        iv_value   = lv_new_shortage_pct_to
        iv_text    = lv_new_sp_to_txt
        iv_present = xsdbool( p_nspt IS NOT INITIAL OR p_spt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_requested_quantity_filter'
        iv_value   = p_qf
        iv_text    = lv_req_qty_from_txt
        iv_present = xsdbool( p_qf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_requested_quantity_filter'
        iv_value   = p_qt
        iv_text    = lv_req_qty_to_txt
        iv_present = xsdbool( p_qt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_requested_quantity_filter'
        iv_value   = lv_old_req_qty_from
        iv_text    = lv_old_req_qty_from_txt
        iv_present = xsdbool( p_oqf IS NOT INITIAL OR p_qf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_requested_quantity_filter'
        iv_value   = lv_old_req_qty_to
        iv_text    = lv_old_req_qty_to_txt
        iv_present = xsdbool( p_oqt IS NOT INITIAL OR p_qt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_requested_quantity_filter'
        iv_value   = lv_new_req_qty_from
        iv_text    = lv_new_req_qty_from_txt
        iv_present = xsdbool( p_nqf IS NOT INITIAL OR p_qf IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_requested_quantity_filter'
        iv_value   = lv_new_req_qty_to
        iv_text    = lv_new_req_qty_to_txt
        iv_present = xsdbool( p_nqt IS NOT INITIAL OR p_qt IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_allocated_quantity_filter'
        iv_value   = p_af
        iv_text    = lv_allocated_from_filter
        iv_present = xsdbool( p_af IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_allocated_quantity_filter'
        iv_value   = p_at
        iv_text    = lv_allocated_to_filter
        iv_present = xsdbool( p_at IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_allocated_quantity_filter'
        iv_value   = lv_old_allocated_from
        iv_text    = lv_old_allocated_from_txt
        iv_present = xsdbool( p_oaf IS NOT INITIAL OR p_af IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_allocated_quantity_filter'
        iv_value   = lv_old_allocated_to
        iv_text    = lv_old_allocated_to_txt
        iv_present = xsdbool( p_oat IS NOT INITIAL OR p_at IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_allocated_quantity_filter'
        iv_value   = lv_new_allocated_from
        iv_text    = lv_new_allocated_from_txt
        iv_present = xsdbool( p_naf IS NOT INITIAL OR p_af IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_allocated_quantity_filter'
        iv_value   = lv_new_allocated_to
        iv_text    = lv_new_allocated_to_txt
        iv_present = xsdbool( p_nat IS NOT INITIAL OR p_at IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'minimum_priority_filter'
        iv_value   = p_priof
        iv_text    = lv_priority_from_txt
        iv_present = xsdbool( p_priof IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_priority_filter'
        iv_value   = p_priot
        iv_text    = lv_priority_to_txt
        iv_present = xsdbool( p_priot IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_minimum_priority_filter'
        iv_value   = lv_old_priority_from
        iv_text    = lv_old_priority_from_txt
        iv_present = xsdbool( p_opf IS NOT INITIAL OR p_priof IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_priority_filter'
        iv_value   = lv_old_priority_to
        iv_text    = lv_old_priority_to_txt
        iv_present = xsdbool( p_opt IS NOT INITIAL OR p_priot IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_minimum_priority_filter'
        iv_value   = lv_new_priority_from
        iv_text    = lv_new_priority_from_txt
        iv_present = xsdbool( p_npf IS NOT INITIAL OR p_priof IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_priority_filter'
        iv_value   = lv_new_priority_to
        iv_text    = lv_new_priority_to_txt
        iv_present = xsdbool( p_npt IS NOT INITIAL OR p_priot IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'snapshot_requested_date_from_filter'
        iv_value = lv_snapshot_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'snapshot_requested_date_to_filter'
        iv_value = lv_snapshot_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_snapshot_requested_date_from_filter'
        iv_value = lv_old_snapshot_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_snapshot_requested_date_to_filter'
        iv_value = lv_old_snapshot_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_snapshot_requested_date_from_filter'
        iv_value = lv_new_snapshot_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_snapshot_requested_date_to_filter'
        iv_value = lv_new_snapshot_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'sales_document_filter'
        iv_value = lv_sales_document_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_sales_document_filter'
        iv_value = lv_old_sales_document_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_sales_document_filter'
        iv_value = lv_new_sales_document_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'sales_document_type_filter'
        iv_value = lv_auart_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_sales_document_type_filter'
        iv_value = lv_old_auart_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_sales_document_type_filter'
        iv_value = lv_new_auart_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'sales_item_filter'
        iv_value = lv_posnr_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_sales_item_filter'
        iv_value = lv_old_posnr_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_sales_item_filter'
        iv_value = lv_new_posnr_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'schedule_line_filter'
        iv_value = lv_etenr_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_schedule_line_filter'
        iv_value = lv_old_etenr_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_schedule_line_filter'
        iv_value = lv_new_etenr_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'order_unit_filter'
        iv_value = lv_ordunit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_order_unit_filter'
        iv_value = lv_old_ordunit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_order_unit_filter'
        iv_value = lv_new_ordunit_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'order_id_filter'
        iv_value = lv_order_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_order_id_filter'
        iv_value = lv_old_order_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_order_id_filter'
        iv_value = lv_new_order_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reservation_id_filter'
        iv_value = lv_resid_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reservation_id_filter'
        iv_value = lv_old_resid_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reservation_id_filter'
        iv_value = lv_new_resid_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reservation_date_from_filter'
        iv_value = lv_rdate_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reservation_date_to_filter'
        iv_value = lv_rdate_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reservation_date_from_filter'
        iv_value = lv_old_rdate_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reservation_date_to_filter'
        iv_value = lv_old_rdate_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reservation_date_from_filter'
        iv_value = lv_new_rdate_from_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reservation_date_to_filter'
        iv_value = lv_new_rdate_to_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'reservation_age_filter'
        iv_value   = p_rage
        iv_text    = lv_rage_filter
        iv_present = xsdbool( p_rage IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'maximum_reservation_age_filter'
        iv_value   = p_rageto
        iv_text    = lv_rageto_filter
        iv_present = xsdbool( p_rageto IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_reservation_age_filter'
        iv_value   = lv_old_rage
        iv_text    = lv_old_rage_filter
        iv_present = xsdbool( p_orage IS NOT INITIAL OR p_rage IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'old_maximum_reservation_age_filter'
        iv_value   = lv_old_rageto
        iv_text    = lv_old_rageto_filter
        iv_present = xsdbool( p_oragto IS NOT INITIAL OR p_rageto IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_reservation_age_filter'
        iv_value   = lv_new_rage
        iv_text    = lv_new_rage_filter
        iv_present = xsdbool( p_nrage IS NOT INITIAL OR p_rage IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>filter_number_property(
        iv_name    = 'new_maximum_reservation_age_filter'
        iv_value   = lv_new_rageto
        iv_text    = lv_new_rageto_filter
        iv_present = xsdbool( p_nragto IS NOT INITIAL OR p_rageto IS NOT INITIAL )
        iv_typed   = p_typed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'change_type'
        iv_value = p_chg ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'reason_filter'
        iv_value = p_reason ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_status_filter'
        iv_value = p_ost ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_status_filter'
        iv_value = p_nst ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_audit_status_filter'
        iv_value = lv_old_audit_status_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_audit_status_filter'
        iv_value = lv_new_audit_status_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_strategy_filter'
        iv_value = lv_old_strategy_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_strategy_filter'
        iv_value = lv_new_strategy_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_legacy_strategy_filter'
        iv_value = p_oleg ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_legacy_strategy_filter'
        iv_value = p_nleg ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_message_filter'
        iv_value = lv_old_message_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_message_filter'
        iv_value = lv_new_message_filter ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'old_message_only'
        iv_value = p_omonly ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'new_message_only'
        iv_value = p_nmonly ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'include_unchanged'
        iv_value = p_all ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'reconciliation_guard'
        iv_value = p_guard ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_run_status'
        iv_value = ls_old_run-status ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_run_status'
        iv_value = ls_new_run-status ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_run_strategy'
        iv_value = ls_old_run-strategy ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_run_strategy'
        iv_value = ls_new_run-strategy ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_movement_type'
        iv_value = ls_old_run-movement_type ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_movement_type'
        iv_value = ls_new_run-movement_type ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_min_shelf_life'
          iv_value = ls_old_run-min_shelf_life ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_min_shelf_life'
          iv_value = ls_new_run-min_shelf_life ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_safety_stock'
          iv_value = ls_old_run-safety_stock ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_safety_stock'
          iv_value = ls_new_run-safety_stock ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_min_shelf_life'
          iv_value = ls_old_run-min_shelf_life ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_min_shelf_life'
          iv_value = ls_new_run-min_shelf_life ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_safety_stock'
          iv_value = ls_old_run-safety_stock ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_safety_stock'
          iv_value = ls_new_run-safety_stock ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_start_date'
        iv_value = ls_old_run-start_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_start_date'
        iv_value = ls_new_run-start_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_start_time'
        iv_value = ls_old_run-start_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_start_time'
        iv_value = ls_new_run-start_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_finish_date'
        iv_value = ls_old_run-finish_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_finish_date'
        iv_value = ls_new_run-finish_date ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_finish_time'
        iv_value = ls_old_run-finish_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_finish_time'
        iv_value = ls_new_run-finish_time ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_on_from'
        iv_value = ls_old_run-requested_on_from ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_on_from'
        iv_value = ls_new_run-requested_on_from ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_on_to'
        iv_value = ls_old_run-requested_on_to ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_on_to'
        iv_value = ls_new_run-requested_on_to ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_requested_deadline'
        iv_value = ls_old_run-requested_deadline ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_requested_deadline'
        iv_value = ls_new_run-requested_deadline ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_old_run-requested_deadline IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_deadline_age_days'
          iv_value = lv_old_deadline_age_days ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_deadline_age_days' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_deadline_age_days'
          iv_value = lv_old_deadline_age_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_new_run-requested_deadline IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_deadline_age_days'
          iv_value = lv_new_deadline_age_days ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_deadline_age_days' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_deadline_age_days'
          iv_value = lv_new_deadline_age_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_deadline_age_delta_text <> 'n/a'.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'deadline_age_delta_days'
          iv_value = lv_deadline_age_delta_days ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'deadline_age_delta_days' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'deadline_age_delta_days'
          iv_value = lv_deadline_age_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_available'
        iv_value = ls_old_run-available ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_available'
        iv_value = ls_new_run-available ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_old_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_duration_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_duration_seconds'
          iv_value = lv_old_duration_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_new_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_duration_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_duration_seconds'
          iv_value = lv_new_duration_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_running_age_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_running_age_seconds'
          iv_value = lv_old_running_age_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND lv_new_running_age_available = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_seconds ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_running_age_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_running_age_seconds'
          iv_value = lv_new_running_age_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND lv_old_running_age_available = abap_true
          AND lv_new_running_age_available = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_audit_running_age_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_running_age_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_running_age_delta_seconds'
          iv_value = lv_aud_run_age_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_running_age_trend'
        iv_value = lv_aud_run_age_trend ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_message'
        iv_value = ls_old_run-message ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_message'
        iv_value = ls_new_run-message ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reconciliation_fields'
        iv_value = ls_old_reconciliation-mismatch_fields ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reconciliation_fields'
        iv_value = ls_new_reconciliation-mismatch_fields ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_reconciliation'
        iv_value = lv_old_reconciliation ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_reconciliation'
        iv_value = lv_new_reconciliation ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_changed'
        iv_value = lv_recon_status_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_reconciliation_ok'
        iv_value = lv_recon_both_ok ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_reconciliation_transition'
        iv_value = lv_recon_transition ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_metadata_changed'
        iv_value = lv_audit_meta_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'audit_metadata_change_reasons'
        iv_value = lv_audit_meta_reasons ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'old_audit_unit'
        iv_value = ls_old_run-unit ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>property(
        iv_name  = 'new_audit_unit'
        iv_value = ls_new_run-unit ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_demand_count'
        iv_value = ls_old_run-demand_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_demand_count'
        iv_value = ls_new_run-demand_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_full_rows'
        iv_value = ls_old_run-full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_full_rows'
        iv_value = ls_new_run-full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_partial_rows'
        iv_value = ls_old_run-partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_partial_rows'
        iv_value = ls_new_run-partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_unallocated_rows'
        iv_value = ls_old_run-unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_unallocated_rows'
        iv_value = ls_new_run-unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_demand_count_delta'
        iv_value = lv_audit_demand_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_full_rows_delta'
        iv_value = lv_audit_full_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_partial_rows_delta'
        iv_value = lv_audit_partial_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'audit_unallocated_rows_delta'
        iv_value = lv_audit_unallocated_delta ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_requested'
        iv_value = ls_old_run-requested ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_requested'
        iv_value = ls_new_run-requested ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_allocated'
        iv_value = ls_old_run-allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_allocated'
        iv_value = ls_new_run-allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_audit_shortage'
        iv_value = ls_old_run-shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_audit_shortage'
        iv_value = ls_new_run-shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_old_run-requested > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_audit_coverage_pct' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'old_audit_shortage_pct' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_audit_coverage_pct'
          iv_value = lv_old_audit_coverage_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'old_audit_shortage_pct'
          iv_value = lv_old_audit_shortage_pct_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND ls_new_run-requested > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_audit_coverage_pct' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'new_audit_shortage_pct' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_audit_coverage_pct'
          iv_value = lv_new_audit_coverage_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'new_audit_shortage_pct'
          iv_value = lv_new_audit_shortage_pct_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_units_match'
        iv_value = lv_audit_units_match ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_horizon_changed'
        iv_value = lv_audit_horizon_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_status_changed'
        iv_value = lv_audit_status_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_strategy_changed'
        iv_value = lv_audit_strategy_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>boolean_property(
        iv_name  = 'audit_running_changed'
        iv_value = lv_audit_running_changed ) NO-GAP.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_aud_dur_delta_secs ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_duration_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_duration_delta_seconds'
          iv_value = lv_audit_duration_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND ls_old_run-start_date IS NOT INITIAL
          AND ls_new_run-start_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_aud_start_delta_secs ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_start_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_start_delta_seconds'
          iv_value = lv_audit_start_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true
          AND ls_old_run-finish_date IS NOT INITIAL
          AND ls_new_run-finish_date IS NOT INITIAL.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_aud_finish_delta_secs ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_finish_delta_seconds' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_finish_delta_seconds'
          iv_value = lv_audit_finish_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_requested_delta' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_available_delta' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_requested_delta'
          iv_value = lv_audit_requested_delta_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_available_delta'
          iv_value = lv_audit_available_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_allocated_delta' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_delta' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_allocated_delta'
          iv_value = lv_audit_allocated_delta_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_shortage_delta'
          iv_value = lv_audit_shortage_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      IF p_typed = abap_true AND lv_audit_units_match = abap_true
          AND ls_old_run-requested > 0 AND ls_new_run-requested > 0.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>number_property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_audit_shortage_pct_delta ) NO-GAP.
      ELSEIF p_typed = abap_true.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_coverage_delta_pct' ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>null_property(
          iv_name = 'audit_shortage_pct_delta' ) NO-GAP.
      ELSE.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_coverage_delta_pct'
          iv_value = lv_audit_coverage_delta_text ) NO-GAP.
        WRITE: / ',' NO-GAP.
        WRITE: / zcl_stock_json=>property(
          iv_name  = 'audit_shortage_pct_delta'
          iv_value = lv_aud_shrt_pct_delta_text ) NO-GAP.
      ENDIF.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_rows'
        iv_value = lines( lt_old ) ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_rows'
        iv_value = lines( lt_new ) ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_requested'
        iv_value = lv_old_requested_total ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_requested'
        iv_value = lv_new_requested_total ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_full_rows'
        iv_value = ls_old_reconciliation-snapshot_full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_full_rows'
        iv_value = ls_new_reconciliation-snapshot_full_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_partial_rows'
        iv_value = ls_old_reconciliation-snapshot_partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_partial_rows'
        iv_value = ls_new_reconciliation-snapshot_partial_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_unallocated_rows'
        iv_value = ls_old_reconciliation-snapshot_unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_unallocated_rows'
        iv_value = ls_new_reconciliation-snapshot_unallocated_count ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_allocated'
        iv_value = ls_old_reconciliation-snapshot_allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_allocated'
        iv_value = ls_new_reconciliation-snapshot_allocated ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'old_snapshot_shortage'
        iv_value = ls_old_reconciliation-snapshot_shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / zcl_stock_json=>number_property(
        iv_name  = 'new_snapshot_shortage'
        iv_value = ls_new_reconciliation-snapshot_shortage ) NO-GAP.
      WRITE: / ',' NO-GAP.
      WRITE: / '"rows":[' NO-GAP.
    ELSEIF p_ndjson = abap_false.
      WRITE: / '['.
    ENDIF.
    lv_first = abap_true.
    LOOP AT lt_changes ASSIGNING <ls_change>.
      CLEAR lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>boolean_property(
          iv_name  = 'typed'
          iv_value = abap_true ) TO lt_json_fields.
      ENDIF.
      APPEND zcl_stock_json=>property(
        iv_name  = 'change_type'
        iv_value = <ls_change>-change_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'change_reasons'
        iv_value = <ls_change>-change_reasons ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'allocation_unit'
        iv_value = <ls_change>-allocation_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'order_id'
        iv_value = <ls_change>-order_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_allocation_strategy'
        iv_value = <ls_change>-old_allocation_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_allocation_strategy'
        iv_value = <ls_change>-new_allocation_strategy ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_document'
        iv_value = <ls_change>-old_sales_document ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_document'
        iv_value = <ls_change>-new_sales_document ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_document_type'
        iv_value = <ls_change>-old_sales_document_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_document_type'
        iv_value = <ls_change>-new_sales_document_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_sales_item'
        iv_value = <ls_change>-old_sales_item ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_sales_item'
        iv_value = <ls_change>-new_sales_item ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_schedule_line'
        iv_value = <ls_change>-old_schedule_line ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_schedule_line'
        iv_value = <ls_change>-new_schedule_line ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_order_unit'
        iv_value = <ls_change>-old_order_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_order_unit'
        iv_value = <ls_change>-new_order_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_requested_on'
        iv_value = <ls_change>-old_requested_on ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_requested_on'
        iv_value = <ls_change>-new_requested_on ) TO lt_json_fields.
      IF p_typed = abap_true.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_priority'
          iv_value = <ls_change>-old_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_priority'
          iv_value = <ls_change>-new_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_requested'
          iv_value = <ls_change>-old_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_requested'
          iv_value = <ls_change>-new_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_requested'
          iv_value = <ls_change>-delta_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_allocated'
          iv_value = <ls_change>-old_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_allocated'
          iv_value = <ls_change>-new_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_allocated'
          iv_value = <ls_change>-delta_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'old_shortage'
          iv_value = <ls_change>-old_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'new_shortage'
          iv_value = <ls_change>-new_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>number_property(
          iv_name  = 'delta_shortage'
          iv_value = <ls_change>-delta_shortage ) TO lt_json_fields.
      ELSE.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_priority'
          iv_value = <ls_change>-old_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_priority'
          iv_value = <ls_change>-new_priority ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_requested'
          iv_value = <ls_change>-old_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_requested'
          iv_value = <ls_change>-new_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_requested'
          iv_value = <ls_change>-delta_requested ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_allocated'
          iv_value = <ls_change>-old_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_allocated'
          iv_value = <ls_change>-new_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_allocated'
          iv_value = <ls_change>-delta_allocated ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'old_shortage'
          iv_value = <ls_change>-old_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'new_shortage'
          iv_value = <ls_change>-new_shortage ) TO lt_json_fields.
        APPEND zcl_stock_json=>property(
          iv_name  = 'delta_shortage'
          iv_value = <ls_change>-delta_shortage ) TO lt_json_fields.
      ENDIF.
      lv_old_snapshot_coverage_text = 'n/a'.
      lv_new_snapshot_coverage_text = 'n/a'.
      lv_old_snap_shrt_pct_text = 'n/a'.
      lv_new_snap_shrt_pct_text = 'n/a'.
      IF <ls_change>-old_coverage_available = abap_true.
        lv_old_snapshot_coverage_text = zcl_stock_csv=>number(
          <ls_change>-old_coverage ).
      ENDIF.
      IF <ls_change>-new_coverage_available = abap_true.
        lv_new_snapshot_coverage_text = zcl_stock_csv=>number(
          <ls_change>-new_coverage ).
      ENDIF.
      IF <ls_change>-old_shortage_pct_available = abap_true.
        lv_old_snap_shrt_pct_text = zcl_stock_csv=>number(
          <ls_change>-old_shortage_pct ).
      ENDIF.
      IF <ls_change>-new_shortage_pct_available = abap_true.
        lv_new_snap_shrt_pct_text = zcl_stock_csv=>number(
          <ls_change>-new_shortage_pct ).
      ENDIF.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_snapshot_coverage_pct'
        iv_value   = <ls_change>-old_coverage
        iv_text    = lv_old_snapshot_coverage_text
        iv_present = <ls_change>-old_coverage_available
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_snapshot_coverage_pct'
        iv_value   = <ls_change>-new_coverage
        iv_text    = lv_new_snapshot_coverage_text
        iv_present = <ls_change>-new_coverage_available
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'old_snapshot_shortage_pct'
        iv_value   = <ls_change>-old_shortage_pct
        iv_text    = lv_old_snap_shrt_pct_text
        iv_present = <ls_change>-old_shortage_pct_available
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'new_snapshot_shortage_pct'
        iv_value   = <ls_change>-new_shortage_pct
        iv_text    = lv_new_snap_shrt_pct_text
        iv_present = <ls_change>-new_shortage_pct_available
        iv_typed   = p_typed ) TO lt_json_fields.
      IF <ls_change>-coverage_delta_available = abap_true.
        lv_snap_cov_delta_text = zcl_stock_csv=>number(
          <ls_change>-coverage_delta ).
      ELSE.
        lv_snap_cov_delta_text = 'n/a'.
      ENDIF.
      IF <ls_change>-shortage_pct_delta_available = abap_true.
        lv_snap_shrt_delta_text = zcl_stock_csv=>number(
          <ls_change>-shortage_pct_delta ).
      ELSE.
        lv_snap_shrt_delta_text = 'n/a'.
      ENDIF.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'snapshot_coverage_delta_pct'
        iv_value   = <ls_change>-coverage_delta
        iv_text    = lv_snap_cov_delta_text
        iv_present = <ls_change>-coverage_delta_available
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>filter_number_property(
        iv_name    = 'snapshot_shortage_pct_delta'
        iv_value   = <ls_change>-shortage_pct_delta
        iv_text    = lv_snap_shrt_delta_text
        iv_present = <ls_change>-shortage_pct_delta_available
        iv_typed   = p_typed ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_status'
        iv_value = <ls_change>-old_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_status'
        iv_value = <ls_change>-new_status ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_id'
        iv_value = <ls_change>-old_reservation_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_id'
        iv_value = <ls_change>-new_reservation_id ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_date'
        iv_value = <ls_change>-old_reservation_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_date'
        iv_value = <ls_change>-new_reservation_date ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_movement_type'
        iv_value = <ls_change>-old_reservation_movement_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_movement_type'
        iv_value = <ls_change>-new_reservation_movement_type ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'old_reservation_unit'
        iv_value = <ls_change>-old_reservation_unit ) TO lt_json_fields.
      APPEND zcl_stock_json=>property(
        iv_name  = 'new_reservation_unit'
        iv_value = <ls_change>-new_reservation_unit ) TO lt_json_fields.
      CONCATENATE LINES OF lt_json_fields INTO lv_json_fields SEPARATED BY ','.
      lv_json_line = '{'.
      CONCATENATE lv_json_line lv_json_fields '}' INTO lv_json_line.
      IF p_ndjson = abap_true.
        WRITE: / lv_json_line NO-GAP.
      ELSE.
        IF lv_first = abap_true.
          lv_first = abap_false.
        ELSE.
          WRITE: / ',' NO-GAP.
        ENDIF.
        WRITE: / lv_json_line NO-GAP.
      ENDIF.
    ENDLOOP.
    IF p_ndjson = abap_false.
      IF p_meta = abap_true.
        WRITE: / ']}' NO-GAP.
      ELSE.
        WRITE: / ']' NO-GAP.
      ENDIF.
    ENDIF.
    RETURN.
  ENDIF.

  IF p_sum = abap_true.
    WRITE: / 'Allocation snapshot comparison summary'.
    WRITE: / 'Schema version:', 7.
    WRITE: / 'Generated date/time:', sy-datum, sy-uzeit.
    WRITE: / 'Old run:', p_old.
    WRITE: / 'New run:', p_new.
    WRITE: / 'Scope:', p_matnr, p_werks, p_lgort, p_charg, p_meins.
    WRITE: / 'Old material filter:', lv_old_material_filter.
    WRITE: / 'New material filter:', lv_new_material_filter.
    WRITE: / 'Old plant filter:', lv_old_plant_filter.
    WRITE: / 'New plant filter:', lv_new_plant_filter.
    WRITE: / 'Old storage location filter:', lv_old_storage_location_filter.
    WRITE: / 'New storage location filter:', lv_new_storage_location_filter.
    WRITE: / 'Old batch filter:', lv_old_batch_filter.
    WRITE: / 'New batch filter:', lv_new_batch_filter.
    WRITE: / 'Old unit filter:', lv_old_unit_filter.
    WRITE: / 'New unit filter:', lv_new_unit_filter.
    WRITE: / 'Reservation movement type filter:',
      lv_reservation_movement_filter.
    WRITE: / 'Old reservation movement type filter:',
      lv_old_rmov_filter.
    WRITE: / 'New reservation movement type filter:',
      lv_new_rmov_filter.
    WRITE: / 'Reservation unit filter:', lv_reservation_unit_filter.
    WRITE: / 'Old reservation unit filter:', lv_old_runit_filter.
    WRITE: / 'New reservation unit filter:', lv_new_runit_filter.
    WRITE: / 'Reserved-only filter:', p_rsv.
    WRITE: / 'Unreserved-only filter:', p_unrsv.
    WRITE: / 'Old reserved-only filter:', lv_old_reserved_only.
    WRITE: / 'New reserved-only filter:', lv_new_reserved_only.
    WRITE: / 'Old unreserved-only filter:', lv_old_unreserved_only.
    WRITE: / 'New unreserved-only filter:', lv_new_unreserved_only.
    WRITE: / 'Shortage-only filter:', p_bklg.
    WRITE: / 'Old shortage-only filter:', lv_old_shortage_only.
    WRITE: / 'New shortage-only filter:', lv_new_shortage_only.
    WRITE: / 'Minimum shortage filter:', lv_shortage_from_filter.
    WRITE: / 'Maximum shortage filter:', lv_shortage_to_filter.
    WRITE: / 'Old minimum shortage filter:', lv_old_shortage_from_filter.
    WRITE: / 'Old maximum shortage filter:', lv_old_shortage_to_filter.
    WRITE: / 'New minimum shortage filter:', lv_new_shortage_from_filter.
    WRITE: / 'New maximum shortage filter:', lv_new_shortage_to_filter.
    WRITE: / 'Minimum coverage filter:', lv_coverage_from_filter.
    WRITE: / 'Maximum coverage filter:', lv_coverage_to_filter.
    WRITE: / 'Old minimum coverage filter:', lv_old_coverage_from_filter.
    WRITE: / 'Old maximum coverage filter:', lv_old_coverage_to_filter.
    WRITE: / 'New minimum coverage filter:', lv_new_coverage_from_filter.
    WRITE: / 'New maximum coverage filter:', lv_new_coverage_to_filter.
    WRITE: / 'Minimum shortage percentage filter:', lv_shortage_pct_from_filter.
    WRITE: / 'Maximum shortage percentage filter:', lv_shortage_pct_to_filter.
    WRITE: / 'Old minimum shortage percentage filter:',
      lv_old_sp_from_txt.
    WRITE: / 'Old maximum shortage percentage filter:',
      lv_old_sp_to_txt.
    WRITE: / 'New minimum shortage percentage filter:',
      lv_new_sp_from_txt.
    WRITE: / 'New maximum shortage percentage filter:',
      lv_new_sp_to_txt.
    WRITE: / 'Minimum requested quantity filter:', lv_req_qty_from_txt.
    WRITE: / 'Maximum requested quantity filter:', lv_req_qty_to_txt.
    WRITE: / 'Old minimum requested quantity filter:', lv_old_req_qty_from_txt.
    WRITE: / 'Old maximum requested quantity filter:', lv_old_req_qty_to_txt.
    WRITE: / 'New minimum requested quantity filter:', lv_new_req_qty_from_txt.
    WRITE: / 'New maximum requested quantity filter:', lv_new_req_qty_to_txt.
    WRITE: / 'Minimum allocated quantity filter:', lv_allocated_from_filter.
    WRITE: / 'Maximum allocated quantity filter:', lv_allocated_to_filter.
    WRITE: / 'Old minimum allocated quantity filter:', lv_old_allocated_from_txt.
    WRITE: / 'Old maximum allocated quantity filter:', lv_old_allocated_to_txt.
    WRITE: / 'New minimum allocated quantity filter:', lv_new_allocated_from_txt.
    WRITE: / 'New maximum allocated quantity filter:', lv_new_allocated_to_txt.
    WRITE: / 'Minimum priority filter:', lv_priority_from_txt.
    WRITE: / 'Maximum priority filter:', lv_priority_to_txt.
    WRITE: / 'Old minimum priority filter:', lv_old_priority_from_txt.
    WRITE: / 'Old maximum priority filter:', lv_old_priority_to_txt.
    WRITE: / 'New minimum priority filter:', lv_new_priority_from_txt.
    WRITE: / 'New maximum priority filter:', lv_new_priority_to_txt.
    WRITE: / 'Snapshot requested date from:', lv_snapshot_from_filter.
    WRITE: / 'Snapshot requested date to:', lv_snapshot_to_filter.
    WRITE: / 'Old snapshot requested date from:', lv_old_snapshot_from_filter.
    WRITE: / 'Old snapshot requested date to:', lv_old_snapshot_to_filter.
    WRITE: / 'New snapshot requested date from:', lv_new_snapshot_from_filter.
    WRITE: / 'New snapshot requested date to:', lv_new_snapshot_to_filter.
    WRITE: / 'Sales document filter:', lv_sales_document_filter.
    WRITE: / 'Old sales document filter:', lv_old_sales_document_filter.
    WRITE: / 'New sales document filter:', lv_new_sales_document_filter.
    WRITE: / 'Sales document type filter:', lv_auart_filter.
    WRITE: / 'Old sales document type filter:', lv_old_auart_filter.
    WRITE: / 'New sales document type filter:', lv_new_auart_filter.
    WRITE: / 'Sales item filter:', lv_posnr_filter.
    WRITE: / 'Old sales item filter:', lv_old_posnr_filter.
    WRITE: / 'New sales item filter:', lv_new_posnr_filter.
    WRITE: / 'Schedule line filter:', lv_etenr_filter.
    WRITE: / 'Old schedule line filter:', lv_old_etenr_filter.
    WRITE: / 'New schedule line filter:', lv_new_etenr_filter.
    WRITE: / 'Order unit filter:', lv_ordunit_filter.
    WRITE: / 'Old order unit filter:', lv_old_ordunit_filter.
    WRITE: / 'New order unit filter:', lv_new_ordunit_filter.
    WRITE: / 'Order ID filter:', lv_order_filter.
    WRITE: / 'Old order ID filter:', lv_old_order_filter.
    WRITE: / 'New order ID filter:', lv_new_order_filter.
    WRITE: / 'Reservation ID filter:', lv_resid_filter.
    WRITE: / 'Old reservation ID filter:', lv_old_resid_filter.
    WRITE: / 'New reservation ID filter:', lv_new_resid_filter.
    WRITE: / 'Reservation date from:', lv_rdate_from_filter.
    WRITE: / 'Reservation date to:', lv_rdate_to_filter.
    WRITE: / 'Old reservation date from:', lv_old_rdate_from_filter.
    WRITE: / 'Old reservation date to:', lv_old_rdate_to_filter.
    WRITE: / 'New reservation date from:', lv_new_rdate_from_filter.
    WRITE: / 'New reservation date to:', lv_new_rdate_to_filter.
    WRITE: / 'Reason filter:', p_reason.
    WRITE: / 'Filters applied:', lv_filters_applied.
    WRITE: / 'Filters:', lv_filter_names_text.
    WRITE: / 'Sort mode:', lv_sort_mode.
    WRITE: / 'Movement type filter:', lv_movement_filter.
    WRITE: / 'Old movement type filter:', lv_old_movement_filter.
    WRITE: / 'New movement type filter:', lv_new_movement_filter.
    WRITE: / 'Minimum shelf-life filter:', lv_min_shelf_filter.
    WRITE: / 'Old minimum shelf-life filter:', lv_old_shelf_filter.
    WRITE: / 'New minimum shelf-life filter:', lv_new_shelf_filter.
    WRITE: / 'Old audit status filter:', lv_old_audit_status_filter.
    WRITE: / 'New audit status filter:', lv_new_audit_status_filter.
    WRITE: / 'Old strategy filter:', lv_old_strategy_filter.
    WRITE: / 'New strategy filter:', lv_new_strategy_filter.
    WRITE: / 'Old legacy strategy filter:', lv_old_legacy_strategy_filter.
    WRITE: / 'New legacy strategy filter:', lv_new_legacy_strategy_filter.
    WRITE: / 'Old message filter:', lv_old_message_filter.
    WRITE: / 'New message filter:', lv_new_message_filter.
    WRITE: / 'Old message only:', lv_old_message_only_text.
    WRITE: / 'New message only:', lv_new_message_only_text.
    WRITE: / 'Overdue-only filter:', p_ovrd.
    WRITE: / 'Old overdue-only filter:', lv_old_overdue_only_filter.
    WRITE: / 'New overdue-only filter:', lv_new_overdue_only_filter.
    WRITE: / 'Overdue as-of date:', lv_overdue_as_of_filter.
    WRITE: / 'Requested-deadline-only filter:', p_dead.
    WRITE: / 'Old requested-deadline-only filter:', lv_old_deadline_only_filter.
    WRITE: / 'New requested-deadline-only filter:', lv_new_deadline_only_filter.
    WRITE: / 'Requested deadline from:', lv_deadline_from_filter,
             'to:', lv_deadline_to_filter.
    WRITE: / 'Old requested deadline from:', lv_old_deadline_from_filter,
             'to:', lv_old_deadline_to_filter.
    WRITE: / 'New requested deadline from:', lv_new_deadline_from_filter,
             'to:', lv_new_deadline_to_filter.
    WRITE: / 'Requested deadline age from:', lv_deadline_age_from_filter,
             'to:', lv_deadline_age_to_filter.
    WRITE: / 'Old requested deadline age from:', lv_old_age_from_txt,
             'to:', lv_old_age_to_txt.
    WRITE: / 'New requested deadline age from:', lv_new_age_from_txt,
             'to:', lv_new_age_to_txt.
    WRITE: / 'Reconciliation guard:', p_guard.
    WRITE: / 'Old status/strategy:', ls_old_run-status, ls_old_run-strategy,
      'New status/strategy:', ls_new_run-status, ls_new_run-strategy.
    WRITE: / 'Old movement type/shelf life:', ls_old_run-movement_type,
      ls_old_run-min_shelf_life, 'Old safety stock:', ls_old_run-safety_stock,
      'New movement type/shelf life:',
      ls_new_run-movement_type, ls_new_run-min_shelf_life,
      'New safety stock:', ls_new_run-safety_stock.
    WRITE: / 'Old start/finish:', ls_old_run-start_date,
      ls_old_run-start_time, ls_old_run-finish_date,
      ls_old_run-finish_time,
      'New start/finish:', ls_new_run-start_date,
      ls_new_run-start_time, ls_new_run-finish_date,
      ls_new_run-finish_time.
    WRITE: / 'Old requested horizon:', ls_old_run-requested_on_from,
      ls_old_run-requested_on_to,
      'New requested horizon:', ls_new_run-requested_on_from,
      ls_new_run-requested_on_to,
      'Old/new deadlines:', ls_old_run-requested_deadline,
      ls_new_run-requested_deadline.
    WRITE: / 'Old/new deadline age days:', lv_old_deadline_age_text,
      lv_new_deadline_age_text,
      'Delta:', lv_deadline_age_delta_text,
      'Reference date:', lv_deadline_reference_date.
    WRITE: / 'Available old/new:', ls_old_run-available, ls_new_run-available.
    WRITE: / 'Duration seconds old/new:', lv_old_duration_text,
      lv_new_duration_text.
    WRITE: / 'Running age seconds old/new:', lv_old_running_age_text,
      lv_new_running_age_text.
    WRITE: / 'Old message:', ls_old_run-message.
    WRITE: / 'New message:', ls_new_run-message.
    WRITE: / 'Old reconciliation:', lv_old_reconciliation,
      'Snapshot rows:', lines( lt_old ).
    WRITE: / 'Old reconciliation fields:',
      ls_old_reconciliation-mismatch_fields.
    WRITE: / 'Audit unit old/new:', ls_old_run-unit, ls_new_run-unit.
    WRITE: / 'Audit demand count old/new:', ls_old_run-demand_count,
      ls_new_run-demand_count.
    WRITE: / 'Audit full rows old/new:', ls_old_run-full_count,
      ls_new_run-full_count.
    WRITE: / 'Audit partial rows old/new:', ls_old_run-partial_count,
      ls_new_run-partial_count.
    WRITE: / 'Audit unallocated rows old/new:',
      ls_old_run-unallocated_count, ls_new_run-unallocated_count.
    WRITE: / 'Audit outcome counter deltas:', lv_audit_demand_delta,
      lv_audit_full_delta, lv_audit_partial_delta,
      lv_audit_unallocated_delta.
    WRITE: / 'Audit requested old/new:', ls_old_run-requested,
      ls_new_run-requested.
    WRITE: / 'Audit allocated old/new:', ls_old_run-allocated,
      ls_new_run-allocated.
    WRITE: / 'Audit shortage old/new:', ls_old_run-shortage,
      ls_new_run-shortage.
    WRITE: / 'Audit coverage pct old/new:', lv_old_audit_coverage_text,
      lv_new_audit_coverage_text.
    WRITE: / 'Audit shortage pct old/new:',
      lv_old_audit_shortage_pct_text, lv_new_audit_shortage_pct_text.
    WRITE: / 'Audit units match:', lv_audit_units_match.
    WRITE: / 'Audit horizon changed:', lv_audit_horizon_changed.
    WRITE: / 'Audit status/strategy changed:',
      lv_audit_status_changed, lv_audit_strategy_changed.
    WRITE: / 'Audit running changed:', lv_audit_running_changed.
    WRITE: / 'Audit duration delta seconds:',
      lv_audit_duration_delta_text.
    WRITE: / 'Audit running age delta seconds:',
      lv_aud_run_age_delta_text.
    WRITE: / 'Audit running age trend:', lv_aud_run_age_trend.
    WRITE: / 'Audit start/finish delta seconds:',
      lv_audit_start_delta_text, lv_audit_finish_delta_text.
    WRITE: / 'Audit requested/available delta:',
      lv_audit_requested_delta_text, lv_audit_available_delta_text.
    WRITE: / 'Audit allocated/shortage delta:',
      lv_audit_allocated_delta_text, lv_audit_shortage_delta_text.
    WRITE: / 'Audit coverage/shortage pct delta:',
      lv_audit_coverage_delta_text, lv_aud_shrt_pct_delta_text.
    WRITE: / 'Snapshot requested old/new:', lv_old_requested_total,
      lv_new_requested_total.
    WRITE: / 'Snapshot full rows old/new:',
      ls_old_reconciliation-snapshot_full_count,
      ls_new_reconciliation-snapshot_full_count.
    WRITE: / 'Snapshot partial rows old/new:',
      ls_old_reconciliation-snapshot_partial_count,
      ls_new_reconciliation-snapshot_partial_count.
    WRITE: / 'Snapshot unallocated rows old/new:',
      ls_old_reconciliation-snapshot_unallocated_count,
      ls_new_reconciliation-snapshot_unallocated_count.
    WRITE: / 'Snapshot allocated old/new:',
      ls_old_reconciliation-snapshot_allocated,
      ls_new_reconciliation-snapshot_allocated.
    WRITE: / 'Snapshot shortage old/new:',
      ls_old_reconciliation-snapshot_shortage,
      ls_new_reconciliation-snapshot_shortage.
    WRITE: / 'New reconciliation:', lv_new_reconciliation,
      'Snapshot rows:', lines( lt_new ).
    WRITE: / 'Audit reconciliation changed:', lv_recon_status_changed.
    WRITE: / 'Audit reconciliation OK:', lv_recon_both_ok.
    WRITE: / 'Audit reconciliation transition:', lv_recon_transition.
    WRITE: / 'Audit metadata changed:', lv_audit_meta_changed.
    WRITE: / 'Audit metadata change reasons:', lv_audit_meta_reasons.
    WRITE: / 'New reconciliation fields:',
      ls_new_reconciliation-mismatch_fields.
    WRITE: / 'Total matching changes:', ls_summary-total_rows.
    WRITE: / 'Returned changes:', lines( lt_changes ).
    WRITE: / 'Added:', ls_summary-added_rows,
      'Removed:', ls_summary-removed_rows,
      'Changed:', ls_summary-changed_rows,
      'Unchanged:', ls_summary-unchanged_rows.
    IF ls_summary-mixed_units = abap_true.
      WRITE: / 'Unit: mixed',
        'Mixed units:', ls_summary-mixed_units.
      WRITE: / 'Quantity totals: n/a (mixed allocation units).' .
      WRITE: / 'Percentage totals: n/a (mixed allocation units).' .
    ELSE.
      WRITE: / 'Unit:', ls_summary-unit,
        'Mixed units:', ls_summary-mixed_units.
      WRITE: / 'Requested old/new/delta:', ls_summary-old_requested,
        ls_summary-new_requested, ls_summary-delta_requested.
      WRITE: / 'Allocated old/new/delta:', ls_summary-old_allocated,
        ls_summary-new_allocated, ls_summary-delta_allocated.
      WRITE: / 'Shortage old/new/delta:', ls_summary-old_shortage,
        ls_summary-new_shortage, ls_summary-delta_shortage.
      WRITE: / 'Coverage pct old/new/delta:', lv_sum_old_cov_text,
        lv_sum_new_cov_text, lv_sum_cov_delta_text.
      WRITE: / 'Shortage pct old/new/delta:', lv_sum_old_shrt_text,
        lv_sum_new_shrt_text, lv_sum_shrt_delta_text.
    ENDIF.
    WRITE: / 'Offset:', p_skip, 'Max rows:', p_max.
    WRITE: / 'Has more:', lv_has_more, 'Next offset:', lv_next_offset_text.
    WRITE: / 'Has previous:', lv_has_previous,
      'Previous offset:', lv_previous_offset_text,
      'Page number:', lv_page_number_text,
      'Page count:', lv_page_count_text,
      'Last offset:', lv_last_offset_text.
    RETURN.
  ENDIF.

  WRITE: / 'Allocation snapshot comparison'.
  WRITE: / 'Schema version:', 7.
  WRITE: / 'Generated date/time:', sy-datum, sy-uzeit.
  WRITE: / 'Old run:', p_old.
  WRITE: / 'New run:', p_new.
  WRITE: / 'Scope:', p_matnr, p_werks, p_lgort, p_charg, p_meins.
  WRITE: / 'Old material filter:', lv_old_material_filter.
  WRITE: / 'New material filter:', lv_new_material_filter.
  WRITE: / 'Old plant filter:', lv_old_plant_filter.
  WRITE: / 'New plant filter:', lv_new_plant_filter.
  WRITE: / 'Old storage location filter:', lv_old_storage_location_filter.
  WRITE: / 'New storage location filter:', lv_new_storage_location_filter.
  WRITE: / 'Old batch filter:', lv_old_batch_filter.
  WRITE: / 'New batch filter:', lv_new_batch_filter.
  WRITE: / 'Old unit filter:', lv_old_unit_filter.
  WRITE: / 'New unit filter:', lv_new_unit_filter.
  WRITE: / 'Reservation movement type filter:',
    lv_reservation_movement_filter.
  WRITE: / 'Old reservation movement type filter:',
    lv_old_rmov_filter.
  WRITE: / 'New reservation movement type filter:',
    lv_new_rmov_filter.
  WRITE: / 'Reservation unit filter:', lv_reservation_unit_filter.
  WRITE: / 'Old reservation unit filter:', lv_old_runit_filter.
  WRITE: / 'New reservation unit filter:', lv_new_runit_filter.
  WRITE: / 'Reserved-only filter:', p_rsv.
  WRITE: / 'Unreserved-only filter:', p_unrsv.
  WRITE: / 'Old reserved-only filter:', lv_old_reserved_only.
  WRITE: / 'New reserved-only filter:', lv_new_reserved_only.
  WRITE: / 'Old unreserved-only filter:', lv_old_unreserved_only.
  WRITE: / 'New unreserved-only filter:', lv_new_unreserved_only.
  WRITE: / 'Shortage-only filter:', p_bklg.
  WRITE: / 'Old shortage-only filter:', lv_old_shortage_only.
  WRITE: / 'New shortage-only filter:', lv_new_shortage_only.
  WRITE: / 'Minimum shortage filter:', lv_shortage_from_filter.
  WRITE: / 'Maximum shortage filter:', lv_shortage_to_filter.
  WRITE: / 'Old minimum shortage filter:', lv_old_shortage_from_filter.
  WRITE: / 'Old maximum shortage filter:', lv_old_shortage_to_filter.
  WRITE: / 'New minimum shortage filter:', lv_new_shortage_from_filter.
  WRITE: / 'New maximum shortage filter:', lv_new_shortage_to_filter.
  WRITE: / 'Minimum coverage filter:', lv_coverage_from_filter.
  WRITE: / 'Maximum coverage filter:', lv_coverage_to_filter.
  WRITE: / 'Old minimum coverage filter:', lv_old_coverage_from_filter.
  WRITE: / 'Old maximum coverage filter:', lv_old_coverage_to_filter.
  WRITE: / 'New minimum coverage filter:', lv_new_coverage_from_filter.
  WRITE: / 'New maximum coverage filter:', lv_new_coverage_to_filter.
  WRITE: / 'Minimum shortage percentage filter:', lv_shortage_pct_from_filter.
  WRITE: / 'Maximum shortage percentage filter:', lv_shortage_pct_to_filter.
  WRITE: / 'Old minimum shortage percentage filter:',
    lv_old_sp_from_txt.
  WRITE: / 'Old maximum shortage percentage filter:',
    lv_old_sp_to_txt.
  WRITE: / 'New minimum shortage percentage filter:',
    lv_new_sp_from_txt.
  WRITE: / 'New maximum shortage percentage filter:',
    lv_new_sp_to_txt.
  WRITE: / 'Minimum requested quantity filter:', lv_req_qty_from_txt.
  WRITE: / 'Maximum requested quantity filter:', lv_req_qty_to_txt.
  WRITE: / 'Old minimum requested quantity filter:', lv_old_req_qty_from_txt.
  WRITE: / 'Old maximum requested quantity filter:', lv_old_req_qty_to_txt.
  WRITE: / 'New minimum requested quantity filter:', lv_new_req_qty_from_txt.
  WRITE: / 'New maximum requested quantity filter:', lv_new_req_qty_to_txt.
  WRITE: / 'Minimum allocated quantity filter:', lv_allocated_from_filter.
  WRITE: / 'Maximum allocated quantity filter:', lv_allocated_to_filter.
  WRITE: / 'Old minimum allocated quantity filter:', lv_old_allocated_from_txt.
  WRITE: / 'Old maximum allocated quantity filter:', lv_old_allocated_to_txt.
  WRITE: / 'New minimum allocated quantity filter:', lv_new_allocated_from_txt.
  WRITE: / 'New maximum allocated quantity filter:', lv_new_allocated_to_txt.
  WRITE: / 'Minimum priority filter:', lv_priority_from_txt.
  WRITE: / 'Maximum priority filter:', lv_priority_to_txt.
  WRITE: / 'Old minimum priority filter:', lv_old_priority_from_txt.
  WRITE: / 'Old maximum priority filter:', lv_old_priority_to_txt.
  WRITE: / 'New minimum priority filter:', lv_new_priority_from_txt.
  WRITE: / 'New maximum priority filter:', lv_new_priority_to_txt.
  WRITE: / 'Snapshot requested date from:', lv_snapshot_from_filter.
  WRITE: / 'Snapshot requested date to:', lv_snapshot_to_filter.
  WRITE: / 'Old snapshot requested date from:', lv_old_snapshot_from_filter.
  WRITE: / 'Old snapshot requested date to:', lv_old_snapshot_to_filter.
  WRITE: / 'New snapshot requested date from:', lv_new_snapshot_from_filter.
  WRITE: / 'New snapshot requested date to:', lv_new_snapshot_to_filter.
  WRITE: / 'Sales document filter:', lv_sales_document_filter.
  WRITE: / 'Old sales document filter:', lv_old_sales_document_filter.
  WRITE: / 'New sales document filter:', lv_new_sales_document_filter.
  WRITE: / 'Sales document type filter:', lv_auart_filter.
  WRITE: / 'Old sales document type filter:', lv_old_auart_filter.
  WRITE: / 'New sales document type filter:', lv_new_auart_filter.
  WRITE: / 'Sales item filter:', lv_posnr_filter.
  WRITE: / 'Old sales item filter:', lv_old_posnr_filter.
  WRITE: / 'New sales item filter:', lv_new_posnr_filter.
  WRITE: / 'Schedule line filter:', lv_etenr_filter.
  WRITE: / 'Old schedule line filter:', lv_old_etenr_filter.
  WRITE: / 'New schedule line filter:', lv_new_etenr_filter.
  WRITE: / 'Order unit filter:', lv_ordunit_filter.
  WRITE: / 'Old order unit filter:', lv_old_ordunit_filter.
  WRITE: / 'New order unit filter:', lv_new_ordunit_filter.
  WRITE: / 'Order ID filter:', lv_order_filter.
  WRITE: / 'Old order ID filter:', lv_old_order_filter.
  WRITE: / 'New order ID filter:', lv_new_order_filter.
  WRITE: / 'Reservation ID filter:', lv_resid_filter.
  WRITE: / 'Old reservation ID filter:', lv_old_resid_filter.
  WRITE: / 'New reservation ID filter:', lv_new_resid_filter.
  WRITE: / 'Reservation date from:', lv_rdate_from_filter.
  WRITE: / 'Reservation date to:', lv_rdate_to_filter.
  WRITE: / 'Old reservation date from:', lv_old_rdate_from_filter.
  WRITE: / 'Old reservation date to:', lv_old_rdate_to_filter.
  WRITE: / 'New reservation date from:', lv_new_rdate_from_filter.
  WRITE: / 'New reservation date to:', lv_new_rdate_to_filter.
  WRITE: / 'Reservation age filter:', lv_rage_filter.
  WRITE: / 'Maximum reservation age filter:', lv_rageto_filter.
  WRITE: / 'Old reservation age filter:', lv_old_rage_filter.
  WRITE: / 'Old maximum reservation age filter:', lv_old_rageto_filter.
  WRITE: / 'New reservation age filter:', lv_new_rage_filter.
  WRITE: / 'New maximum reservation age filter:', lv_new_rageto_filter.
  WRITE: / 'Reason filter:', p_reason.
  WRITE: / 'Filters applied:', lv_filters_applied.
  WRITE: / 'Filters:', lv_filter_names_text.
  WRITE: / 'Sort mode:', lv_sort_mode.
  WRITE: / 'Movement type filter:', lv_movement_filter.
  WRITE: / 'Old movement type filter:', lv_old_movement_filter.
  WRITE: / 'New movement type filter:', lv_new_movement_filter.
  WRITE: / 'Minimum shelf-life filter:', lv_min_shelf_filter.
  WRITE: / 'Old minimum shelf-life filter:', lv_old_shelf_filter.
  WRITE: / 'New minimum shelf-life filter:', lv_new_shelf_filter.
  WRITE: / 'Old audit status filter:', lv_old_audit_status_filter.
  WRITE: / 'New audit status filter:', lv_new_audit_status_filter.
  WRITE: / 'Old strategy filter:', lv_old_strategy_filter.
  WRITE: / 'New strategy filter:', lv_new_strategy_filter.
  WRITE: / 'Old legacy strategy filter:', lv_old_legacy_strategy_filter.
  WRITE: / 'New legacy strategy filter:', lv_new_legacy_strategy_filter.
  WRITE: / 'Old message filter:', lv_old_message_filter.
  WRITE: / 'New message filter:', lv_new_message_filter.
  WRITE: / 'Old message only:', lv_old_message_only_text.
  WRITE: / 'New message only:', lv_new_message_only_text.
  WRITE: / 'Overdue-only filter:', p_ovrd.
  WRITE: / 'Old overdue-only filter:', lv_old_overdue_only_filter.
  WRITE: / 'New overdue-only filter:', lv_new_overdue_only_filter.
  WRITE: / 'Overdue as-of date:', lv_overdue_as_of_filter.
  WRITE: / 'Requested horizon from:', lv_requested_from_filter.
  WRITE: / 'Requested horizon to:', lv_requested_to_filter.
  WRITE: / 'Old requested horizon from:', lv_old_requested_from_filter.
  WRITE: / 'Old requested horizon to:', lv_old_requested_to_filter.
  WRITE: / 'New requested horizon from:', lv_new_requested_from_filter.
  WRITE: / 'New requested horizon to:', lv_new_requested_to_filter.
  WRITE: / 'Requested-deadline-only filter:', p_dead.
  WRITE: / 'Old requested-deadline-only filter:', lv_old_deadline_only_filter.
  WRITE: / 'New requested-deadline-only filter:', lv_new_deadline_only_filter.
  WRITE: / 'Requested deadline from:', lv_deadline_from_filter,
           'to:', lv_deadline_to_filter.
  WRITE: / 'Old requested deadline from:', lv_old_deadline_from_filter,
           'to:', lv_old_deadline_to_filter.
  WRITE: / 'New requested deadline from:', lv_new_deadline_from_filter,
           'to:', lv_new_deadline_to_filter.
  WRITE: / 'Requested deadline age from:', lv_deadline_age_from_filter,
           'to:', lv_deadline_age_to_filter.
  WRITE: / 'Old requested deadline age from:', lv_old_age_from_txt,
           'to:', lv_old_age_to_txt.
  WRITE: / 'New requested deadline age from:', lv_new_age_from_txt,
           'to:', lv_new_age_to_txt.
  WRITE: / 'Reconciliation guard:', p_guard.
  WRITE: / 'Old status/strategy:', ls_old_run-status, ls_old_run-strategy,
    'New status/strategy:', ls_new_run-status, ls_new_run-strategy.
  WRITE: / 'Old movement type/shelf life:', ls_old_run-movement_type,
    ls_old_run-min_shelf_life, 'Old safety stock:', ls_old_run-safety_stock,
    'New movement type/shelf life:',
    ls_new_run-movement_type, ls_new_run-min_shelf_life,
    'New safety stock:', ls_new_run-safety_stock.
  WRITE: / 'Old start/finish:', ls_old_run-start_date,
    ls_old_run-start_time, ls_old_run-finish_date,
    ls_old_run-finish_time,
    'New start/finish:', ls_new_run-start_date,
    ls_new_run-start_time, ls_new_run-finish_date,
    ls_new_run-finish_time.
  WRITE: / 'Old requested horizon:', ls_old_run-requested_on_from,
    ls_old_run-requested_on_to,
    'New requested horizon:', ls_new_run-requested_on_from,
    ls_new_run-requested_on_to,
    'Old/new deadlines:', ls_old_run-requested_deadline,
    ls_new_run-requested_deadline.
  WRITE: / 'Old/new deadline age days:', lv_old_deadline_age_text,
    lv_new_deadline_age_text,
    'Delta:', lv_deadline_age_delta_text,
    'Reference date:', lv_deadline_reference_date.
  WRITE: / 'Available old/new:', ls_old_run-available, ls_new_run-available.
  WRITE: / 'Duration seconds old/new:', lv_old_duration_text,
    lv_new_duration_text.
  WRITE: / 'Running age seconds old/new:', lv_old_running_age_text,
    lv_new_running_age_text.
  WRITE: / 'Old message:', ls_old_run-message.
  WRITE: / 'New message:', ls_new_run-message.
  WRITE: / 'Old reconciliation:', lv_old_reconciliation,
    'Snapshot rows:', lines( lt_old ).
  WRITE: / 'Old reconciliation fields:',
    ls_old_reconciliation-mismatch_fields.
  WRITE: / 'Audit unit old/new:', ls_old_run-unit, ls_new_run-unit.
  WRITE: / 'Audit demand count old/new:', ls_old_run-demand_count,
    ls_new_run-demand_count.
  WRITE: / 'Audit full rows old/new:', ls_old_run-full_count,
    ls_new_run-full_count.
  WRITE: / 'Audit partial rows old/new:', ls_old_run-partial_count,
    ls_new_run-partial_count.
  WRITE: / 'Audit unallocated rows old/new:',
    ls_old_run-unallocated_count, ls_new_run-unallocated_count.
  WRITE: / 'Audit outcome counter deltas:', lv_audit_demand_delta,
    lv_audit_full_delta, lv_audit_partial_delta,
    lv_audit_unallocated_delta.
  WRITE: / 'Audit requested old/new:', ls_old_run-requested,
    ls_new_run-requested.
  WRITE: / 'Audit allocated old/new:', ls_old_run-allocated,
    ls_new_run-allocated.
  WRITE: / 'Audit shortage old/new:', ls_old_run-shortage,
    ls_new_run-shortage.
  WRITE: / 'Audit coverage pct old/new:', lv_old_audit_coverage_text,
    lv_new_audit_coverage_text.
  WRITE: / 'Audit shortage pct old/new:',
    lv_old_audit_shortage_pct_text, lv_new_audit_shortage_pct_text.
  WRITE: / 'Audit units match:', lv_audit_units_match.
  WRITE: / 'Audit horizon changed:', lv_audit_horizon_changed.
  WRITE: / 'Audit status/strategy changed:',
    lv_audit_status_changed, lv_audit_strategy_changed.
  WRITE: / 'Audit running changed:', lv_audit_running_changed.
  WRITE: / 'Audit duration delta seconds:',
    lv_audit_duration_delta_text.
  WRITE: / 'Audit running age delta seconds:',
    lv_aud_run_age_delta_text.
  WRITE: / 'Audit running age trend:', lv_aud_run_age_trend.
  WRITE: / 'Audit start/finish delta seconds:',
    lv_audit_start_delta_text, lv_audit_finish_delta_text.
  WRITE: / 'Audit requested/available delta:',
    lv_audit_requested_delta_text, lv_audit_available_delta_text.
  WRITE: / 'Audit allocated/shortage delta:',
    lv_audit_allocated_delta_text, lv_audit_shortage_delta_text.
  WRITE: / 'Audit coverage/shortage pct delta:',
    lv_audit_coverage_delta_text, lv_aud_shrt_pct_delta_text.
  WRITE: / 'Snapshot requested old/new:', lv_old_requested_total,
    lv_new_requested_total.
  WRITE: / 'Snapshot full rows old/new:',
    ls_old_reconciliation-snapshot_full_count,
    ls_new_reconciliation-snapshot_full_count.
  WRITE: / 'Snapshot partial rows old/new:',
    ls_old_reconciliation-snapshot_partial_count,
    ls_new_reconciliation-snapshot_partial_count.
  WRITE: / 'Snapshot unallocated rows old/new:',
    ls_old_reconciliation-snapshot_unallocated_count,
    ls_new_reconciliation-snapshot_unallocated_count.
  WRITE: / 'Snapshot allocated old/new:',
    ls_old_reconciliation-snapshot_allocated,
    ls_new_reconciliation-snapshot_allocated.
  WRITE: / 'Snapshot shortage old/new:',
    ls_old_reconciliation-snapshot_shortage,
    ls_new_reconciliation-snapshot_shortage.
  WRITE: / 'New reconciliation:', lv_new_reconciliation,
    'Snapshot rows:', lines( lt_new ).
  WRITE: / 'Audit reconciliation changed:', lv_recon_status_changed.
  WRITE: / 'Audit reconciliation OK:', lv_recon_both_ok.
  WRITE: / 'Audit reconciliation transition:', lv_recon_transition.
  WRITE: / 'Audit metadata changed:', lv_audit_meta_changed.
  WRITE: / 'Audit metadata change reasons:', lv_audit_meta_reasons.
  WRITE: / 'New reconciliation fields:',
    ls_new_reconciliation-mismatch_fields.
  WRITE: / 'Total matching changes:', lv_total_rows.
  WRITE: / 'Returned changes:', lines( lt_changes ).
  WRITE: / 'Offset:', p_skip, 'Max rows:', p_max.
  WRITE: / 'Has more:', lv_has_more, 'Next offset:', lv_next_offset_text.
  WRITE: / 'Has previous:', lv_has_previous,
    'Previous offset:', lv_previous_offset_text,
    'Page number:', lv_page_number_text,
    'Page count:', lv_page_count_text,
    'Last offset:', lv_last_offset_text.
  IF lt_changes IS INITIAL.
    WRITE: / 'No allocation changes found.'.
    RETURN.
  ENDIF.
  WRITE: / 'Type', 8 'Unit', 15 'Order', 38 'Reasons', 80 'Old status',
    92 'New status', 104 'Old alloc', 118 'New alloc', 132 'Delta alloc',
    148 'Old shortage', 164 'New shortage', 180 'Delta shortage',
    196 'Old coverage %', 214 'New coverage %',
    232 'Old shortage %', 252 'New shortage %',
    272 'Coverage delta %', 292 'Shortage delta %'.
  LOOP AT lt_changes ASSIGNING <ls_change>.
    lv_old_snapshot_coverage_text = 'n/a'.
    lv_new_snapshot_coverage_text = 'n/a'.
    lv_old_snap_shrt_pct_text = 'n/a'.
    lv_new_snap_shrt_pct_text = 'n/a'.
    IF <ls_change>-old_coverage_available = abap_true.
      lv_old_snapshot_coverage_text = zcl_stock_csv=>number(
        <ls_change>-old_coverage ).
    ENDIF.
    IF <ls_change>-new_coverage_available = abap_true.
      lv_new_snapshot_coverage_text = zcl_stock_csv=>number(
        <ls_change>-new_coverage ).
    ENDIF.
    IF <ls_change>-old_shortage_pct_available = abap_true.
      lv_old_snap_shrt_pct_text = zcl_stock_csv=>number(
        <ls_change>-old_shortage_pct ).
    ENDIF.
    IF <ls_change>-new_shortage_pct_available = abap_true.
      lv_new_snap_shrt_pct_text = zcl_stock_csv=>number(
        <ls_change>-new_shortage_pct ).
    ENDIF.
    IF <ls_change>-coverage_delta_available = abap_true.
      lv_snap_cov_delta_text = zcl_stock_csv=>number(
        <ls_change>-coverage_delta ).
    ELSE.
      lv_snap_cov_delta_text = 'n/a'.
    ENDIF.
    IF <ls_change>-shortage_pct_delta_available = abap_true.
      lv_snap_shrt_delta_text = zcl_stock_csv=>number(
        <ls_change>-shortage_pct_delta ).
    ELSE.
      lv_snap_shrt_delta_text = 'n/a'.
    ENDIF.
    WRITE: / <ls_change>-change_type,
      8 <ls_change>-allocation_unit,
      15 <ls_change>-order_id,
      38 <ls_change>-change_reasons,
      80 <ls_change>-old_status,
      92 <ls_change>-new_status,
      104 <ls_change>-old_allocated,
      118 <ls_change>-new_allocated,
      132 <ls_change>-delta_allocated,
      148 <ls_change>-old_shortage,
      164 <ls_change>-new_shortage,
      180 <ls_change>-delta_shortage,
      196 lv_old_snapshot_coverage_text,
      214 lv_new_snapshot_coverage_text,
      232 lv_old_snap_shrt_pct_text,
      252 lv_new_snap_shrt_pct_text,
      272 lv_snap_cov_delta_text,
      292 lv_snap_shrt_delta_text.
  ENDLOOP.
