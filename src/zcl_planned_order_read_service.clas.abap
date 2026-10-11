CLASS zcl_planned_order_read_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_order_result,
        request_index         TYPE i,
        planned_order         TYPE zif_planned_order_read_repo=>ty_order_number,
        order_header          TYPE zif_planned_order_read_repo=>ty_order_header,
        quantity_in_base_unit TYPE decfloat34,
        is_found              TYPE abap_bool,
        is_quantity_converted TYPE abap_bool,
      END OF ty_order_result.
    TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_read_result,
        orders                  TYPE ty_order_results,
        found_count             TYPE i,
        not_found_count         TYPE i,
        conversion_failed_count TYPE i,
        is_successful           TYPE abap_bool,
      END OF ty_bulk_read_result.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_planned_order_read_repo.

    METHODS read_orders_bulk
      IMPORTING
        it_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers
      RETURNING
        VALUE(rs_result)  TYPE ty_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS validate_order_numbers
      IMPORTING
        it_planned_orders TYPE zif_planned_order_read_repo=>ty_order_numbers
      RAISING
        zcx_invalid_stock_request.

    DATA mo_repository TYPE REF TO zif_planned_order_read_repo.
ENDCLASS.

CLASS zcl_planned_order_read_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD validate_order_numbers.
    TYPES ty_seen_order TYPE zif_planned_order_read_repo=>ty_order_number.
    DATA lt_seen_orders TYPE HASHED TABLE OF ty_seen_order
      WITH UNIQUE KEY table_line.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      INSERT lv_planned_order INTO TABLE lt_seen_orders.
      IF lv_planned_order IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_orders_bulk.
    TYPES:
      ty_order_lookup TYPE HASHED TABLE OF
        zif_planned_order_read_repo=>ty_order_header
        WITH UNIQUE KEY planned_order.
    DATA lt_order_lookup TYPE ty_order_lookup.
    DATA(lo_quantity_calculator) = NEW zcl_planned_order_qty_calc( ).

    rs_result-is_successful = abap_true.
    IF it_planned_orders IS INITIAL.
      RETURN.
    ENDIF.

    validate_order_numbers( it_planned_orders = it_planned_orders ).
    DATA(lt_order_headers) = mo_repository->read_orders(
      it_planned_orders = it_planned_orders ).
    LOOP AT lt_order_headers INTO DATA(ls_lookup_row).
      INSERT ls_lookup_row INTO TABLE lt_order_lookup.
    ENDLOOP.

    LOOP AT it_planned_orders INTO DATA(lv_planned_order).
      DATA(lv_request_index) = sy-tabix.
      APPEND VALUE #(
        request_index = lv_request_index
        planned_order = lv_planned_order ) TO rs_result-orders.
      ASSIGN rs_result-orders[ lv_request_index ]
        TO FIELD-SYMBOL(<ls_order_result>).

      READ TABLE lt_order_lookup
        WITH TABLE KEY planned_order = lv_planned_order
        INTO DATA(ls_order_header).
      IF sy-subrc <> 0.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-not_found_count.
        CONTINUE.
      ENDIF.

      <ls_order_result>-is_found = abap_true.
      <ls_order_result>-order_header = ls_order_header.
      ADD 1 TO rs_result-found_count.

      IF ls_order_header-base_unit IS INITIAL.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-conversion_failed_count.
        CONTINUE.
      ENDIF.

      IF ls_order_header-order_unit = ls_order_header-base_unit.
        <ls_order_result>-quantity_in_base_unit =
          CONV decfloat34( ls_order_header-quantity ).
        <ls_order_result>-is_quantity_converted = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_order_header-unit_to_base_numerator <= 0
          OR ls_order_header-unit_to_base_denominator <= 0.
        rs_result-is_successful = abap_false.
        ADD 1 TO rs_result-conversion_failed_count.
        CONTINUE.
      ENDIF.

      <ls_order_result>-quantity_in_base_unit =
        lo_quantity_calculator->calculate_open_base_quantity(
          iv_planned_quantity   = ls_order_header-quantity
          iv_unit_to_base_num   =
            ls_order_header-unit_to_base_numerator
          iv_unit_to_base_denom =
            ls_order_header-unit_to_base_denominator ).
      <ls_order_result>-is_quantity_converted = abap_true.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
