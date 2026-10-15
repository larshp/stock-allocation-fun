CLASS zcl_alloc_book_phys DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_stock,
             bin_id   TYPE string,
             book     TYPE i,
             physical TYPE i,
           END OF ty_stock.
    TYPES ty_stock_tt TYPE STANDARD TABLE OF ty_stock WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_mismatch,
             bin_id   TYPE string,
             book     TYPE i,
             physical TYPE i,
             diff     TYPE i,
           END OF ty_mismatch.
    TYPES ty_mismatch_tt TYPE STANDARD TABLE OF ty_mismatch WITH DEFAULT KEY.

    METHODS mismatches
      IMPORTING
        it_stock           TYPE ty_stock_tt
      RETURNING
        VALUE(rt_mismatch) TYPE ty_mismatch_tt.

    METHODS is_consistent
      IMPORTING
        it_stock     TYPE ty_stock_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS total_difference
      IMPORTING
        it_stock       TYPE ty_stock_tt
      RETURNING
        VALUE(rv_diff) TYPE i.

ENDCLASS.


CLASS zcl_alloc_book_phys IMPLEMENTATION.

  METHOD mismatches.
    DATA ls_mismatch TYPE ty_mismatch.

    LOOP AT it_stock INTO DATA(ls_stock).
      IF ls_stock-book = ls_stock-physical.
        CONTINUE.
      ENDIF.

      CLEAR ls_mismatch.
      ls_mismatch-bin_id = ls_stock-bin_id.
      ls_mismatch-book = ls_stock-book.
      ls_mismatch-physical = ls_stock-physical.
      ls_mismatch-diff = ls_stock-physical - ls_stock-book.
      APPEND ls_mismatch TO rt_mismatch.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_consistent.
    rv_ok = xsdbool( lines( mismatches( it_stock ) ) = 0 ).
  ENDMETHOD.

  METHOD total_difference.
    " The total nets the differences out, so an overage in one bin can hide a
    " shortage in another; the mismatch list is what shows the detail.
    LOOP AT it_stock INTO DATA(ls_stock).
      rv_diff = rv_diff + ls_stock-physical - ls_stock-book.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
