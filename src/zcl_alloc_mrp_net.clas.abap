CLASS zcl_alloc_mrp_net DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             demand       TYPE menge_d,
             stock        TYPE menge_d,
             scheduled_in TYPE menge_d,
             safety_stock TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             net_requirement TYPE menge_d,
             available       TYPE menge_d,
             covered         TYPE menge_d,
           END OF ty_result.

    METHODS calculate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_mrp_net IMPLEMENTATION.

  METHOD calculate.
    DATA lv_open TYPE menge_d.

    lv_open = is_input-stock + is_input-scheduled_in - is_input-safety_stock.

    IF lv_open < 0.
      lv_open = 0.
    ENDIF.

    rs_result-available = lv_open.

    IF is_input-demand <= 0.
      RETURN.
    ENDIF.

    IF lv_open >= is_input-demand.
      rs_result-covered = is_input-demand.
      RETURN.
    ENDIF.

    rs_result-covered = lv_open.
    rs_result-net_requirement = is_input-demand - lv_open.
  ENDMETHOD.

ENDCLASS.
