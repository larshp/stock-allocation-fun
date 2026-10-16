CLASS zcl_alloc_sql_escape DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS needs_escape
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_flag) TYPE abap_bool.

    METHODS escape
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS literal
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    CONSTANTS c_quote TYPE string VALUE `'`.

ENDCLASS.


CLASS zcl_alloc_sql_escape IMPLEMENTATION.

  METHOD needs_escape.
    DATA lv_len  TYPE i.
    DATA lv_pos  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.

    lv_len = strlen( iv_text ).

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char = c_quote.
        rv_flag = abap_true.
        RETURN.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD escape.
    DATA lv_len  TYPE i.
    DATA lv_pos  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.

    lv_len = strlen( iv_text ).

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      rv_text = rv_text && lv_char.

      " A literal quote is written twice inside an SQL string literal.
      IF lv_char = c_quote.
        rv_text = rv_text && c_quote.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

  METHOD literal.
    rv_text = c_quote.
    rv_text = rv_text && escape( iv_text = iv_text ).
    rv_text = rv_text && c_quote.
  ENDMETHOD.

ENDCLASS.
