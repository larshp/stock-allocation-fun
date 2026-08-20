INTERFACE zif_allocation_history_reader PUBLIC.
  CONSTANTS gc_max_rows_with_sentinel TYPE i VALUE 10001.
  TYPES ty_boolean_filter TYPE c LENGTH 1.
  CONSTANTS gc_filter_true TYPE ty_boolean_filter VALUE 'X'.
  CONSTANTS gc_filter_false TYPE ty_boolean_filter VALUE '-'.
  TYPES ty_fill_filter TYPE c LENGTH 1.
  CONSTANTS gc_fill_full TYPE ty_fill_filter VALUE 'F'.
  CONSTANTS gc_fill_partial TYPE ty_fill_filter VALUE 'P'.
  CONSTANTS gc_fill_none TYPE ty_fill_filter VALUE 'N'.

  TYPES ty_entries TYPE STANDARD TABLE OF zstock_algh WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_result,
      is_success TYPE abap_bool,
      message    TYPE string,
      entries    TYPE ty_entries,
    END OF ty_result.

  METHODS read
    IMPORTING
      iv_from_date            TYPE d
      iv_to_date              TYPE d
      iv_from_time            TYPE t OPTIONAL
      iv_to_time              TYPE t OPTIONAL
      iv_requirement_from     TYPE zstock_algh-requirement_date OPTIONAL
      iv_requirement_to       TYPE zstock_algh-requirement_date OPTIONAL
      iv_request_id           TYPE zstock_algh-request_id OPTIONAL
      iv_reservation_id       TYPE zstock_algh-reservation_id OPTIONAL
      iv_prior_reservation_id TYPE zstock_algh-prior_reservation_id OPTIONAL
      iv_material             TYPE zstock_algh-material OPTIONAL
      iv_plant                TYPE zstock_algh-plant OPTIONAL
      iv_storage_location     TYPE zstock_algh-storage_location OPTIONAL
      iv_movement_type        TYPE zstock_algh-movement_type OPTIONAL
      iv_source_unit          TYPE zstock_algh-source_unit OPTIONAL
      iv_unit_of_measure      TYPE zstock_algh-unit_of_measure OPTIONAL
      iv_allocation_strategy  TYPE zstock_algh-allocation_strategy OPTIONAL
      iv_horizon_from         TYPE zstock_algh-horizon_date OPTIONAL
      iv_horizon_to           TYPE zstock_algh-horizon_date OPTIONAL
      iv_partial_filter       TYPE ty_boolean_filter OPTIONAL
      iv_full_batch_filter    TYPE ty_boolean_filter OPTIONAL
      iv_availability_filter  TYPE ty_boolean_filter OPTIONAL
      iv_stock_filter         TYPE ty_boolean_filter OPTIONAL
      iv_shortfall_filter     TYPE ty_boolean_filter OPTIONAL
      iv_fill_filter          TYPE ty_fill_filter OPTIONAL
      iv_cost_center          TYPE zstock_algh-cost_center OPTIONAL
      iv_order_id             TYPE zstock_algh-order_id OPTIONAL
      iv_wbs_element          TYPE zstock_algh-wbs_element OPTIONAL
      iv_sales_order          TYPE zstock_algh-sales_order OPTIONAL
      iv_sales_order_item     TYPE zstock_algh-sales_order_item OPTIONAL
      iv_asset_number         TYPE zstock_algh-asset_number OPTIONAL
      iv_asset_subnumber      TYPE zstock_algh-asset_subnumber OPTIONAL
      iv_network_id           TYPE zstock_algh-network_id OPTIONAL
      iv_network_activity     TYPE zstock_algh-network_activity OPTIONAL
      iv_allocation_status    TYPE zstock_algh-allocation_status OPTIONAL
      iv_posting_status       TYPE zstock_algh-posting_status OPTIONAL
      iv_run_mode             TYPE zstock_algh-run_mode OPTIONAL
      iv_run_id               TYPE zstock_algh-run_id OPTIONAL
      iv_decision_code        TYPE zstock_algh-decision_code OPTIONAL
      iv_logged_by            TYPE zstock_algh-logged_by OPTIONAL
      iv_max_rows             TYPE i
    RETURNING
      VALUE(rs_result)        TYPE ty_result.
ENDINTERFACE.
