CLASS zcl_quality_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_service          TYPE REF TO zcl_stock_service
        io_goods_movement_service TYPE REF TO zcl_goods_movement_service.

    METHODS release_quality_fefo
      IMPORTING
        is_allocation                  TYPE zcl_stock_service=>ty_unit_batch_result
        it_demands                     TYPE zcl_stock_service=>ty_unit_fefo_demands
        is_header                      TYPE zif_goods_movement_api=>ty_header
        it_material_units              TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)               TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS release_quality_fefo_priority
      IMPORTING
        is_allocation                  TYPE
          zcl_stock_service=>ty_priority_unit_fefo_result
        it_demands                     TYPE
          zcl_stock_service=>ty_priority_unit_fefo_demands
        is_header                      TYPE zif_goods_movement_api=>ty_header
        it_material_units              TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)               TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS send_quality_fefo
      IMPORTING
        is_allocation                  TYPE zcl_stock_service=>ty_unit_batch_result
        it_demands                     TYPE zcl_stock_service=>ty_unit_fefo_demands
        is_header                      TYPE zif_goods_movement_api=>ty_header
        it_material_units              TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)               TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

    METHODS send_quality_fefo_priority
      IMPORTING
        is_allocation                  TYPE
          zcl_stock_service=>ty_priority_unit_fefo_result
        it_demands                     TYPE
          zcl_stock_service=>ty_priority_unit_fefo_demands
        is_header                      TYPE zif_goods_movement_api=>ty_header
        it_material_units              TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_protect_safety_stock        TYPE abap_bool DEFAULT abap_false
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)               TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_goods_movement_service TYPE REF TO zcl_goods_movement_service.

    METHODS validate_boolean_options
      IMPORTING
        iv_include_undated_batches TYPE abap_bool
        iv_prioritize_by_date      TYPE abap_bool
        iv_protect_safety_stock    TYPE abap_bool
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_posting_input
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_material_units          TYPE
          zcl_goods_movement_service=>ty_material_unit_mappings
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
      RAISING
        zcx_invalid_goods_movement.
ENDCLASS.

