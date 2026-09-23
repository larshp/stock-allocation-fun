CLASS zcl_goods_movement_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_transfer_destination,
        request_id                 TYPE c LENGTH 30,
        receiving_storage_location TYPE mard-lgort,
      END OF ty_transfer_destination.
    TYPES ty_transfer_destinations TYPE STANDARD TABLE OF
      ty_transfer_destination WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_material_unit,
        material      TYPE mard-matnr,
        base_unit     TYPE mara-meins,
        base_unit_iso TYPE c LENGTH 3,
      END OF ty_transfer_material_unit.
    TYPES ty_transfer_material_units TYPE STANDARD TABLE OF
      ty_transfer_material_unit WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_two_step_transfer_result,
        removal_result TYPE zif_goods_movement_api=>ty_result,
        putaway_result TYPE zif_goods_movement_api=>ty_result,
        is_successful  TYPE abap_bool,
        is_in_transit  TYPE abap_bool,
      END OF ty_two_step_transfer_result.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_goods_movement_api.

    METHODS execute
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        iv_gm_code       TYPE zif_goods_movement_api=>ty_gm_code
        it_items         TYPE zif_goods_movement_api=>ty_items
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_batch_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_fefo_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_fefo_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_2step_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_allocation
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_two_step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_batch_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_loc_batch_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_fefo_2step
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_loc_fefo_2step_uom
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_2step_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_units_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_location_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_batch_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_fefo_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_fefo_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_location_batch_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_batch_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_plant_fefo_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_units_alloc
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_allocation_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_batch_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_batch_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_plant_fefo_units
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        is_allocation              TYPE zcl_stock_service=>ty_unit_plant_fefo_result
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS cancel
      IMPORTING
        iv_material_document TYPE zif_goods_movement_api=>ty_material_document
        iv_fiscal_year       TYPE zif_goods_movement_api=>ty_fiscal_year
        iv_posting_date      TYPE d OPTIONAL
        it_item_numbers      TYPE zif_goods_movement_api=>ty_material_document_items OPTIONAL
      RETURNING
        VALUE(rs_result)     TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES ty_movement_type TYPE c LENGTH 3.
    TYPES:
      BEGIN OF ty_transfer_request_key,
        request_id TYPE c LENGTH 30,
      END OF ty_transfer_request_key.
    TYPES ty_transfer_request_keys TYPE HASHED TABLE OF
      ty_transfer_request_key WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_transfer_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        batch              TYPE mchb-charg,
        base_unit          TYPE mara-meins,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_transfer_demand.
    TYPES ty_transfer_demands TYPE STANDARD TABLE OF ty_transfer_demand
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_split,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        target_plant       TYPE mard-werks,
        source_plant       TYPE mard-werks,
        storage_location   TYPE mard-lgort,
        batch              TYPE mchb-charg,
        base_unit          TYPE mara-meins,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
      END OF ty_transfer_split.
    TYPES ty_transfer_splits TYPE STANDARD TABLE OF ty_transfer_split
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_transfer_material_key,
        material TYPE mard-matnr,
      END OF ty_transfer_material_key.
    TYPES ty_transfer_material_keys TYPE HASHED TABLE OF
      ty_transfer_material_key WITH UNIQUE KEY material.
    TYPES:
      BEGIN OF ty_transfer_split_key,
        request_id       TYPE c LENGTH 30,
        source_plant     TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_transfer_split_key.
    TYPES ty_transfer_split_keys TYPE HASHED TABLE OF
      ty_transfer_split_key WITH UNIQUE KEY request_id source_plant
        storage_location batch.
    TYPES:
      BEGIN OF ty_transfer_quantity,
        request_id TYPE c LENGTH 30,
        quantity   TYPE mard-labst,
      END OF ty_transfer_quantity.
    TYPES ty_transfer_quantities TYPE HASHED TABLE OF
      ty_transfer_quantity WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_transfer_batch_quantity,
        request_id TYPE c LENGTH 30,
        batch      TYPE mchb-charg,
        quantity   TYPE mard-labst,
      END OF ty_transfer_batch_quantity.
    TYPES ty_transfer_batch_quantities TYPE STANDARD TABLE OF
      ty_transfer_batch_quantity WITH EMPTY KEY.

    METHODS transfer_plant_splits
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_demands                 TYPE ty_transfer_demands
        it_splits                  TYPE ty_transfer_splits
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
        iv_require_batch           TYPE abap_bool
        iv_movement_type           TYPE ty_movement_type DEFAULT '301'
      RETURNING
        VALUE(rs_result)           TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS transfer_two_step_splits
      IMPORTING
        is_header                  TYPE zif_goods_movement_api=>ty_header
        it_demands                 TYPE ty_transfer_demands
        it_splits                  TYPE ty_transfer_splits
        it_destinations            TYPE ty_transfer_destinations
        it_material_units          TYPE ty_transfer_material_units
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
        iv_require_batch           TYPE abap_bool
        iv_allow_multiple_batches  TYPE abap_bool
        iv_removal_movement_type   TYPE ty_movement_type
      RETURNING
        VALUE(rs_result)           TYPE ty_two_step_transfer_result
      RAISING
        zcx_invalid_goods_movement.

    DATA mo_api TYPE REF TO zif_goods_movement_api.
