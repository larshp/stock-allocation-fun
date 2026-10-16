CLASS zcl_alloc_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_field_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS quote
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS build_line
      IMPORTING
        it_fields      TYPE ty_field_tt
        iv_separator   TYPE string DEFAULT ';'
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_csv IMPLEMENTATION.

  METHOD quote.
    DATA lv_quote  TYPE string.
    DATA lv_escaped TYPE string.

    lv_quote = '"'.
    lv_escaped = '""'.
    rv_value = iv_value.

    IF iv_value CS lv_quote
        OR iv_value CS ';'
        OR iv_value CS ','.
      " a value containing a quote or a separator has to be quoted
      REPLACE ALL OCCURRENCES OF lv_quote IN rv_value WITH lv_escaped.
      rv_value = lv_quote && rv_value.
      rv_value = rv_value && lv_quote.
    ENDIF.
  ENDMETHOD.

  METHOD build_line.
    DATA lv_field  TYPE string.
    DATA lv_quoted TYPE string.
    DATA lv_first  TYPE abap_bool.

    CLEAR rv_line.
    lv_first = abap_true.

    LOOP AT it_fields INTO lv_field.
      IF lv_first = abap_false.
        rv_line = rv_line && iv_separator.
      ENDIF.
      lv_quoted = quote( lv_field ).
      rv_line = rv_line && lv_quoted.
      lv_first = abap_false.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
