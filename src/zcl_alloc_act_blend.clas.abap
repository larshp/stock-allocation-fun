CLASS zcl_alloc_act_blend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name     TYPE string,
             quantity TYPE i,
             rate     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS blend
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS weight_of
      IMPORTING
        iv_quantity       TYPE i
        iv_total_quantity TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS blended
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rv_cost) TYPE i.

ENDCLASS.


CLASS zcl_alloc_act_blend IMPLEMENTATION.

  METHOD blend.
    DATA lv_cost TYPE i.
    DATA lv_qty  TYPE i.

    " The blend is the weighted average rate over the quantities.
    LOOP AT it_lines INTO DATA(ls_line).
      lv_cost = lv_cost + ls_line-quantity * ls_line-rate.
      lv_qty = lv_qty + ls_line-quantity.
    ENDLOOP.

    IF lv_qty = 0.
      RETURN.
    ENDIF.

    rv_rate = lv_cost DIV lv_qty.
  ENDMETHOD.

  METHOD weight_of.
    " The weight is one quantity as a share of the whole.
    IF iv_total_quantity = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_quantity * 100 DIV iv_total_quantity.
  ENDMETHOD.

  METHOD blended.
    " The blended cost adds the cost of every activity line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_cost = rv_cost + ls_line-quantity * ls_line-rate.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
