CLASS zcl_stock_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES tt_strings TYPE STANDARD TABLE OF string WITH EMPTY KEY.
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
    CLASS-METHODS number_property
      IMPORTING
        iv_name         TYPE string
        iv_value        TYPE any
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS filter_number_property
      IMPORTING
        iv_name         TYPE string
        iv_value        TYPE any
        iv_text         TYPE string
        iv_present      TYPE abap_bool
        iv_typed        TYPE abap_bool
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS boolean_property
      IMPORTING
        iv_name         TYPE string
        iv_value        TYPE abap_bool
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS null_property
      IMPORTING
        iv_name         TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS string_array_property
      IMPORTING
        iv_name         TYPE string
        it_values       TYPE tt_strings
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS error
      IMPORTING
        iv_message      TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS error_with_run_id
      IMPORTING
        iv_message      TYPE string
        iv_run_id       TYPE any
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
    DATA lv_formatted TYPE c LENGTH 1024.
    DATA lv_text TYPE string.
    DATA lv_quoted TYPE string.

    WRITE iv_value TO lv_formatted.
    lv_text = lv_formatted.
    lv_quoted = quote( lv_text ).
    CONCATENATE '"' iv_name '":' lv_quoted INTO rv_value.
  ENDMETHOD.

  METHOD number_property.
    DATA lv_formatted TYPE c LENGTH 100.
    DATA lv_text TYPE string.

    WRITE iv_value TO lv_formatted NO-GROUPING.
    lv_text = lv_formatted.
    REPLACE ALL OCCURRENCES OF ',' IN lv_text WITH '.'.
    CONDENSE lv_text NO-GAPS.
    CONCATENATE '"' iv_name '":' lv_text INTO rv_value.
  ENDMETHOD.

  METHOD filter_number_property.
    IF iv_typed = abap_true.
      IF iv_present = abap_true.
        rv_value = number_property(
          iv_name  = iv_name
          iv_value = iv_value ).
      ELSE.
        rv_value = null_property( iv_name = iv_name ).
      ENDIF.
    ELSE.
      rv_value = property(
        iv_name  = iv_name
        iv_value = iv_text ).
    ENDIF.
  ENDMETHOD.

  METHOD boolean_property.
    DATA lv_text TYPE string.

    IF iv_value = abap_true.
      lv_text = 'true'.
    ELSE.
      lv_text = 'false'.
    ENDIF.
    CONCATENATE '"' iv_name '":' lv_text INTO rv_value.
  ENDMETHOD.

  METHOD null_property.
    CONCATENATE '"' iv_name '":null' INTO rv_value.
  ENDMETHOD.

  METHOD string_array_property.
    DATA lv_item TYPE string.
    DATA lv_quoted_item TYPE string.
    DATA lv_items TYPE string.
    DATA lv_quoted_name TYPE string.

    LOOP AT it_values INTO lv_item.
      lv_quoted_item = quote( lv_item ).
      IF lv_items IS INITIAL.
        lv_items = lv_quoted_item.
      ELSE.
        CONCATENATE lv_items lv_quoted_item
          INTO lv_items SEPARATED BY ','.
      ENDIF.
    ENDLOOP.
    lv_quoted_name = quote( iv_name ).
    CONCATENATE lv_quoted_name ':[' lv_items ']'
      INTO rv_value.
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

  METHOD error_with_run_id.
    DATA lv_mode TYPE string.
    DATA lv_message TYPE string.
    DATA lv_run_id TYPE string.

    lv_mode = property(
      iv_name  = 'mode'
      iv_value = 'error' ).
    lv_message = property(
      iv_name  = 'message'
      iv_value = iv_message ).
    lv_run_id = iv_run_id.
    lv_run_id = property(
      iv_name  = 'run_id'
      iv_value = lv_run_id ).
    CONCATENATE '{' lv_mode ',' lv_message ',' lv_run_id '}'
      INTO rv_value.
  ENDMETHOD.
ENDCLASS.
