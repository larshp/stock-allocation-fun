CLASS zcl_alloc_toc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_section,
             title TYPE string,
             level TYPE i,
           END OF ty_section.
    TYPES ty_section_tt TYPE STANDARD TABLE OF ty_section WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_entry,
             number TYPE string,
             level  TYPE i,
             title  TYPE string,
             indent TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_sections       TYPE ty_section_tt
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

  PRIVATE SECTION.
    CONSTANTS c_max_level TYPE i VALUE 3.
    CONSTANTS c_indent    TYPE i VALUE 2.

    TYPES: BEGIN OF ty_counter,
             level TYPE i,
             value TYPE i,
           END OF ty_counter.
    TYPES ty_counter_tt TYPE STANDARD TABLE OF ty_counter WITH DEFAULT KEY.

    " A numeric-to-string conversion is not reliable in the transpiler, so the
    " chapter numbers are built from single digit literals (up to nine).
    METHODS digit_of
      IMPORTING
        iv_value        TYPE i
      RETURNING
        VALUE(rv_digit) TYPE string.

ENDCLASS.


CLASS zcl_alloc_toc IMPLEMENTATION.

  METHOD digit_of.
    IF iv_value = 1.
      rv_digit = '1'.
    ELSEIF iv_value = 2.
      rv_digit = '2'.
    ELSEIF iv_value = 3.
      rv_digit = '3'.
    ELSEIF iv_value = 4.
      rv_digit = '4'.
    ELSEIF iv_value = 5.
      rv_digit = '5'.
    ELSEIF iv_value = 6.
      rv_digit = '6'.
    ELSEIF iv_value = 7.
      rv_digit = '7'.
    ELSEIF iv_value = 8.
      rv_digit = '8'.
    ELSEIF iv_value = 9.
      rv_digit = '9'.
    ELSE.
      rv_digit = '?'.
    ENDIF.
  ENDMETHOD.

  METHOD build.
    DATA lt_counters TYPE ty_counter_tt.
    DATA ls_counter  TYPE ty_counter.
    DATA ls_entry    TYPE ty_entry.
    DATA lv_level    TYPE i.
    DATA lv_i        TYPE i.
    DATA lv_num      TYPE string.
    DATA lv_part     TYPE string.

    lv_i = 1.
    WHILE lv_i <= c_max_level.
      CLEAR ls_counter.
      ls_counter-level = lv_i.
      APPEND ls_counter TO lt_counters.
      lv_i = lv_i + 1.
    ENDWHILE.

    LOOP AT it_sections INTO DATA(ls_section).
      lv_level = ls_section-level.
      IF lv_level < 1.
        lv_level = 1.
      ENDIF.
      IF lv_level > c_max_level.
        lv_level = c_max_level.
      ENDIF.

      " Step the counter of this level and reset every deeper one, so that
      " "1.2.3" becomes "1.2.4" and a new level 1 chapter resets its children.
      CLEAR lv_num.
      lv_i = 1.
      WHILE lv_i <= c_max_level.
        READ TABLE lt_counters INTO ls_counter WITH KEY level = lv_i.
        IF sy-subrc <> 0.
          lv_i = lv_i + 1.
          CONTINUE.
        ENDIF.

        IF lv_i = lv_level.
          ls_counter-value = ls_counter-value + 1.
        ELSEIF lv_i > lv_level.
          ls_counter-value = 0.
        ENDIF.

        DELETE lt_counters WHERE level = lv_i.
        APPEND ls_counter TO lt_counters.

        IF lv_i <= lv_level.
          lv_part = digit_of( iv_value = ls_counter-value ).

          IF lv_num IS INITIAL.
            lv_num = lv_part.
          ELSE.
            lv_num = lv_num && '.'.
            lv_num = lv_num && lv_part.
          ENDIF.
        ENDIF.

        lv_i = lv_i + 1.
      ENDWHILE.

      CLEAR ls_entry.
      ls_entry-number = lv_num.
      ls_entry-level = lv_level.
      ls_entry-title = ls_section-title.
      ls_entry-indent = ( lv_level - 1 ) * c_indent.
      APPEND ls_entry TO rt_entries.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
