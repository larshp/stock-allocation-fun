CLASS zcl_alloc_text_trunc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS fits
      IMPORTING
        iv_text        TYPE string
        iv_width       TYPE i
      RETURNING
        VALUE(rv_fits) TYPE abap_bool.

    METHODS truncate
      IMPORTING
        iv_text        TYPE string
        iv_width       TYPE i
        iv_marker      TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_text_trunc IMPLEMENTATION.

  METHOD fits.
    IF strlen( iv_text ) <= iv_width.
      rv_fits = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD truncate.
    DATA lv_len  TYPE i.
    DATA lv_mark TYPE i.
    DATA lv_keep TYPE i.

    rv_text = iv_text.

    IF iv_width <= 0.
      CLEAR rv_text.
      RETURN.
    ENDIF.

    lv_len = strlen( iv_text ).
    IF lv_len <= iv_width.
      RETURN.
    ENDIF.

    lv_mark = strlen( iv_marker ).

    " When the width cannot even hold the marker, show as much of it as fits.
    IF iv_width <= lv_mark.
      rv_text = substring( val = iv_marker off = 0 len = iv_width ).
      RETURN.
    ENDIF.

    lv_keep = iv_width - lv_mark.
    rv_text = substring( val = iv_text off = 0 len = lv_keep ).
    rv_text = rv_text && iv_marker.
  ENDMETHOD.

ENDCLASS.
