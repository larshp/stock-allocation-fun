CLASS zcl_alloc_strategy_priority DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_strategy.

ENDCLASS.


CLASS zcl_alloc_strategy_priority IMPLEMENTATION.

  METHOD zif_allocation_strategy~allocate.

    DATA(lv_remaining) = iv_available.
    IF lv_remaining < 0.
      CLEAR lv_remaining.
    ENDIF.

    DATA(lt_sorted) = it_demand.
    SORT lt_sorted BY priority ASCENDING req_date ASCENDING demand_id ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_demand).

      DATA(lv_confirmed) = ls_demand-quantity.
      IF lv_confirmed > lv_remaining.
        lv_confirmed = lv_remaining.
      ENDIF.
      IF lv_confirmed < 0.
        CLEAR lv_confirmed.
      ENDIF.

      APPEND VALUE #(
        demand_id = ls_demand-demand_id
        requested = ls_demand-quantity
        confirmed = lv_confirmed
        shortfall = COND #( WHEN ls_demand-quantity > lv_confirmed
                            THEN ls_demand-quantity - lv_confirmed
                            ELSE 0 ) ) TO rt_allocation.

      lv_remaining = lv_remaining - lv_confirmed.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