CLASS zcl_quality_stock_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_service = io_stock_service.
    mo_goods_movement_service = io_goods_movement_service.
  ENDMETHOD.

  METHOD validate_boolean_options.
    IF ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false )
        OR ( iv_protect_safety_stock <> abap_true
          AND iv_protect_safety_stock <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD validate_posting_input.
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

  METHOD release_quality_fefo.
    validate_boolean_options( iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date                              = abap_false
      iv_protect_safety_stock                            = abap_false
      iv_test_run                                        = iv_test_run
      iv_require_full_allocation                         = iv_require_full_allocation ).
    IF it_demands IS INITIAL.
      IF is_allocation-allocations IS NOT INITIAL
          OR is_allocation-batch_allocations IS NOT INITIAL
          OR is_allocation-request_locations IS NOT INITIAL
          OR it_storage_location_priority IS NOT INITIAL
          OR it_request_location_priorities IS NOT INITIAL
          OR it_allowed_storage_locations IS NOT INITIAL
          OR it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No quality FEFO demands to release' )
        TO rs_result-messages.
      RETURN.
    ENDIF.
    validate_posting_input(
      is_header                  = is_header
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).

    DATA(ls_rechecked_allocation) =
      mo_stock_service->allocate_quality_by_expiry_uom(
        it_demands                     = it_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_as_of_date                  = iv_as_of_date
        iv_min_days                    = iv_min_days
        iv_include_undated_batches     = iv_include_undated_batches
        iv_require_full_quantity       = iv_require_full_allocation ).

    rs_result = mo_goods_movement_service->release_quality_fefo_rechecked(
      is_header                  = is_header
      is_allocation              = is_allocation
      is_rechecked_allocation    = ls_rechecked_allocation
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD release_quality_fefo_priority.
    validate_boolean_options( iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date                              = iv_prioritize_by_date
      iv_protect_safety_stock                            = abap_false
      iv_test_run                                        = iv_test_run
      iv_require_full_allocation                         = iv_require_full_allocation ).
    IF it_demands IS INITIAL.
      IF is_allocation-allocations IS NOT INITIAL
          OR is_allocation-batch_allocations IS NOT INITIAL
          OR is_allocation-request_locations IS NOT INITIAL
          OR it_storage_location_priority IS NOT INITIAL
          OR it_request_location_priorities IS NOT INITIAL
          OR it_allowed_storage_locations IS NOT INITIAL
          OR it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No priority quality FEFO demands to release' )
        TO rs_result-messages.
      RETURN.
    ENDIF.
    validate_posting_input(
      is_header                  = is_header
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).

    DATA(ls_rechecked_allocation) =
      mo_stock_service->allocate_quality_uom_priority(
        it_demands                     = it_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_as_of_date                  = iv_as_of_date
        iv_prioritize_by_date          = iv_prioritize_by_date
        iv_min_days                    = iv_min_days
        iv_include_undated_batches     = iv_include_undated_batches
        iv_require_full_quantity       = iv_require_full_allocation ).

    rs_result =
      mo_goods_movement_service->release_quality_fefo_prio_post(
        is_header                  = is_header
        is_allocation              = is_allocation
        is_rechecked_allocation    = ls_rechecked_allocation
        it_material_units          = it_material_units
        iv_test_run                = iv_test_run
        iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD send_quality_fefo.
    validate_boolean_options( iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date                              = abap_false
      iv_protect_safety_stock                            = iv_protect_safety_stock
      iv_test_run                                        = iv_test_run
      iv_require_full_allocation                         = iv_require_full_allocation ).
    IF it_demands IS INITIAL.
      IF is_allocation-allocations IS NOT INITIAL
          OR is_allocation-batch_allocations IS NOT INITIAL
          OR is_allocation-request_locations IS NOT INITIAL
          OR it_storage_location_priority IS NOT INITIAL
          OR it_request_location_priorities IS NOT INITIAL
          OR it_allowed_storage_locations IS NOT INITIAL
          OR it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No FEFO demands to send to quality' )
        TO rs_result-messages.
      RETURN.
    ENDIF.
    validate_posting_input(
      is_header                  = is_header
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).

    DATA(ls_rechecked_allocation) = mo_stock_service->allocate_by_expiry_in_units(
      it_demands                     = it_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_min_days                    = iv_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_protect_safety_stock        = iv_protect_safety_stock
      iv_require_full_quantity       = iv_require_full_allocation ).

    rs_result = mo_goods_movement_service->send_quality_fefo_rechecked(
      is_header                  = is_header
      is_allocation              = is_allocation
      is_rechecked_allocation    = ls_rechecked_allocation
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD send_quality_fefo_priority.
    validate_boolean_options( iv_include_undated_batches = iv_include_undated_batches
      iv_prioritize_by_date                              = iv_prioritize_by_date
      iv_protect_safety_stock                            = iv_protect_safety_stock
      iv_test_run                                        = iv_test_run
      iv_require_full_allocation                         = iv_require_full_allocation ).
    IF it_demands IS INITIAL.
      IF is_allocation-allocations IS NOT INITIAL
          OR is_allocation-batch_allocations IS NOT INITIAL
          OR is_allocation-request_locations IS NOT INITIAL
          OR it_storage_location_priority IS NOT INITIAL
          OR it_request_location_priorities IS NOT INITIAL
          OR it_allowed_storage_locations IS NOT INITIAL
          OR it_request_locations IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No priority FEFO demands to send to quality' )
        TO rs_result-messages.
      RETURN.
    ENDIF.
    validate_posting_input(
      is_header                  = is_header
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).

    DATA(ls_rechecked_allocation) =
      mo_stock_service->allocate_fefo_uom_priority(
        it_demands                     = it_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = it_request_location_priorities
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = it_request_locations
        iv_as_of_date                  = iv_as_of_date
        iv_prioritize_by_date          = iv_prioritize_by_date
        iv_min_days                    = iv_min_days
        iv_include_undated_batches     = iv_include_undated_batches
        iv_protect_safety_stock        = iv_protect_safety_stock
        iv_require_full_quantity       = iv_require_full_allocation ).

    rs_result = mo_goods_movement_service->send_quality_fefo_prio_post(
      is_header                  = is_header
      is_allocation              = is_allocation
      is_rechecked_allocation    = ls_rechecked_allocation
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.
ENDCLASS.
