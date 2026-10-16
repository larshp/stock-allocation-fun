CLASS zcl_alloc_putaway_near DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin_id   TYPE string,
             free     TYPE i,
             distance TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    METHODS nearest
      IMPORTING
        it_bins       TYPE ty_bin_tt
        iv_qty        TYPE i
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_putaway_near IMPLEMENTATION.

  METHOD nearest.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    LOOP AT it_bins INTO DATA(ls_bin).
      IF ls_bin-free < iv_qty.
        CONTINUE.
      ENDIF.

      IF lv_found = abap_false OR ls_bin-distance < lv_best.
        lv_found = abap_true.
        lv_best = ls_bin-distance.
        rv_bin = ls_bin-bin_id.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
