CLASS lcl_saved_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_source.
    METHODS constructor
      IMPORTING
        is_saved    TYPE zif_stock_allocation=>ty_saved_plan
        it_versions TYPE zif_stock_allocation=>tt_plan_versions OPTIONAL.
    METHODS was_called
      RETURNING
        VALUE(rv_called) TYPE abap_bool.
    METHODS get_version_no
      RETURNING
        VALUE(rv_version_no) TYPE i.
    METHODS get_max_versions
      RETURNING
        VALUE(rv_max_versions) TYPE i.
    METHODS get_before_version
      RETURNING
        VALUE(rv_before_version) TYPE i.
    METHODS get_strategy
      RETURNING
        VALUE(rv_strategy) TYPE zif_stock_allocation=>ty_strategy.
    METHODS get_created_by
      RETURNING
        VALUE(rv_created_by) TYPE zif_stock_allocation=>ty_created_by.
  PRIVATE SECTION.
    DATA ms_saved TYPE zif_stock_allocation=>ty_saved_plan.
    DATA mt_versions TYPE zif_stock_allocation=>tt_plan_versions.
    DATA mv_called TYPE abap_bool.
    DATA mv_version_no TYPE i.
    DATA mv_max_versions TYPE i.
    DATA mv_before_version TYPE i.
    DATA mv_strategy TYPE zif_stock_allocation=>ty_strategy.
    DATA mv_created_by TYPE zif_stock_allocation=>ty_created_by.
ENDCLASS.

CLASS lcl_saved_source IMPLEMENTATION.
  METHOD constructor.
    ms_saved = is_saved.
    mt_versions = it_versions.
  ENDMETHOD.

  METHOD zif_allocation_source~get_saved.
    mv_called = abap_true.
    mv_version_no = iv_version_no.
    rs_saved = ms_saved.
  ENDMETHOD.

  METHOD was_called.
    rv_called = mv_called.
  ENDMETHOD.

  METHOD get_version_no.
    rv_version_no = mv_version_no.
  ENDMETHOD.

  METHOD zif_allocation_source~list_versions.
    mv_called = abap_true.
    mv_max_versions = iv_max_versions.
    mv_before_version = iv_before_version.
    mv_strategy = iv_strategy.
    mv_created_by = iv_created_by.
    rt_versions = mt_versions.
  ENDMETHOD.

  METHOD get_max_versions.
    rv_max_versions = mv_max_versions.
  ENDMETHOD.

  METHOD get_before_version.
    rv_before_version = mv_before_version.
  ENDMETHOD.

  METHOD get_strategy.
    rv_strategy = mv_strategy.
  ENDMETHOD.

  METHOD get_created_by.
    rv_created_by = mv_created_by.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_query_authorization DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_authorization.
    METHODS constructor
      IMPORTING
        iv_authorized TYPE abap_bool.
    METHODS get_activity
      RETURNING
        VALUE(rv_activity) TYPE zif_allocation_authorization=>ty_activity.
  PRIVATE SECTION.
    DATA mv_authorized TYPE abap_bool.
    DATA mv_activity TYPE zif_allocation_authorization=>ty_activity.
ENDCLASS.

