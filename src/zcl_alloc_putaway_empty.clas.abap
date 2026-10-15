CLASS zcl_alloc_putaway_empty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin_id TYPE string,
             used   TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    METHODS next_empty
      IMPORTING
        it_bins       TYPE ty_bin_tt
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_putaway_empty IMPLEMENTATION.

  METHOD next_empty.
    LOOP AT it_bins INTO DATA(ls_bin).
      IF ls_bin-used <= 0.
        rv_bin = ls_bin-bin_id.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
