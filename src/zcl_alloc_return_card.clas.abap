CLASS zcl_alloc_return_card DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_card,
             total     TYPE i,
             on_target TYPE abap_bool,
           END OF ty_card.

    METHODS build
      IMPORTING
        iv_returns     TYPE i
        iv_target      TYPE i
        iv_unit_value  TYPE i
      RETURNING
        VALUE(rs_card) TYPE ty_card.

    METHODS total
      IMPORTING
        iv_returns      TYPE i
        iv_unit_value   TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS on_target
      IMPORTING
        iv_returns   TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_card IMPLEMENTATION.

  METHOD total.
    " The card value is what the returns are worth; a bad input is worth nothing.
    IF iv_returns <= 0 OR iv_unit_value <= 0.
      RETURN.
    ENDIF.

    rv_total = iv_returns * iv_unit_value.
  ENDMETHOD.

  METHOD on_target.
    " Fewer returns is better, so the card is on target at or below the target
    " count.
    rv_ok = xsdbool( iv_target >= 0 AND iv_returns <= iv_target ).
  ENDMETHOD.

  METHOD build.
    rs_card-total = total( iv_returns    = iv_returns
                           iv_unit_value = iv_unit_value ).
    rs_card-on_target = on_target( iv_returns = iv_returns
                                   iv_target  = iv_target ).
  ENDMETHOD.

ENDCLASS.
