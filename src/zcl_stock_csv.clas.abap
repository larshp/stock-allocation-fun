CLASS zcl_stock_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS quote
      IMPORTING
        iv_value        TYPE string
      RETURNING
        VALUE(rv_value) TYPE string.
ENDCLASS.

CLASS zcl_stock_csv IMPLEMENTATION.
  METHOD quote.
    DATA lv_escaped TYPE string.

    lv_escaped = iv_value.
    REPLACE ALL OCCURRENCES OF '"' IN lv_escaped WITH '""'.
    CONCATENATE '"' lv_escaped '"' INTO rv_value.
  ENDMETHOD.
ENDCLASS.
