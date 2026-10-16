CLASS zcl_alloc_core_return DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_core,
             material TYPE matnr,
             quantity TYPE i,
             returned TYPE i,
           END OF ty_core.
    TYPES ty_core_tt TYPE STANDARD TABLE OF ty_core WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        is_core TYPE ty_core.

    METHODS outstanding
      IMPORTING
        iv_material   TYPE matnr
      RETURNING
        VALUE(rv_qty) TYPE i.

    METHODS is_returned
      IMPORTING
        iv_material  TYPE matnr
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS clear.

  PRIVATE SECTION.
    DATA mt_cores TYPE ty_core_tt.

ENDCLASS.


CLASS zcl_alloc_core_return IMPLEMENTATION.

  METHOD add.
    APPEND is_core TO mt_cores.
  ENDMETHOD.

  METHOD outstanding.
    DATA lv_open TYPE i.

    " The outstanding quantity is summed across every core record of a material,
    " with an over-return on one record never cancelling a shortfall on another.
    LOOP AT mt_cores INTO DATA(ls_core).
      IF ls_core-material <> iv_material.
        CONTINUE.
      ENDIF.

      lv_open = ls_core-quantity - ls_core-returned.
      IF lv_open > 0.
        rv_qty = rv_qty + lv_open.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_returned.
    DATA lv_found TYPE abap_bool.

    rv_ok = abap_false.

    LOOP AT mt_cores INTO DATA(ls_core).
      IF ls_core-material <> iv_material.
        CONTINUE.
      ENDIF.

      lv_found = abap_true.

      IF ls_core-returned < ls_core-quantity.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF lv_found = abap_true.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD clear.
    CLEAR mt_cores.
  ENDMETHOD.

ENDCLASS.
