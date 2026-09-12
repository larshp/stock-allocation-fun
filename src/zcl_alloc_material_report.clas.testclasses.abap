CLASS ltcl_alloc_material_report DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_header      TYPE REF TO zcl_alloc_run_header.
    DATA mo_cut         TYPE REF TO zcl_alloc_material_report.

    METHODS setup.
    METHODS teardown.

    METHODS given_run
      IMPORTING
        iv_run_id    TYPE zstock_run_id
        iv_matnr     TYPE matnr
        iv_werks     TYPE werks_d DEFAULT '1000'
        iv_requested TYPE menge_d
        iv_allocated TYPE menge_d.

    METHODS given_log
      IMPORTING
        iv_run_id TYPE zstock_run_id
        iv_matnr  TYPE matnr
        iv_werks  TYPE werks_d DEFAULT '1000'
        iv_req_id TYPE zstockalloc-req_id
        iv_lgort  TYPE lgort_d
        iv_qty    TYPE menge_d DEFAULT 0.

    METHODS add_line
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_requested     TYPE menge_d
        iv_allocated     TYPE menge_d
      RETURNING
        VALUE(rt_result) TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS overview_joins_positions  FOR TESTING.
    METHODS overview_aggregates_runs  FOR TESTING.
    METHODS overview_groups_plants    FOR TESTING.
    METHODS overview_filters_material FOR TESTING.
    METHODS overview_ignores_log_only FOR TESTING.
    METHODS overview_computes_coverage FOR TESTING.
    METHODS empty_log_empty_overview  FOR TESTING.
    METHODS to_lines_has_header       FOR TESTING.
    METHODS catalog_lists_columns     FOR TESTING.
    METHODS reversed_run_excluded     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_material_report IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'ZSTOCKRUN' ) ( 'ZSTOCKALLOC' ) ) ).
    mo_header = NEW zcl_alloc_run_header( ).
    mo_cut = NEW zcl_alloc_material_report( io_header = mo_header ).
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
                                       iv_werks  = iv_werks ).
    lv_written = mo_header->finish_run( iv_run_id = iv_run_id
                                        iv_matnr  = iv_matnr
                                        iv_werks  = iv_werks
                                        it_result = lt_result ).
  ENDMETHOD.

  METHOD given_log.
    DATA ls_log TYPE zstockalloc.

    ls_log-mandt     = sy-mandt.
    ls_log-run_id    = iv_run_id.
    ls_log-req_id    = iv_req_id.
    ls_log-lgort     = iv_lgort.
    ls_log-matnr     = iv_matnr.
    ls_log-werks     = iv_werks.
    ls_log-alloc_dat = '20260101'.
    ls_log-alloc_tim = '120000'.
    ls_log-uname     = 'TESTER'.
    ls_log-alloc_qty = iv_qty.

    mo_environment->insert_test_data(
      VALUE zcl_alloc_log_reader=>ty_log_tt( ( ls_log ) ) ).
  ENDMETHOD.

  METHOD overview_joins_positions.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '6' ).
    given_log( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
               iv_req_id = 'REQ-1' iv_lgort = '0001' iv_qty = '4' ).
    given_log( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
               iv_req_id = 'REQ-1' iv_lgort = '0002' iv_qty = '2' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-run_count
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-item_count
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-positions
                                        exp = 2 ).
  ENDMETHOD.

  METHOD overview_aggregates_runs.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '6' ).
    given_run( iv_run_id    = 'RUN-2'
               iv_matnr     = 'MAT-1'
               iv_requested = '20'
               iv_allocated = '5' ).
    given_log( iv_run_id = 'RUN-1' iv_matnr = 'MAT-1'
               iv_req_id = 'REQ-1' iv_lgort = '0001' iv_qty = '6' ).
    given_log( iv_run_id = 'RUN-2' iv_matnr = 'MAT-1'
               iv_req_id = 'REQ-2' iv_lgort = '0001' iv_qty = '5' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-run_count
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-positions
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-requested_qty
                                        exp = '30' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-allocated_qty
                                        exp = '11' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-shortage_qty
                                        exp = '19' ).
  ENDMETHOD.

  METHOD overview_groups_plants.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_werks     = '1000'
               iv_requested = '10'
               iv_allocated = '10' ).
    given_run( iv_run_id    = 'RUN-2'
               iv_matnr     = 'MAT-1'
               iv_werks     = '2000'
               iv_requested = '10'
               iv_allocated = '5' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-werks
                                        exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 2 ]-werks
                                        exp = '2000' ).
  ENDMETHOD.

  METHOD overview_filters_material.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '10' ).
    given_run( iv_run_id    = 'RUN-2'
               iv_matnr     = 'MAT-2'
               iv_requested = '10'
               iv_allocated = '5' ).

    DATA(lt_overview) = mo_cut->overview_of_material( 'MAT-2' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-matnr
                                        exp = 'MAT-2' ).
  ENDMETHOD.

  METHOD overview_ignores_log_only.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '10' ).
    given_log( iv_run_id = 'RUN-1' iv_matnr = 'MAT-9'
               iv_req_id = 'REQ-9' iv_lgort = '0001' iv_qty = '3' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_overview )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-positions
                                        exp = 0 ).
  ENDMETHOD.

  METHOD overview_computes_coverage.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '6' ).

    DATA(lt_overview) = mo_cut->overview( ).

    cl_abap_unit_assert=>assert_equals( act = lt_overview[ 1 ]-coverage_pct
                                        exp = 60 ).
  ENDMETHOD.

  METHOD empty_log_empty_overview.
    cl_abap_unit_assert=>assert_initial( act = mo_cut->overview( ) ).
  ENDMETHOD.

  METHOD to_lines_has_header.
    DATA lt_overview TYPE zcl_alloc_material_report=>ty_material_line_tt.
    DATA lt_lines    TYPE zcl_alloc_material_report=>ty_lines_tt.

    lt_lines = mo_cut->to_lines( lt_overview ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'MATNR;WERKS;RUNS;ITEMS;POSITIONS;REQUESTED;ALLOCATED;SHORTAGE;COVERAGE' ).
  ENDMETHOD.

  METHOD catalog_lists_columns.
    DATA(lt_fields) = mo_cut->field_catalog( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_fields )
                                        exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 1 ]-fieldname
                                        exp = 'MATNR' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 5 ]-fieldname
                                        exp = 'POSITIONS' ).
    cl_abap_unit_assert=>assert_equals( act = lt_fields[ 9 ]-fieldname
                                        exp = 'COVERAGE' ).
  ENDMETHOD.

  METHOD reversed_run_excluded.
    given_run( iv_run_id    = 'RUN-1'
               iv_matnr     = 'MAT-1'
               iv_requested = '10'
               iv_allocated = '10' ).

    DATA lv_written TYPE i.
    lv_written = mo_header->reverse_run( 'RUN-1' ).

    cl_abap_unit_assert=>assert_initial( act = mo_cut->overview( ) ).
  ENDMETHOD.

ENDCLASS.
