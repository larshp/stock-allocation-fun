CLASS zcl_alloc_location_score DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             fill_pct TYPE i,
             distance TYPE i,
             picks    TYPE i,
           END OF ty_input.

    METHODS score
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.


CLASS zcl_alloc_location_score IMPLEMENTATION.

  METHOD score.
    rv_score = is_input-fill_pct * 2
      - is_input-distance
      - is_input-picks * 5.

    IF rv_score < 0.
      rv_score = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
