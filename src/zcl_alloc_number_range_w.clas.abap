CLASS zcl_alloc_number_range_w DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_reserve,
             range_name TYPE c LENGTH 10,
             requested  TYPE i,
             available  TYPE i,
           END OF ty_reserve.

    TYPES: BEGIN OF ty_state,
             range_name TYPE c LENGTH 10,
             used       TYPE i,
             capacity   TYPE i,
           END OF ty_state.

    METHODS reserve
      IMPORTING
        is_input          TYPE ty_reserve
      RETURNING
        VALUE(rv_granted) TYPE i.

    METHODS exhausted
      IMPORTING
        is_state       TYPE ty_state
      RETURNING
        VALUE(rv_full) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_number_range_w IMPLEMENTATION.

  METHOD reserve.
    IF is_input-requested <= 0 OR is_input-available <= 0.
      rv_granted = 0.
      RETURN.
    ENDIF.

    IF is_input-requested > is_input-available.
      rv_granted = is_input-available.
    ELSE.
      rv_granted = is_input-requested.
    ENDIF.
  ENDMETHOD.

  METHOD exhausted.
    IF is_state-used >= is_state-capacity.
      rv_full = abap_true.
    ELSE.
      rv_full = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
