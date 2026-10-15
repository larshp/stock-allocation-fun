CLASS zcl_alloc_replenish_card DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_plan,
             plan_count     TYPE i,
             total_quantity TYPE i,
           END OF ty_plan.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rs_plan) TYPE ty_plan.

    METHODS total_quantity
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS on_target
      IMPORTING
        iv_total_quantity  TYPE i
        iv_target_quantity TYPE i
      RETURNING
        VALUE(rv_ok)       TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_replenish_card IMPLEMENTATION.

  METHOD total_quantity.
    " The card quantity sums the plan lines.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD on_target.
    " The plan is on target once its quantity reaches the target.
    rv_ok = xsdbool( iv_total_quantity >= iv_target_quantity ).
  ENDMETHOD.

  METHOD build.
    rs_plan-plan_count = lines( it_lines ).
    rs_plan-total_quantity = total_quantity( it_lines ).
  ENDMETHOD.

ENDCLASS.
