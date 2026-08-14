INTERFACE zif_allocation_sink PUBLIC.
  METHODS get_allocations
    IMPORTING
      iv_material                   TYPE zif_stock_allocation=>ty_material
      iv_plant                      TYPE zif_stock_allocation=>ty_plant
      iv_storage_location           TYPE zif_stock_allocation=>ty_storage_location
      iv_batch                      TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit                       TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_run_id                     TYPE zif_stock_allocation=>ty_run_id OPTIONAL
      iv_run_id_contains            TYPE zif_stock_allocation=>ty_run_id OPTIONAL
      iv_strategy                   TYPE zif_allocation_audit=>ty_strategy OPTIONAL
      iv_legacy_strategy            TYPE abap_bool OPTIONAL
      iv_allocation_movement_type   TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_min_shelf_life             TYPE i OPTIONAL
      iv_safety_filter              TYPE abap_bool OPTIONAL
      iv_safety_from                TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_safety_to                  TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_status                     TYPE zif_stock_allocation=>ty_allocation_status OPTIONAL
      iv_run_status                 TYPE zif_allocation_audit=>ty_run_status OPTIONAL
      iv_preview_filter             TYPE zif_allocation_audit=>ty_preview_filter OPTIONAL
      iv_run_demand_from            TYPE i OPTIONAL
      iv_run_demand_to              TYPE i OPTIONAL
      iv_run_available_from         TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_run_available_to           TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_run_duration_from          TYPE i OPTIONAL
      iv_run_duration_to            TYPE i OPTIONAL
      iv_run_message_contains       TYPE zif_allocation_audit=>ty_message OPTIONAL
      iv_run_message_only           TYPE abap_bool OPTIONAL
      iv_sales_document             TYPE zif_stock_allocation=>ty_sales_document OPTIONAL
      iv_sales_document_type        TYPE zif_stock_allocation=>ty_sales_document_type OPTIONAL
      iv_sales_item                 TYPE zif_stock_allocation=>ty_sales_item OPTIONAL
      iv_schedule_line              TYPE zif_stock_allocation=>ty_schedule_line OPTIONAL
      iv_order_unit                 TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_order_id                   TYPE zif_stock_allocation=>ty_order_id OPTIONAL
      iv_reservation_id             TYPE zif_stock_allocation=>ty_order_id OPTIONAL
      iv_movement_type              TYPE zif_stock_allocation=>ty_movement_type OPTIONAL
      iv_reservation_unit           TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_reserved_only              TYPE abap_bool OPTIONAL
      iv_unreserved_only            TYPE abap_bool OPTIONAL
      iv_shortage_only              TYPE abap_bool OPTIONAL
      iv_overdue_only               TYPE abap_bool OPTIONAL
      iv_overdue_date               TYPE d OPTIONAL
      iv_deadline_only              TYPE abap_bool OPTIONAL
      iv_run_requested_on_from      TYPE d OPTIONAL
      iv_run_requested_on_to        TYPE d OPTIONAL
      iv_run_deadline_from          TYPE d OPTIONAL
      iv_run_deadline_to            TYPE d OPTIONAL
      iv_run_deadline_age_from      TYPE i OPTIONAL
      iv_run_deadline_age_to        TYPE i OPTIONAL
      iv_run_deadline_age_date      TYPE d OPTIONAL
      iv_run_start_date_from        TYPE d OPTIONAL
      iv_run_start_date_to          TYPE d OPTIONAL
      iv_run_finish_date_from       TYPE d OPTIONAL
      iv_run_finish_date_to         TYPE d OPTIONAL
      iv_reservation_date_from      TYPE d OPTIONAL
      iv_reservation_date_to        TYPE d OPTIONAL
      iv_reservation_age_from       TYPE i OPTIONAL
      iv_reservation_age_to         TYPE i OPTIONAL
      iv_requested_on_from          TYPE d OPTIONAL
      iv_requested_on_to            TYPE d OPTIONAL
      iv_priority_from              TYPE zif_stock_allocation=>ty_priority OPTIONAL
      iv_priority_to                TYPE zif_stock_allocation=>ty_priority OPTIONAL
      iv_shortage_from              TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_shortage_to                TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_requested_quantity_from    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_requested_quantity_to      TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_allocated_quantity_from    TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_allocated_quantity_to      TYPE zif_stock_allocation=>ty_quantity OPTIONAL
      iv_coverage_from              TYPE zif_allocation_audit=>ty_coverage OPTIONAL
      iv_coverage_to                TYPE zif_allocation_audit=>ty_coverage OPTIONAL
      iv_shortage_pct_from          TYPE zif_allocation_audit=>ty_coverage OPTIONAL
      iv_shortage_pct_to            TYPE zif_allocation_audit=>ty_coverage OPTIONAL
      iv_max_rows                   TYPE i OPTIONAL
      iv_sort_by_priority           TYPE abap_bool OPTIONAL
      iv_sort_by_status             TYPE abap_bool OPTIONAL
      iv_sort_by_requested_date     TYPE abap_bool OPTIONAL
      iv_sort_by_reservation_date   TYPE abap_bool OPTIONAL
      iv_sort_by_shortage           TYPE abap_bool OPTIONAL
      iv_sort_by_coverage           TYPE abap_bool OPTIONAL
      iv_sort_by_shrt_pct           TYPE abap_bool OPTIONAL
      iv_sort_by_demand_count       TYPE abap_bool OPTIONAL
      iv_sort_by_deadline_age       TYPE abap_bool OPTIONAL
      iv_sort_by_requested_deadline TYPE abap_bool OPTIONAL
      iv_sort_by_audit_duration     TYPE abap_bool OPTIONAL
      iv_sort_by_requested_quantity TYPE abap_bool OPTIONAL
      iv_sort_by_allocated_quantity TYPE abap_bool OPTIONAL
      iv_offset                     TYPE i OPTIONAL
    EXPORTING
      ev_total_rows                 TYPE i
    RETURNING
      VALUE(rt_demands)             TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
  METHODS save_allocations
    IMPORTING
      iv_material         TYPE zif_stock_allocation=>ty_material
      iv_plant            TYPE zif_stock_allocation=>ty_plant
      iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
      iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_run_id           TYPE zif_stock_allocation=>ty_run_id
      iv_unit             TYPE zif_stock_allocation=>ty_unit
      it_demands          TYPE zif_stock_allocation=>tt_demands
    RAISING
      zcx_stock_allocation.
ENDINTERFACE.
