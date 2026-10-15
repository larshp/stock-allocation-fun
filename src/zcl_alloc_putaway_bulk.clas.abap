CLASS zcl_alloc_putaway_bulk DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin_id   TYPE string,
             material TYPE matnr,
             free     TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    METHODS pick
      IMPORTING
        it_bins       TYPE ty_bin_tt
        iv_material   TYPE matnr
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_putaway_bulk IMPLEMENTATION.

  METHOD pick.
    " Bulk storage consolidates: a bin that already holds the material is filled
    " first, and only if there is none does the first free empty bin get the goods.
    LOOP AT it_bins INTO DATA(ls_bin).
      IF ls_bin-material = iv_material AND ls_bin-free > 0.
        rv_bin = ls_bin-bin_id.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT it_bins INTO DATA(ls_empty).
      IF ls_empty-material IS INITIAL AND ls_empty-free > 0.
        rv_bin = ls_empty-bin_id.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
