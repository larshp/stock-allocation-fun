CLASS zcl_alloc_return_putaway DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
             bin      TYPE string,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS propose
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS bin_of
      IMPORTING
        it_lines      TYPE ty_line_tt
        iv_material   TYPE matnr
      RETURNING
        VALUE(rv_bin) TYPE string.

    METHODS line_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_putaway IMPLEMENTATION.

  METHOD propose.
    " Every returned material with a real quantity gets a putaway line into its
    " target storage bin.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL OR ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      APPEND ls_item TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

  METHOD bin_of.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-material = iv_material.
        rv_bin = ls_line-bin.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD line_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
