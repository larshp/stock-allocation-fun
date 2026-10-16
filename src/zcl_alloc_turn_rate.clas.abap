CLASS zcl_alloc_turn_rate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             consumption   TYPE menge_d,
             average_stock TYPE menge_d,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_rate) TYPE i.

ENDCLASS.


CLASS zcl_alloc_turn_rate IMPLEMENTATION.

  METHOD calculate.
    IF is_input-average_stock <= 0.
      rv_rate = 0.
      RETURN.
    ENDIF.

    rv_rate = is_input-consumption DIV is_input-average_stock.
  ENDMETHOD.

ENDCLASS.
