CLASS ltcl_alloc_run_header DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    CLASS-DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut TYPE REF TO zcl_alloc_run_header.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS starts_with_running_status FOR TESTING.
    METHODS finishes_with_totals       FOR TESTING.
    METHODS finish_without_start       FOR TESTING.
    METHODS reads_only_its_run         FOR TESTING.
    METHODS empty_result_zero_totals   FOR TESTING.
    METHODS reverse_sets_status        FOR TESTING.
    METHODS reverse_returns_count      FOR TESTING.
    METHODS reverse_unknown_run_zero   FOR TESTING.
    METHODS read_active_skips_reversed FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_run_header IMPLEMENTATION.

  METHOD class_setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKRUN' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
    ENDIF.
  ENDMETHOD.

  METHOD setup.
    mo_environment->clear_doubles( ).
    mo_cut = NEW zcl_alloc_run_header( ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    rt_result = it_result.

    ls_line-requirement_id = 'REQ-1'.
    ls_line-requested_qty = iv_requested.
    ls_line-allocated_qty = iv_allocated.
    ls_line-shortage_qty = iv_requested - iv_allocated.

    APPEND ls_line TO rt_result.
  ENDMETHOD.

  METHOD starts_with_running_status.
    DATA lv_written TYPE i.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lv_written
                                        exp = 1 ).

    DATA(lt_header) = mo_cut->read_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_header )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-status
                                        exp = 'R' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-matnr
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD finishes_with_totals.
    DATA lv_written TYPE i.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).

    DATA lt_result TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_requested = '10'
                          iv_allocated = '6' ).
    lt_result = add_line( it_result    = lt_result
                          iv_requested = '4'
                          iv_allocated = '4' ).

    lv_written = mo_cut->finish_run( iv_run_id = 'RUN-1'
                                     iv_matnr  = 'MAT-1'
                                     iv_werks  = '1000'
                                     it_result = lt_result ).

    DATA(lt_header) = mo_cut->read_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-status
                                        exp = 'D' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-req_qty
                                        exp = '14' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-alloc_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-short_qty
                                        exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-item_count
                                        exp = 2 ).
  ENDMETHOD.

  METHOD finish_without_start.
    DATA lv_written TYPE i.
    DATA lt_result  TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_requested = '5'
                          iv_allocated = '5' ).

    lv_written = mo_cut->finish_run( iv_run_id = 'RUN-9'
                                     iv_matnr  = 'MAT-9'
                                     iv_werks  = '1000'
                                     it_result = lt_result ).

    DATA(lt_header) = mo_cut->read_run( 'RUN-9' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_header )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-status
                                        exp = 'D' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-alloc_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD reads_only_its_run.
    DATA lv_written TYPE i.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).
    lv_written = mo_cut->start_run( iv_run_id = 'RUN-2'
                                    iv_matnr  = 'MAT-2'
                                    iv_werks  = '1000' ).

    DATA(lt_header) = mo_cut->read_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_header )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-matnr
                                        exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD empty_result_zero_totals.
    DATA lv_written TYPE i.
    DATA lt_result  TYPE zcl_stock_allocator=>ty_result_tt.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).

    lv_written = mo_cut->finish_run( iv_run_id = 'RUN-1'
                                     iv_matnr  = 'MAT-1'
                                     iv_werks  = '1000'
                                     it_result = lt_result ).

    DATA(lt_header) = mo_cut->read_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-item_count
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-req_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-status
                                        exp = 'D' ).
  ENDMETHOD.

  METHOD reverse_sets_status.
    DATA lv_written TYPE i.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).
    lv_written = mo_cut->reverse_run( 'RUN-1' ).

    DATA(lt_header) = mo_cut->read_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-status
                                        exp = 'X' ).
  ENDMETHOD.

  METHOD reverse_returns_count.
    DATA lv_written TYPE i.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).
    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-2'
                                    iv_werks  = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reverse_run( 'RUN-1' )
      exp = 2 ).
  ENDMETHOD.

  METHOD reverse_unknown_run_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reverse_run( 'RUN-X' )
      exp = 0 ).
  ENDMETHOD.

  METHOD read_active_skips_reversed.
    DATA lv_written TYPE i.

    lv_written = mo_cut->start_run( iv_run_id = 'RUN-1'
                                    iv_matnr  = 'MAT-1'
                                    iv_werks  = '1000' ).
    lv_written = mo_cut->start_run( iv_run_id = 'RUN-2'
                                    iv_matnr  = 'MAT-2'
                                    iv_werks  = '1000' ).
    lv_written = mo_cut->reverse_run( 'RUN-1' ).

    DATA(lt_header) = mo_cut->read_active( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_header )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_header[ 1 ]-run_id
                                        exp = 'RUN-2' ).
  ENDMETHOD.

ENDCLASS.
