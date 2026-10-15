CLASS zcl_alloc_return_bin DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin      TYPE string,
             capacity TYPE i,
             used     TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    METHODS select
      IMPORTING
        it_bins       TYPE ty_bin_tt
        iv_quantity   TYPE i
      RETURNING
        VALUE(rv_bin) TYPE string.

    METHODS fits
      IMPORTING
        is_bin       TYPE ty_bin
        iv_quantity  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS best_bin
      IMPORTING
        it_bins       TYPE ty_bin_tt
        iv_quantity   TYPE i
      RETURNING
        VALUE(rv_bin) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_bin IMPLEMENTATION.

  METHOD fits.
    " A bin fits the stock when its free space covers the quantity.
    rv_ok = xsdbool( is_bin-bin IS NOT INITIAL
                     AND iv_quantity > 0
                     AND is_bin-capacity - is_bin-used >= iv_quantity ).
  ENDMETHOD.

  METHOD select.
    " The first bin in the list that fits the stock is chosen.
    LOOP AT it_bins INTO DATA(ls_bin).
      IF fits( is_bin      = ls_bin
               iv_quantity = iv_quantity ) = abap_true.
        rv_bin = ls_bin-bin.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD best_bin.
    DATA lv_free  TYPE i.
    DATA lv_best  TYPE i.
    DATA lv_found TYPE abap_bool.

    " The best bin is the tightest fit: the smallest free space that still takes
    " the whole quantity. The first bin seen breaks a tie.
    LOOP AT it_bins INTO DATA(ls_bin).
      IF fits( is_bin      = ls_bin
               iv_quantity = iv_quantity ) = abap_false.
        CONTINUE.
      ENDIF.

      lv_free = ls_bin-capacity - ls_bin-used.

      IF lv_found = abap_false OR lv_free < lv_best.
        lv_found = abap_true.
        lv_best = lv_free.
        rv_bin = ls_bin-bin.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
