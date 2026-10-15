CLASS zcl_alloc_base_units DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS units
      IMPORTING
        it_quantities   TYPE ty_values_tt
      RETURNING
        VALUE(rv_units) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_total       TYPE i
        iv_units       TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_base_units IMPLEMENTATION.

  METHOD units.
    " The units add up over the base quantities.
    LOOP AT it_quantities INTO DATA(lv_quantity).
      rv_units = rv_units + lv_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD per_unit.
    " The unit rate is the cost spread over the units.
    IF iv_units <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_total DIV iv_units.
  ENDMETHOD.

  METHOD total.
    " The total adds up the base values.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
