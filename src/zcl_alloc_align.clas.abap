CLASS zcl_alloc_align DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS left_value
      IMPORTING
        iv_value       TYPE string
        iv_width       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS right_value
      IMPORTING
        iv_value       TYPE string
        iv_width       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS center_value
      IMPORTING
        iv_value       TYPE string
        iv_width       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    METHODS spaces
      IMPORTING
        iv_count       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_align IMPLEMENTATION.

  METHOD spaces.
    DATA lv_count TYPE i.

    CLEAR rv_text.
    lv_count = iv_count.
    WHILE lv_count > 0.
      rv_text = rv_text && ` `.
      lv_count = lv_count - 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD left_value.
    DATA lv_len     TYPE i.
    DATA lv_padding TYPE string.

    rv_text = iv_value.
    IF iv_width <= 0.
      RETURN.
    ENDIF.

    IF strlen( rv_text ) > iv_width.
      rv_text = substring( val = rv_text
                           len = iv_width ).
      RETURN.
    ENDIF.

    lv_len = iv_width - strlen( rv_text ).
    lv_padding = spaces( lv_len ).
    rv_text = rv_text && lv_padding.
  ENDMETHOD.

  METHOD right_value.
    DATA lv_len     TYPE i.
    DATA lv_padding TYPE string.

    rv_text = iv_value.
    IF iv_width <= 0.
      RETURN.
    ENDIF.

    IF strlen( rv_text ) > iv_width.
      rv_text = substring( val = rv_text
                           len = iv_width ).
      RETURN.
    ENDIF.

    lv_len = iv_width - strlen( rv_text ).
    lv_padding = spaces( lv_len ).
    rv_text = lv_padding && rv_text.
  ENDMETHOD.

  METHOD center_value.
    DATA lv_len    TYPE i.
    DATA lv_before TYPE i.
    DATA lv_after  TYPE i.
    DATA lv_lead   TYPE string.
    DATA lv_trail  TYPE string.

    rv_text = iv_value.
    IF iv_width <= 0.
      RETURN.
    ENDIF.

    IF strlen( rv_text ) >= iv_width.
      rv_text = substring( val = rv_text
                           len = iv_width ).
      RETURN.
    ENDIF.

    lv_len = iv_width - strlen( rv_text ).
    lv_before = lv_len DIV 2.
    lv_after = lv_len - lv_before.

    lv_lead = spaces( lv_before ).
    lv_trail = spaces( lv_after ).

    rv_text = lv_lead && rv_text.
    rv_text = rv_text && lv_trail.
  ENDMETHOD.

ENDCLASS.
