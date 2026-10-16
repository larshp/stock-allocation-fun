CLASS zcl_alloc_feasible DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             demand    TYPE menge_d,
             supply    TYPE menge_d,
             min_order TYPE menge_d,
             max_order TYPE menge_d,
             lot_size  TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             feasible  TYPE abap_bool,
             reason    TYPE string,
             orders    TYPE i,
             order_qty TYPE menge_d,
           END OF ty_result.

    METHODS check
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_feasible IMPLEMENTATION.

  METHOD check.
    DATA lv_lots TYPE i.

    IF is_input-demand <= 0.
      rs_result-feasible = abap_true.
      rs_result-reason = 'no demand'.
      RETURN.
    ENDIF.

    IF is_input-supply < is_input-demand.
      rs_result-reason = 'insufficient supply'.
      RETURN.
    ENDIF.

    IF is_input-min_order > 0 AND is_input-demand < is_input-min_order.
      rs_result-reason = 'demand below minimum order quantity'.
      RETURN.
    ENDIF.

    rs_result-order_qty = is_input-demand.

    IF is_input-lot_size > 0.
      lv_lots = is_input-demand DIV is_input-lot_size.
      IF is_input-demand MOD is_input-lot_size > 0.
        lv_lots = lv_lots + 1.
      ENDIF.
      rs_result-order_qty = lv_lots * is_input-lot_size.
    ENDIF.

    rs_result-orders = 1.
    IF is_input-max_order > 0 AND rs_result-order_qty > is_input-max_order.
      rs_result-orders = rs_result-order_qty DIV is_input-max_order.
      IF rs_result-order_qty MOD is_input-max_order > 0.
        rs_result-orders = rs_result-orders + 1.
      ENDIF.
    ENDIF.

    IF rs_result-order_qty > is_input-supply.
      rs_result-orders = 0.
      rs_result-order_qty = 0.
      rs_result-reason = 'order exceeds supply'.
      RETURN.
    ENDIF.

    rs_result-feasible = abap_true.
    rs_result-reason = 'ok'.
  ENDMETHOD.

ENDCLASS.
