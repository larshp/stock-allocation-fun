CLASS zcl_alloc_safety_level DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             avg_demand TYPE menge_d,
             sigma      TYPE menge_d,
             lead_time  TYPE i,
             z_x100     TYPE i,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rv_safety) TYPE menge_d.

    METHODS sqrt_of
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_root) TYPE i.

ENDCLASS.


CLASS zcl_alloc_safety_level IMPLEMENTATION.

  METHOD sqrt_of.
    DATA lv_try TYPE i.

    IF iv_value <= 0.
      RETURN.
    ENDIF.

    " Largest integer whose square does not exceed the input.
    lv_try = 1.
    WHILE lv_try * lv_try <= iv_value.
      lv_try = lv_try + 1.
    ENDWHILE.

    rv_root = lv_try - 1.
  ENDMETHOD.

  METHOD calculate.
    DATA lv_root TYPE i.
    DATA lv_work TYPE menge_d.

    IF is_input-sigma <= 0 OR is_input-z_x100 <= 0.
      RETURN.
    ENDIF.

    lv_root = sqrt_of( iv_value = is_input-lead_time ).
    IF lv_root <= 0.
      RETURN.
    ENDIF.

    " Safety stock = service factor * demand deviation * sqrt(lead time).
    lv_work = is_input-sigma * lv_root.
    rv_safety = is_input-z_x100 * lv_work DIV 100.
  ENDMETHOD.

ENDCLASS.
