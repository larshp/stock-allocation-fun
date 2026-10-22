CLASS zcl_so_fefo_issue_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_service          TYPE REF TO zcl_so_stock_service
        io_goods_movement_service TYPE REF TO zcl_goods_movement_service.

    METHODS issue_fefo
      IMPORTING
        is_allocation                  TYPE
          zcl_so_stock_service=>ty_fefo_issue_result
        it_requests                    TYPE
          zcl_so_stock_service=>ty_fefo_issue_requests
        is_header                      TYPE zif_goods_movement_api=>ty_header
        it_material_units              TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_so_stock_service=>ty_fefo_request_location_priorities OPTIONAL
        it_request_ids                 TYPE
          zcl_goods_movement_service=>ty_so_fefo_request_ids OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation     TYPE abap_bool DEFAULT abap_true
        it_location_allowlist          TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_so_stock_service=>ty_fefo_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS issue_fefo_uom
      IMPORTING
        is_allocation                  TYPE
          zcl_so_stock_service=>ty_fefo_issue_result
        it_requests                    TYPE
          zcl_so_stock_service=>ty_fefo_issue_unit_requests
        is_header                      TYPE zif_goods_movement_api=>ty_header
        it_material_units              TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_so_stock_service=>ty_fefo_request_location_priorities OPTIONAL
        it_request_ids                 TYPE
          zcl_goods_movement_service=>ty_so_fefo_request_ids OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation     TYPE abap_bool DEFAULT abap_true
        it_location_allowlist          TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_so_stock_service=>ty_fefo_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES ty_request_ids TYPE STANDARD TABLE OF ty_request_id WITH EMPTY KEY.
    DATA mo_stock_service TYPE REF TO zcl_so_stock_service.
    DATA mo_goods_movement_service TYPE REF TO zcl_goods_movement_service.

    METHODS validate_boolean_options
      IMPORTING
        iv_include_undated_batches TYPE abap_bool
        iv_prioritize_by_date      TYPE abap_bool
        iv_prioritize_by_priority  TYPE abap_bool
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_input
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_material_units          TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        iv_as_of_date              TYPE d
        iv_min_days                TYPE i
        iv_include_undated_batches TYPE abap_bool
        iv_prioritize_by_date      TYPE abap_bool
        iv_prioritize_by_priority  TYPE abap_bool
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_request_ids
      IMPORTING
        it_selected_ids TYPE
          zcl_goods_movement_service=>ty_so_fefo_request_ids
        it_known_ids    TYPE ty_request_ids
      RAISING
        zcx_invalid_goods_movement.
ENDCLASS.

