CLASS zcl_stock_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS quote
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS property
      IMPORTING
        iv_name         TYPE string
        iv_value        TYPE any
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS error
      IMPORTING
        iv_message      TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
ENDCLASS.

CLASS zcl_stock_json IMPLEMENTATION.
  METHOD quote.
    DATA lv_escaped TYPE string.

    lv_escaped = iv_value.
    REPLACE ALL OCCURRENCES OF '\' IN lv_escaped WITH '\\'.
    REPLACE ALL OCCURRENCES OF '"' IN lv_escaped WITH '\"'.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf
      IN lv_escaped WITH '\n'.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline
      IN lv_escaped WITH '\n'.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab
      IN lv_escaped WITH '\t'.
    CONCATENATE '"' lv_escaped '"' INTO rv_value.
  ENDMETHOD.

  METHOD property.
    DATA lv_text TYPE string.
    DATA lv_quoted TYPE string.

    WRITE iv_value TO lv_text.
    lv_quoted = quote( lv_text ).
    CONCATENATE '"' iv_name '":' lv_quoted INTO rv_value.
  ENDMETHOD.

  METHOD error.
    DATA lv_mode TYPE string.
    DATA lv_message TYPE string.

    lv_mode = property(
      iv_name  = 'mode'
      iv_value = 'error' ).
    lv_message = property(
      iv_name  = 'message'
      iv_value = iv_message ).
    CONCATENATE '{' lv_mode ',' lv_message '}' INTO rv_value.
  ENDMETHOD.
ENDCLASS.
