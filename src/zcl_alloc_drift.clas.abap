CLASS zcl_alloc_drift DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             baseline  TYPE menge_d,
             current   TYPE menge_d,
             tolerance TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_drift,
             delta     TYPE menge_d,
             drift_pct TYPE i,
             direction TYPE string,
             is_drift  TYPE abap_bool,
           END OF ty_drift.

    METHODS detect
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rs_drift) TYPE ty_drift.

ENDCLASS.


CLASS zcl_alloc_drift IMPLEMENTATION.

  METHOD detect.
    DATA lv_abs   TYPE menge_d.
    DATA lv_total TYPE menge_d.

    rs_drift-delta = is_input-current - is_input-baseline.
    rs_drift-direction = 'flat'.

    IF rs_drift-delta > 0.
      rs_drift-direction = 'up'.
    ELSEIF rs_drift-delta < 0.
      rs_drift-direction = 'down'.
    ENDIF.

    lv_abs = rs_drift-delta.
    IF lv_abs < 0.
      lv_abs = 0 - lv_abs.
    ENDIF.

    lv_total = is_input-baseline.
    IF lv_total < 0.
      lv_total = 0 - lv_total.
    ENDIF.

    IF lv_total > 0.
      rs_drift-drift_pct = lv_abs * 100 DIV lv_total.
    ELSEIF lv_abs > 0.
      rs_drift-drift_pct = 100.
    ENDIF.

    IF lv_abs > is_input-tolerance.
      rs_drift-is_drift = abap_true.
    ELSE.
      rs_drift-is_drift = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
