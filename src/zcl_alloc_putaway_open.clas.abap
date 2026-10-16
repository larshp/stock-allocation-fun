CLASS zcl_alloc_putaway_open DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin_id TYPE string,
             free   TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    METHODS largest_free
      IMPORTING
        it_bins       TYPE ty_bin_tt
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_putaway_open IMPLEMENTATION.

  METHOD largest_free.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    " Open storage spreads the goods: the bin with the most room wins, so a full
    " bin is never chosen.
    LOOP AT it_bins INTO DATA(ls_bin).
      IF ls_bin-free <= 0.
        CONTINUE.
      ENDIF.

      IF lv_found = abap_false OR ls_bin-free > lv_best.
        lv_found = abap_true.
        lv_best = ls_bin-free.
        rv_bin = ls_bin-bin_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
