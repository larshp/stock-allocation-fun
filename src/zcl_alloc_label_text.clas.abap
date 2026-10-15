CLASS zcl_alloc_label_text DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS wrap
      IMPORTING
        iv_text         TYPE string
        iv_width        TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_text_tt.

    METHODS join
      IMPORTING
        it_lines       TYPE ty_text_tt
        iv_separator   TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_label_text IMPLEMENTATION.

  METHOD wrap.
    DATA lv_len   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_char  TYPE string.
    DATA lv_word  TYPE string.
    DATA lv_line  TYPE string.

    IF iv_width <= 0.
      RETURN.
    ENDIF.

    lv_len = strlen( iv_text ).

    " One extra position flushes the last word, so the flush logic exists once.
    " The separator is a backtick literal because a character literal loses its
    " trailing blank (ANOMALIES.md A18).
    WHILE lv_off <= lv_len.
      IF lv_off = lv_len.
        lv_char = ` `.
      ELSE.
        lv_char = substring( val = iv_text off = lv_off len = 1 ).
      ENDIF.
      lv_off = lv_off + 1.

      IF lv_char = ` `.
        IF lv_word IS NOT INITIAL.
          IF lv_line IS INITIAL.
            lv_line = lv_word.
          ELSEIF strlen( lv_line ) + 1 + strlen( lv_word ) <= iv_width.
            lv_line = lv_line && ` ` && lv_word.
          ELSE.
            APPEND lv_line TO rt_lines.
            lv_line = lv_word.
          ENDIF.

          CLEAR lv_word.
        ENDIF.
      ELSE.
        lv_word = lv_word && lv_char.
      ENDIF.
    ENDWHILE.

    IF lv_line IS NOT INITIAL.
      APPEND lv_line TO rt_lines.
    ENDIF.
  ENDMETHOD.

  METHOD join.
    DATA lv_first TYPE abap_bool VALUE abap_true.

    LOOP AT it_lines INTO DATA(lv_line).
      IF lv_first = abap_true.
        rv_text = lv_line.
        lv_first = abap_false.
      ELSE.
        rv_text = rv_text && iv_separator && lv_line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
