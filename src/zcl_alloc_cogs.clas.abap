CLASS zcl_alloc_cogs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cogs
      IMPORTING
        iv_quantity    TYPE i
        iv_unit_cost   TYPE i
      RETURNING
        VALUE(rv_cogs) TYPE i.

    METHODS unit_cost
      IMPORTING
        iv_cogs        TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_cogs      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cogs IMPLEMENTATION.

  METHOD cogs.
    " The cost of goods sold is the quantity at its unit cost.
    rv_cogs = iv_quantity * iv_unit_cost.
  ENDMETHOD.

  METHOD unit_cost.
    " The unit cost is the whole cost spread over the quantity.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cogs DIV iv_quantity.
  ENDMETHOD.

  METHOD is_zero.
    " Sold goods with no cost carry nothing.
    rv_ok = xsdbool( iv_cogs = 0 ).
  ENDMETHOD.

ENDCLASS.
