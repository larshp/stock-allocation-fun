CLASS zcl_alloc_landed_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS apportion
      IMPORTING
        it_lines         TYPE ty_line_tt
        iv_cost          TYPE i
      RETURNING
        VALUE(rt_shares) TYPE ty_values_tt.

    METHODS value_share
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_index        TYPE i
      RETURNING
        VALUE(rv_share) TYPE i.

    METHODS total
      IMPORTING
        it_shares       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_landed_value IMPLEMENTATION.

  METHOD apportion.
    DATA lv_total TYPE i.
    DATA lv_share TYPE i.
    DATA ls_line  TYPE ty_line.

    " The cost is spread over the lines in proportion to their value.
    LOOP AT it_lines INTO ls_line.
      lv_total = lv_total + ls_line-value.
    ENDLOOP.

    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_lines INTO ls_line.
      lv_share = iv_cost * ls_line-value DIV lv_total.
      APPEND lv_share TO rt_shares.
    ENDLOOP.
  ENDMETHOD.

  METHOD value_share.
    DATA lv_total TYPE i.
    DATA ls_line  TYPE ty_line.

    " The share of a line is its value related to the whole.
    LOOP AT it_lines INTO ls_line.
      lv_total = lv_total + ls_line-value.
    ENDLOOP.

    IF lv_total <= 0 OR iv_index < 1.
      RETURN.
    ENDIF.

    READ TABLE it_lines INTO ls_line INDEX iv_index.
    IF sy-subrc = 0.
      rv_share = ls_line-value * 100 DIV lv_total.
    ENDIF.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_shares INTO DATA(lv_share).
      rv_total = rv_total + lv_share.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
