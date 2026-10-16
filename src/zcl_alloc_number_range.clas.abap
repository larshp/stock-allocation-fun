CLASS zcl_alloc_number_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_next,
             current  TYPE i,
             interval TYPE i,
           END OF ty_next.

    TYPES: BEGIN OF ty_range,
             number TYPE i,
             from   TYPE i,
             to     TYPE i,
           END OF ty_range.

    TYPES: BEGIN OF ty_remaining,
             current TYPE i,
             to      TYPE i,
           END OF ty_remaining.

    METHODS next
      IMPORTING
        is_input       TYPE ty_next
      RETURNING
        VALUE(rv_next) TYPE i.

    METHODS in_range
      IMPORTING
        is_input         TYPE ty_range
      RETURNING
        VALUE(rv_inside) TYPE abap_bool.

    METHODS remaining
      IMPORTING
        is_input        TYPE ty_remaining
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_number_range IMPLEMENTATION.

  METHOD next.
    rv_next = is_input-current + is_input-interval.
  ENDMETHOD.

  METHOD in_range.
    IF is_input-number >= is_input-from AND is_input-number <= is_input-to.
      rv_inside = abap_true.
    ELSE.
      rv_inside = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD remaining.
    rv_count = is_input-to - is_input-current.
    IF rv_count < 0.
      rv_count = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
