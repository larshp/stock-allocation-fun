CLASS zcl_alloc_lot_period DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_lot,
             period_from TYPE i,
             period_to   TYPE i,
             quantity    TYPE menge_d,
           END OF ty_lot.
    TYPES ty_lot_tt TYPE STANDARD TABLE OF ty_lot WITH DEFAULT KEY.

    METHODS size
      IMPORTING
        it_demand      TYPE ty_series_tt
        iv_periods     TYPE i
      RETURNING
        VALUE(rt_lots) TYPE ty_lot_tt.

ENDCLASS.


CLASS zcl_alloc_lot_period IMPLEMENTATION.

  METHOD size.
    DATA lv_span  TYPE i.
    DATA lv_count TYPE i.
    DATA lv_start TYPE i.
    DATA lv_end   TYPE i.
    DATA lv_pos   TYPE i.
    DATA lv_qty   TYPE menge_d.
    DATA ls_lot   TYPE ty_lot.

    lv_count = lines( it_demand ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    lv_span = iv_periods.
    IF lv_span < 1.
      lv_span = 1.
    ENDIF.

    lv_start = 1.
    WHILE lv_start <= lv_count.
      lv_end = lv_start + lv_span - 1.
      IF lv_end > lv_count.
        lv_end = lv_count.
      ENDIF.

      CLEAR lv_qty.
      lv_pos = lv_start.
      WHILE lv_pos <= lv_end.
        READ TABLE it_demand INTO DATA(lv_value) INDEX lv_pos.
        lv_qty = lv_qty + lv_value.
        lv_pos = lv_pos + 1.
      ENDWHILE.

      CLEAR ls_lot.
      ls_lot-period_from = lv_start.
      ls_lot-period_to = lv_end.
      ls_lot-quantity = lv_qty.
      APPEND ls_lot TO rt_lots.

      lv_start = lv_end + 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
