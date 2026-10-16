CLASS zcl_alloc_recon_diff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS difference
      IMPORTING
        iv_left        TYPE i
        iv_right       TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

    METHODS is_balanced
      IMPORTING
        iv_left      TYPE i
        iv_right     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS magnitude
      IMPORTING
        iv_left        TYPE i
        iv_right       TYPE i
      RETURNING
        VALUE(rv_size) TYPE i.

ENDCLASS.


CLASS zcl_alloc_recon_diff IMPLEMENTATION.

  METHOD difference.
    " The difference is one side less the other.
    rv_diff = iv_left - iv_right.
  ENDMETHOD.

  METHOD is_balanced.
    " The two sides are balanced once they agree.
    rv_ok = xsdbool( iv_left = iv_right ).
  ENDMETHOD.

  METHOD magnitude.
    " The magnitude is the size of the difference, whichever side is bigger.
    rv_size = iv_left - iv_right.
    IF rv_size < 0.
      rv_size = -1 * rv_size.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
