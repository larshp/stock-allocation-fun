CLASS zcl_alloc_putaway_fixed DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_fixed,
             material TYPE matnr,
             bin_id   TYPE string,
           END OF ty_fixed.
    TYPES ty_fixed_tt TYPE STANDARD TABLE OF ty_fixed WITH DEFAULT KEY.

    METHODS assign
      IMPORTING
        it_fixed      TYPE ty_fixed_tt
        iv_material   TYPE matnr
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_putaway_fixed IMPLEMENTATION.

  METHOD assign.
    LOOP AT it_fixed INTO DATA(ls_fixed).
      IF ls_fixed-material = iv_material.
        rv_bin = ls_fixed-bin_id.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
