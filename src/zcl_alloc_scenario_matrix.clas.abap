CLASS zcl_alloc_scenario_matrix DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_scenario,
             scenario_id TYPE string,
             uplift_pct  TYPE i,
             stock_pct   TYPE i,
           END OF ty_scenario.
    TYPES ty_scenario_tt TYPE STANDARD TABLE OF ty_scenario WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_cell,
             scenario_id TYPE string,
             requested   TYPE menge_d,
             available   TYPE menge_d,
             allocated   TYPE menge_d,
             shortage    TYPE menge_d,
             fill_x100   TYPE i,
           END OF ty_cell.
    TYPES ty_cell_tt TYPE STANDARD TABLE OF ty_cell WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_scenarios      TYPE ty_scenario_tt
        iv_base_requested TYPE menge_d
        iv_base_available TYPE menge_d
      RETURNING
        VALUE(rt_cells)   TYPE ty_cell_tt.

    METHODS scaled
      IMPORTING
        iv_base         TYPE menge_d
        iv_pct          TYPE i
      RETURNING
        VALUE(rv_value) TYPE menge_d.

    METHODS fill_of
      IMPORTING
        iv_requested   TYPE menge_d
        iv_allocated   TYPE menge_d
      RETURNING
        VALUE(rv_fill) TYPE i.

ENDCLASS.


CLASS zcl_alloc_scenario_matrix IMPLEMENTATION.

  METHOD scaled.
    " A percentage of 100 leaves the base value unchanged.
    rv_value = iv_base * iv_pct DIV 100.

    IF rv_value < 0.
      rv_value = 0.
    ENDIF.
  ENDMETHOD.

  METHOD fill_of.
    IF iv_requested <= 0.
      RETURN.
    ENDIF.

    rv_fill = iv_allocated * 100 DIV iv_requested.
  ENDMETHOD.

  METHOD build.
    DATA ls_cell TYPE ty_cell.

    LOOP AT it_scenarios INTO DATA(ls_scenario).
      CLEAR ls_cell.
      ls_cell-scenario_id = ls_scenario-scenario_id.
      ls_cell-requested = scaled( iv_base = iv_base_requested
                                  iv_pct  = ls_scenario-uplift_pct ).
      ls_cell-available = scaled( iv_base = iv_base_available
                                  iv_pct  = ls_scenario-stock_pct ).

      " Demand is only met up to the stock that is available.
      IF ls_cell-available < ls_cell-requested.
        ls_cell-allocated = ls_cell-available.
      ELSE.
        ls_cell-allocated = ls_cell-requested.
      ENDIF.

      ls_cell-shortage = ls_cell-requested - ls_cell-allocated.
      ls_cell-fill_x100 = fill_of( iv_requested = ls_cell-requested
                                   iv_allocated = ls_cell-allocated ).
      APPEND ls_cell TO rt_cells.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
