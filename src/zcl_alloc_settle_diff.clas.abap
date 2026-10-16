CLASS zcl_alloc_settle_diff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS difference
      IMPORTING
        iv_target      TYPE i
        iv_actual      TYPE i
      RETURNING
        VALUE(rv_diff) TYPE i.

    METHODS is_balanced
      IMPORTING
        iv_difference TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS magnitude
      IMPORTING
        iv_difference       TYPE i
      RETURNING
        VALUE(rv_magnitude) TYPE i.

ENDCLASS.


CLASS zcl_alloc_settle_diff IMPLEMENTATION.

  METHOD difference.
    " The difference is what the actual leaves against the target.
    rv_diff = iv_target - iv_actual.
  ENDMETHOD.

  METHOD is_balanced.
    " The difference is balanced once it nets out.
    rv_ok = xsdbool( iv_difference = 0 ).
  ENDMETHOD.

  METHOD magnitude.
    DATA lv_diff TYPE i.

    " The magnitude is the size of the difference, always positive.
    lv_diff = iv_difference.
    IF lv_diff < 0.
      lv_diff = lv_diff * -1.
    ENDIF.

    rv_magnitude = lv_diff.
  ENDMETHOD.

ENDCLASS.
