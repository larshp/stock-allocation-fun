CLASS zcl_alloc_chunk_write DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_chunk,
             chunk_index TYPE i,
             lines       TYPE zcl_stock_allocator=>ty_result_tt,
           END OF ty_chunk.

    TYPES ty_chunk_tt TYPE STANDARD TABLE OF ty_chunk WITH DEFAULT KEY.

    METHODS write
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_size          TYPE i
      RETURNING
        VALUE(rt_chunks) TYPE ty_chunk_tt.

ENDCLASS.


CLASS zcl_alloc_chunk_write IMPLEMENTATION.

  METHOD write.
    DATA ls_chunk TYPE ty_chunk.
    DATA lv_size  TYPE i.
    DATA lv_block TYPE i.
    DATA lv_count TYPE i.
    DATA lv_pos   TYPE i.

    lv_count = lines( it_result ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    lv_size = iv_size.
    IF lv_size < 1.
      lv_size = lv_count.
    ENDIF.

    lv_block = -1.
    LOOP AT it_result INTO DATA(ls_line).
      lv_pos = ( sy-tabix - 1 ) DIV lv_size.

      IF lv_pos <> lv_block.
        IF lines( ls_chunk-lines ) > 0.
          APPEND ls_chunk TO rt_chunks.
        ENDIF.
        CLEAR ls_chunk.
        lv_block = lv_pos.
        ls_chunk-chunk_index = lv_pos + 1.
      ENDIF.

      APPEND ls_line TO ls_chunk-lines.
    ENDLOOP.

    IF lines( ls_chunk-lines ) > 0.
      APPEND ls_chunk TO rt_chunks.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