ENDCLASS.

CLASS zcl_goods_movement_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD execute.
    DATA lv_mode_known TYPE abap_bool.
    DATA lv_reservation_issue TYPE abap_bool.
    DATA lv_purchase_order_receipt TYPE abap_bool.
    DATA lv_production_order_receipt TYPE abap_bool.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR iv_gm_code IS INITIAL
        OR it_items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_items INTO DATA(ls_item).
      DATA(lv_item_uses_reservation) = xsdbool(
        ls_item-reservation_number IS NOT INITIAL ).
      DATA(lv_item_uses_purchase_order) = xsdbool(
        ls_item-purchase_order IS NOT INITIAL
        OR ls_item-purchase_order_item IS NOT INITIAL ).
      DATA(lv_uses_prod_receipt) = xsdbool(
        iv_gm_code = '02'
        OR ( ls_item-order_id IS NOT INITIAL
          AND ls_item-movement_type = '101' ) ).
      IF lv_mode_known = abap_false.
        lv_reservation_issue = lv_item_uses_reservation.
        lv_purchase_order_receipt = lv_item_uses_purchase_order.
        lv_production_order_receipt =
          lv_uses_prod_receipt.
        lv_mode_known = abap_true.
      ELSEIF lv_reservation_issue <> lv_item_uses_reservation
          OR lv_purchase_order_receipt <> lv_item_uses_purchase_order
          OR lv_production_order_receipt
            <> lv_uses_prod_receipt.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF lv_item_uses_reservation = abap_true.
        IF iv_gm_code <> '03'
            OR ls_item-reservation_item IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-entry_unit IS INITIAL
            OR ls_item-entry_unit_iso IS INITIAL
            OR ls_item-material IS NOT INITIAL
            OR ls_item-plant IS NOT INITIAL
            OR ls_item-movement_type IS NOT INITIAL
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-purchase_order IS NOT INITIAL
            OR ls_item-purchase_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL
            OR ls_item-movement_indicator IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_item-reservation_item IS NOT INITIAL
          OR ls_item-reservation_record_type IS NOT INITIAL
          OR ( ls_item-movement_indicator IS NOT INITIAL
            AND lv_item_uses_purchase_order = abap_false
            AND lv_uses_prod_receipt = abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( lv_item_uses_purchase_order = abap_false
            AND lv_uses_prod_receipt = abap_false
            AND ( ls_item-material IS INITIAL
              OR ls_item-plant IS INITIAL
              OR ls_item-storage_location IS INITIAL ) )
          OR ls_item-movement_type IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-entry_unit IS INITIAL
          OR ls_item-entry_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF lv_item_uses_purchase_order = abap_true.
        IF iv_gm_code <> '01'
            OR ( ls_item-movement_type <> '101'
              AND ls_item-movement_type <> '122' )
            OR ls_item-purchase_order IS INITIAL
            OR ls_item-purchase_order_item IS INITIAL
            OR ls_item-movement_indicator <> 'B'
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_uses_prod_receipt = abap_true.
        IF iv_gm_code <> '02'
            OR ls_item-movement_type <> '101'
            OR ls_item-order_id IS INITIAL
            OR ls_item-movement_indicator <> 'F'
            OR ls_item-purchase_order IS NOT INITIAL
            OR ls_item-purchase_order_item IS NOT INITIAL
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ls_item-receiving_plant IS NOT INITIAL
            OR ls_item-receiving_storage_location IS NOT INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ls_item-purchase_order_item IS NOT INITIAL
          OR ls_item-purchase_order IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_item-movement_type = '303'
          OR ls_item-movement_type = '305'
          OR ls_item-movement_type = '313'
          OR ls_item-movement_type = '315'.
        IF iv_gm_code <> '04'
            OR ls_item-cost_center IS NOT INITIAL
            OR ls_item-order_id IS NOT INITIAL
            OR ls_item-sales_order IS NOT INITIAL
            OR ls_item-sales_order_item IS NOT INITIAL
            OR ( ls_item-movement_type = '303'
              AND ( ls_item-receiving_plant IS INITIAL
                OR ls_item-receiving_plant = ls_item-plant
                OR ls_item-receiving_storage_location IS NOT INITIAL ) )
            OR ( ls_item-movement_type = '305'
              AND ( ls_item-receiving_plant IS NOT INITIAL
                OR ls_item-receiving_storage_location IS NOT INITIAL ) )
            OR ( ls_item-movement_type = '313'
              AND ( ls_item-receiving_plant IS NOT INITIAL
                OR ls_item-receiving_storage_location IS INITIAL
                OR ls_item-receiving_storage_location
                  = ls_item-storage_location ) )
            OR ( ls_item-movement_type = '315'
              AND ( ls_item-receiving_plant IS NOT INITIAL
                OR ls_item-receiving_storage_location IS NOT INITIAL ) ).
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF ( ls_item-movement_type = '201'
          OR ls_item-movement_type = '202' )
          AND ls_item-cost_center IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '261'
          OR ls_item-movement_type = '262' )
          AND ls_item-order_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '231'
          OR ls_item-movement_type = '232' )
          AND ( ls_item-sales_order IS INITIAL
            OR ls_item-sales_order_item IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '301'
          OR ls_item-movement_type = '302' )
          AND ( ls_item-receiving_plant IS INITIAL
            OR ls_item-receiving_storage_location IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ( ls_item-movement_type = '311'
          OR ls_item-movement_type = '312' )
          AND ls_item-receiving_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    rs_result = mo_api->create_movement(
      is_header   = is_header
      iv_gm_code  = iv_gm_code
      it_items    = it_items
      iv_test_run = iv_test_run ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-material_document IS INITIAL
        OR rs_result-fiscal_year IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Goods movement did not return a material document' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD transfer_plant_allocation.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations
        INTO DATA(ls_location_allocation).
      APPEND VALUE #(
        request_id         = ls_location_allocation-request_id
        material           = ls_location_allocation-material
        target_plant       = ls_location_allocation-target_plant
        source_plant       = ls_location_allocation-source_plant
        storage_location   = ls_location_allocation-storage_location
        available_quantity = ls_location_allocation-available_quantity
        allocated_quantity = ls_location_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false ).
  ENDMETHOD.

  METHOD transfer_location_allocation.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations
      INTO DATA(ls_storage_allocation).
      APPEND VALUE #(
        request_id         = ls_storage_allocation-request_id
        material           = ls_storage_allocation-material
        target_plant       = ls_storage_allocation-plant
        source_plant       = ls_storage_allocation-plant
        storage_location   = ls_storage_allocation-storage_location
        available_quantity = ls_storage_allocation-allocated_quantity
        allocated_quantity = ls_storage_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations
      INTO DATA(ls_storage_allocation).
      APPEND VALUE #(
        request_id         = ls_storage_allocation-request_id
        material           = ls_storage_allocation-material
        target_plant       = ls_storage_allocation-plant
        source_plant       = ls_storage_allocation-plant
        storage_location   = ls_storage_allocation-storage_location
        available_quantity = ls_storage_allocation-allocated_quantity
        allocated_quantity = ls_storage_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '313' ).
  ENDMETHOD.

  METHOD transfer_location_fefo_2step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_true
      iv_removal_movement_type   = '313' ).
  ENDMETHOD.

  METHOD transfer_location_batch_2step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.

      READ TABLE lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY request_id = ls_batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_demand>-batch IS NOT INITIAL
          AND <ls_demand>-batch <> ls_batch_allocation-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_demand>-batch = ls_batch_allocation-batch.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '313' ).
  ENDMETHOD.

  METHOD transfer_loc_batch_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-batch_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-batch_allocation
        TO ls_base_allocation-batch_allocations.
    ENDLOOP.

    rs_result = transfer_location_batch_2step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_loc_fefo_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_batch_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-batch_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-batch_allocation
        TO ls_base_allocation-batch_allocations.
    ENDLOOP.

    rs_result = transfer_location_fefo_2step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations
      INTO DATA(ls_location_allocation).
      APPEND VALUE #(
        request_id         = ls_location_allocation-request_id
        material           = ls_location_allocation-material
        target_plant       = ls_location_allocation-target_plant
        source_plant       = ls_location_allocation-source_plant
        storage_location   = ls_location_allocation-storage_location
        available_quantity = ls_location_allocation-available_quantity
        allocated_quantity = ls_location_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '303' ).
  ENDMETHOD.

  METHOD transfer_plant_batch_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        batch              = ls_allocation-batch
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_location).
      APPEND VALUE #(
        request_id         = ls_location-request_id
        material           = ls_location-material
        target_plant       = ls_location-target_plant
        source_plant       = ls_location-source_plant
        storage_location   = ls_location-storage_location
        batch              = ls_location-batch
        available_quantity = ls_location-available_quantity
        allocated_quantity = ls_location-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_allow_multiple_batches  = abap_false
      iv_removal_movement_type   = '303' ).
  ENDMETHOD.

  METHOD transfer_plant_batch_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_plant_batch_allocation_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-allocation
        TO ls_base_allocation-location_allocations.
    ENDLOOP.

    rs_result = transfer_plant_batch_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_two_step.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-target_plant
        source_plant       = ls_batch_allocation-source_plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-available_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_two_step_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_allow_multiple_batches  = abap_true
      iv_removal_movement_type   = '303' ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_2step_uom.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_plant_fefo_allocation_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-allocation
        TO ls_base_allocation-batch_allocations.
    ENDLOOP.

    rs_result = transfer_plant_fefo_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_plant_2step_units.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_plant_allocation_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      IF ls_unit_demand-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_demand-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_demand-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_demand-allocation TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-allocation
        TO ls_base_allocation-location_allocations.
    ENDLOOP.

    rs_result = transfer_plant_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_two_step_splits.
    DATA lv_putaway_movement_type TYPE ty_movement_type.
    DATA lt_seen_requests TYPE ty_transfer_request_keys.
    DATA lt_seen_destinations TYPE ty_transfer_request_keys.
    DATA lt_seen_material_units TYPE ty_transfer_material_keys.
    DATA lt_seen_splits TYPE ty_transfer_split_keys.
    DATA lt_transfer_quantities TYPE ty_transfer_quantities.
    DATA lt_transfer_batch_quantities TYPE ty_transfer_batch_quantities.
    DATA lt_removal_items TYPE zif_goods_movement_api=>ty_items.
    DATA lt_putaway_items TYPE zif_goods_movement_api=>ty_items.
    DATA ls_demand TYPE ty_transfer_demand.
    DATA ls_split TYPE ty_transfer_split.
    DATA ls_destination TYPE ty_transfer_destination.
    DATA ls_material_unit TYPE ty_transfer_material_unit.
    DATA ls_transfer_quantity TYPE ty_transfer_quantity.
    DATA ls_transfer_batch_quantity TYPE ty_transfer_batch_quantity.
    FIELD-SYMBOLS <ls_transfer_quantity> TYPE ty_transfer_quantity.
    FIELD-SYMBOLS <ls_transfer_batch_quantity>
      TYPE ty_transfer_batch_quantity.

    IF it_demands IS INITIAL
        OR ( iv_removal_movement_type <> '303'
          AND iv_removal_movement_type <> '313' )
        OR ( iv_require_batch <> abap_true
          AND iv_require_batch <> abap_false )
        OR ( iv_allow_multiple_batches <> abap_true
          AND iv_allow_multiple_batches <> abap_false )
        OR ( iv_require_batch = abap_true
          AND iv_allow_multiple_batches = abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
    lv_putaway_movement_type = COND #(
      WHEN iv_removal_movement_type = '303' THEN '305'
      ELSE '315' ).

    LOOP AT it_demands INTO ls_demand.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ( iv_require_batch = abap_true
            AND ls_demand-batch IS INITIAL )
          OR ( iv_require_batch = abap_false
            AND ls_demand-batch IS NOT INITIAL )
          OR ls_demand-requested_quantity < 0
          OR ls_demand-available_quantity < 0
          OR ls_demand-allocated_quantity < 0
          OR ls_demand-shortfall_quantity < 0
          OR ls_demand-allocated_quantity > ls_demand-requested_quantity
          OR ls_demand-allocated_quantity > ls_demand-available_quantity
          OR ls_demand-allocated_quantity + ls_demand-shortfall_quantity
            <> ls_demand-requested_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_demand-request_id
        quantity   = 0 ) INTO TABLE lt_transfer_quantities.

      IF ls_demand-base_unit IS NOT INITIAL.
        READ TABLE it_material_units INTO ls_material_unit
          WITH KEY material = ls_demand-material.
        IF sy-subrc <> 0
            OR ls_demand-base_unit <> ls_material_unit-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_demand-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_destinations INTO ls_destination.
      IF ls_destination-request_id IS INITIAL
          OR ls_destination-receiving_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_destination-request_id )
        INTO TABLE lt_seen_destinations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_destination-request_id.
      IF sy-subrc <> 0 OR ls_demand-allocated_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO ls_material_unit.
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_material_units.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_splits INTO ls_split.
      IF ls_split-allocated_quantity < 0
          OR ls_split-available_quantity < 0
          OR ls_split-allocated_quantity > ls_split-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_split-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_split-request_id IS INITIAL
          OR ls_split-material IS INITIAL
          OR ls_split-target_plant IS INITIAL
          OR ls_split-source_plant IS INITIAL
          OR ls_split-storage_location IS INITIAL
          OR ( iv_require_batch = abap_true
            AND ls_split-batch IS INITIAL )
          OR ( iv_require_batch = abap_false
            AND iv_allow_multiple_batches = abap_false
            AND ls_split-batch IS NOT INITIAL )
          OR ( iv_allow_multiple_batches = abap_true
            AND ls_split-batch IS INITIAL )
          OR ( iv_removal_movement_type = '303'
            AND ls_split-source_plant = ls_split-target_plant )
          OR ( iv_removal_movement_type = '313'
            AND ls_split-source_plant <> ls_split-target_plant ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ls_demand-material <> ls_split-material
          OR ls_demand-target_plant <> ls_split-target_plant
          OR ( iv_require_batch = abap_true
            AND ls_demand-batch <> ls_split-batch ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_destinations INTO ls_destination
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ( iv_removal_movement_type = '313'
            AND ls_destination-receiving_storage_location
              = ls_split-storage_location ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id       = ls_split-request_id
        source_plant     = ls_split-source_plant
        storage_location = ls_split-storage_location
        batch            = ls_split-batch )
        INTO TABLE lt_seen_splits.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_split-material.
      IF sy-subrc <> 0
          OR ( ls_split-base_unit IS NOT INITIAL
            AND ls_split-base_unit <> ls_material_unit-base_unit ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material                   = ls_split-material
        plant                      = ls_split-source_plant
        storage_location           = ls_split-storage_location
        movement_type              = iv_removal_movement_type
        batch                      = ls_split-batch
        quantity                   = ls_split-allocated_quantity
        entry_unit                 = ls_material_unit-base_unit
        entry_unit_iso             = ls_material_unit-base_unit_iso
        receiving_plant            = COND #(
          WHEN iv_removal_movement_type = '303'
            THEN ls_split-target_plant )
        receiving_storage_location = COND #(
          WHEN iv_removal_movement_type = '313'
            THEN ls_destination-receiving_storage_location ) )
        TO lt_removal_items.

      READ TABLE lt_transfer_quantities ASSIGNING <ls_transfer_quantity>
        WITH TABLE KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_transfer_quantity>-quantity = <ls_transfer_quantity>-quantity
        + ls_split-allocated_quantity.
      IF iv_allow_multiple_batches = abap_true.
        READ TABLE lt_transfer_batch_quantities
          ASSIGNING <ls_transfer_batch_quantity>
          WITH KEY request_id = ls_split-request_id
                   batch      = ls_split-batch.
        IF sy-subrc = 0.
          <ls_transfer_batch_quantity>-quantity =
            <ls_transfer_batch_quantity>-quantity
              + ls_split-allocated_quantity.
        ELSE.
          APPEND VALUE #(
            request_id = ls_split-request_id
            batch      = ls_split-batch
            quantity   = ls_split-allocated_quantity )
            TO lt_transfer_batch_quantities.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_transfer_quantities INTO ls_transfer_quantity
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_transfer_quantity-quantity <> ls_demand-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_demand-allocated_quantity = 0.
        CONTINUE.
      ENDIF.
      READ TABLE it_destinations INTO ls_destination
        WITH KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_demand-material.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF iv_allow_multiple_batches = abap_true.
        LOOP AT lt_transfer_batch_quantities INTO ls_transfer_batch_quantity
          WHERE request_id = ls_demand-request_id.
          APPEND VALUE #(
            material         = ls_demand-material
            plant            = ls_demand-target_plant
            storage_location = ls_destination-receiving_storage_location
            movement_type    = lv_putaway_movement_type
            batch            = ls_transfer_batch_quantity-batch
            quantity         = ls_transfer_batch_quantity-quantity
            entry_unit       = ls_material_unit-base_unit
            entry_unit_iso   = ls_material_unit-base_unit_iso )
            TO lt_putaway_items.
        ENDLOOP.
      ELSE.
        APPEND VALUE #(
          material         = ls_demand-material
          plant            = ls_demand-target_plant
          storage_location = ls_destination-receiving_storage_location
          movement_type    = lv_putaway_movement_type
          batch            = ls_demand-batch
          quantity         = ls_demand-allocated_quantity
          entry_unit       = ls_material_unit-base_unit
          entry_unit_iso   = ls_material_unit-base_unit_iso )
          TO lt_putaway_items.
      ENDIF.
    ENDLOOP.

    IF lt_removal_items IS INITIAL OR lt_putaway_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated quantity to transfer' )
        TO rs_result-removal_result-messages.
      RETURN.
    ENDIF.

    rs_result-removal_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_removal_items
      iv_test_run = iv_test_run ).
    IF rs_result-removal_result-is_successful = abap_false.
      RETURN.
    ENDIF.
    IF iv_test_run = abap_false.
      rs_result-is_in_transit = abap_true.
    ENDIF.

    rs_result-putaway_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_putaway_items
      iv_test_run = iv_test_run ).
    IF rs_result-putaway_result-is_successful = abap_true.
      rs_result-is_successful = abap_true.
      rs_result-is_in_transit = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD transfer_location_2step_units.
    DATA ls_base_allocation TYPE zcl_stock_service=>ty_location_result.
    DATA ls_material_unit TYPE ty_transfer_material_unit.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      IF ls_unit_allocation-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_allocation-allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_allocation-allocation
        TO ls_base_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations INTO DATA(ls_unit_split).
      IF ls_unit_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_unit_split-storage_allocation-material.
      IF sy-subrc <> 0
          OR ls_material_unit-base_unit <> ls_unit_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_unit_split-storage_allocation
        TO ls_base_allocation-storage_allocations.
    ENDLOOP.

    rs_result = transfer_location_two_step(
      is_header                  = is_header
      is_allocation              = ls_base_allocation
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation ).
  ENDMETHOD.

  METHOD transfer_location_units_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-allocation-request_id
        material           = ls_allocation-allocation-material
        target_plant       = ls_allocation-allocation-plant
        base_unit          = ls_allocation-base_unit
        requested_quantity =
          ls_allocation-allocation-requested_quantity
        available_quantity =
          ls_allocation-allocation-available_quantity
        allocated_quantity =
          ls_allocation-allocation-allocated_quantity
        shortfall_quantity =
          ls_allocation-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-storage_allocations
      INTO DATA(ls_storage_allocation).
      APPEND VALUE #(
        request_id         =
          ls_storage_allocation-storage_allocation-request_id
        material           =
          ls_storage_allocation-storage_allocation-material
        target_plant       =
          ls_storage_allocation-storage_allocation-plant
        source_plant       =
          ls_storage_allocation-storage_allocation-plant
        storage_location   =
          ls_storage_allocation-storage_allocation-storage_location
        base_unit          = ls_storage_allocation-base_unit
        available_quantity =
          ls_storage_allocation-storage_allocation-allocated_quantity
        allocated_quantity =
          ls_storage_allocation-storage_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_batch_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.

      READ TABLE lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY request_id = ls_batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_demand>-batch IS NOT INITIAL
          AND <ls_demand>-batch <> ls_batch_allocation-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_demand>-batch = ls_batch_allocation-batch.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_fefo_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_allocation).
      APPEND VALUE #(
        request_id         = ls_batch_allocation-request_id
        material           = ls_batch_allocation-material
        target_plant       = ls_batch_allocation-plant
        source_plant       = ls_batch_allocation-plant
        storage_location   = ls_batch_allocation-storage_location
        batch              = ls_batch_allocation-batch
        available_quantity = ls_batch_allocation-allocated_quantity
        allocated_quantity = ls_batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_fefo_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      APPEND VALUE #(
        request_id         = ls_unit_allocation-allocation-request_id
        material           = ls_unit_allocation-allocation-material
        target_plant       = ls_unit_allocation-allocation-plant
        base_unit          = ls_unit_allocation-base_unit
        requested_quantity =
          ls_unit_allocation-allocation-requested_quantity
        available_quantity =
          ls_unit_allocation-allocation-available_quantity
        allocated_quantity =
          ls_unit_allocation-allocation-allocated_quantity
        shortfall_quantity =
          ls_unit_allocation-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-batch_allocation-request_id
        material           = ls_unit_split-batch_allocation-material
        target_plant       = ls_unit_split-batch_allocation-plant
        source_plant       = ls_unit_split-batch_allocation-plant
        storage_location   =
          ls_unit_split-batch_allocation-storage_location
        batch              = ls_unit_split-batch_allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity =
          ls_unit_split-batch_allocation-allocated_quantity
        allocated_quantity =
          ls_unit_split-batch_allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_location_batch_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_allocation).
      APPEND VALUE #(
        request_id         = ls_unit_allocation-allocation-request_id
        material           = ls_unit_allocation-allocation-material
        target_plant       = ls_unit_allocation-allocation-plant
        base_unit          = ls_unit_allocation-base_unit
        requested_quantity =
          ls_unit_allocation-allocation-requested_quantity
        available_quantity =
          ls_unit_allocation-allocation-available_quantity
        allocated_quantity =
          ls_unit_allocation-allocation-allocated_quantity
        shortfall_quantity =
          ls_unit_allocation-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-batch_allocation-request_id
        material           = ls_unit_split-batch_allocation-material
        target_plant       = ls_unit_split-batch_allocation-plant
        source_plant       = ls_unit_split-batch_allocation-plant
        storage_location   =
          ls_unit_split-batch_allocation-storage_location
        batch              = ls_unit_split-batch_allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity =
          ls_unit_split-batch_allocation-allocated_quantity
        allocated_quantity =
          ls_unit_split-batch_allocation-allocated_quantity )
        TO lt_splits.

      READ TABLE lt_demands ASSIGNING FIELD-SYMBOL(<ls_demand>)
        WITH KEY request_id = ls_unit_split-batch_allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF <ls_demand>-batch IS NOT INITIAL
          AND <ls_demand>-batch <> ls_unit_split-batch_allocation-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_demand>-batch = ls_unit_split-batch_allocation-batch.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_movement_type           = '311' ).
  ENDMETHOD.

  METHOD transfer_plant_batch_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        batch              = ls_allocation-batch
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_location).
      APPEND VALUE #(
        request_id         = ls_location-request_id
        material           = ls_location-material
        target_plant       = ls_location-target_plant
        source_plant       = ls_location-source_plant
        storage_location   = ls_location-storage_location
        batch              = ls_location-batch
        available_quantity = ls_location-available_quantity
        allocated_quantity = ls_location-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_allocation).
      APPEND VALUE #(
        request_id         = ls_allocation-request_id
        material           = ls_allocation-material
        target_plant       = ls_allocation-target_plant
        requested_quantity = ls_allocation-requested_quantity
        available_quantity = ls_allocation-available_quantity
        allocated_quantity = ls_allocation-allocated_quantity
        shortfall_quantity = ls_allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_location).
      APPEND VALUE #(
        request_id         = ls_batch_location-request_id
        material           = ls_batch_location-material
        target_plant       = ls_batch_location-target_plant
        source_plant       = ls_batch_location-source_plant
        storage_location   = ls_batch_location-storage_location
        batch              = ls_batch_location-batch
        available_quantity = ls_batch_location-available_quantity
        allocated_quantity = ls_batch_location-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_units_alloc.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      APPEND VALUE #(
        request_id         = ls_unit_demand-allocation-request_id
        material           = ls_unit_demand-allocation-material
        target_plant       = ls_unit_demand-allocation-target_plant
        base_unit          = ls_unit_demand-base_unit
        requested_quantity = ls_unit_demand-allocation-requested_quantity
        available_quantity = ls_unit_demand-allocation-available_quantity
        allocated_quantity = ls_unit_demand-allocation-allocated_quantity
        shortfall_quantity = ls_unit_demand-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-allocation-request_id
        material           = ls_unit_split-allocation-material
        target_plant       = ls_unit_split-allocation-target_plant
        source_plant       = ls_unit_split-allocation-source_plant
        storage_location   = ls_unit_split-allocation-storage_location
        base_unit          = ls_unit_split-base_unit
        available_quantity = ls_unit_split-allocation-available_quantity
        allocated_quantity = ls_unit_split-allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false ).
  ENDMETHOD.

  METHOD transfer_plant_batch_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      APPEND VALUE #(
        request_id         = ls_unit_demand-allocation-request_id
        material           = ls_unit_demand-allocation-material
        target_plant       = ls_unit_demand-allocation-target_plant
        batch              = ls_unit_demand-allocation-batch
        base_unit          = ls_unit_demand-base_unit
        requested_quantity = ls_unit_demand-allocation-requested_quantity
        available_quantity = ls_unit_demand-allocation-available_quantity
        allocated_quantity = ls_unit_demand-allocation-allocated_quantity
        shortfall_quantity = ls_unit_demand-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-allocation-request_id
        material           = ls_unit_split-allocation-material
        target_plant       = ls_unit_split-allocation-target_plant
        source_plant       = ls_unit_split-allocation-source_plant
        storage_location   = ls_unit_split-allocation-storage_location
        batch              = ls_unit_split-allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity = ls_unit_split-allocation-available_quantity
        allocated_quantity = ls_unit_split-allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_fefo_units.
    DATA lt_demands TYPE ty_transfer_demands.
    DATA lt_splits TYPE ty_transfer_splits.

    LOOP AT is_allocation-allocations INTO DATA(ls_unit_demand).
      APPEND VALUE #(
        request_id         = ls_unit_demand-allocation-request_id
        material           = ls_unit_demand-allocation-material
        target_plant       = ls_unit_demand-allocation-target_plant
        base_unit          = ls_unit_demand-base_unit
        requested_quantity = ls_unit_demand-allocation-requested_quantity
        available_quantity = ls_unit_demand-allocation-available_quantity
        allocated_quantity = ls_unit_demand-allocation-allocated_quantity
        shortfall_quantity = ls_unit_demand-allocation-shortfall_quantity )
        TO lt_demands.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_unit_split).
      APPEND VALUE #(
        request_id         = ls_unit_split-allocation-request_id
        material           = ls_unit_split-allocation-material
        target_plant       = ls_unit_split-allocation-target_plant
        source_plant       = ls_unit_split-allocation-source_plant
        storage_location   = ls_unit_split-allocation-storage_location
        batch              = ls_unit_split-allocation-batch
        base_unit          = ls_unit_split-base_unit
        available_quantity = ls_unit_split-allocation-available_quantity
        allocated_quantity = ls_unit_split-allocation-allocated_quantity )
        TO lt_splits.
    ENDLOOP.

    rs_result = transfer_plant_splits(
      is_header                  = is_header
      it_demands                 = lt_demands
      it_splits                  = lt_splits
      it_destinations            = it_destinations
      it_material_units          = it_material_units
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true ).
  ENDMETHOD.

  METHOD transfer_plant_splits.
    DATA lt_seen_requests TYPE ty_transfer_request_keys.
    DATA lt_seen_destinations TYPE ty_transfer_request_keys.
    DATA lt_seen_material_units TYPE ty_transfer_material_keys.
    DATA lt_seen_splits TYPE ty_transfer_split_keys.
    DATA lt_transfer_quantities TYPE ty_transfer_quantities.
    DATA lt_items TYPE zif_goods_movement_api=>ty_items.
    DATA ls_demand TYPE ty_transfer_demand.
    DATA ls_split TYPE ty_transfer_split.
    DATA ls_destination TYPE ty_transfer_destination.
    DATA ls_material_unit TYPE ty_transfer_material_unit.
    DATA ls_transfer_quantity TYPE ty_transfer_quantity.
    FIELD-SYMBOLS <ls_transfer_quantity> TYPE ty_transfer_quantity.

    IF it_demands IS INITIAL
        OR ( iv_movement_type <> '301'
          AND iv_movement_type <> '311' ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_demands INTO ls_demand.
      IF ls_demand-request_id IS INITIAL
          OR ls_demand-material IS INITIAL
          OR ls_demand-target_plant IS INITIAL
          OR ls_demand-requested_quantity < 0
          OR ls_demand-available_quantity < 0
          OR ls_demand-allocated_quantity < 0
          OR ls_demand-shortfall_quantity < 0
          OR ls_demand-allocated_quantity > ls_demand-requested_quantity
          OR ls_demand-allocated_quantity > ls_demand-available_quantity
          OR ls_demand-allocated_quantity + ls_demand-shortfall_quantity
            <> ls_demand-requested_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_demand-base_unit IS NOT INITIAL.
        READ TABLE it_material_units INTO ls_material_unit
          WITH KEY material = ls_demand-material.
        IF sy-subrc <> 0
            OR ls_demand-base_unit <> ls_material_unit-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ENDIF.

      INSERT VALUE #( request_id = ls_demand-request_id )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_demand-request_id
        quantity   = 0 ) INTO TABLE lt_transfer_quantities.

      IF iv_require_full_allocation = abap_true
          AND ls_demand-shortfall_quantity > 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_destinations INTO ls_destination.
      IF ls_destination-request_id IS INITIAL
          OR ls_destination-receiving_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( request_id = ls_destination-request_id )
        INTO TABLE lt_seen_destinations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_destination-request_id.
      IF sy-subrc <> 0 OR ls_demand-allocated_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_material_units INTO ls_material_unit.
      IF ls_material_unit-material IS INITIAL
          OR ls_material_unit-base_unit IS INITIAL
          OR ls_material_unit-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #( material = ls_material_unit-material )
        INTO TABLE lt_seen_material_units.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_splits INTO ls_split.
      IF ls_split-allocated_quantity < 0
          OR ls_split-available_quantity < 0
          OR ls_split-allocated_quantity > ls_split-available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      IF ls_split-allocated_quantity = 0.
        CONTINUE.
      ENDIF.

      IF ls_split-request_id IS INITIAL
          OR ls_split-material IS INITIAL
          OR ls_split-target_plant IS INITIAL
          OR ls_split-source_plant IS INITIAL
          OR ( iv_movement_type = '301'
            AND ls_split-source_plant = ls_split-target_plant )
          OR ( iv_movement_type = '311'
            AND ls_split-source_plant <> ls_split-target_plant )
          OR ls_split-storage_location IS INITIAL
          OR ( iv_require_batch = abap_true AND ls_split-batch IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_demands INTO ls_demand
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ls_demand-material <> ls_split-material
          OR ls_demand-target_plant <> ls_split-target_plant
          OR ( ls_demand-batch IS NOT INITIAL
            AND ls_demand-batch <> ls_split-batch ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        request_id       = ls_split-request_id
        source_plant     = ls_split-source_plant
        storage_location = ls_split-storage_location
        batch            = ls_split-batch )
        INTO TABLE lt_seen_splits.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE it_destinations INTO ls_destination
        WITH KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0
          OR ( iv_movement_type = '311'
            AND ls_destination-receiving_storage_location
              = ls_split-storage_location ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE it_material_units INTO ls_material_unit
        WITH KEY material = ls_split-material.
      IF sy-subrc <> 0
          OR ( ls_split-base_unit IS NOT INITIAL
            AND ls_split-base_unit <> ls_material_unit-base_unit ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        material                   = ls_split-material
        plant                      = ls_split-source_plant
        storage_location           = ls_split-storage_location
        batch                      = ls_split-batch
        movement_type              = iv_movement_type
        quantity                   = ls_split-allocated_quantity
        entry_unit                 = ls_material_unit-base_unit
        entry_unit_iso             = ls_material_unit-base_unit_iso
        receiving_plant            = COND #(
          WHEN iv_movement_type = '301' THEN ls_split-target_plant )
        receiving_storage_location =
          ls_destination-receiving_storage_location ) TO lt_items.

      READ TABLE lt_transfer_quantities ASSIGNING <ls_transfer_quantity>
        WITH TABLE KEY request_id = ls_split-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_transfer_quantity>-quantity = <ls_transfer_quantity>-quantity
        + ls_split-allocated_quantity.
    ENDLOOP.

    LOOP AT it_demands INTO ls_demand.
      READ TABLE lt_transfer_quantities INTO ls_transfer_quantity
        WITH TABLE KEY request_id = ls_demand-request_id.
      IF sy-subrc <> 0
          OR ls_transfer_quantity-quantity <> ls_demand-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lt_items IS INITIAL.
      rs_result-is_successful = abap_true.
      APPEND VALUE #(
        type    = 'W'
        message = 'No allocated quantity to transfer' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = execute(
      is_header   = is_header
      iv_gm_code  = '04'
      it_items    = lt_items
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD cancel.
    DATA lt_seen_item_numbers TYPE
      zif_goods_movement_api=>ty_material_document_items.

    IF iv_material_document IS INITIAL
        OR iv_fiscal_year IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      IF lv_item_number IS INITIAL
          OR line_exists( lt_seen_item_numbers[
            table_line = lv_item_number ] ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND lv_item_number TO lt_seen_item_numbers.
    ENDLOOP.

    rs_result = mo_api->cancel_movement(
      iv_material_document = iv_material_document
      iv_fiscal_year       = iv_fiscal_year
      iv_posting_date      = iv_posting_date
      it_item_numbers      = it_item_numbers ).

    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      RETURN.
    ENDIF.

    IF rs_result-material_document IS INITIAL
        OR rs_result-fiscal_year IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Cancellation did not return a material document' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

ENDCLASS.
