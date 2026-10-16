CLASS zcl_alloc_act_step DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name TYPE string,
             cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS step
      IMPORTING
        iv_cost         TYPE i
        iv_step_size    TYPE i
      RETURNING
        VALUE(rv_steps) TYPE i.

    METHODS is_stepped
      IMPORTING
        iv_cost      TYPE i
        iv_step_size TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS step_count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_step_size    TYPE i
      RETURNING
        VALUE(rv_steps) TYPE i.

ENDCLASS.


CLASS zcl_alloc_act_step IMPLEMENTATION.

  METHOD step.
    " A step cost is charged in whole steps, rounding up.
    IF iv_step_size <= 0.
      RETURN.
    ENDIF.

    rv_steps = ( iv_cost + iv_step_size - 1 ) DIV iv_step_size.
  ENDMETHOD.

  METHOD is_stepped.
    " A cost is stepped once it does not land exactly on a step boundary.
    IF iv_step_size <= 0.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_cost MOD iv_step_size <> 0 ).
  ENDMETHOD.

  METHOD step_count.
    DATA lv_steps TYPE i.

    " The step count adds the steps needed by every line.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_steps = step( iv_cost = ls_line-cost iv_step_size = iv_step_size ).
      rv_steps = rv_steps + lv_steps.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
