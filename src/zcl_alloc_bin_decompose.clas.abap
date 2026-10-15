CLASS zcl_alloc_bin_decompose DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_parts_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_key,
             block TYPE string,
             aisle TYPE string,
             rack  TYPE string,
             level TYPE string,
           END OF ty_key.

    CLASS-METHODS split
      IMPORTING
        iv_bin_id       TYPE string
      RETURNING
        VALUE(rt_parts) TYPE ty_parts_tt.

    CLASS-METHODS decompose
      IMPORTING
        iv_bin_id     TYPE string
      RETURNING
        VALUE(rs_key) TYPE ty_key.

    CLASS-METHODS part_count
      IMPORTING
        iv_bin_id       TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    CONSTANTS c_sep TYPE string VALUE '-'.

ENDCLASS.


CLASS zcl_alloc_bin_decompose IMPLEMENTATION.

  METHOD split.
    DATA lv_len   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_char  TYPE string.
    DATA lv_token TYPE string.

    " The identifier is walked one character at a time so that the separator is
    " treated literally, whatever it is.
    lv_len = strlen( iv_bin_id ).

    WHILE lv_off < lv_len.
      lv_char = substring( val = iv_bin_id off = lv_off len = 1 ).

      IF lv_char = c_sep.
        IF lv_token IS NOT INITIAL.
          APPEND lv_token TO rt_parts.
        ENDIF.
        CLEAR lv_token.
      ELSE.
        lv_token = lv_token && lv_char.
      ENDIF.

      lv_off = lv_off + 1.
    ENDWHILE.

    IF lv_token IS NOT INITIAL.
      APPEND lv_token TO rt_parts.
    ENDIF.
  ENDMETHOD.

  METHOD decompose.
    DATA lt_parts TYPE ty_parts_tt.

    lt_parts = split( iv_bin_id ).

    IF lines( lt_parts ) >= 1.
      rs_key-block = lt_parts[ 1 ].
    ENDIF.
    IF lines( lt_parts ) >= 2.
      rs_key-aisle = lt_parts[ 2 ].
    ENDIF.
    IF lines( lt_parts ) >= 3.
      rs_key-rack = lt_parts[ 3 ].
    ENDIF.
    IF lines( lt_parts ) >= 4.
      rs_key-level = lt_parts[ 4 ].
    ENDIF.
  ENDMETHOD.

  METHOD part_count.
    DATA lt_parts TYPE ty_parts_tt.

    lt_parts = split( iv_bin_id ).
    rv_count = lines( lt_parts ).
  ENDMETHOD.

ENDCLASS.
