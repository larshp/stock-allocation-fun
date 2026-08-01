INTERFACE zif_allocation_sink PUBLIC.
  METHODS get_allocations
    IMPORTING
      iv_material                   TYPE zif_stock_allocation=>ty_material
      iv_plant                      TYPE zif_stock_allocation=>ty_plant
      iv_storage_location           TYPE zif_stock_allocation=>ty_storage_location
      iv_batch                      TYPE zif_stock_allocation=>ty_batch OPTIONAL
      iv_unit                       TYPE zif_stock_allocation=>ty_unit OPTIONAL
      iv_run_id                     TYPE zif_stock_allocation=>ty_run_id OPTIONAL
      iv_status                     TYPE zif_stock_allocation=>ty_allocation_status OPTIONAL
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
      iv_reservation_date_from      TYPE d OPTIONAL
      iv_reservation_date_to        TYPE d OPTIONAL
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
      iv_max_rows                   TYPE i OPTIONAL
      iv_sort_by_priority           TYPE abap_bool OPTIONAL
      iv_sort_by_requested_date     TYPE abap_bool OPTIONAL
      iv_sort_by_reservation_date   TYPE abap_bool OPTIONAL
      iv_sort_by_shortage           TYPE abap_bool OPTIONAL
      iv_sort_by_coverage           TYPE abap_bool OPTIONAL
      iv_sort_by_requested_quantity TYPE abap_bool OPTIONAL
      iv_sort_by_allocated_quantity TYPE abap_bool OPTIONAL
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
