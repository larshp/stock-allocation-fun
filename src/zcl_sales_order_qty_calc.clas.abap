CLASS zcl_sales_order_qty_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        is_successful TYPE abap_bool,
        open_quantity TYPE mard-labst,
      END OF ty_result.

    METHODS calculate_open_quantity
      IMPORTING
        iv_ordered_quantity   TYPE mard-labst
        iv_delivered_quantity TYPE mard-labst
        iv_delivery_status    TYPE vbup-lfsta
      RETURNING
        VALUE(rs_result)      TYPE ty_result.
ENDCLASS.

CLASS zcl_sales_order_qty_calc IMPLEMENTATION.

  METHOD calculate_open_quantity.
    rs_result-is_successful = abap_true.

    IF iv_ordered_quantity < 0 OR iv_delivered_quantity < 0.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF iv_delivery_status IS INITIAL OR iv_delivery_status = 'C'.
      RETURN.
    ENDIF.

    IF iv_delivery_status <> 'A' AND iv_delivery_status <> 'B'.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-open_quantity = iv_ordered_quantity - iv_delivered_quantity.
    IF rs_result-open_quantity < 0.
      CLEAR rs_result-open_quantity.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
