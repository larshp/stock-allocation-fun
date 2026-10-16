CLASS zcl_alloc_unit_display DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             quantity TYPE menge_d,
             unit     TYPE meins,
             decimals TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             quantity TYPE menge_d,
             unit     TYPE meins,
             decimals TYPE i,
             factor   TYPE i,
             scaled   TYPE i,
           END OF ty_result.

    METHODS format
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

  PRIVATE SECTION.
    CONSTANTS c_max_decimals TYPE i VALUE 3.

ENDCLASS.


CLASS zcl_alloc_unit_display IMPLEMENTATION.

  METHOD format.
    DATA lv_used   TYPE i.
    DATA lv_left   TYPE i.
    DATA lv_fac    TYPE i.
    DATA lv_scaled TYPE menge_d.

    lv_used = is_input-decimals.
    IF lv_used < 0.
      lv_used = 0.
    ENDIF.
    IF lv_used > c_max_decimals.
      lv_used = c_max_decimals.
    ENDIF.

    " The factor turns the requested number of decimals into an integer scale,
    " so the caller can render the value without floating point arithmetic.
    lv_fac = 1.
    lv_left = lv_used.
    WHILE lv_left > 0.
      lv_fac = lv_fac * 10.
      lv_left = lv_left - 1.
    ENDWHILE.

    rs_result-quantity = is_input-quantity.
    rs_result-unit = is_input-unit.
    rs_result-decimals = lv_used.
    rs_result-factor = lv_fac.

    " Integer division by one truncates, which keeps the scaled value an exact
    " whole number of scaled units.
    lv_scaled = is_input-quantity * lv_fac.
    rs_result-scaled = lv_scaled DIV 1.
  ENDMETHOD.

ENDCLASS.
