CLASS zcl_alloc_text_wrap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_state,
             line  TYPE string,
             lines TYPE ty_text_tt,
           END OF ty_state.

    METHODS wrap
      IMPORTING
        iv_text         TYPE string
        iv_width        TYPE i
      RETURNING
        VALUE(rt_lines) TYPE ty_text_tt.

  PRIVATE SECTION.
    METHODS flush_word
      IMPORTING
        iv_word         TYPE string
        iv_width        TYPE i
        iv_space        TYPE string
        is_state        TYPE ty_state
      RETURNING
        VALUE(rs_state) TYPE ty_state.

ENDCLASS.


CLASS zcl_alloc_text_wrap IMPLEMENTATION.

  METHOD flush_word.
    DATA lv_len_line TYPE i.
    DATA lv_len_word TYPE i.

    rs_state = is_state.

    lv_len_word = strlen( iv_word ).
    IF lv_len_word = 0.
      RETURN.
    ENDIF.

    lv_len_line = strlen( rs_state-line ).

    IF lv_len_line = 0.
      rs_state-line = iv_word.
      RETURN.
    ENDIF.

    " The word still fits when it plus the separating blank stays inside the
    " requested width; a single word longer than the width keeps its own line.
    IF lv_len_line + 1 + lv_len_word <= iv_width.
      rs_state-line = rs_state-line && iv_space.
      rs_state-line = rs_state-line && iv_word.
      RETURN.
    ENDIF.

    APPEND rs_state-line TO rs_state-lines.
    rs_state-line = iv_word.
  ENDMETHOD.

  METHOD wrap.
    DATA ls_state TYPE ty_state.
    DATA lv_char  TYPE string.
    DATA lv_word  TYPE string.
    DATA lv_space TYPE string.
    DATA lv_width TYPE i.
    DATA lv_len   TYPE i.
    DATA lv_pos   TYPE i.
    DATA lv_off   TYPE i.

    lv_width = iv_width.
    IF lv_width < 1.
      lv_width = 1.
    ENDIF.

    lv_space = ` `.
    lv_len = strlen( iv_text ).

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char = lv_space.
        ls_state = flush_word( iv_word  = lv_word
                               iv_width = lv_width
                               iv_space = lv_space
                               is_state = ls_state ).
        CLEAR lv_word.
        CONTINUE.
      ENDIF.

      lv_word = lv_word && lv_char.
    ENDWHILE.

    ls_state = flush_word( iv_word  = lv_word
                           iv_width = lv_width
                           iv_space = lv_space
                           is_state = ls_state ).

    IF strlen( ls_state-line ) > 0.
      APPEND ls_state-line TO ls_state-lines.
    ENDIF.

    rt_lines = ls_state-lines.
  ENDMETHOD.

ENDCLASS.
