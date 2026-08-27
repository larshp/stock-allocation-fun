CLASS zcl_allocation_log_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines TYPE STANDARD TABLE OF string WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result,
        is_success    TYPE abap_bool,
        exported_rows TYPE i,
        message       TYPE string,
        lines         TYPE ty_lines,
      END OF ty_result.

    CONSTANTS gc_default_max_rows TYPE i VALUE 1000.
    CONSTANTS gc_max_rows TYPE i VALUE 10000.

    METHODS constructor
      IMPORTING
        io_reader TYPE REF TO zif_allocation_history_reader.

    CLASS-METHODS create_sap
      RETURNING
        VALUE(ro_export) TYPE REF TO zcl_allocation_log_export.

    METHODS run
      IMPORTING
        iv_from_date            TYPE d OPTIONAL
        iv_to_date              TYPE d OPTIONAL
        iv_from_time            TYPE t OPTIONAL
        iv_to_time              TYPE t OPTIONAL
        iv_requirement_from     TYPE zstock_algh-requirement_date OPTIONAL
        iv_requirement_to       TYPE zstock_algh-requirement_date OPTIONAL
        iv_log_uuid             TYPE zstock_algh-log_uuid OPTIONAL
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
        iv_partial_filter       TYPE zif_allocation_history_reader=>ty_boolean_filter OPTIONAL
        iv_full_batch_filter    TYPE zif_allocation_history_reader=>ty_boolean_filter OPTIONAL
        iv_availability_filter  TYPE zif_allocation_history_reader=>ty_boolean_filter OPTIONAL
        iv_stock_filter         TYPE zif_allocation_history_reader=>ty_boolean_filter OPTIONAL
        iv_shortfall_filter     TYPE zif_allocation_history_reader=>ty_boolean_filter OPTIONAL
        iv_fill_filter          TYPE zif_allocation_history_reader=>ty_fill_filter OPTIONAL
        iv_fill_pct_from        TYPE zstock_algh-fill_pct OPTIONAL
        iv_fill_pct_to          TYPE zstock_algh-fill_pct OPTIONAL
        iv_min_fill_from        TYPE zstock_algh-minimum_fill_pct OPTIONAL
        iv_min_fill_to          TYPE zstock_algh-minimum_fill_pct OPTIONAL
        iv_source_qty_from      TYPE zstock_algh-source_requested_qty OPTIONAL
        iv_source_qty_to        TYPE zstock_algh-source_requested_qty OPTIONAL
        iv_available_qty_from   TYPE zstock_algh-available_qty OPTIONAL
        iv_available_qty_to     TYPE zstock_algh-available_qty OPTIONAL
        iv_shortfall_qty_from   TYPE zstock_algh-shortfall_qty OPTIONAL
        iv_shortfall_qty_to     TYPE zstock_algh-shortfall_qty OPTIONAL
        iv_priority_from        TYPE zstock_algh-priority OPTIONAL
        iv_priority_to          TYPE zstock_algh-priority OPTIONAL
        iv_requested_qty_from   TYPE zstock_algh-requested_qty OPTIONAL
        iv_requested_qty_to     TYPE zstock_algh-requested_qty OPTIONAL
        iv_allocated_qty_from   TYPE zstock_algh-allocated_qty OPTIONAL
        iv_allocated_qty_to     TYPE zstock_algh-allocated_qty OPTIONAL
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
        iv_log_message          TYPE zstock_algh-log_message OPTIONAL
        iv_logged_by            TYPE zstock_algh-logged_by OPTIONAL
        iv_max_rows             TYPE i DEFAULT gc_default_max_rows
        iv_today                TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)        TYPE ty_result.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO zif_allocation_history_reader.

    METHODS quote
      IMPORTING
        iv_value         TYPE string
      RETURNING
        VALUE(rv_quoted) TYPE string.

    METHODS format_entry
      IMPORTING
        is_entry       TYPE zstock_algh
      RETURNING
        VALUE(rv_line) TYPE string.
ENDCLASS.

