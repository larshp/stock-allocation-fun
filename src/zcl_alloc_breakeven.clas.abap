CLASS zcl_alloc_breakeven DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             fixed_cost TYPE menge_d,
             unit_price TYPE menge_d,
             unit_cost  TYPE menge_d,
             max_units  TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             break_even_units TYPE i,
             margin_per_unit  TYPE menge_d,
             found            TYPE abap_bool,
           END OF ty_result.

    METHODS solve
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_breakeven IMPLEMENTATION.

  METHOD solve.
    DATA lv_units TYPE i.

    rs_result-margin_per_unit = is_input-unit_price - is_input-unit_cost.

    IF rs_result-margin_per_unit <= 0.
      RETURN.
    ENDIF.

    IF is_input-fixed_cost <= 0.
      rs_result-found = abap_true.
      RETURN.
    ENDIF.

    lv_units = is_input-fixed_cost DIV rs_result-margin_per_unit.
    IF is_input-fixed_cost MOD rs_result-margin_per_unit > 0.
      lv_units = lv_units + 1.
    ENDIF.

    rs_result-break_even_units = lv_units.

    IF is_input-max_units > 0 AND lv_units > is_input-max_units.
      RETURN.
    ENDIF.

    rs_result-found = abap_true.
  ENDMETHOD.

ENDCLASS.
