CLASS zcl_alloc_landed_freight DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS apportion
      IMPORTING
        it_lines         TYPE ty_line_tt
        iv_freight       TYPE i
      RETURNING
        VALUE(rt_shares) TYPE ty_values_tt.

    METHODS share_of
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_index        TYPE i
      RETURNING
        VALUE(rv_share) TYPE i.

    METHODS per_unit
      IMPORTING
        it_lines       TYPE ty_line_tt
        iv_freight     TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_landed_freight IMPLEMENTATION.

  METHOD apportion.
    DATA lv_total TYPE i.
    DATA lv_share TYPE i.
    DATA ls_line  TYPE ty_line.

    " The freight is spread over the lines in proportion to their quantity.
    LOOP AT it_lines INTO ls_line.
      lv_total = lv_total + ls_line-quantity.
    ENDLOOP.

    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_lines INTO ls_line.
      lv_share = iv_freight * ls_line-quantity DIV lv_total.
      APPEND lv_share TO rt_shares.
    ENDLOOP.
  ENDMETHOD.

  METHOD share_of.
    DATA lv_total TYPE i.
    DATA ls_line  TYPE ty_line.

    " The share of a line is its quantity related to the whole.
    LOOP AT it_lines INTO ls_line.
      lv_total = lv_total + ls_line-quantity.
    ENDLOOP.

    IF lv_total <= 0 OR iv_index < 1.
      RETURN.
    ENDIF.

    READ TABLE it_lines INTO ls_line INDEX iv_index.
    IF sy-subrc = 0.
      rv_share = ls_line-quantity * 100 DIV lv_total.
    ENDIF.
  ENDMETHOD.

  METHOD per_unit.
    DATA lv_total TYPE i.
    DATA ls_line  TYPE ty_line.

    " The unit freight spreads the cost over the whole quantity.
    LOOP AT it_lines INTO ls_line.
      lv_total = lv_total + ls_line-quantity.
    ENDLOOP.

    IF lv_total <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_freight DIV lv_total.
  ENDMETHOD.

ENDCLASS.
