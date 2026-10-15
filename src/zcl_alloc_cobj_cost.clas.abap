CLASS zcl_alloc_cobj_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cost
      IMPORTING
        iv_material    TYPE i
        iv_labour      TYPE i
        iv_overhead    TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_cobj_cost IMPLEMENTATION.

  METHOD cost.
    " The cost object cost adds its material, labour and overhead.
    rv_cost = iv_material + iv_labour + iv_overhead.
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the object cost over its quantity.
    IF iv_quantity <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cost DIV iv_quantity.
  ENDMETHOD.

  METHOD is_zero.
    " A cost at zero carries nothing.
    rv_ok = xsdbool( iv_cost = 0 ).
  ENDMETHOD.

ENDCLASS.