CLASS lcl_query_authorization IMPLEMENTATION.
  METHOD constructor.
    mv_authorized = iv_authorized.
  ENDMETHOD.

  METHOD zif_allocation_authorization~is_authorized.
    mv_activity = iv_activity.
    rv_authorized = mv_authorized.
  ENDMETHOD.

  METHOD get_activity.
    rv_activity = mv_activity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_query_service DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS reads_authorized_snapshot FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized_read FOR TESTING.
    METHODS flags_stale_snapshot FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_negative_max_age FOR TESTING.
    METHODS rejects_negative_version FOR TESTING.
    METHODS rejects_mismatched_version FOR TESTING.
    METHODS rejects_missing_provenance FOR TESTING.
    METHODS lists_authorized_versions FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_invalid_list_limit FOR TESTING.
    METHODS rejects_corrupt_version_list FOR TESTING.
    METHODS rejects_negative_cursor FOR TESTING.
    METHODS rejects_reversed_history FOR TESTING.
    METHODS rejects_corrupt_outcome_list FOR TESTING.
    METHODS rejects_invalid_hist_strategy FOR TESTING.
    METHODS rejects_wrong_filtered_list FOR TESTING.
    METHODS rejects_corrupt_context_list FOR TESTING.
    METHODS rejects_corrupt_strategy_list FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_query_service IMPLEMENTATION.
  METHOD reads_authorized_snapshot.
    DATA(lo_source) = NEW lcl_saved_source(
      VALUE #(
        found      = abap_true
        version_no = 3
        plan       = VALUE #( version_no = 3 stock_qty = '5' )
        created_on = sy-datum
        created_by = 'PLANNER1' ) ).
    DATA(lo_authorization) = NEW lcl_query_authorization( abap_true ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = lo_authorization ).

    DATA(ls_saved) = lo_service->get_saved(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_version_no       = 3 ).

    cl_abap_unit_assert=>assert_true( ls_saved-found ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-plan-stock_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = ls_saved-age_days exp = 0 ).
    cl_abap_unit_assert=>assert_false( ls_saved-stale ).
    cl_abap_unit_assert=>assert_true( lo_source->was_called( ) ).
    cl_abap_unit_assert=>assert_equals( act = lo_source->get_version_no( ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_activity( )
      exp = '03' ).
  ENDMETHOD.

  METHOD rejects_unauthorized_read.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_false ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Unauthorized persisted-plan read must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD flags_stale_snapshot.
    DATA lv_created_on TYPE d.
    lv_created_on = sy-datum - 2.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        VALUE #(
          found      = abap_true
          version_no = 1
          plan       = VALUE #( version_no = 1 )
          created_on = lv_created_on
          created_by = 'PLANNER1' ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    DATA(ls_saved) = lo_service->get_saved(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_max_age_days     = 1 ).

    cl_abap_unit_assert=>assert_equals( act = ls_saved-age_days exp = 2 ).
    cl_abap_unit_assert=>assert_true( ls_saved-stale ).
  ENDMETHOD.

  METHOD rejects_negative_max_age.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_max_age_days     = -1 ).
        cl_abap_unit_assert=>fail( 'Negative maximum age must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_negative_version.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_version_no       = -1 ).
        cl_abap_unit_assert=>fail( 'Negative plan version must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_mismatched_version.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        VALUE #(
          found      = abap_true
          version_no = 2
          plan       = VALUE #( version_no = 2 )
          created_on = sy-datum ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_version_no       = 3 ).
        cl_abap_unit_assert=>fail( 'Wrong historical version must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_missing_provenance.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        VALUE #(
          found      = abap_true
          version_no = 1
          plan       = VALUE #( version_no = 1 )
          created_on = sy-datum ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->get_saved(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Missing plan creator provenance must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD lists_authorized_versions.
    DATA(lo_source) = NEW lcl_saved_source(
      is_saved    = VALUE #( )
      it_versions = VALUE #(
        ( version_no = 3
          unit       = 'EA'
          strategy   = zif_stock_allocation=>c_strategy_fifo
          created_on = sy-datum
          created_by = 'PLANNER1' ) ) ).
    DATA(lo_authorization) = NEW lcl_query_authorization( abap_true ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = lo_authorization ).

    DATA(lt_versions) = lo_service->list_versions(
      iv_material         = 'MAT-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_max_versions     = 7
      iv_before_version   = 4
      iv_strategy         = zif_stock_allocation=>c_strategy_fifo
      iv_created_by       = 'PLANNER1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_versions ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_versions[ 1 ]-version_no exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_versions[ 1 ]-age_days exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lo_source->get_max_versions( ) exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = lo_source->get_before_version( ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_source->get_strategy( )
      exp = zif_stock_allocation=>c_strategy_fifo ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_source->get_created_by( )
      exp = 'PLANNER1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_activity( )
      exp = '03' ).
  ENDMETHOD.

  METHOD rejects_invalid_list_limit.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_max_versions     = 101 ).
        cl_abap_unit_assert=>fail( 'Excessive history list size must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_corrupt_version_list.
    DATA(lo_source) = NEW lcl_saved_source(
      is_saved    = VALUE #( )
      it_versions = VALUE #(
        ( version_no = 2
          unit       = 'EA'
          strategy   = zif_stock_allocation=>c_strategy_fifo
          created_on = sy-datum
          created_by = 'PLANNER1' )
        ( version_no = 2
          unit       = 'EA'
          strategy   = zif_stock_allocation=>c_strategy_fifo
          created_on = sy-datum
          created_by = 'PLANNER1' ) ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Duplicate history versions must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_negative_cursor.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_before_version   = -1 ).
        cl_abap_unit_assert=>fail( 'Negative history cursor must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_reversed_history.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_created_from     = '20260730'
          iv_created_to       = '20260729' ).
        cl_abap_unit_assert=>fail( 'Reversed history date window must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_corrupt_outcome_list.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        is_saved    = VALUE #( )
        it_versions = VALUE #(
          ( version_no    = 1
            requested_qty = '1'
            unit          = 'EA'
            strategy      = zif_stock_allocation=>c_strategy_fifo
            created_on    = sy-datum
            created_by    = 'PLANNER1' ) ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Corrupt catalog outcome must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_invalid_hist_strategy.
    DATA(lo_source) = NEW lcl_saved_source( VALUE #( ) ).
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = lo_source
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = 'X' ).
        cl_abap_unit_assert=>fail( 'Invalid history strategy must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_source->was_called( ) ).
  ENDMETHOD.

  METHOD rejects_wrong_filtered_list.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        is_saved    = VALUE #( )
        it_versions = VALUE #(
          ( version_no = 1
            unit       = 'EA'
            strategy   = zif_stock_allocation=>c_strategy_fifo
            created_on = sy-datum
            created_by = 'OTHER' ) ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_strategy         = zif_stock_allocation=>c_strategy_proportional
          iv_created_by       = 'PLANNER1' ).
        cl_abap_unit_assert=>fail( 'Mismatched filtered history must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_corrupt_context_list.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        is_saved    = VALUE #( )
        it_versions = VALUE #(
          ( version_no      = 1
            stock_qty       = '5'
            allocatable_qty = '5'
            reserve_qty     = '1'
            unit            = 'EA'
            strategy        = zif_stock_allocation=>c_strategy_fifo
            created_on      = sy-datum
            created_by      = 'PLANNER1' ) ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Corrupt catalog stock context must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_corrupt_strategy_list.
    DATA(lo_service) = NEW zcl_allocation_query_service(
      io_source        = NEW lcl_saved_source(
        is_saved    = VALUE #( )
        it_versions = VALUE #(
          ( version_no = 1
            unit       = 'EA'
            strategy   = 'X'
            created_on = sy-datum
            created_by = 'PLANNER1' ) ) )
      io_authorization = NEW lcl_query_authorization( abap_true ) ).

    TRY.
        lo_service->list_versions(
          iv_material         = 'MAT-1'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Corrupt catalog strategy must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
