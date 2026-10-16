CLASS zcl_alloc_area_capacity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS can_add
      IMPORTING
        iv_used      TYPE i
        iv_capacity  TYPE i
        iv_add       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS remaining_after
      IMPORTING
        iv_used             TYPE i
        iv_capacity         TYPE i
        iv_add              TYPE i
      RETURNING
        VALUE(rv_remaining) TYPE i.

    METHODS would_overflow
      IMPORTING
        iv_used        TYPE i
        iv_capacity    TYPE i
        iv_add         TYPE i
      RETURNING
        VALUE(rv_over) TYPE i.

ENDCLASS.


CLASS zcl_alloc_area_capacity IMPLEMENTATION.

  METHOD can_add.
    IF iv_capacity <= 0 OR iv_add <= 0.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( iv_used + iv_add <= iv_capacity ).
  ENDMETHOD.

  METHOD remaining_after.
    DATA lv_after TYPE i.

    IF iv_capacity <= 0.
      RETURN.
    ENDIF.

    lv_after = iv_used + iv_add.
    IF lv_after < iv_capacity.
      rv_remaining = iv_capacity - lv_after.
    ENDIF.
  ENDMETHOD.

  METHOD would_overflow.
    IF iv_capacity <= 0 OR iv_add <= 0.
      RETURN.
    ENDIF.

    IF iv_used + iv_add > iv_capacity.
      rv_over = iv_used + iv_add - iv_capacity.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
