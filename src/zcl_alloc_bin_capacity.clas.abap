CLASS zcl_alloc_bin_capacity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS overloaded
      IMPORTING
        iv_used        TYPE i
        iv_capacity    TYPE i
      RETURNING
        VALUE(rv_over) TYPE abap_bool.

    METHODS overflow
      IMPORTING
        iv_used          TYPE i
        iv_capacity      TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS utilisation
      IMPORTING
        iv_used       TYPE i
        iv_capacity   TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bin_capacity IMPLEMENTATION.

  METHOD overloaded.
    rv_over = xsdbool( iv_capacity > 0 AND iv_used > iv_capacity ).
  ENDMETHOD.

  METHOD overflow.
    IF iv_capacity <= 0 OR iv_used <= iv_capacity.
      RETURN.
    ENDIF.

    rv_amount = iv_used - iv_capacity.
  ENDMETHOD.

  METHOD utilisation.
    IF iv_capacity <= 0 OR iv_used <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_used * 100 DIV iv_capacity.
  ENDMETHOD.

ENDCLASS.