CLASS zcl_so_fefo_issue_service IMPLEMENTATION.

  METHOD constructor.
    mo_stock_service = io_stock_service.
    mo_goods_movement_service = io_goods_movement_service.
  ENDMETHOD.

  METHOD validate_boolean_options.
    IF ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD validate_input.
    TYPES:
      BEGIN OF ty_material_key,
        material TYPE mard-matnr,
      END OF ty_material_key,
      ty_material_keys TYPE HASHED TABLE OF ty_material_key
        WITH UNIQUE KEY material.
    DATA lt_material_keys TYPE ty_material_keys.

    IF mo_stock_service IS NOT BOUND
        OR mo_goods_movement_service IS NOT BOUND
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          is_header-posting_date ) <> abap_true
        OR zcl_date_validation=>is_valid_gregorian_date(
          is_header-document_date ) <> abap_true
        OR it_material_units IS INITIAL
        OR iv_as_of_date IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_as_of_date ) <> abap_true
        OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_material_units INTO DATA(ls_material_unit).
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_material_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_request_ids.
    TYPES ty_seen_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_known_ids TYPE ty_seen_ids.
    DATA lt_selected_ids TYPE ty_seen_ids.

    IF it_selected_ids IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_known_ids INTO DATA(lv_known_id).
      IF lv_known_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT lv_known_id INTO TABLE lt_known_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_selected_ids INTO DATA(lv_selected_id).
      IF lv_selected_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT lv_selected_id INTO TABLE lt_selected_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE lt_known_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line = lv_selected_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD issue_fefo.
    validate_boolean_options(
      iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date      = iv_prioritize_by_date
      iv_prioritize_by_priority  = iv_prioritize_by_priority
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
    IF it_requests IS INITIAL.
      IF it_request_ids IS NOT INITIAL
          OR is_allocation-allocations IS NOT INITIAL
          OR is_allocation-batch_allocations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No sales-order FEFO demands to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    validate_input(
      is_header                  = is_header
      it_material_units          = it_material_units
      iv_as_of_date              = iv_as_of_date
      iv_min_days                = iv_min_days
      iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date      = iv_prioritize_by_date
      iv_prioritize_by_priority  = iv_prioritize_by_priority
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).

    DATA lt_known_ids TYPE ty_request_ids.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND ls_request-request_id TO lt_known_ids.
    ENDLOOP.
    validate_request_ids(
      it_selected_ids = it_request_ids
      it_known_ids    = lt_known_ids ).

    DATA(ls_rechecked_allocation) =
      mo_stock_service->preview_issue_demands_by_fefo(
        it_requests                    = it_requests
        iv_as_of_date                  = iv_as_of_date
        iv_min_days                    = iv_min_days
        iv_include_undated_batches     = iv_include_undated_batches
        iv_require_full_quantity       = iv_require_full_allocation
        iv_prioritize_by_date          = iv_prioritize_by_date
        iv_prioritize_by_priority      = iv_prioritize_by_priority
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_location_allowlist          = it_location_allowlist
        it_request_locations           = it_request_locations ).

    IF it_request_ids IS INITIAL.
      rs_result = mo_goods_movement_service->issue_so_fefo_rechecked(
        is_header                  = is_header
        is_allocation              = is_allocation
        is_rechecked_allocation    = ls_rechecked_allocation
        it_material_units          = it_material_units
        iv_test_run                = iv_test_run
        iv_require_full_allocation = iv_require_full_allocation ).
    ELSE.
      rs_result = mo_goods_movement_service->issue_so_fefo_sel_rechecked(
        is_header                  = is_header
        is_allocation              = is_allocation
        is_rechecked_allocation    = ls_rechecked_allocation
        it_request_ids             = it_request_ids
        it_material_units          = it_material_units
        iv_test_run                = iv_test_run
        iv_require_full_allocation = iv_require_full_allocation ).
    ENDIF.
  ENDMETHOD.

  METHOD issue_fefo_uom.
    validate_boolean_options(
      iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date      = iv_prioritize_by_date
      iv_prioritize_by_priority  = iv_prioritize_by_priority
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
    IF it_requests IS INITIAL.
      IF it_request_ids IS NOT INITIAL
          OR is_allocation-allocations IS NOT INITIAL
          OR is_allocation-batch_allocations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No sales-order FEFO demands to issue' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    validate_input(
      is_header                  = is_header
      it_material_units          = it_material_units
      iv_as_of_date              = iv_as_of_date
      iv_min_days                = iv_min_days
      iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date      = iv_prioritize_by_date
      iv_prioritize_by_priority  = iv_prioritize_by_priority
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).

    DATA lt_known_ids TYPE ty_request_ids.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND ls_request-request_id TO lt_known_ids.
    ENDLOOP.
    validate_request_ids(
      it_selected_ids = it_request_ids
      it_known_ids    = lt_known_ids ).

    DATA(ls_rechecked_allocation) =
      mo_stock_service->preview_issue_fefo_uom(
        it_requests                    = it_requests
        iv_as_of_date                  = iv_as_of_date
        iv_min_days                    = iv_min_days
        iv_include_undated_batches     = iv_include_undated_batches
        iv_require_full_quantity       = iv_require_full_allocation
        iv_prioritize_by_date          = iv_prioritize_by_date
        iv_prioritize_by_priority      = iv_prioritize_by_priority
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_location_allowlist          = it_location_allowlist
        it_request_locations           = it_request_locations ).

    IF it_request_ids IS INITIAL.
      rs_result = mo_goods_movement_service->issue_so_fefo_rechecked(
        is_header                  = is_header
        is_allocation              = is_allocation
        is_rechecked_allocation    = ls_rechecked_allocation
        it_material_units          = it_material_units
        iv_test_run                = iv_test_run
        iv_require_full_allocation = iv_require_full_allocation ).
    ELSE.
      rs_result = mo_goods_movement_service->issue_so_fefo_sel_rechecked(
        is_header                  = is_header
        is_allocation              = is_allocation
        is_rechecked_allocation    = ls_rechecked_allocation
        it_request_ids             = it_request_ids
        it_material_units          = it_material_units
        iv_test_run                = iv_test_run
        iv_require_full_allocation = iv_require_full_allocation ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
