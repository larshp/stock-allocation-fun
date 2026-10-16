CLASS zcl_alloc_greedy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_demand,
             demand_id TYPE string,
             quantity  TYPE menge_d,
             priority  TYPE i,
           END OF ty_demand.
    TYPES ty_demand_tt TYPE STANDARD TABLE OF ty_demand WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_assignment,
             demand_id TYPE string,
             allocated TYPE menge_d,
             shortage  TYPE menge_d,
           END OF ty_assignment.
    TYPES ty_assignment_tt TYPE STANDARD TABLE OF ty_assignment WITH DEFAULT KEY.

    METHODS solve
      IMPORTING
        it_demands       TYPE ty_demand_tt
        iv_stock         TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE ty_assignment_tt.

    METHODS total_shortage
      IMPORTING
        it_result       TYPE ty_assignment_tt
      RETURNING
        VALUE(rv_short) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_greedy IMPLEMENTATION.

  METHOD solve.
    DATA lt_sorted TYPE ty_demand_tt.
    DATA ls_result TYPE ty_assignment.
    DATA lv_free   TYPE menge_d.

    IF lines( it_demands ) = 0.
      RETURN.
    ENDIF.

    lt_sorted = it_demands.
    SORT lt_sorted BY priority ASCENDING.

    lv_free = iv_stock.
    IF lv_free < 0.
      lv_free = 0.
    ENDIF.

    LOOP AT lt_sorted INTO DATA(ls_demand).
      CLEAR ls_result.
      ls_result-demand_id = ls_demand-demand_id.

      IF ls_demand-quantity > lv_free.
        ls_result-allocated = lv_free.
        ls_result-shortage = ls_demand-quantity - lv_free.
        lv_free = 0.
      ELSE.
        ls_result-allocated = ls_demand-quantity.
        lv_free = lv_free - ls_demand-quantity.
      ENDIF.

      APPEND ls_result TO rt_result.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_shortage.
    LOOP AT it_result INTO DATA(ls_result).
      rv_short = rv_short + ls_result-shortage.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
