CLASS ltcl_alloc_chunk_read DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut   TYPE REF TO zcl_alloc_chunk_read.
    DATA mt_line  TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS first_chunk       FOR TESTING.
    METHODS second_chunk      FOR TESTING.
    METHODS last_chunk_short  FOR TESTING.
    METHODS beyond_end_empty  FOR TESTING.
    METHODS index_zero_empty  FOR TESTING.
    METHODS size_zero_all      FOR TESTING.
    METHODS empty_input_empty FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_chunk_read IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_chunk_read( ).

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

  METHOD first_chunk.
    DATA(lt_chunk) = mo_cut->read( it_result = mt_line
                                   iv_index  = 1
                                   iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunk[ 1 ]-requirement_id exp = 'R1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunk[ 2 ]-requirement_id exp = 'R2' ).
  ENDMETHOD.

  METHOD second_chunk.
    DATA(lt_chunk) = mo_cut->read( it_result = mt_line
                                   iv_index  = 2
                                   iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunk[ 1 ]-requirement_id exp = 'R3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunk[ 2 ]-requirement_id exp = 'R4' ).
  ENDMETHOD.

  METHOD last_chunk_short.
    DATA(lt_chunk) = mo_cut->read( it_result = mt_line
                                   iv_index  = 3
                                   iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_chunk[ 1 ]-requirement_id exp = 'R5' ).
  ENDMETHOD.

  METHOD beyond_end_empty.
    DATA(lt_chunk) = mo_cut->read( it_result = mt_line
                                   iv_index  = 9
                                   iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 0 ).
  ENDMETHOD.

  METHOD index_zero_empty.
    DATA(lt_chunk) = mo_cut->read( it_result = mt_line
                                   iv_index  = 0
                                   iv_size   = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 0 ).
  ENDMETHOD.

  METHOD size_zero_all.
    DATA(lt_chunk) = mo_cut->read( it_result = mt_line
                                   iv_index  = 4
                                   iv_size   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 5 ).
  ENDMETHOD.

  METHOD empty_input_empty.
    DATA lt_empty TYPE zcl_stock_allocator=>ty_result_tt.
    DATA(lt_chunk) = mo_cut->read( it_result = lt_empty
                                   iv_index  = 1
                                   iv_size   = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_chunk ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
