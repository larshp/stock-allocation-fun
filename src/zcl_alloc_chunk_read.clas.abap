CLASS zcl_alloc_chunk_read DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS read
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
        iv_index        TYPE i
        iv_size         TYPE i
      RETURNING
        VALUE(rt_lines) TYPE zcl_stock_allocator=>ty_result_tt.

ENDCLASS.


CLASS zcl_alloc_chunk_read IMPLEMENTATION.

  METHOD read.
    DATA lv_count TYPE i.
    DATA lv_from  TYPE i.
    DATA lv_to    TYPE i.
    DATA lv_pos   TYPE i.

    lv_count = lines( it_result ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    IF iv_size < 1.
      lv_from = 1.
      lv_to = lv_count.
    ELSE.
      IF iv_index < 1.
        RETURN.
      ENDIF.

      lv_from = ( iv_index - 1 ) * iv_size + 1.
      IF lv_from > lv_count.
        RETURN.
      ENDIF.

      lv_to = lv_from + iv_size - 1.
      IF lv_to > lv_count.
        lv_to = lv_count.
      ENDIF.
    ENDIF.

    lv_pos = 0.
    LOOP AT it_result INTO DATA(ls_line).
      lv_pos = lv_pos + 1.
      IF lv_pos < lv_from.
        CONTINUE.
      ENDIF.
      IF lv_pos > lv_to.
        EXIT.
      ENDIF.

      APPEND ls_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
