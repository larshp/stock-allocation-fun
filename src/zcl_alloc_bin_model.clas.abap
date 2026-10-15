CLASS zcl_alloc_bin_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin_id   TYPE string,
             capacity TYPE i,
             used     TYPE i,
           END OF ty_bin.

    METHODS free_space
      IMPORTING
        is_bin         TYPE ty_bin
      RETURNING
        VALUE(rv_free) TYPE i.

    METHODS is_full
      IMPORTING
        is_bin         TYPE ty_bin
      RETURNING
        VALUE(rv_full) TYPE abap_bool.

    METHODS can_hold
      IMPORTING
        is_bin       TYPE ty_bin
        iv_qty       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS add_stock
      IMPORTING
        is_bin        TYPE ty_bin
        iv_qty        TYPE i
      RETURNING
        VALUE(rs_bin) TYPE ty_bin.

ENDCLASS.


CLASS zcl_alloc_bin_model IMPLEMENTATION.

  METHOD free_space.
    DATA lv_free TYPE i.

    IF is_bin-capacity <= 0.
      RETURN.
    ENDIF.

    lv_free = is_bin-capacity - is_bin-used.
    IF lv_free < 0.
      lv_free = 0.
    ENDIF.

    rv_free = lv_free.
  ENDMETHOD.

  METHOD is_full.
    rv_full = xsdbool( free_space( is_bin = is_bin ) <= 0 ).
  ENDMETHOD.

  METHOD can_hold.
    rv_ok = xsdbool( iv_qty > 0
                 AND free_space( is_bin = is_bin ) >= iv_qty ).
  ENDMETHOD.

  METHOD add_stock.
    DATA lv_free TYPE i.

    rs_bin = is_bin.

    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    lv_free = free_space( is_bin = is_bin ).
    IF lv_free >= iv_qty.
      rs_bin-used = is_bin-used + iv_qty.
    ELSE.
      rs_bin-used = is_bin-used + lv_free.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
