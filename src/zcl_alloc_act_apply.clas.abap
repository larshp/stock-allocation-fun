CLASS zcl_alloc_act_apply DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             activity TYPE string,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS apply
      IMPORTING
        it_lines       TYPE ty_line_tt
        iv_rate        TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS cost_of
      IMPORTING
        iv_quantity    TYPE i
        iv_rate        TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_applied
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_act_apply IMPLEMENTATION.

  METHOD apply.
    DATA lv_qty TYPE i.

    " The rate is applied to every line and the cost adds up.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_qty = lv_qty + ls_line-quantity.
    ENDLOOP.

    rv_cost = iv_rate * lv_qty.
  ENDMETHOD.

  METHOD cost_of.
    " The cost of one line is its quantity at the rate.
    rv_cost = iv_quantity * iv_rate.
  ENDMETHOD.

  METHOD is_applied.
    " An activity is applied once it carries a cost.
    rv_ok = xsdbool( iv_cost > 0 ).
  ENDMETHOD.

ENDCLASS.
