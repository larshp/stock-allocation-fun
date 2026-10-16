CLASS ltcl_alloc_chunk_write DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_chunk_write.
    DATA mt_line TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS splits_evenly    FOR TESTING.
    METHODS last_chunk_short FOR TESTING.
    METHODS size_zero_one    FOR TESTING.
    METHODS size_beyond_one   FOR TESTING.
    METHODS empty_input_none  FOR TESTING.
    METHODS keeps_order       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_chunk_write IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_chunk_write( ).

    add_line( iv_id = 'R1' iv_qty = 1 ).
    add_line( iv_id = 'R2' iv_qty = 2 ).
    add_line( iv_id = 'R3' iv_qty = 3 ).
    add_line( iv_id = 'R4' iv_qty = 4 ).
    add_line( iv_id = 'R5' iv_qty = 5 ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = iv_id.
    ls_line-allocated_qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD splits_evenly.
    DATA(lt_chunks) = mo_cut->write( it_result = mt_line
                                     iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunks[ 1 ]-chunk_index exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunks[ 2 ]-chunk_index exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunks[ 3 ]-chunk_index exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks[ 1 ]-lines ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks[ 3 ]-lines ) exp = 1 ).
  ENDMETHOD.

  METHOD last_chunk_short.
    DATA(lt_chunks) = mo_cut->write( it_result = mt_line
                                     iv_size   = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks[ 1 ]-lines ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks[ 2 ]-lines ) exp = 2 ).
  ENDMETHOD.

  METHOD size_zero_one.
    DATA(lt_chunks) = mo_cut->write( it_result = mt_line
                                     iv_size   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks[ 1 ]-lines ) exp = 5 ).
  ENDMETHOD.

  METHOD size_beyond_one.
    DATA(lt_chunks) = mo_cut->write( it_result = mt_line
                                     iv_size   = 99 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunks[ 1 ]-chunk_index exp = 1 ).
  ENDMETHOD.

  METHOD empty_input_none.
    DATA lt_empty TYPE zcl_stock_allocator=>ty_result_tt.
    DATA(lt_chunks) = mo_cut->write( it_result = lt_empty
                                     iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunks ) exp = 0 ).
  ENDMETHOD.

  METHOD keeps_order.
    DATA(lt_chunks) = mo_cut->write( it_result = mt_line
                                     iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_chunks[ 1 ]-lines[ 1 ]-requirement_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_chunks[ 3 ]-lines[ 1 ]-requirement_id exp = 'R5' ).
  ENDMETHOD.

ENDCLASS.
