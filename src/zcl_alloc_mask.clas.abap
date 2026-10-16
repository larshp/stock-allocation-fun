CLASS zcl_alloc_mask DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS mask_text
      IMPORTING
        iv_text          TYPE string
        iv_keep_prefix   TYPE i DEFAULT 0
        iv_keep_suffix   TYPE i DEFAULT 0
      RETURNING
        VALUE(rv_masked) TYPE string.

    METHODS mask_email
      IMPORTING
        iv_email         TYPE string
      RETURNING
        VALUE(rv_masked) TYPE string.

    METHODS mask_last_digits
      IMPORTING
        iv_text          TYPE string
        iv_keep_last     TYPE i DEFAULT 4
      RETURNING
        VALUE(rv_masked) TYPE string.

  PRIVATE SECTION.
    METHODS stars
      IMPORTING
        iv_count        TYPE i
      RETURNING
        VALUE(rv_stars) TYPE string.

ENDCLASS.


CLASS zcl_alloc_mask IMPLEMENTATION.

  METHOD mask_text.
    DATA lv_prefix_len TYPE i.
    DATA lv_suffix_len TYPE i.
    DATA lv_len        TYPE i.
    DATA lv_mid        TYPE i.
    DATA lv_prefix     TYPE string.
    DATA lv_suffix     TYPE string.
    DATA lv_stars      TYPE string.
    DATA lv_sufoff     TYPE i.

    lv_prefix_len = iv_keep_prefix.
    IF lv_prefix_len < 0.
      lv_prefix_len = 0.
    ENDIF.

    lv_suffix_len = iv_keep_suffix.
    IF lv_suffix_len < 0.
      lv_suffix_len = 0.
    ENDIF.

    lv_len = strlen( iv_text ).

    IF lv_len <= lv_prefix_len + lv_suffix_len.
      rv_masked = iv_text.
      RETURN.
    ENDIF.

    lv_mid = lv_len - lv_prefix_len - lv_suffix_len.

    IF lv_prefix_len > 0.
      lv_prefix = substring( val = iv_text off = 0 len = lv_prefix_len ).
    ENDIF.

    IF lv_suffix_len > 0.
      lv_sufoff = lv_len - lv_suffix_len.
      lv_suffix = substring( val = iv_text off = lv_sufoff len = lv_suffix_len ).
    ENDIF.

    lv_stars = stars( lv_mid ).

    rv_masked = lv_prefix && lv_stars.
    rv_masked = rv_masked && lv_suffix.
  ENDMETHOD.

  METHOD mask_email.
    DATA lv_at        TYPE i.
    DATA lv_local     TYPE string.
    DATA lv_domain    TYPE string.
    DATA lv_local_len TYPE i.
    DATA lv_steps     TYPE i.
    DATA lv_head      TYPE string.
    DATA lv_stars     TYPE string.

    lv_at = find( val = iv_email sub = '@' ).

    IF lv_at <= 0.
      rv_masked = mask_text( iv_text = iv_email iv_keep_prefix = 1 ).
      RETURN.
    ENDIF.

    lv_local = substring( val = iv_email off = 0 len = lv_at ).
    lv_domain = substring( val = iv_email off = lv_at ).
    lv_local_len = strlen( lv_local ).

    IF lv_local_len > 0.
      lv_head = substring( val = lv_local off = 0 len = 1 ).
    ENDIF.

    lv_steps = lv_local_len - 1.
    IF lv_steps < 0.
      lv_steps = 0.
    ENDIF.
    lv_stars = stars( lv_steps ).

    rv_masked = lv_head && lv_stars.
    rv_masked = rv_masked && lv_domain.
  ENDMETHOD.

  METHOD mask_last_digits.
    DATA lv_len   TYPE i.
    DATA lv_keep  TYPE i.
    DATA lv_mid   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_tail  TYPE string.
    DATA lv_stars TYPE string.

    lv_len = strlen( iv_text ).
    lv_keep = iv_keep_last.

    IF lv_keep < 0.
      lv_keep = 0.
    ENDIF.

    IF lv_len <= lv_keep.
      rv_masked = iv_text.
      RETURN.
    ENDIF.

    lv_mid = lv_len - lv_keep.
    lv_stars = stars( lv_mid ).

    IF lv_keep > 0.
      lv_off = lv_mid.
      lv_tail = substring( val = iv_text off = lv_off len = lv_keep ).
    ENDIF.

    rv_masked = lv_stars && lv_tail.
  ENDMETHOD.

  METHOD stars.
    rv_stars = ''.
    DO iv_count TIMES.
      rv_stars = rv_stars && '*'.
    ENDDO.
  ENDMETHOD.

ENDCLASS.
