CLASS zcl_stock_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS quote
      IMPORTING
        iv_value        TYPE any
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS number
      IMPORTING
        iv_value        TYPE any
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS error
      IMPORTING
        iv_mode         TYPE any
        iv_message      TYPE any
      RETURNING
        VALUE(rv_value) TYPE string.
    CLASS-METHODS error_with_run_id
      IMPORTING
        iv_mode         TYPE any
        iv_message      TYPE any
        iv_run_id       TYPE any
      RETURNING
        VALUE(rv_value) TYPE string.
ENDCLASS.

CLASS zcl_stock_csv IMPLEMENTATION.
  METHOD quote.
    DATA lv_text TYPE string.
    DATA lv_escaped TYPE string.

    lv_text = iv_value.
    lv_escaped = lv_text.
    REPLACE ALL OCCURRENCES OF '"' IN lv_escaped WITH '""'.
    CONCATENATE '"' lv_escaped '"' INTO rv_value.
  ENDMETHOD.

  METHOD number.
    DATA lv_formatted TYPE c LENGTH 100.

    WRITE iv_value TO lv_formatted NO-GROUPING.
    rv_value = lv_formatted.
    REPLACE ALL OCCURRENCES OF ',' IN rv_value WITH '.'.
    CONDENSE rv_value NO-GAPS.
  ENDMETHOD.

  METHOD error.
    DATA lv_mode TYPE string.
    DATA lv_status TYPE string.
    DATA lv_message TYPE string.

    lv_mode = quote( iv_mode ).
    lv_status = quote( 'error' ).
    lv_message = quote( iv_message ).
    CONCATENATE lv_mode lv_status lv_message
           INTO rv_value SEPARATED BY ';'.
  ENDMETHOD.

  METHOD error_with_run_id.
    DATA lv_run_id TYPE string.

    rv_value = error(
      iv_mode    = iv_mode
      iv_message = iv_message ).
    lv_run_id = quote( iv_run_id ).
    CONCATENATE rv_value lv_run_id
      INTO rv_value SEPARATED BY ';'.
  ENDMETHOD.
ENDCLASS.
