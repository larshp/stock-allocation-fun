CLASS zcl_alloc_cheapest DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_source,
             source_id TYPE string,
             available TYPE menge_d,
             unit_cost TYPE menge_d,
           END OF ty_source.
    TYPES ty_source_tt TYPE STANDARD TABLE OF ty_source WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_pick,
             source_id TYPE string,
             quantity  TYPE menge_d,
             cost      TYPE menge_d,
           END OF ty_pick.
    TYPES ty_pick_tt TYPE STANDARD TABLE OF ty_pick WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             picks      TYPE ty_pick_tt,
             covered    TYPE menge_d,
             shortfall  TYPE menge_d,
             total_cost TYPE menge_d,
           END OF ty_result.

    METHODS solve
      IMPORTING
        it_sources       TYPE ty_source_tt
        iv_quantity      TYPE menge_d
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_cheapest IMPLEMENTATION.

  METHOD solve.
    DATA lt_sorted TYPE ty_source_tt.
    DATA ls_pick   TYPE ty_pick.
    DATA lv_open   TYPE menge_d.
    DATA lv_take   TYPE menge_d.

    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    lt_sorted = it_sources.
    SORT lt_sorted BY unit_cost ASCENDING.

    lv_open = iv_quantity.

    LOOP AT lt_sorted INTO DATA(ls_source).
      IF lv_open <= 0.
        EXIT.
      ENDIF.

      IF ls_source-available <= 0.
        CONTINUE.
      ENDIF.

      IF ls_source-available < lv_open.
        lv_take = ls_source-available.
      ELSE.
        lv_take = lv_open.
      ENDIF.

      CLEAR ls_pick.
      ls_pick-source_id = ls_source-source_id.
      ls_pick-quantity = lv_take.
      ls_pick-cost = lv_take * ls_source-unit_cost.
      APPEND ls_pick TO rs_result-picks.

      rs_result-covered = rs_result-covered + lv_take.
      rs_result-total_cost = rs_result-total_cost + ls_pick-cost.
      lv_open = lv_open - lv_take.
    ENDLOOP.

    rs_result-shortfall = lv_open.
  ENDMETHOD.

ENDCLASS.
