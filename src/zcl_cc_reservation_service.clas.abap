CLASS zcl_cc_reservation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        cost_center             TYPE bapi2093_res_head-costcenter,
        requested_quantity      TYPE mard-labst,
        source_unit             TYPE mara-meins,
        base_requested_quantity TYPE mard-labst,
        base_unit               TYPE mara-meins,
        available_quantity      TYPE mard-labst,
        allocated_quantity      TYPE mard-labst,
        shortfall_quantity      TYPE mard-labst,
        storage_allocations     TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations       TYPE zcl_stock_service=>ty_batch_allocations,
        reservation_number      TYPE bapi2093_res_key-reserv_no,
        messages                TYPE zif_cc_reservation_api=>ty_messages,
        is_successful           TYPE abap_bool,
      END OF ty_result.

    METHODS constructor
      IMPORTING
        io_stock_repository TYPE REF TO zif_stock_repository
        io_reservation_api  TYPE REF TO zif_cc_reservation_api OPTIONAL
        io_uom_repository   TYPE REF TO zif_material_uom_repository OPTIONAL.

    METHODS reserve_for_cost_center
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_storage_location     TYPE mard-lgort OPTIONAL
        iv_allow_fallback       TYPE abap_bool DEFAULT abap_false
        iv_cost_center          TYPE bapi2093_res_head-costcenter
        iv_requested_quantity   TYPE mard-labst
        iv_unit                 TYPE mara-meins
        iv_batch                TYPE mchb-charg OPTIONAL
        iv_required_date        TYPE d DEFAULT sy-datum
        iv_use_fefo_batches     TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date      TYPE d DEFAULT sy-datum
        iv_fefo_min_days        TYPE i DEFAULT 0
        iv_test_run             TYPE abap_bool DEFAULT abap_false
        iv_require_full_alloc   TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_stock_request.

    METHODS preview_for_cost_center
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_storage_location     TYPE mard-lgort OPTIONAL
        iv_allow_fallback       TYPE abap_bool DEFAULT abap_false
        iv_cost_center          TYPE bapi2093_res_head-costcenter
        iv_requested_quantity   TYPE mard-labst
        iv_unit                 TYPE mara-meins
        iv_batch                TYPE mchb-charg OPTIONAL
        iv_required_date        TYPE d DEFAULT sy-datum
        iv_use_fefo_batches     TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date      TYPE d DEFAULT sy-datum
        iv_fefo_min_days        TYPE i DEFAULT 0
        iv_require_full_alloc   TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_prepared_reservation,
        result  TYPE ty_result,
        request TYPE zif_cc_reservation_api=>ty_request,
      END OF ty_prepared_reservation.

    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_reservation_api TYPE REF TO zif_cc_reservation_api.
    DATA mo_uom_repository TYPE REF TO zif_material_uom_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.

    METHODS prepare_reservation
      IMPORTING
        iv_material             TYPE mard-matnr
        iv_plant                TYPE mard-werks
        iv_storage_location     TYPE mard-lgort
        iv_location_supplied    TYPE abap_bool
        iv_allow_fallback       TYPE abap_bool
        iv_cost_center          TYPE bapi2093_res_head-costcenter
        iv_requested_quantity   TYPE mard-labst
        iv_unit                 TYPE mara-meins
        iv_batch                TYPE mchb-charg
        iv_batch_supplied       TYPE abap_bool
        iv_required_date        TYPE d
        iv_use_fefo_batches     TYPE abap_bool
        iv_fefo_as_of_date      TYPE d
        iv_fefo_min_days        TYPE i
        iv_require_full_alloc   TYPE abap_bool
        iv_protect_safety_stock TYPE abap_bool
      RETURNING
        VALUE(rs_prepared)      TYPE ty_prepared_reservation
      RAISING
        zcx_invalid_reservation
        zcx_invalid_stock_request.
ENDCLASS.

