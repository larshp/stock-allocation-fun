CLASS zcl_alloc_absorb_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS compare
      IMPORTING
        iv_amount_a      TYPE i
        iv_amount_b      TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS closer
      IMPORTING
        iv_amount     TYPE i
        iv_target     TYPE i
      RETURNING
        VALUE(rv_gap) TYPE i.

    METHODS delta
      IMPORTING
        iv_amount_a     TYPE i
        iv_amount_b     TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_absorb_compare IMPLEMENTATION.

  METHOD compare.
    " The smaller amount absorbs less, the bigger one more.
    IF iv_amount_a < iv_amount_b.
      rv_choice = 'A'.
    ELSEIF iv_amount_b < iv_amount_a.
      rv_choice = 'B'.
    ELSE.
      rv_choice = 'SAME'.
    ENDIF.
  ENDMETHOD.

  METHOD closer.
    " The distance to the target is what matters, not the side.
    rv_gap = iv_amount - iv_target.
    IF rv_gap < 0.
      rv_gap = -1 * rv_gap.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    " The delta is the first amount less the second.
    rv_delta = iv_amount_a - iv_amount_b.
  ENDMETHOD.

ENDCLASS.
