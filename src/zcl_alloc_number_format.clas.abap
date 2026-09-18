CLASS zcl_alloc_number_format DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS format_qty
      IMPORTING
        iv_value       TYPE menge_d
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS trim_zeros
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    METHODS last_char
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_char) TYPE string.

ENDCLASS.


CLASS zcl_alloc_number_format IMPLEMENTATION.

  METHOD last_char.
    DATA lv_len TYPE i.

    lv_len = strlen( iv_text ).
    IF lv_len <= 0.
      CLEAR rv_char.
      RETURN.
    ENDIF.
    rv_char = substring( val = iv_text
                         off = lv_len - 1
                         len = 1 ).
  ENDMETHOD.

  METHOD format_qty.
    rv_text = |{ iv_value }|.
  ENDMETHOD.

  METHOD trim_zeros.
    DATA lv_len  TYPE i.
    DATA lv_char TYPE string.

    rv_text = iv_text.

    WHILE strlen( rv_text ) > 0.
      lv_char = last_char( rv_text ).
      IF lv_char <> '0'.
        EXIT.
      ENDIF.
      lv_len = strlen( rv_text ) - 1.
      rv_text = substring( val = rv_text
                           len = lv_len ).
    ENDWHILE.

    IF strlen( rv_text ) > 0.
      lv_char = last_char( rv_text ).
      IF lv_char = '.'.
        lv_len = strlen( rv_text ) - 1.
        rv_text = substring( val = rv_text
                             len = lv_len ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
