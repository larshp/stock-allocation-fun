CLASS zcl_alloc_unit_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS basis
      IMPORTING
        iv_total_cost  TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS total_of
      IMPORTING
        iv_unit_cost    TYPE i
        iv_quantity     TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_unit_cost TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_unit_cost IMPLEMENTATION.

  METHOD basis.
    " The unit cost spreads the total cost over the quantity.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_total_cost DIV iv_quantity.
  ENDMETHOD.

  METHOD total_of.
    " The total is the unit cost carried over the whole quantity.
    rv_total = iv_unit_cost * iv_quantity.
  ENDMETHOD.

  METHOD is_zero.
    " A unit cost of zero means the stock carries no value.
    rv_ok = xsdbool( iv_unit_cost = 0 ).
  ENDMETHOD.

ENDCLASS.
