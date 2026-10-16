CLASS zcl_alloc_footprint DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             distance_km TYPE i,
             quantity    TYPE menge_d,
             factor      TYPE menge_d,
           END OF ty_input.

    METHODS estimate
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rv_value) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_footprint IMPLEMENTATION.

  METHOD estimate.
    rv_value = is_input-distance_km * is_input-quantity * is_input-factor.
  ENDMETHOD.

ENDCLASS.
