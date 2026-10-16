CLASS zcl_alloc_copro_cost DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cost
      IMPORTING
        iv_joint_cost    TYPE i
        iv_share_percent TYPE i
      RETURNING
        VALUE(rv_cost)   TYPE i.

    METHODS per_unit
      IMPORTING
        iv_cost        TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_cost      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_copro_cost IMPLEMENTATION.

  METHOD cost.
    " A product carries its share of the joint cost.
    rv_cost = iv_joint_cost * iv_share_percent DIV 100.
  ENDMETHOD.

  METHOD per_unit.
    " The unit cost spreads the product cost over its quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_cost DIV iv_qty.
  ENDMETHOD.

  METHOD is_zero.
    " The product cost is nil at zero.
    rv_ok = xsdbool( iv_cost = 0 ).
  ENDMETHOD.

ENDCLASS.
