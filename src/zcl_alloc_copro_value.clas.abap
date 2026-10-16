CLASS zcl_alloc_copro_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS value_of
      IMPORTING
        iv_qty          TYPE i
        iv_unit_value   TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS is_zero
      IMPORTING
        iv_value     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS per_unit
      IMPORTING
        iv_value       TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_copro_value IMPLEMENTATION.

  METHOD value_of.
    " The value of a by-product is its quantity at the unit value.
    rv_value = iv_qty * iv_unit_value.
  ENDMETHOD.

  METHOD is_zero.
    " The value is nil at zero.
    rv_ok = xsdbool( iv_value = 0 ).
  ENDMETHOD.

  METHOD per_unit.
    " The unit value spreads the value over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_value DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
