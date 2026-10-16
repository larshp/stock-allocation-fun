CLASS zcl_alloc_stdcost_compare DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS compare
      IMPORTING
        iv_left          TYPE i
        iv_right         TYPE i
      RETURNING
        VALUE(rv_choice) TYPE string.

    METHODS higher
      IMPORTING
        iv_left          TYPE i
        iv_right         TYPE i
      RETURNING
        VALUE(rv_higher) TYPE i.

    METHODS delta
      IMPORTING
        iv_left         TYPE i
        iv_right        TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stdcost_compare IMPLEMENTATION.

  METHOD compare.
    " Two standard costs read lower, higher or equal.
    IF iv_left < iv_right.
      rv_choice = 'LOWER'.
    ELSEIF iv_left > iv_right.
      rv_choice = 'HIGHER'.
    ELSE.
      rv_choice = 'EQUAL'.
    ENDIF.
  ENDMETHOD.

  METHOD higher.
    " The higher of the two standard costs.
    IF iv_left >= iv_right.
      rv_higher = iv_left.
    ELSE.
      rv_higher = iv_right.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    " The delta is the left cost less the right one.
    rv_delta = iv_left - iv_right.
  ENDMETHOD.

ENDCLASS.
