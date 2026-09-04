CLASS zcl_alloc_strategy_fairshare DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

  PRIVATE SECTION.

    "! Quantities are scaled to whole thousandths so the proportions can be
    "! worked out with integer division, which never rounds a line up.
    "! 16 bytes hold 31 digits, enough for the square of the largest quantity.
    TYPES ty_thousandths TYPE p LENGTH 16 DECIMALS 0.

    CONSTANTS c_thousandth TYPE zif_allocation=>ty_quantity VALUE '0.001'.

    METHODS to_thousandths
      IMPORTING
        iv_quantity           TYPE zif_allocation=>ty_quantity
      RETURNING
        VALUE(rv_thousandths) TYPE ty_thousandths.

ENDCLASS.


CLASS zcl_alloc_strategy_fairshare IMPLEMENTATION.

  METHOD zif_allocation_strategy~allocate.

    DATA lv_cum_requested TYPE ty_thousandths.
    DATA lv_cum_confirmed TYPE ty_thousandths.
    DATA lv_target        TYPE ty_thousandths.
    DATA lv_confirmed     TYPE zif_allocation=>ty_quantity.

    DATA(lt_sorted) = it_demand.
    SORT lt_sorted BY priority ASCENDING req_date ASCENDING demand_id ASCENDING.

    DATA(lv_total) = REDUCE ty_thousandths(
      INIT lv_sum = CONV ty_thousandths( 0 )
      FOR ls_line IN lt_sorted
      NEXT lv_sum = lv_sum + to_thousandths( ls_line-quantity ) ).

    DATA(lv_available) = to_thousandths( iv_available ).

    IF lv_total = 0.
      " nothing positive is being asked for, so every line is answered with a
      " zero confirmation. The 1 only keeps the division below defined.
      lv_available = 0.
      lv_total     = 1.
    ELSEIF lv_available > lv_total.
      lv_available = lv_total.
    ENDIF.

    LOOP AT lt_sorted INTO DATA(ls_demand).

      " the share is derived from the running total rather than per line, so
      " the thousandths lost to rounding cannot accumulate into a drift
      lv_cum_requested = lv_cum_requested + to_thousandths( ls_demand-quantity ).
      lv_target        = ( lv_cum_requested * lv_available ) DIV lv_total.

      lv_confirmed     = ( lv_target - lv_cum_confirmed ) * c_thousandth.
      lv_cum_confirmed = lv_target.

      APPEND VALUE #(
        demand_id = ls_demand-demand_id
        req_date  = ls_demand-req_date
        requested = ls_demand-quantity
        confirmed = lv_confirmed
        shortfall = COND #( WHEN ls_demand-quantity > lv_confirmed
                            THEN ls_demand-quantity - lv_confirmed
                            ELSE 0 ) ) TO rt_allocation.

    ENDLOOP.

  ENDMETHOD.

  METHOD to_thousandths.

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_thousandths = iv_quantity * 1000.

  ENDMETHOD.

ENDCLASS.
