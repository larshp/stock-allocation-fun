CLASS zcl_alloc_duration DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS to_text
      IMPORTING
        iv_seconds     TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS to_seconds
      IMPORTING
        iv_hours         TYPE i
        iv_minutes       TYPE i
        iv_seconds       TYPE i
      RETURNING
        VALUE(rv_result) TYPE i.

  PRIVATE SECTION.
    METHODS pad2
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_duration IMPLEMENTATION.

  METHOD pad2.
    IF iv_value < 10.
      rv_text = '0'.
      rv_text = rv_text && |{ iv_value }|.
    ELSE.
      rv_text = |{ iv_value }|.
    ENDIF.
  ENDMETHOD.

  METHOD to_text.
    DATA lv_hours   TYPE i.
    DATA lv_rest    TYPE i.
    DATA lv_minutes TYPE i.
    DATA lv_seconds TYPE i.
    DATA lv_m_text  TYPE string.
    DATA lv_s_text  TYPE string.

    lv_hours = iv_seconds DIV 3600.
    lv_rest = iv_seconds MOD 3600.
    lv_minutes = lv_rest DIV 60.
    lv_seconds = lv_rest MOD 60.

    lv_m_text = pad2( lv_minutes ).
    lv_s_text = pad2( lv_seconds ).

    rv_text = |{ lv_hours }:{ lv_m_text }:{ lv_s_text }|.
  ENDMETHOD.

  METHOD to_seconds.
    rv_result = iv_hours * 3600 + iv_minutes * 60 + iv_seconds.
  ENDMETHOD.

ENDCLASS.
