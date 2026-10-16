CLASS zcl_alloc_copro_share DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             product TYPE string,
             qty     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS share_percent
      IMPORTING
        iv_part_qty       TYPE i
        iv_total_qty      TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS largest
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rv_product) TYPE string.

    METHODS is_zero
      IMPORTING
        iv_qty       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_copro_share IMPLEMENTATION.

  METHOD share_percent.
    " The share is one product's quantity as a percentage of the joint.
    IF iv_total_qty = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part_qty * 100 DIV iv_total_qty.
  ENDMETHOD.

  METHOD largest.
    DATA lv_max TYPE i.

    " The largest product carries the most quantity.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-qty > lv_max.
        lv_max = ls_line-qty.
        rv_product = ls_line-product.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_zero.
    " The quantity is nil at zero.
    rv_ok = xsdbool( iv_qty = 0 ).
  ENDMETHOD.

ENDCLASS.
