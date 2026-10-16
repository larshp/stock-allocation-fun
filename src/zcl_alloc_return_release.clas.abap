CLASS zcl_alloc_return_release DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             quantity TYPE i,
             released TYPE i,
           END OF ty_line.

    METHODS release
      IMPORTING
        is_line        TYPE ty_line
        iv_release_qty TYPE i
      RETURNING
        VALUE(rs_line) TYPE ty_line.

    METHODS is_released
      IMPORTING
        is_line      TYPE ty_line
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        is_line       TYPE ty_line
      RETURNING
        VALUE(rv_qty) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_release IMPLEMENTATION.

  METHOD release.
    " Releasing adds to the released quantity but never past the stock on hand.
    rs_line = is_line.

    IF iv_release_qty <= 0 OR is_line-quantity <= 0.
      RETURN.
    ENDIF.

    rs_line-released = is_line-released + iv_release_qty.
    IF rs_line-released > is_line-quantity.
      rs_line-released = is_line-quantity.
    ENDIF.
  ENDMETHOD.

  METHOD is_released.
    rv_ok = xsdbool( is_line-quantity > 0
                     AND is_line-released >= is_line-quantity ).
  ENDMETHOD.

  METHOD remaining.
    " The quantity not yet released never goes below zero.
    IF is_line-quantity <= is_line-released.
      RETURN.
    ENDIF.

    rv_qty = is_line-quantity - is_line-released.
  ENDMETHOD.

ENDCLASS.
