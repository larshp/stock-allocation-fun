CLASS ltcl_allocation_writer_db DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_log_tt TYPE STANDARD TABLE OF zstockalloc WITH DEFAULT KEY.

    CLASS-DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut TYPE REF TO zif_allocation_writer.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS sample_result
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.
    METHODS read_log
      RETURNING
        VALUE(rt_log) TYPE ty_log_tt.

    METHODS one_row_per_allocation    FOR TESTING.
    METHODS stores_header_fields      FOR TESTING.
    METHODS empty_result_writes_nothing FOR TESTING.
ENDCLASS.


CLASS ltcl_allocation_writer_db IMPLEMENTATION.

  METHOD class_setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKALLOC' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    mo_environment->clear_doubles( ).
    mo_cut = NEW zcl_allocation_writer_db( ).
  ENDMETHOD.

  METHOD sample_result.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = 'REQ-1'.
    ls_result-requested_qty  = '6'.
    ls_result-allocated_qty  = '6'.

    APPEND VALUE #( lgort = '0001' quantity = '3' ) TO ls_result-allocations.
    APPEND VALUE #( lgort = '0002' quantity = '3' ) TO ls_result-allocations.

    APPEND ls_result TO rt_result.
  ENDMETHOD.

  METHOD read_log.
    SELECT * FROM zstockalloc INTO TABLE @rt_log.
  ENDMETHOD.

  METHOD one_row_per_allocation.
    mo_cut->write( iv_run_id = 'RUN-1'
                   iv_matnr  = 'MAT-1'
                   iv_werks  = '1000'
                   it_result = sample_result( ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( read_log( ) )
                                        exp = 2 ).
  ENDMETHOD.

  METHOD stores_header_fields.
    mo_cut->write( iv_run_id = 'RUN-1'
                   iv_matnr  = 'MAT-1'
                   iv_werks  = '1000'
                   it_result = sample_result( ) ).

    DATA(lt_log) = read_log( ).

    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-req_id
                                        exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-matnr
                                        exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-werks
                                        exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-alloc_qty
                                        exp = '3' ).
  ENDMETHOD.

  METHOD empty_result_writes_nothing.
    DATA lv_written TYPE i.
    DATA lt_empty    TYPE zcl_stock_allocator=>ty_result_tt.

    lv_written = mo_cut->write( iv_run_id = 'RUN-1'
                                iv_matnr  = 'MAT-1'
                                iv_werks  = '1000'
                                it_result = lt_empty ).

    cl_abap_unit_assert=>assert_equals( act = lv_written
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_initial( act = read_log( ) ).
  ENDMETHOD.

ENDCLASS.