CLASS zcl_cc_reservation_service IMPLEMENTATION.

  METHOD constructor.
    mo_stock_service = NEW zcl_stock_service(
      io_stock_repository = io_stock_repository ).

    IF io_reservation_api IS BOUND.
      mo_reservation_api = io_reservation_api.
    ELSE.
      mo_reservation_api = NEW zcl_bapi_cc_reservation( ).
    ENDIF.

    IF io_uom_repository IS BOUND.
      mo_uom_repository = io_uom_repository.
    ELSE.
      mo_uom_repository = NEW zcl_material_uom_repository( ).
    ENDIF.

    mo_uom_converter = NEW zcl_material_uom_converter(
      io_repository = mo_uom_repository ).
  ENDMETHOD.

  METHOD reserve_for_cost_center.
    DATA(ls_prepared) = prepare_reservation(
      iv_material             = iv_material
      iv_plant                = iv_plant
      iv_storage_location     = iv_storage_location
      iv_location_supplied    =
        xsdbool( iv_storage_location IS SUPPLIED )
      iv_allow_fallback       = iv_allow_fallback
      iv_cost_center          = iv_cost_center
      iv_requested_quantity   = iv_requested_quantity
      iv_unit                 = iv_unit
      iv_batch                = iv_batch
      iv_batch_supplied       = xsdbool( iv_batch IS SUPPLIED )
      iv_required_date        = iv_required_date
      iv_use_fefo_batches     = iv_use_fefo_batches
      iv_fefo_as_of_date      = iv_fefo_as_of_date
      iv_fefo_min_days        = iv_fefo_min_days
      iv_require_full_alloc   = iv_require_full_alloc
      iv_protect_safety_stock = iv_protect_safety_stock ).
    rs_result = ls_prepared-result.

    IF rs_result-is_successful = abap_false
        OR rs_result-allocated_quantity <= 0.
      RETURN.
    ENDIF.

    DATA(ls_create_result) = mo_reservation_api->create_reservation(
      is_request  = ls_prepared-request
      iv_test_run = iv_test_run ).
    APPEND LINES OF ls_create_result-messages TO rs_result-messages.
    rs_result-reservation_number = ls_create_result-reservation_number.

    IF ls_create_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservation_number.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    LOOP AT ls_create_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_reservation_api->rollback( ).
        CLEAR rs_result-reservation_number.
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-reservation_number IS INITIAL.
      mo_reservation_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API returned no reservation number' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservation_number.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD preview_for_cost_center.
    DATA(ls_prepared) = prepare_reservation(
      iv_material             = iv_material
      iv_plant                = iv_plant
      iv_storage_location     = iv_storage_location
      iv_location_supplied    =
        xsdbool( iv_storage_location IS SUPPLIED )
      iv_allow_fallback       = iv_allow_fallback
      iv_cost_center          = iv_cost_center
      iv_requested_quantity   = iv_requested_quantity
      iv_unit                 = iv_unit
      iv_batch                = iv_batch
      iv_batch_supplied       = xsdbool( iv_batch IS SUPPLIED )
      iv_required_date        = iv_required_date
      iv_use_fefo_batches     = iv_use_fefo_batches
      iv_fefo_as_of_date      = iv_fefo_as_of_date
      iv_fefo_min_days        = iv_fefo_min_days
      iv_require_full_alloc   = iv_require_full_alloc
      iv_protect_safety_stock = iv_protect_safety_stock ).
    rs_result = ls_prepared-result.
  ENDMETHOD.

  METHOD prepare_reservation.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR ( iv_location_supplied = abap_true
          AND iv_storage_location IS INITIAL )
        OR ( iv_allow_fallback = abap_true
          AND iv_location_supplied = abap_false )
        OR iv_cost_center IS INITIAL
        OR iv_requested_quantity <= 0
        OR iv_unit IS INITIAL
        OR iv_required_date IS INITIAL
        OR ( iv_batch_supplied = abap_true AND iv_batch IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    IF iv_use_fefo_batches = abap_true
        AND iv_batch_supplied = abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    IF iv_fefo_min_days < 0
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true )
        OR ( iv_use_fefo_batches = abap_true
          AND iv_fefo_as_of_date IS INITIAL ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
      iv_material    = iv_material
      iv_quantity    = iv_requested_quantity
      iv_source_unit = iv_unit ).
    IF ls_conversion-is_successful <> abap_true
        OR ls_conversion-base_unit IS INITIAL
        OR ls_conversion-base_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_prepared-result-material = iv_material.
    rs_prepared-result-plant = iv_plant.
    rs_prepared-result-storage_location = iv_storage_location.
    rs_prepared-result-batch = iv_batch.
    rs_prepared-result-cost_center = iv_cost_center.
    rs_prepared-result-requested_quantity = iv_requested_quantity.
    rs_prepared-result-source_unit = iv_unit.
    rs_prepared-result-base_requested_quantity =
      ls_conversion-base_quantity.
    rs_prepared-result-base_unit = ls_conversion-base_unit.

    DATA ls_allocation TYPE zcl_stock_service=>ty_allocation.
    DATA ls_batch_result TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_fefo_result TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_location_result TYPE zcl_stock_service=>ty_location_result.

    IF iv_use_fefo_batches = abap_true.
      ls_fefo_result = mo_stock_service->allocate_by_expiry(
        it_demands              = VALUE #(
          ( material                    = iv_material
            plant                       = iv_plant
            storage_location            = iv_storage_location
            fallback_to_other_locations = iv_allow_fallback
            requested_quantity          = ls_conversion-base_quantity ) )
        iv_as_of_date           = iv_fefo_as_of_date
        iv_min_days             = iv_fefo_min_days
        iv_protect_safety_stock = iv_protect_safety_stock ).
      READ TABLE ls_fefo_result-allocations INDEX 1 INTO ls_allocation.
    ELSEIF iv_batch_supplied = abap_true.
      ls_batch_result = mo_stock_service->allocate_by_batch(
        it_demands              = VALUE #(
          ( material                    = iv_material
            plant                       = iv_plant
            storage_location            = iv_storage_location
            fallback_to_other_locations = iv_allow_fallback
            batch                       = iv_batch
            requested_quantity          = ls_conversion-base_quantity ) )
        iv_protect_safety_stock = iv_protect_safety_stock ).
      READ TABLE ls_batch_result-allocations INDEX 1 INTO ls_allocation.
    ELSE.
      ls_location_result = mo_stock_service->allocate_by_storage_location(
          it_demands              = VALUE #(
            ( material                    = iv_material
              plant                       = iv_plant
              storage_location            = iv_storage_location
              fallback_to_other_locations = iv_allow_fallback
              requested_quantity          = ls_conversion-base_quantity ) )
          iv_protect_safety_stock = iv_protect_safety_stock ).
      READ TABLE ls_location_result-allocations INDEX 1 INTO ls_allocation.
    ENDIF.

    rs_prepared-result-available_quantity =
      ls_allocation-available_quantity.
    rs_prepared-result-allocated_quantity =
      ls_allocation-allocated_quantity.
    rs_prepared-result-shortfall_quantity =
      ls_allocation-shortfall_quantity.

    DATA lt_request_items TYPE zif_cc_reservation_api=>ty_items.
    IF iv_use_fefo_batches = abap_true.
      rs_prepared-result-batch_allocations =
        ls_fefo_result-batch_allocations.
      LOOP AT ls_fefo_result-batch_allocations
        INTO DATA(ls_fefo_allocation).
        APPEND VALUE #(
          storage_location = ls_fefo_allocation-storage_location
          batch            = ls_fefo_allocation-batch
          quantity         = ls_fefo_allocation-allocated_quantity
          unit             = ls_conversion-base_unit )
          TO lt_request_items.
      ENDLOOP.
    ELSEIF iv_batch_supplied = abap_true.
      rs_prepared-result-batch_allocations =
        ls_batch_result-batch_allocations.
      LOOP AT ls_batch_result-batch_allocations
        INTO DATA(ls_batch_allocation).
        APPEND VALUE #(
          storage_location = ls_batch_allocation-storage_location
          batch            = ls_batch_allocation-batch
          quantity         = ls_batch_allocation-allocated_quantity
          unit             = ls_conversion-base_unit )
          TO lt_request_items.
      ENDLOOP.
    ELSE.
      rs_prepared-result-storage_allocations =
        ls_location_result-storage_allocations.
      LOOP AT ls_location_result-storage_allocations
        INTO DATA(ls_storage_allocation).
        APPEND VALUE #(
          storage_location = ls_storage_allocation-storage_location
          quantity         = ls_storage_allocation-allocated_quantity
          unit             = ls_conversion-base_unit )
          TO lt_request_items.
      ENDLOOP.
    ENDIF.

    rs_prepared-request = VALUE #(
      material      = iv_material
      plant         = iv_plant
      cost_center   = iv_cost_center
      required_date = iv_required_date
      items         = lt_request_items ).

    IF iv_require_full_alloc = abap_true
        AND rs_prepared-result-shortfall_quantity > 0.
      APPEND VALUE #(
        type    = 'E'
        message = 'Full allocation required; no cost-center reservation was created' )
        TO rs_prepared-result-messages.
      RETURN.
    ENDIF.

    IF rs_prepared-result-allocated_quantity <= 0.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocatable stock; no cost-center reservation was created' )
        TO rs_prepared-result-messages.
      rs_prepared-result-is_successful = abap_true.
      RETURN.
    ENDIF.

    rs_prepared-result-is_successful = abap_true.
  ENDMETHOD.
ENDCLASS.
