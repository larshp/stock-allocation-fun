CLASS zcl_alloc_lot_luc DEFINITION
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
           END OF ty_cost.

    METHODS size
      IMPORTING
        it_demand      TYPE ty_series_tt
        is_cost        TYPE ty_cost
      RETURNING
        VALUE(rt_lots) TYPE ty_lot_tt.

ENDCLASS.


CLASS zcl_alloc_lot_luc IMPLEMENTATION.

  METHOD size.
    DATA lv_count     TYPE i.
    DATA lv_start     TYPE i.
    DATA lv_k         TYPE i.
    DATA lv_pos       TYPE i.
    DATA lv_best      TYPE i.
    DATA lv_setup     TYPE menge_d.
    DATA lv_unit      TYPE menge_d.
    DATA lv_hold_unit TYPE menge_d.
    DATA lv_add       TYPE menge_d.
    DATA lv_hold      TYPE menge_d.
    DATA lv_qty       TYPE menge_d.
    DATA lv_cost      TYPE menge_d.
    DATA lv_best_qty  TYPE menge_d.
    DATA lv_best_cost TYPE menge_d.
    DATA ls_lot       TYPE ty_lot.

    lv_count = lines( it_demand ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    " Costs are kept in hundredths of the currency so that the comparison of
    " two averages can use exact integer cross multiplication.
    lv_setup = is_cost-setup_cost * 100.
    lv_unit = is_cost-unit_cost * 100.
    lv_hold_unit = is_cost-unit_cost * is_cost-holding_pct.

    lv_start = 1.
    WHILE lv_start <= lv_count.
      lv_qty = 0.
      lv_cost = lv_setup.
      lv_best = lv_start.
      lv_best_qty = 0.
      lv_best_cost = 0.

      lv_k = lv_start.
      WHILE lv_k <= lv_count.
        lv_pos = lv_k - lv_start.
        READ TABLE it_demand INTO DATA(lv_value) INDEX lv_k.

        lv_add = lv_unit * lv_value.
        lv_hold = lv_hold_unit * lv_value * lv_pos.
        lv_cost = lv_cost + lv_add + lv_hold.
        lv_qty = lv_qty + lv_value.

        IF lv_qty > 0.
          IF lv_best_qty = 0
             OR lv_cost * lv_best_qty < lv_best_cost * lv_qty.
            lv_best = lv_k.
            lv_best_qty = lv_qty.
            lv_best_cost = lv_cost.
          ENDIF.
        ENDIF.

        lv_k = lv_k + 1.
      ENDWHILE.

      CLEAR ls_lot.
      ls_lot-period_from = lv_start.
      ls_lot-period_to = lv_best.
      ls_lot-quantity = lv_best_qty.
      APPEND ls_lot TO rt_lots.

      lv_start = lv_best + 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
