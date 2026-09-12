CLASS zcl_alloc_days_supply DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             stock        TYPE menge_d,
             daily_demand TYPE menge_d,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_days_supply IMPLEMENTATION.

  METHOD calculate.
    IF is_input-daily_demand <= 0.
      rv_days = 0.
      RETURN.
    ENDIF.

    rv_days = is_input-stock DIV is_input-daily_demand.
  ENDMETHOD.

ENDCLASS.
