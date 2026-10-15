CLASS zcl_alloc_return_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_returned    TYPE i
        iv_shipped     TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS rate_percent
      IMPORTING
        iv_returned   TYPE i
        iv_shipped    TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS above_target
      IMPORTING
        iv_percent   TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_rate IMPLEMENTATION.

  METHOD rate.
    " The rate is stated per thousand shipped units, which keeps a small return
    " rate visible where a whole-number percentage would round it to zero.
    IF iv_shipped <= 0 OR iv_returned <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_returned * 1000 DIV iv_shipped.
  ENDMETHOD.

  METHOD rate_percent.
    IF iv_shipped <= 0 OR iv_returned <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_returned * 100 DIV iv_shipped.
  ENDMETHOD.

  METHOD above_target.
    rv_ok = xsdbool( iv_percent > iv_target ).
  ENDMETHOD.

ENDCLASS.
