CLASS zcl_alloc_wip_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS value_of
      IMPORTING
        iv_material     TYPE i
        iv_labour       TYPE i
        iv_overhead     TYPE i
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


CLASS zcl_alloc_wip_value IMPLEMENTATION.

  METHOD value_of.
    " The work in progress adds its material, labour and overhead.
    rv_value = iv_material + iv_labour + iv_overhead.
  ENDMETHOD.

  METHOD is_zero.
    " Work in progress at zero carries nothing.
    rv_ok = xsdbool( iv_value = 0 ).
  ENDMETHOD.

  METHOD per_unit.
    " The value of one unit out of the whole.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_value DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
