CLASS zcl_alloc_lot_ppb DEFINITION
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

    TYPES: BEGIN OF ty_cost,
             setup_cost  TYPE menge_d,
             unit_cost   TYPE menge_d,
             holding_pct TYPE i,
             max_periods TYPE i,
           END OF ty_cost.

    METHODS size
      IMPORTING
        it_demand      TYPE ty_series_tt
        is_cost        TYPE ty_cost
      RETURNING
        VALUE(rt_lots) TYPE ty_lot_tt.

ENDCLASS.


CLASS zcl_alloc_lot_ppb IMPLEMENTATION.

  METHOD size.
    DATA lv_count     TYPE i.
    DATA lv_start     TYPE i.
    DATA lv_end       TYPE i.
    DATA lv_k         TYPE i.
    DATA lv_pos       TYPE i.
    DATA lv_setup     TYPE menge_d.
    DATA lv_hold_unit TYPE menge_d.
    DATA lv_add_hold  TYPE menge_d.
    DATA lv_hold      TYPE menge_d.
    DATA lv_qty       TYPE menge_d.
    DATA ls_lot       TYPE ty_lot.

    lv_count = lines( it_demand ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    " Both the setup cost and the holding cost are kept in hundredths of the
    " currency, so the accumulation can stop exactly when the holding cost of
    " the extra period would exceed the setup cost it is supposed to save.
    lv_setup = is_cost-setup_cost * 100.
    lv_hold_unit = is_cost-unit_cost * is_cost-holding_pct.

    lv_start = 1.
    WHILE lv_start <= lv_count.
      lv_qty = 0.
      lv_hold = 0.
      lv_end = lv_start.

      lv_k = lv_start.
      WHILE lv_k <= lv_count.
        READ TABLE it_demand INTO DATA(lv_value) INDEX lv_k.

        lv_pos = lv_k - lv_start.
        lv_add_hold = lv_hold_unit * lv_value * lv_pos.

        IF lv_k > lv_start AND lv_hold + lv_add_hold > lv_setup.
          EXIT.
        ENDIF.

        IF lv_k > lv_start.
          lv_hold = lv_hold + lv_add_hold.
        ENDIF.

        lv_qty = lv_qty + lv_value.
        lv_end = lv_k.

        IF is_cost-max_periods > 0
           AND lv_end - lv_start + 1 >= is_cost-max_periods.
          EXIT.
        ENDIF.

        lv_k = lv_k + 1.
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