CLASS zcl_allocation_log_export IMPLEMENTATION.
  METHOD constructor.
    mo_reader = io_reader.
  ENDMETHOD.

  METHOD create_sap.
    DATA(lo_reader) = NEW zcl_allocation_history_reader( ).
    ro_export = NEW #( lo_reader ).
  ENDMETHOD.

  METHOD run.
    DATA(lv_today) = COND d(
      WHEN iv_today IS INITIAL
      THEN sy-datum
      ELSE iv_today ).
    DATA(lv_to_date) = COND d(
      WHEN iv_to_date IS INITIAL
      THEN lv_today
      ELSE iv_to_date ).
    DATA(lv_to_time) = COND t(
      WHEN iv_to_time IS INITIAL
      THEN '235959'
      ELSE iv_to_time ).
    DATA lv_from_date TYPE d.
    IF iv_from_date IS INITIAL.
      lv_from_date = lv_to_date - 29.
    ELSE.
      lv_from_date = iv_from_date.
    ENDIF.

    IF lv_from_date > lv_to_date.
      rs_result-message = 'Export start date must not exceed end date'.
      RETURN.
    ENDIF.
    IF lv_from_date = lv_to_date AND iv_from_time > lv_to_time.
      rs_result-message = 'Export start time must not exceed end time'.
      RETURN.
    ENDIF.
    IF iv_requirement_from IS NOT INITIAL
        AND iv_requirement_to IS NOT INITIAL
        AND iv_requirement_from > iv_requirement_to.
      rs_result-message =
        'Requirement start date must not exceed end date'.
      RETURN.
    ENDIF.
    IF iv_horizon_from IS NOT INITIAL
        AND iv_horizon_to IS NOT INITIAL
        AND iv_horizon_from > iv_horizon_to.
      rs_result-message = 'Horizon start date must not exceed end date'.
      RETURN.
    ENDIF.
    IF ( iv_partial_filter IS NOT INITIAL
          AND iv_partial_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_partial_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_full_batch_filter IS NOT INITIAL
          AND iv_full_batch_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_full_batch_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_availability_filter IS NOT INITIAL
          AND iv_availability_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_availability_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_stock_filter IS NOT INITIAL
          AND iv_stock_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_stock_filter
            <> zif_allocation_history_reader=>gc_filter_false )
        OR ( iv_shortfall_filter IS NOT INITIAL
          AND iv_shortfall_filter
            <> zif_allocation_history_reader=>gc_filter_true
          AND iv_shortfall_filter
            <> zif_allocation_history_reader=>gc_filter_false ).
      rs_result-message = 'Policy filters must be blank, X, or -'.
      RETURN.
    ENDIF.
    IF ( iv_stock_filter IS NOT INITIAL
          OR iv_available_qty_from IS NOT INITIAL
          OR iv_available_qty_to IS NOT INITIAL )
        AND iv_availability_filter
          = zif_allocation_history_reader=>gc_filter_false.
      rs_result-message = 'Availability filters conflict'.
      RETURN.
    ENDIF.
    IF iv_fill_filter IS NOT INITIAL
        AND iv_fill_filter
          <> zif_allocation_history_reader=>gc_fill_full
        AND iv_fill_filter
          <> zif_allocation_history_reader=>gc_fill_partial
        AND iv_fill_filter
          <> zif_allocation_history_reader=>gc_fill_none.
      rs_result-message = 'Fill filter must be blank, F, P, or N'.
      RETURN.
    ENDIF.
    IF iv_fill_pct_from < 0
        OR iv_fill_pct_from > 100
        OR iv_fill_pct_to < 0
        OR iv_fill_pct_to > 100
        OR ( iv_fill_pct_from IS NOT INITIAL
          AND iv_fill_pct_to IS NOT INITIAL
          AND iv_fill_pct_from > iv_fill_pct_to ).
      rs_result-message = 'Fill percentage range is invalid'.
      RETURN.
    ENDIF.
    IF iv_min_fill_from < 0
        OR iv_min_fill_from > 100
        OR iv_min_fill_to < 0
        OR iv_min_fill_to > 100
        OR ( iv_min_fill_from IS NOT INITIAL
          AND iv_min_fill_to IS NOT INITIAL
          AND iv_min_fill_from > iv_min_fill_to ).
      rs_result-message = 'Minimum fill range is invalid'.
      RETURN.
    ENDIF.
    IF iv_source_qty_from < 0
        OR iv_source_qty_to < 0
        OR iv_available_qty_from < 0
        OR iv_available_qty_to < 0
        OR iv_shortfall_qty_from < 0
        OR iv_shortfall_qty_to < 0
        OR ( iv_source_qty_from IS NOT INITIAL
          AND iv_source_qty_to IS NOT INITIAL
          AND iv_source_qty_from > iv_source_qty_to )
        OR ( iv_available_qty_from IS NOT INITIAL
          AND iv_available_qty_to IS NOT INITIAL
          AND iv_available_qty_from > iv_available_qty_to )
        OR ( iv_shortfall_qty_from IS NOT INITIAL
          AND iv_shortfall_qty_to IS NOT INITIAL
          AND iv_shortfall_qty_from > iv_shortfall_qty_to ).
      rs_result-message = 'Quantity range is invalid'.
      RETURN.
    ENDIF.
    IF iv_priority_from < 0
        OR iv_priority_to < 0
        OR iv_requested_qty_from < 0
        OR iv_requested_qty_to < 0
        OR iv_allocated_qty_from < 0
        OR iv_allocated_qty_to < 0
        OR ( iv_priority_from IS NOT INITIAL
          AND iv_priority_to IS NOT INITIAL
          AND iv_priority_from > iv_priority_to )
        OR ( iv_requested_qty_from IS NOT INITIAL
          AND iv_requested_qty_to IS NOT INITIAL
          AND iv_requested_qty_from > iv_requested_qty_to )
        OR ( iv_allocated_qty_from IS NOT INITIAL
          AND iv_allocated_qty_to IS NOT INITIAL
          AND iv_allocated_qty_from > iv_allocated_qty_to ).
      rs_result-message = 'Numeric filters are invalid'.
      RETURN.
    ENDIF.
    IF iv_max_rows <= 0 OR iv_max_rows > gc_max_rows.
      rs_result-message = 'Export row limit must be between 1 and 10000'.
      RETURN.
    ENDIF.
    IF iv_run_mode IS NOT INITIAL
        AND iv_run_mode <> 'P'
        AND iv_run_mode <> 'S'
        AND iv_run_mode <> 'I'.
      rs_result-message = 'Export run mode must be P, S, I, or blank'.
      RETURN.
    ENDIF.

    DATA(lv_read_limit) = iv_max_rows + 1.
    DATA(ls_read_result) = mo_reader->read(
      iv_from_date            = lv_from_date
      iv_to_date              = lv_to_date
      iv_from_time            = iv_from_time
      iv_to_time              = lv_to_time
      iv_requirement_from     = iv_requirement_from
      iv_requirement_to       = iv_requirement_to
      iv_log_uuid             = iv_log_uuid
      iv_request_id           = iv_request_id
      iv_reservation_id       = iv_reservation_id
      iv_prior_reservation_id = iv_prior_reservation_id
      iv_material             = iv_material
      iv_plant                = iv_plant
      iv_storage_location     = iv_storage_location
      iv_movement_type        = iv_movement_type
      iv_source_unit          = iv_source_unit
      iv_unit_of_measure      = iv_unit_of_measure
      iv_allocation_strategy  = iv_allocation_strategy
      iv_horizon_from         = iv_horizon_from
      iv_horizon_to           = iv_horizon_to
      iv_partial_filter       = iv_partial_filter
      iv_full_batch_filter    = iv_full_batch_filter
      iv_availability_filter  = iv_availability_filter
      iv_stock_filter         = iv_stock_filter
      iv_shortfall_filter     = iv_shortfall_filter
      iv_fill_filter          = iv_fill_filter
      iv_fill_pct_from        = iv_fill_pct_from
      iv_fill_pct_to          = iv_fill_pct_to
      iv_min_fill_from        = iv_min_fill_from
      iv_min_fill_to          = iv_min_fill_to
      iv_source_qty_from      = iv_source_qty_from
      iv_source_qty_to        = iv_source_qty_to
      iv_available_qty_from   = iv_available_qty_from
      iv_available_qty_to     = iv_available_qty_to
      iv_shortfall_qty_from   = iv_shortfall_qty_from
      iv_shortfall_qty_to     = iv_shortfall_qty_to
      iv_priority_from        = iv_priority_from
      iv_priority_to          = iv_priority_to
      iv_requested_qty_from   = iv_requested_qty_from
      iv_requested_qty_to     = iv_requested_qty_to
      iv_allocated_qty_from   = iv_allocated_qty_from
      iv_allocated_qty_to     = iv_allocated_qty_to
      iv_cost_center          = iv_cost_center
      iv_order_id             = iv_order_id
      iv_wbs_element          = iv_wbs_element
      iv_sales_order          = iv_sales_order
      iv_sales_order_item     = iv_sales_order_item
      iv_asset_number         = iv_asset_number
      iv_asset_subnumber      = iv_asset_subnumber
      iv_network_id           = iv_network_id
      iv_network_activity     = iv_network_activity
      iv_allocation_status    = iv_allocation_status
      iv_posting_status       = iv_posting_status
      iv_run_mode             = iv_run_mode
      iv_run_id               = iv_run_id
      iv_decision_code        = iv_decision_code
      iv_log_message          = iv_log_message
      iv_logged_by            = iv_logged_by
      iv_max_rows             = lv_read_limit ).
    IF ls_read_result-is_success <> abap_true.
      rs_result-message = COND string(
        WHEN ls_read_result-is_success = abap_false
        THEN ls_read_result-message
        ELSE 'Audit history reader returned invalid state' ).
      RETURN.
    ENDIF.
    IF lines( ls_read_result-entries ) > iv_max_rows.
      rs_result-message = 'Export row limit exceeded; narrow the filters'.
      RETURN.
    ENDIF.

    LOOP AT ls_read_result-entries INTO DATA(ls_scoped_entry).
      IF ls_scoped_entry-logged_on < lv_from_date
          OR ls_scoped_entry-logged_on > lv_to_date
          OR ( ls_scoped_entry-logged_on = lv_from_date
            AND ls_scoped_entry-logged_at < iv_from_time )
          OR ( ls_scoped_entry-logged_on = lv_to_date
            AND ls_scoped_entry-logged_at > lv_to_time )
          OR ( iv_requirement_from IS NOT INITIAL
            AND ls_scoped_entry-requirement_date < iv_requirement_from )
          OR ( iv_requirement_to IS NOT INITIAL
            AND ls_scoped_entry-requirement_date > iv_requirement_to )
          OR ( iv_horizon_from IS NOT INITIAL
            AND ls_scoped_entry-horizon_date < iv_horizon_from )
          OR ( iv_horizon_to IS NOT INITIAL
            AND ls_scoped_entry-horizon_date > iv_horizon_to ).
        rs_result-message = 'Audit history reader returned out-of-scope rows'.
        RETURN.
      ENDIF.
      IF ( iv_log_uuid IS NOT INITIAL
            AND ls_scoped_entry-log_uuid <> iv_log_uuid )
          OR ( iv_request_id IS NOT INITIAL
            AND ls_scoped_entry-request_id <> iv_request_id )
          OR ( iv_reservation_id IS NOT INITIAL
            AND ls_scoped_entry-reservation_id <> iv_reservation_id )
          OR ( iv_prior_reservation_id IS NOT INITIAL
            AND ls_scoped_entry-prior_reservation_id
              <> iv_prior_reservation_id )
          OR ( iv_material IS NOT INITIAL
            AND ls_scoped_entry-material <> iv_material )
          OR ( iv_plant IS NOT INITIAL
            AND ls_scoped_entry-plant <> iv_plant )
          OR ( iv_storage_location IS NOT INITIAL
            AND ls_scoped_entry-storage_location <> iv_storage_location )
          OR ( iv_movement_type IS NOT INITIAL
            AND ls_scoped_entry-movement_type <> iv_movement_type )
          OR ( iv_source_unit IS NOT INITIAL
            AND ls_scoped_entry-source_unit <> iv_source_unit )
          OR ( iv_unit_of_measure IS NOT INITIAL
            AND ls_scoped_entry-unit_of_measure <> iv_unit_of_measure )
          OR ( iv_allocation_strategy IS NOT INITIAL
            AND ls_scoped_entry-allocation_strategy
              <> iv_allocation_strategy )
          OR ( iv_cost_center IS NOT INITIAL
            AND ls_scoped_entry-cost_center <> iv_cost_center )
          OR ( iv_order_id IS NOT INITIAL
            AND ls_scoped_entry-order_id <> iv_order_id )
          OR ( iv_wbs_element IS NOT INITIAL
            AND ls_scoped_entry-wbs_element <> iv_wbs_element )
          OR ( iv_sales_order IS NOT INITIAL
            AND ls_scoped_entry-sales_order <> iv_sales_order )
          OR ( iv_sales_order_item IS NOT INITIAL
            AND ls_scoped_entry-sales_order_item <> iv_sales_order_item )
          OR ( iv_asset_number IS NOT INITIAL
            AND ls_scoped_entry-asset_number <> iv_asset_number )
          OR ( iv_asset_subnumber IS NOT INITIAL
            AND ls_scoped_entry-asset_subnumber <> iv_asset_subnumber )
          OR ( iv_network_id IS NOT INITIAL
            AND ls_scoped_entry-network_id <> iv_network_id )
          OR ( iv_network_activity IS NOT INITIAL
            AND ls_scoped_entry-network_activity <> iv_network_activity )
          OR ( iv_allocation_status IS NOT INITIAL
            AND ls_scoped_entry-allocation_status <> iv_allocation_status )
          OR ( iv_posting_status IS NOT INITIAL
            AND ls_scoped_entry-posting_status <> iv_posting_status )
          OR ( iv_run_mode IS NOT INITIAL
            AND ls_scoped_entry-run_mode <> iv_run_mode )
          OR ( iv_run_id IS NOT INITIAL
            AND ls_scoped_entry-run_id <> iv_run_id )
          OR ( iv_decision_code IS NOT INITIAL
            AND ls_scoped_entry-decision_code <> iv_decision_code )
          OR ( iv_log_message IS NOT INITIAL
            AND ls_scoped_entry-log_message <> iv_log_message )
          OR ( iv_logged_by IS NOT INITIAL
            AND ls_scoped_entry-logged_by <> iv_logged_by ).
        rs_result-message = 'Audit history reader returned out-of-scope rows'.
        RETURN.
      ENDIF.
      IF ( iv_partial_filter IS NOT INITIAL
            AND ls_scoped_entry-allow_partial <> COND abap_bool(
              WHEN iv_partial_filter
                = zif_allocation_history_reader=>gc_filter_true
              THEN abap_true
              ELSE abap_false ) )
          OR ( iv_full_batch_filter IS NOT INITIAL
            AND ls_scoped_entry-require_full_batch <> COND abap_bool(
              WHEN iv_full_batch_filter
                = zif_allocation_history_reader=>gc_filter_true
              THEN abap_true
              ELSE abap_false ) )
          OR ( iv_availability_filter IS NOT INITIAL
            AND ls_scoped_entry-availability_checked <> COND abap_bool(
              WHEN iv_availability_filter
                = zif_allocation_history_reader=>gc_filter_true
              THEN abap_true
              ELSE abap_false ) )
          OR ( ( iv_stock_filter IS NOT INITIAL
              OR iv_available_qty_from IS NOT INITIAL
              OR iv_available_qty_to IS NOT INITIAL )
            AND ls_scoped_entry-availability_checked <> abap_true )
          OR ( iv_stock_filter
              = zif_allocation_history_reader=>gc_filter_true
            AND ls_scoped_entry-available_qty <= 0 )
          OR ( iv_stock_filter
              = zif_allocation_history_reader=>gc_filter_false
            AND ls_scoped_entry-available_qty <> 0 )
          OR ( iv_shortfall_filter
              = zif_allocation_history_reader=>gc_filter_true
            AND ls_scoped_entry-shortfall_qty <= 0 )
          OR ( iv_shortfall_filter
              = zif_allocation_history_reader=>gc_filter_false
            AND ls_scoped_entry-shortfall_qty <> 0 )
          OR ( iv_fill_filter
              = zif_allocation_history_reader=>gc_fill_full
            AND ls_scoped_entry-fill_pct <> 100 )
          OR ( iv_fill_filter
              = zif_allocation_history_reader=>gc_fill_partial
            AND ( ls_scoped_entry-fill_pct <= 0
              OR ls_scoped_entry-fill_pct >= 100 ) )
          OR ( iv_fill_filter
              = zif_allocation_history_reader=>gc_fill_none
            AND ls_scoped_entry-fill_pct <> 0 ).
        rs_result-message = 'Audit history reader returned out-of-scope rows'.
        RETURN.
      ENDIF.
      IF ( iv_fill_pct_from IS NOT INITIAL
            AND ls_scoped_entry-fill_pct < iv_fill_pct_from )
          OR ( iv_fill_pct_to IS NOT INITIAL
            AND ls_scoped_entry-fill_pct > iv_fill_pct_to )
          OR ( iv_min_fill_from IS NOT INITIAL
            AND ls_scoped_entry-minimum_fill_pct < iv_min_fill_from )
          OR ( iv_min_fill_to IS NOT INITIAL
            AND ls_scoped_entry-minimum_fill_pct > iv_min_fill_to )
          OR ( iv_source_qty_from IS NOT INITIAL
            AND ls_scoped_entry-source_requested_qty < iv_source_qty_from )
          OR ( iv_source_qty_to IS NOT INITIAL
            AND ls_scoped_entry-source_requested_qty > iv_source_qty_to )
          OR ( iv_available_qty_from IS NOT INITIAL
            AND ls_scoped_entry-available_qty < iv_available_qty_from )
          OR ( iv_available_qty_to IS NOT INITIAL
            AND ls_scoped_entry-available_qty > iv_available_qty_to )
          OR ( iv_shortfall_qty_from IS NOT INITIAL
            AND ls_scoped_entry-shortfall_qty < iv_shortfall_qty_from )
          OR ( iv_shortfall_qty_to IS NOT INITIAL
            AND ls_scoped_entry-shortfall_qty > iv_shortfall_qty_to )
          OR ( iv_priority_from IS NOT INITIAL
            AND ls_scoped_entry-priority < iv_priority_from )
          OR ( iv_priority_to IS NOT INITIAL
            AND ls_scoped_entry-priority > iv_priority_to )
          OR ( iv_requested_qty_from IS NOT INITIAL
            AND ls_scoped_entry-requested_qty < iv_requested_qty_from )
          OR ( iv_requested_qty_to IS NOT INITIAL
            AND ls_scoped_entry-requested_qty > iv_requested_qty_to )
          OR ( iv_allocated_qty_from IS NOT INITIAL
            AND ls_scoped_entry-allocated_qty < iv_allocated_qty_from )
          OR ( iv_allocated_qty_to IS NOT INITIAL
            AND ls_scoped_entry-allocated_qty > iv_allocated_qty_to ).
        rs_result-message = 'Audit history reader returned out-of-scope rows'.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA(lv_header) =
      'LOGGED_ON;LOGGED_AT;LOG_UUID;RUN_ID;REQUEST_ID;RUN_MODE;'
      && 'MATERIAL;PLANT;STORAGE_LOCATION;MOVEMENT_TYPE;REQUIREMENT_DATE;'
      && 'MINIMUM_FILL_PCT;PRIORITY;ALLOW_PARTIAL;ALLOCATION_STRATEGY;HORIZON_DATE;'
      && 'REQUIRE_FULL_BATCH;COST_CENTER;ORDER_ID;WBS_ELEMENT;'
      && 'SALES_ORDER;SALES_ORDER_ITEM;ASSET_NUMBER;ASSET_SUBNUMBER;'
      && 'NETWORK_ID;NETWORK_ACTIVITY;'
      && 'ALLOCATION_STATUS;DECISION_CODE;POSTING_STATUS;'
      && 'AVAILABILITY_CHECKED;AVAILABLE_QTY;SOURCE_REQUESTED_QTY;SOURCE_UNIT;'
      && 'REQUESTED_QTY;ALLOCATED_QTY;SHORTFALL_QTY;FILL_PCT;UNIT_OF_MEASURE;'
      && 'RESERVATION_ID;PRIOR_RESERVATION_ID;LOG_MESSAGE;LOGGED_BY'.
    APPEND lv_header TO rs_result-lines.
    LOOP AT ls_read_result-entries INTO DATA(ls_entry).
      APPEND format_entry( ls_entry ) TO rs_result-lines.
    ENDLOOP.

    rs_result-is_success = abap_true.
    rs_result-exported_rows = lines( ls_read_result-entries ).
    rs_result-message = 'Audit history export completed'.
  ENDMETHOD.

  METHOD quote.
    rv_quoted = iv_value.
    IF rv_quoted IS NOT INITIAL.
      DATA(lv_first_character) = rv_quoted(1).
      IF lv_first_character = '='
          OR lv_first_character = '+'
          OR lv_first_character = '-'
          OR lv_first_character = '@'
          OR lv_first_character = cl_abap_char_utilities=>horizontal_tab
          OR lv_first_character = cl_abap_char_utilities=>newline
          OR lv_first_character = cl_abap_char_utilities=>cr_lf(1).
        rv_quoted = `'` && rv_quoted.
      ENDIF.
    ENDIF.
    REPLACE ALL OCCURRENCES OF `"` IN rv_quoted WITH `""`.
    rv_quoted = `"` && rv_quoted && `"`.
  ENDMETHOD.

  METHOD format_entry.
    DATA(lv_uuid) = |{ is_entry-log_uuid }|.
    DATA(lv_available_quantity) = |{ is_entry-available_qty }|.
    DATA(lv_source_quantity) = |{ is_entry-source_requested_qty }|.
    DATA(lv_minimum_fill_pct) = |{ is_entry-minimum_fill_pct }|.
    DATA(lv_priority) = |{ is_entry-priority }|.
    DATA(lv_requested_quantity) = |{ is_entry-requested_qty }|.
    DATA(lv_quantity) = |{ is_entry-allocated_qty }|.
    DATA(lv_shortfall_quantity) = |{ is_entry-shortfall_qty }|.
    DATA(lv_fill_pct) = |{ is_entry-fill_pct }|.
    CONDENSE lv_available_quantity NO-GAPS.
    CONDENSE lv_source_quantity NO-GAPS.
    CONDENSE lv_minimum_fill_pct NO-GAPS.
    CONDENSE lv_priority NO-GAPS.
    CONDENSE lv_requested_quantity NO-GAPS.
    CONDENSE lv_quantity NO-GAPS.
    CONDENSE lv_shortfall_quantity NO-GAPS.
    CONDENSE lv_fill_pct NO-GAPS.

    rv_line = quote( CONV string( is_entry-logged_on ) )
      && ';' && quote( CONV string( is_entry-logged_at ) )
      && ';' && quote( lv_uuid )
      && ';' && quote( CONV string( is_entry-run_id ) )
      && ';' && quote( CONV string( is_entry-request_id ) )
      && ';' && quote( CONV string( is_entry-run_mode ) )
      && ';' && quote( CONV string( is_entry-material ) )
      && ';' && quote( CONV string( is_entry-plant ) )
      && ';' && quote( CONV string( is_entry-storage_location ) )
      && ';' && quote( CONV string( is_entry-movement_type ) )
      && ';' && quote( CONV string( is_entry-requirement_date ) )
      && ';' && quote( lv_minimum_fill_pct )
      && ';' && quote( lv_priority )
      && ';' && quote( CONV string( is_entry-allow_partial ) )
      && ';' && quote( CONV string( is_entry-allocation_strategy ) )
      && ';' && quote( CONV string( is_entry-horizon_date ) )
      && ';' && quote( CONV string( is_entry-require_full_batch ) )
      && ';' && quote( CONV string( is_entry-cost_center ) )
      && ';' && quote( CONV string( is_entry-order_id ) )
      && ';' && quote( CONV string( is_entry-wbs_element ) )
      && ';' && quote( CONV string( is_entry-sales_order ) )
      && ';' && quote( CONV string( is_entry-sales_order_item ) )
      && ';' && quote( CONV string( is_entry-asset_number ) )
      && ';' && quote( CONV string( is_entry-asset_subnumber ) )
      && ';' && quote( CONV string( is_entry-network_id ) )
      && ';' && quote( CONV string( is_entry-network_activity ) )
      && ';' && quote( CONV string( is_entry-allocation_status ) )
      && ';' && quote( CONV string( is_entry-decision_code ) )
      && ';' && quote( CONV string( is_entry-posting_status ) )
      && ';' && quote( CONV string( is_entry-availability_checked ) )
      && ';' && quote( lv_available_quantity )
      && ';' && quote( lv_source_quantity )
      && ';' && quote( CONV string( is_entry-source_unit ) )
      && ';' && quote( lv_requested_quantity )
      && ';' && quote( lv_quantity )
      && ';' && quote( lv_shortfall_quantity )
      && ';' && quote( lv_fill_pct )
      && ';' && quote( CONV string( is_entry-unit_of_measure ) )
      && ';' && quote( CONV string( is_entry-reservation_id ) )
      && ';' && quote( CONV string( is_entry-prior_reservation_id ) )
      && ';' && quote( CONV string( is_entry-log_message ) )
      && ';' && quote( CONV string( is_entry-logged_by ) ).
  ENDMETHOD.
ENDCLASS.
