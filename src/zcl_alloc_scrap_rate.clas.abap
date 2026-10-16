CLASS zcl_alloc_scrap_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS rate
      IMPORTING
        iv_scrapped    TYPE i
        iv_produced    TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS rate_percent
      IMPORTING
        iv_scrapped   TYPE i
        iv_produced   TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS above_target
      IMPORTING
        iv_percent   TYPE i
        iv_target    TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_scrap_rate IMPLEMENTATION.

  METHOD rate.
    " The scrap rate is stated per thousand produced units, which keeps a small
    " rate visible where a whole-number percentage would round it to zero.
    IF iv_produced <= 0 OR iv_scrapped <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_scrapped * 1000 DIV iv_produced.
  ENDMETHOD.

  METHOD rate_percent.
    IF iv_produced <= 0 OR iv_scrapped <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_scrapped * 100 DIV iv_produced.
  ENDMETHOD.

  METHOD above_target.
    rv_ok = xsdbool( iv_percent > iv_target ).
  ENDMETHOD.

ENDCLASS.
