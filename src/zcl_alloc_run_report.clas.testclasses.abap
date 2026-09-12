CLASS ltcl_alloc_run_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_header      TYPE REF TO zcl_alloc_run_header.
    DATA mo_cut         TYPE REF TO zcl_alloc_run_report.

    METHODS setup.
    METHODS teardown.

    METHODS given_run
      IMPORTING
        iv_run_id    TYPE zstock_run_id
        iv_matnr     TYPE matnr
        iv_requested TYPE menge_d
        iv_allocated TYPE menge_d.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS overview_computes_coverage FOR TESTING.
    METHODS overview_lists_all_runs    FOR TESTING.
    METHODS overview_of_run_filters    FOR TESTING.
    METHODS full_coverage_is_100       FOR TESTING.
    METHODS empty_log_empty_overview   FOR TESTING.
    METHODS to_lines_has_header        FOR TESTING.
    METHODS to_lines_formats_row       FOR TESTING.
    METHODS catalog_lists_columns      FOR TESTING.
    METHODS catalog_matches_header     FOR TESTING.
    METHODS catalog_marks_quantities   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_run_report IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKRUN' ) ) ).
    mo_header = NEW zcl_alloc_run_header( ).
    mo_cut = NEW zcl_alloc_run_report( io_header = mo_header ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
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

  METHOD given_run.
    DATA lv_written TYPE i.
    DATA lt_result  TYPE zcl_stock_allocator=>ty_result_tt.

    lt_result = add_line( it_result    = lt_result
                          iv_requested = iv_requested
                          iv_allocated = iv_allocated ).

    lv_written = mo_header->start_run( iv_run_id = iv_run_id
                                       iv_matnr  = iv_matnr
                                       iv_werks  = '1000' ).
    lv_written = mo_header->finish_run( iv_run_id = iv_run_id
                                        iv_matnr  = iv_matnr
                                        iv_werks  = '1000'
                                        it_result = lt_result ).
  ENDMETHOD.

  METHOD overview_computes_coverage.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '6' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-status
                                        exp = 'D' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-item_count
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-coverage_pct
                                        exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-shortage_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD overview_lists_all_runs.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '10' ).
    given_run( iv_run_id    = 'RUN-2'
               iv_matnr     = 'MAT-2'
               iv_requested = '10'
               iv_allocated = '5' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 2 ]-run_id
                                        exp = 'RUN-2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 2 ]-coverage_pct
                                        exp = 50 ).
  ENDMETHOD.

  METHOD overview_of_run_filters.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '10' ).
    given_run( iv_run_id    = 'RUN-2'
               iv_matnr     = 'MAT-2'
               iv_requested = '10'
               iv_allocated = '5' ).

    DATA(lt_overview) = mo_cut->overview_of_run( 'RUN-2' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-matnr
                                        exp = 'MAT-2' ).
  ENDMETHOD.

  METHOD full_coverage_is_100.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '10' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-coverage_pct
                                        exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD empty_log_empty_overview.
    cl_abap_unit_assert=>assert_initial( act = mo_cut->overview( ) ).
  ENDMETHOD.

  METHOD to_lines_has_header.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lt_lines    TYPE zcl_alloc_run_report=>ty_lines_tt.

    lt_lines = mo_cut->to_lines( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'RUN_ID;MATNR;WERKS;STATUS;ITEMS;REQUESTED;ALLOCATED;SHORTAGE;COVERAGE' ).
  ENDMETHOD.

  METHOD to_lines_formats_row.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA ls_row      TYPE zcl_alloc_run_report=>ty_overview.

    ls_row-run_id = 'RUN-1'.
    ls_row-matnr = 'MAT-1'.
    ls_row-werks = '1000'.
    ls_row-status = 'D'.
    ls_row-item_count = 2.
    ls_row-requested_qty = '10'.
    ls_row-allocated_qty = '6'.
    ls_row-shortage_qty = '4'.
    ls_row-coverage_pct = 60.

    APPEND ls_row TO lt_overview.

    DATA(lt_lines) = mo_cut->to_lines( lt_overview ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lt_lines[ 2 ] off = 0 len = 5 )
      exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = substring( val = lt_lines[ 2 ] off = 6 len = 5 )
      exp = 'MAT-1' ).
  ENDMETHOD.

  METHOD catalog_lists_columns.
    DATA(lt_fields) = mo_cut->field_catalog( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fields )
                                        exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 1 ]-fieldname
                                        exp = 'RUN_ID' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 2 ]-fieldname
                                        exp = 'MATNR' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 9 ]-fieldname
                                        exp = 'COVERAGE' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 9 ]-just
                                        exp = 'R' ).
  ENDMETHOD.

  METHOD catalog_matches_header.
    DATA lt_overview TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lv_expected TYPE string.

    DATA(lt_lines) = mo_cut->to_lines( lt_overview ).

    " the header must be exactly the catalog columns, in catalog order
    LOOP AT mo_cut->field_catalog( ) INTO DATA(ls_field).
      IF lv_expected IS NOT INITIAL.
        lv_expected = lv_expected && |;|.
      ENDIF.
      lv_expected = lv_expected && |{ ls_field-fieldname }|.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 1 ]
                                        exp = lv_expected ).
  ENDMETHOD.

  METHOD catalog_marks_quantities.
    DATA(lt_fields) = mo_cut->field_catalog( ).

    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 2 ]-rollname
                                        exp = 'MATNR' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 7 ]-rollname
                                        exp = 'MENGE_D' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 7 ]-decimals
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 7 ]-text
                                        exp = 'Allocated qty' ).
  ENDMETHOD.

ENDCLASS.
