CLASS zcl_alloc_price_unit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS units_per
      IMPORTING
        iv_price_unit   TYPE i
        iv_base_unit    TYPE i
      RETURNING
        VALUE(rv_units) TYPE i.

    METHODS scale
      IMPORTING
        iv_price        TYPE i
        iv_price_unit   TYPE i
        iv_base_unit    TYPE i
      RETURNING
        VALUE(rv_price) TYPE i.

    METHODS is_bulk
      IMPORTING
        iv_price_unit TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_price_unit IMPLEMENTATION.

  METHOD units_per.
    " The price unit is quoted over this many base units.
    IF iv_base_unit <= 0.
      RETURN.
    ENDIF.

    rv_units = iv_price_unit DIV iv_base_unit.
  ENDMETHOD.

  METHOD scale.
    " The price is carried from the price unit over to the base unit.
    IF iv_price_unit <= 0.
      RETURN.
    ENDIF.

    rv_price = iv_price * iv_base_unit DIV iv_price_unit.
  ENDMETHOD.

  METHOD is_bulk.
    " A price unit of a hundred or more is a bulk quote.
    rv_ok = xsdbool( iv_price_unit >= 100 ).
  ENDMETHOD.

ENDCLASS.
