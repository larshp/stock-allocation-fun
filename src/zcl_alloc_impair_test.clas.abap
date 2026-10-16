CLASS zcl_alloc_impair_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_impaired
      IMPORTING
        iv_book_value  TYPE i
        iv_recoverable TYPE i
      RETURNING
        VALUE(rv_ok)   TYPE abap_bool.

    METHODS gap
      IMPORTING
        iv_book_value  TYPE i
        iv_recoverable TYPE i
      RETURNING
        VALUE(rv_gap)  TYPE i.

    METHODS severity
      IMPORTING
        iv_book_value      TYPE i
        iv_recoverable     TYPE i
      RETURNING
        VALUE(rv_severity) TYPE string.

ENDCLASS.


CLASS zcl_alloc_impair_test IMPLEMENTATION.

  METHOD is_impaired.
    " Stock is impaired once its recoverable amount falls below the book value.
    rv_ok = xsdbool( iv_recoverable < iv_book_value ).
  ENDMETHOD.

  METHOD gap.
    " The gap is what the recoverable amount falls short of the book value.
    IF iv_recoverable >= iv_book_value.
      RETURN.
    ENDIF.

    rv_gap = iv_book_value - iv_recoverable.
  ENDMETHOD.

  METHOD severity.
    DATA lv_gap TYPE i.
    DATA lv_pct TYPE i.

    " How badly the value fell is read from the gap as a share of the book value.
    IF iv_book_value <= 0.
      rv_severity = 'NONE'.
      RETURN.
    ENDIF.

    lv_gap = gap( iv_book_value  = iv_book_value
                  iv_recoverable = iv_recoverable ).
    IF lv_gap <= 0.
      rv_severity = 'NONE'.
      RETURN.
    ENDIF.

    lv_pct = lv_gap * 100 DIV iv_book_value.
    IF lv_pct >= 50.
      rv_severity = 'HIGH'.
    ELSE.
      rv_severity = 'MEDIUM'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
