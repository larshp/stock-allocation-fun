CLASS zcl_alloc_checksum DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS of_result
      IMPORTING
        it_result     TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rv_sum) TYPE i.

ENDCLASS.


CLASS zcl_alloc_checksum IMPLEMENTATION.

  METHOD of_result.
    DATA lv_length TYPE i.

    LOOP AT it_result INTO DATA(ls_result).
      lv_length = strlen( ls_result-requirement_id ).

      rv_sum = rv_sum + sy-tabix * lv_length.
      rv_sum = rv_sum + ls_result-allocated_qty.
      rv_sum = rv_sum + ls_result-shortage_qty * 2.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
