CLASS zcl_alloc_base_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS compare
      IMPORTING
        iv_base_a        TYPE i
        iv_base_b        TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS closer
      IMPORTING
        iv_base       TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

    METHODS delta
      IMPORTING
        iv_base_a       TYPE i
        iv_base_b       TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_base_compare IMPLEMENTATION.

  METHOD compare.
    " The smaller base spreads the cost over less ground.
    IF iv_base_a < iv_base_b.
      rv_choice = 'A'.
    ELSEIF iv_base_b < iv_base_a.
      rv_choice = 'B'.
    ELSE.
      rv_choice = 'SAME'.
    ENDIF.
  ENDMETHOD.

  METHOD closer.
    " The distance to the target is what matters, not the side.
    rv_gap = iv_base - iv_target.
    IF rv_gap < 0.
      rv_gap = -1 * rv_gap.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    " The delta is the first base less the second.
    rv_delta = iv_base_a - iv_base_b.
  ENDMETHOD.

ENDCLASS.
