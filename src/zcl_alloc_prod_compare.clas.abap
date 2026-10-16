CLASS zcl_alloc_prod_compare DEFINITION
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

    METHODS cheaper
      IMPORTING
        iv_left           TYPE i
        iv_right          TYPE i
      RETURNING
        VALUE(rv_cheaper) TYPE i.

    METHODS delta
      IMPORTING
        iv_left         TYPE i
        iv_right        TYPE i
      RETURNING
        VALUE(rv_delta) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prod_compare IMPLEMENTATION.

  METHOD compare.
    " Two costs read lower, higher or equal.
    IF iv_left < iv_right.
      rv_choice = 'LOWER'.
    ELSEIF iv_left > iv_right.
      rv_choice = 'HIGHER'.
    ELSE.
      rv_choice = 'EQUAL'.
    ENDIF.
  ENDMETHOD.

  METHOD cheaper.
    " The cheaper of the two costs.
    IF iv_left <= iv_right.
      rv_cheaper = iv_left.
    ELSE.
      rv_cheaper = iv_right.
    ENDIF.
  ENDMETHOD.

  METHOD delta.
    " The delta is the left cost less the right one.
    rv_delta = iv_left - iv_right.
  ENDMETHOD.

ENDCLASS.
