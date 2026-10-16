CLASS zcl_alloc_dedupe_key DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_parts_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_parts      TYPE ty_parts_tt
      RETURNING
        VALUE(rv_key) TYPE string.

    METHODS parts_of
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rt_parts) TYPE ty_parts_tt.

    METHODS count_of
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_dedupe_key IMPLEMENTATION.

  METHOD build.
    DATA lv_part  TYPE string.
    DATA lv_first TYPE abap_bool.

    LOOP AT it_parts INTO lv_part.
      IF lv_part IS NOT INITIAL.
        IF lv_first = abap_false.
          rv_key = lv_part.
          lv_first = abap_true.
        ELSE.
          rv_key = rv_key && '|'.
          rv_key = rv_key && lv_part.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD parts_of.
    DATA lv_len     TYPE i.
    DATA lv_pos     TYPE i.
    DATA lv_char    TYPE string.
    DATA lv_current TYPE string.

    lv_len = strlen( iv_key ).

    IF lv_len = 0.
      RETURN.
    ENDIF.

    WHILE lv_pos < lv_len.
      lv_char = substring( val = iv_key off = lv_pos len = 1 ).
      lv_pos = lv_pos + 1.

      IF lv_char = '|'.
        APPEND lv_current TO rt_parts.
        lv_current = ''.
      ELSE.
        lv_current = lv_current && lv_char.
      ENDIF.
    ENDWHILE.

    APPEND lv_current TO rt_parts.
  ENDMETHOD.

  METHOD count_of.
    DATA lt_parts TYPE ty_parts_tt.

    lt_parts = parts_of( iv_key ).

    rv_count = lines( lt_parts ).
  ENDMETHOD.

ENDCLASS.
