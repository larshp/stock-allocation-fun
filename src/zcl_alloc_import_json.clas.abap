CLASS zcl_alloc_import_json DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_key     TYPE c LENGTH 30.
    TYPES ty_value   TYPE c LENGTH 60.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_pair,
             key   TYPE ty_key,
             value TYPE ty_value,
           END OF ty_pair.
    TYPES ty_pair_tt TYPE STANDARD TABLE OF ty_pair WITH DEFAULT KEY.

    METHODS parse
      IMPORTING
        iv_json         TYPE string
      RETURNING
        VALUE(rt_pairs) TYPE ty_pair_tt.

    METHODS count_of
      IMPORTING
        iv_json         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    METHODS trim
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS strip_quotes
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS split
      IMPORTING
        iv_text         TYPE string
        iv_sep          TYPE string
      RETURNING
        VALUE(rt_parts) TYPE ty_lines_tt.

ENDCLASS.


CLASS zcl_alloc_import_json IMPLEMENTATION.

  METHOD parse.
    DATA lv_body     TYPE string.
    DATA lv_len      TYPE i.
    DATA lv_last_off TYPE i.
    DATA lv_inner    TYPE i.
    DATA lv_first    TYPE string.
    DATA lv_last     TYPE string.
    DATA lt_parts    TYPE ty_lines_tt.
    DATA lv_part     TYPE string.
    DATA lv_part_len TYPE i.
    DATA lv_colon    TYPE i.
    DATA lv_skip     TYPE i.
    DATA lv_tail_len TYPE i.
    DATA lv_key      TYPE string.
    DATA lv_value    TYPE string.

    lv_body = me->trim( iv_json ).
    lv_len = strlen( lv_body ).

    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_first = substring( val = lv_body off = 0 len = 1 ).
    lv_last_off = lv_len - 1.
    lv_last = substring( val = lv_body off = lv_last_off len = 1 ).

    IF lv_first = '{' AND lv_last = '}'.
      lv_inner = lv_len - 2.
      lv_body = substring( val = lv_body off = 1 len = lv_inner ).
    ENDIF.

    lt_parts = me->split( iv_text = lv_body iv_sep = ',' ).

    LOOP AT lt_parts INTO lv_part.
      lv_part = me->trim( lv_part ).

      IF lv_part IS NOT INITIAL.
        lv_colon = find( val = lv_part sub = ':' ).

        IF lv_colon >= 0.
          lv_part_len = strlen( lv_part ).
          lv_skip = lv_colon + 1.
          lv_tail_len = lv_part_len - lv_skip.

          lv_key = substring( val = lv_part off = 0 len = lv_colon ).
          lv_key = me->trim( lv_key ).
          lv_key = me->strip_quotes( lv_key ).

          lv_value = substring( val = lv_part off = lv_skip len = lv_tail_len ).
          lv_value = me->trim( lv_value ).
          lv_value = me->strip_quotes( lv_value ).

          APPEND VALUE #( key = lv_key value = lv_value ) TO rt_pairs.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_of.
    DATA lt_pairs TYPE ty_pair_tt.

    lt_pairs = parse( iv_json ).

    rv_count = lines( lt_pairs ).
  ENDMETHOD.

  METHOD trim.
    DATA lv_space TYPE string.
    DATA lv_len   TYPE i.
    DATA lv_start TYPE i.
    DATA lv_end   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_count TYPE i.
    DATA lv_char  TYPE string.

    " A18: a literal that holds only blanks is trimmed to an empty string by the
    " transpiler; a backtick literal keeps the blank (same idiom as zcl_alloc_markdown).
    lv_space = ` `.

    lv_len = strlen( iv_text ).
    lv_end = lv_len.

    DO lv_len TIMES.
      lv_off = lv_start.

      IF lv_off >= lv_end.
        EXIT.
      ENDIF.

      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char <> lv_space.
        EXIT.
      ENDIF.

      lv_start = lv_start + 1.
    ENDDO.

    DO lv_len TIMES.
      IF lv_end <= lv_start.
        EXIT.
      ENDIF.

      lv_off = lv_end - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char <> lv_space.
        EXIT.
      ENDIF.

      lv_end = lv_end - 1.
    ENDDO.

    lv_count = lv_end - lv_start.

    IF lv_count <= 0.
      rv_text = ''.
    ELSE.
      rv_text = substring( val = iv_text off = lv_start len = lv_count ).
    ENDIF.
  ENDMETHOD.

  METHOD strip_quotes.
    DATA lv_len   TYPE i.
    DATA lv_last  TYPE i.
    DATA lv_inner TYPE i.
    DATA lv_first TYPE string.
    DATA lv_end   TYPE string.

    rv_text = iv_text.
    lv_len = strlen( iv_text ).

    IF lv_len < 2.
      RETURN.
    ENDIF.

    lv_first = substring( val = iv_text off = 0 len = 1 ).
    lv_last = lv_len - 1.
    lv_end = substring( val = iv_text off = lv_last len = 1 ).

    IF lv_first = '"' AND lv_end = '"'.
      lv_inner = lv_len - 2.
      rv_text = substring( val = iv_text off = 1 len = lv_inner ).
    ENDIF.
  ENDMETHOD.

  METHOD split.
    DATA lv_len     TYPE i.
    DATA lv_i       TYPE i.
    DATA lv_off     TYPE i.
    DATA lv_char    TYPE string.
    DATA lv_current TYPE string.

    lv_len = strlen( iv_text ).

    DO lv_len TIMES.
      lv_i = lv_i + 1.
      lv_off = lv_i - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char = iv_sep.
        APPEND lv_current TO rt_parts.
        lv_current = ''.
      ELSE.
        lv_current = lv_current && lv_char.
      ENDIF.
    ENDDO.

    APPEND lv_current TO rt_parts.
  ENDMETHOD.

ENDCLASS.
