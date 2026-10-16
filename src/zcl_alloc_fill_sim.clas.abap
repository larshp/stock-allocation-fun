CLASS zcl_alloc_fill_sim DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_series_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             demand TYPE ty_series_tt,
             stock  TYPE ty_series_tt,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             served     TYPE menge_d,
             demand_sum TYPE menge_d,
             fill_x100  TYPE i,
             stockouts  TYPE i,
             periods    TYPE i,
           END OF ty_result.

    METHODS simulate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_fill_sim IMPLEMENTATION.

  METHOD simulate.
    DATA lv_limit  TYPE i.
    DATA lv_pos    TYPE i.
    DATA lv_served TYPE menge_d.

    lv_limit = lines( is_input-demand ).
    IF lines( is_input-stock ) < lv_limit.
      lv_limit = lines( is_input-stock ).
    ENDIF.

    rs_result-periods = lv_limit.

    WHILE lv_pos < lv_limit.
      lv_pos = lv_pos + 1.

      READ TABLE is_input-demand INTO DATA(lv_dem) INDEX lv_pos.
      READ TABLE is_input-stock INTO DATA(lv_stk) INDEX lv_pos.

      rs_result-demand_sum = rs_result-demand_sum + lv_dem.

      IF lv_stk < lv_dem.
        lv_served = lv_stk.
        rs_result-stockouts = rs_result-stockouts + 1.
      ELSE.
        lv_served = lv_dem.
      ENDIF.

      rs_result-served = rs_result-served + lv_served.
    ENDWHILE.

    IF rs_result-demand_sum > 0.
      rs_result-fill_x100 = rs_result-served * 100 DIV rs_result-demand_sum.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
