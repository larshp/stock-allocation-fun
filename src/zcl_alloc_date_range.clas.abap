CLASS zcl_alloc_date_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             from_date TYPE d,
             to_date   TYPE d,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             from_date  TYPE d,
             to_date    TYPE d,
             chunk_days TYPE i,
           END OF ty_input.

    METHODS split
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_date_range IMPLEMENTATION.

  METHOD split.
    DATA ls_line  TYPE ty_line.
    DATA lv_start TYPE d.
    DATA lv_end   TYPE d.
    DATA lv_chunk TYPE i.

    IF is_input-from_date > is_input-to_date.
      RETURN.
    ENDIF.

    lv_chunk = is_input-chunk_days.
    IF lv_chunk <= 0.
      lv_chunk = is_input-to_date - is_input-from_date + 1.
      IF lv_chunk <= 0.
        lv_chunk = 1.
      ENDIF.
    ENDIF.

    lv_start = is_input-from_date.

    WHILE lv_start <= is_input-to_date.
      lv_end = lv_start + lv_chunk - 1.
      IF lv_end > is_input-to_date.
        lv_end = is_input-to_date.
      ENDIF.

      CLEAR ls_line.
      ls_line-from_date = lv_start.
      ls_line-to_date = lv_end.
      APPEND ls_line TO rt_lines.

      lv_start = lv_end + 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
