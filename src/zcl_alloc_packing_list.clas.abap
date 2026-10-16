CLASS zcl_alloc_packing_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_packed,
             pos      TYPE i,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_packed.
    TYPES ty_packed_tt TYPE STANDARD TABLE OF ty_packed WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rt_packed) TYPE ty_packed_tt.

    METHODS total_quantity
      IMPORTING
        it_packed       TYPE ty_packed_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_packing_list IMPLEMENTATION.

  METHOD build.
    DATA lo_sums    TYPE REF TO zcl_alloc_key_map.
    DATA lt_entries TYPE zcl_alloc_key_map=>ty_entry_tt.
    DATA lv_key     TYPE string.
    DATA lv_qty     TYPE menge_d.
    DATA ls_packed  TYPE ty_packed.

    lo_sums = NEW zcl_alloc_key_map( ).

    " put( ) keeps the position of a key that is already there, so the lines keep
    " the first-appearance order of the input while the quantity is summed.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-quantity <= 0.
        CONTINUE.
      ENDIF.

      lv_key = ls_line-material.
      lv_qty = lo_sums->get( iv_key = lv_key ).
      lo_sums->put( iv_key   = lv_key
                    iv_value = lv_qty + ls_line-quantity ).
    ENDLOOP.

    lt_entries = lo_sums->entries( ).

    LOOP AT lt_entries INTO DATA(ls_entry).
      CLEAR ls_packed.
      ls_packed-pos = lines( rt_packed ) + 1.
      ls_packed-material = ls_entry-entry_key.
      ls_packed-quantity = ls_entry-value.
      APPEND ls_packed TO rt_packed.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_quantity.
    LOOP AT it_packed INTO DATA(ls_packed).
      rv_total = rv_total + ls_packed-quantity.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
