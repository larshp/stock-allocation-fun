CLASS zcl_alloc_secret_mask DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS mask
      IMPORTING
        iv_secret        TYPE string
      RETURNING
        VALUE(rv_masked) TYPE string.

    METHODS is_masked
      IMPORTING
        iv_text          TYPE string
      RETURNING
        VALUE(rv_masked) TYPE abap_bool.

    METHODS mask_all
      IMPORTING
        it_secrets       TYPE ty_lines_tt
      RETURNING
        VALUE(rt_masked) TYPE ty_lines_tt.

  PRIVATE SECTION.
    METHODS stars
      IMPORTING
        iv_count        TYPE i
      RETURNING
        VALUE(rv_stars) TYPE string.

ENDCLASS.


CLASS zcl_alloc_secret_mask IMPLEMENTATION.

  METHOD mask.
    DATA lv_len   TYPE i.
    DATA lv_mid   TYPE i.
    DATA lv_last  TYPE i.
    DATA lv_head  TYPE string.
    DATA lv_tail  TYPE string.
    DATA lv_stars TYPE string.

    lv_len = strlen( iv_secret ).

    IF lv_len = 0.
      rv_masked = ''.
      RETURN.
    ENDIF.

    IF lv_len <= 2.
      rv_masked = stars( lv_len ).
      RETURN.
    ENDIF.

    lv_head = substring( val = iv_secret off = 0 len = 1 ).
    lv_last = lv_len - 1.
    lv_tail = substring( val = iv_secret off = lv_last len = 1 ).
    lv_mid = lv_len - 2.
    lv_stars = stars( lv_mid ).

    rv_masked = lv_head && lv_stars.
    rv_masked = rv_masked && lv_tail.
  ENDMETHOD.

  METHOD is_masked.
    IF find( val = iv_text sub = '*' ) >= 0.
      rv_masked = abap_true.
    ELSE.
      rv_masked = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD mask_all.
    DATA lv_line   TYPE string.
    DATA lv_masked TYPE string.

    LOOP AT it_secrets INTO lv_line.
      lv_masked = mask( lv_line ).
      APPEND lv_masked TO rt_masked.
    ENDLOOP.
  ENDMETHOD.

  METHOD stars.
    DATA lv_i TYPE i.

    rv_stars = ''.
    DO iv_count TIMES.
      lv_i = lv_i + 1.
      rv_stars = rv_stars && '*'.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
