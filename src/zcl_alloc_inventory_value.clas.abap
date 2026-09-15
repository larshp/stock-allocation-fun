CLASS zcl_alloc_inventory_value DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             quantity TYPE menge_d,
             price    TYPE menge_d,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rv_value) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_inventory_value IMPLEMENTATION.

  METHOD calculate.
    rv_value = is_input-quantity * is_input-price.
  ENDMETHOD.

ENDCLASS.
