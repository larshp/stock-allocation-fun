CLASS zcl_alloc_risk DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_shortage,
             requirement_id TYPE zcl_stock_allocator=>ty_result-requirement_id,
             shortage_qty   TYPE menge_d,
           END OF ty_shortage.
    TYPES ty_shortage_tt TYPE STANDARD TABLE OF ty_shortage WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_risk,
             lines        TYPE i,
             shortage_qty TYPE menge_d,
             risk_pct     TYPE i,
             level        TYPE c LENGTH 1,
           END OF ty_risk.

    METHODS assess
      IMPORTING
        it_shortages   TYPE ty_shortage_tt
        iv_reference   TYPE menge_d DEFAULT 0
      RETURNING
        VALUE(rs_risk) TYPE ty_risk.

ENDCLASS.


CLASS zcl_alloc_risk IMPLEMENTATION.

  METHOD assess.
    LOOP AT it_shortages INTO DATA(ls_shortage).
      rs_risk-lines = rs_risk-lines + 1.
      rs_risk-shortage_qty = rs_risk-shortage_qty + ls_shortage-shortage_qty.
    ENDLOOP.

    IF iv_reference > 0.
      rs_risk-risk_pct = rs_risk-shortage_qty * 100 DIV iv_reference.
    ENDIF.

    IF rs_risk-risk_pct >= 50.
      rs_risk-level = 'H'.
    ELSEIF rs_risk-risk_pct >= 20.
      rs_risk-level = 'M'.
    ELSE.
      rs_risk-level = 'L'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
