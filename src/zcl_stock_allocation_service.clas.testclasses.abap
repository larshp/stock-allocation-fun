CLASS lcl_stock_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
    METHODS constructor
      IMPORTING
        iv_quantity        TYPE zif_stock_allocation=>ty_quantity
        iv_latest_quantity TYPE zif_stock_allocation=>ty_quantity
        iv_unit            TYPE zif_stock_allocation=>ty_unit DEFAULT 'EA'.
    METHODS get_calls
      RETURNING
        VALUE(rv_calls) TYPE i.
  PRIVATE SECTION.
    DATA mv_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA mv_latest_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA mv_calls TYPE i.
    DATA mv_unit TYPE zif_stock_allocation=>ty_unit.
ENDCLASS.

CLASS lcl_stock_source IMPLEMENTATION.
  METHOD constructor.
    mv_quantity = iv_quantity.
    mv_latest_quantity = iv_latest_quantity.
    mv_unit = iv_unit.
  ENDMETHOD.

  METHOD zif_stock_source~get_available.
    mv_calls = mv_calls + 1.
    IF mv_calls = 1.
      rs_stock-quantity = mv_quantity.
    ELSE.
      rs_stock-quantity = mv_latest_quantity.
    ENDIF.
    rs_stock-unit = mv_unit.
  ENDMETHOD.

  METHOD get_calls.
    rv_calls = mv_calls.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_lock DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_lock.
    METHODS constructor
      IMPORTING
        iv_acquired TYPE abap_bool.
    METHODS was_released
      RETURNING
        VALUE(rv_released) TYPE abap_bool.
    METHODS was_requested
      RETURNING
        VALUE(rv_requested) TYPE abap_bool.
    METHODS request_matches
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      RETURNING
        VALUE(rv_matches)   TYPE abap_bool.
    METHODS release_matches
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_loc
      RETURNING
        VALUE(rv_matches)   TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_acquired TYPE abap_bool.
    DATA mv_released TYPE abap_bool.
    DATA mv_requested TYPE abap_bool.
    DATA mv_requested_material TYPE zif_stock_allocation=>ty_material.
    DATA mv_requested_plant TYPE zif_stock_allocation=>ty_plant.
    DATA mv_requested_storage TYPE zif_stock_allocation=>ty_storage_loc.
    DATA mv_released_material TYPE zif_stock_allocation=>ty_material.
    DATA mv_released_plant TYPE zif_stock_allocation=>ty_plant.
    DATA mv_released_storage TYPE zif_stock_allocation=>ty_storage_loc.
ENDCLASS.

CLASS lcl_allocation_lock IMPLEMENTATION.
  METHOD constructor.
    mv_acquired = iv_acquired.
  ENDMETHOD.

  METHOD zif_allocation_lock~acquire.
    mv_requested = abap_true.
    mv_requested_material = iv_material.
    mv_requested_plant = iv_plant.
    mv_requested_storage = iv_storage_location.
    rv_acquired = mv_acquired.
  ENDMETHOD.

  METHOD zif_allocation_lock~release.
    mv_released = abap_true.
    mv_released_material = iv_material.
    mv_released_plant = iv_plant.
    mv_released_storage = iv_storage_location.
  ENDMETHOD.

  METHOD was_released.
    rv_released = mv_released.
  ENDMETHOD.

  METHOD was_requested.
    rv_requested = mv_requested.
  ENDMETHOD.

  METHOD request_matches.
    rv_matches = xsdbool( mv_requested_material = iv_material
                      AND mv_requested_plant = iv_plant
                      AND mv_requested_storage = iv_storage_location ).
  ENDMETHOD.

  METHOD release_matches.
    rv_matches = xsdbool( mv_released_material = iv_material
                      AND mv_released_plant = iv_plant
                      AND mv_released_storage = iv_storage_location ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_authorization DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_authorization.
    METHODS constructor
      IMPORTING
        iv_authorized TYPE abap_bool.
    METHODS was_called
      RETURNING
        VALUE(rv_called) TYPE abap_bool.
    METHODS get_plant
      RETURNING
        VALUE(rv_plant) TYPE zif_stock_allocation=>ty_plant.
    METHODS get_storage_location
      RETURNING
        VALUE(rv_storage_location) TYPE zif_stock_allocation=>ty_storage_loc.
    METHODS get_activity
      RETURNING
        VALUE(rv_activity) TYPE zif_allocation_authorization=>ty_activity.
  PRIVATE SECTION.
    DATA mv_authorized TYPE abap_bool.
    DATA mv_called TYPE abap_bool.
    DATA mv_plant TYPE zif_stock_allocation=>ty_plant.
    DATA mv_storage_location TYPE zif_stock_allocation=>ty_storage_loc.
    DATA mv_activity TYPE zif_allocation_authorization=>ty_activity.
ENDCLASS.

CLASS lcl_authorization IMPLEMENTATION.
  METHOD constructor.
    mv_authorized = iv_authorized.
  ENDMETHOD.

  METHOD zif_allocation_authorization~is_authorized.
    mv_called = abap_true.
    mv_activity = iv_activity.
    mv_plant = iv_plant.
    mv_storage_location = iv_storage_location.
    rv_authorized = mv_authorized.
  ENDMETHOD.

  METHOD was_called.
    rv_called = mv_called.
  ENDMETHOD.

  METHOD get_plant.
    rv_plant = mv_plant.
  ENDMETHOD.

  METHOD get_storage_location.
    rv_storage_location = mv_storage_location.
  ENDMETHOD.

  METHOD get_activity.
    rv_activity = mv_activity.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_log DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_log.
    METHODS constructor
      IMPORTING
        iv_recorded TYPE abap_bool.
    METHODS was_called
      RETURNING
        VALUE(rv_called) TYPE abap_bool.
    METHODS context_matches
      IMPORTING
        iv_stock_qty       TYPE zif_stock_allocation=>ty_quantity
        iv_allocatable_qty TYPE zif_stock_allocation=>ty_quantity
        iv_reserve         TYPE zif_stock_allocation=>ty_quantity
        iv_unit            TYPE zif_stock_allocation=>ty_unit
        iv_strategy        TYPE zif_stock_allocation=>ty_strategy
        iv_cutoff_date     TYPE zif_stock_allocation=>ty_cutoff_date OPTIONAL
      RETURNING
        VALUE(rv_matches)  TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_recorded TYPE abap_bool.
    DATA mv_called TYPE abap_bool.
    DATA mv_stock_qty TYPE zif_stock_allocation=>ty_quantity.
    DATA mv_allocatable_qty TYPE zif_stock_allocation=>ty_quantity.
    DATA mv_reserve TYPE zif_stock_allocation=>ty_quantity.
    DATA mv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA mv_strategy TYPE zif_stock_allocation=>ty_strategy.
    DATA mv_cutoff_date TYPE zif_stock_allocation=>ty_cutoff_date.
ENDCLASS.

CLASS lcl_allocation_log IMPLEMENTATION.
  METHOD constructor.
    mv_recorded = iv_recorded.
  ENDMETHOD.

  METHOD zif_allocation_log~record_run.
    mv_called = abap_true.
    mv_stock_qty = iv_stock_qty.
    mv_allocatable_qty = iv_allocatable_qty.
    mv_reserve = iv_reserve.
    mv_unit = iv_unit.
    mv_strategy = iv_strategy.
    mv_cutoff_date = iv_cutoff_date.
    rv_recorded = mv_recorded.
  ENDMETHOD.

  METHOD was_called.
    rv_called = mv_called.
  ENDMETHOD.

  METHOD context_matches.
    rv_matches = xsdbool( mv_stock_qty = iv_stock_qty
                      AND mv_allocatable_qty = iv_allocatable_qty
                      AND mv_reserve = iv_reserve
                      AND mv_unit = iv_unit
                      AND mv_strategy = iv_strategy
                      AND mv_cutoff_date = iv_cutoff_date ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_demand_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_demand_source.
    METHODS constructor
      IMPORTING
        it_demands TYPE zif_stock_allocation=>tt_demands.
    METHODS get_cutoff_date
      RETURNING
        VALUE(rv_cutoff_date) TYPE zif_stock_allocation=>ty_cutoff_date.
  PRIVATE SECTION.
    DATA mt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA mv_cutoff_date TYPE zif_stock_allocation=>ty_cutoff_date.
ENDCLASS.

CLASS lcl_demand_source IMPLEMENTATION.
  METHOD constructor.
    mt_demands = it_demands.
  ENDMETHOD.

  METHOD zif_demand_source~get_open_demands.
    rt_demands = mt_demands.
    mv_cutoff_date = iv_cutoff_date.
    IF iv_cutoff_date IS NOT INITIAL.
      DELETE rt_demands WHERE delivery_date > iv_cutoff_date.
    ENDIF.
  ENDMETHOD.

  METHOD get_cutoff_date.
    rv_cutoff_date = mv_cutoff_date.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
    METHODS get_saved
      RETURNING
        VALUE(rt_allocations) TYPE zif_stock_allocation=>tt_allocations.
  PRIVATE SECTION.
    DATA mt_allocations TYPE zif_stock_allocation=>tt_allocations.
ENDCLASS.

CLASS lcl_allocation_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~save.
    mt_allocations = it_allocations.
  ENDMETHOD.

  METHOD get_saved.
    rt_allocations = mt_allocations.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_sink DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_failing_sink IMPLEMENTATION.
  METHOD zif_allocation_sink~save.
    RAISE EXCEPTION NEW cx_sy_zerodivide( ).
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_db DEFINITION FINAL
  FOR TESTING RISK LEVEL DANGEROUS DURATION SHORT.
  PRIVATE SECTION.
    METHODS teardown.
    METHODS runs_productive_data_adapters FOR TESTING RAISING zcx_stock_allocation.
    METHODS runs_cutoff_integration FOR TESTING RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocation_db IMPLEMENTATION.
  METHOD teardown.
    DELETE FROM zstockalloc
      WHERE matnr = 'ZUT-SOURCE'
        AND werks = 'UT01'
        AND lgort = 'UT01'.
  ENDMETHOD.

  METHOD runs_productive_data_adapters.
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW zcl_stock_source_sap( )
      io_demand_source = NEW zcl_demand_source_sap( )
      io_allocation_sink = NEW zcl_allocation_sink_sap( )
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = lo_log ).

    DATA(lt_result) = lo_service->run(
      iv_material = 'ZUT-SOURCE'
      iv_plant = 'UT01'
      iv_storage_location = 'UT01'
      iv_reserve = '1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-sales_order
      exp = '0099999902' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-priority exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '4.500' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-sales_order
      exp = '0099999901' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 2 ]-allocated_qty exp = '7' ).
    cl_abap_unit_assert=>assert_true( lo_log->was_called( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_released( ) ).

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'ZUT-SOURCE'
        AND werks = 'UT01'
        AND lgort = 'UT01'
        AND reserve_qty = '1'
        AND meins = 'EA'
      INTO @DATA(lv_saved_count).
    cl_abap_unit_assert=>assert_equals( act = lv_saved_count exp = 2 ).
  ENDMETHOD.

  METHOD runs_cutoff_integration.
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW zcl_stock_source_sap( )
      io_demand_source = NEW zcl_demand_source_sap( )
      io_allocation_sink = NEW zcl_allocation_sink_sap( )
      io_allocation_lock = NEW lcl_allocation_lock( abap_true )
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = lo_log ).

    DATA(lt_result) = lo_service->run(
      iv_material = 'ZUT-SOURCE'
      iv_plant = 'UT01'
      iv_storage_location = 'UT01'
      iv_cutoff_date = '20260801' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-sales_order
      exp = '0099999901' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '7' ).
    cl_abap_unit_assert=>assert_true( lo_log->context_matches(
      iv_stock_qty = '12.5'
      iv_allocatable_qty = '12.5'
      iv_reserve = '0'
      iv_unit = 'EA'
      iv_strategy = zif_stock_allocation=>c_strategy_fifo
      iv_cutoff_date = '20260801' ) ).

    SELECT COUNT( * )
      FROM zstockalloc
      WHERE matnr = 'ZUT-SOURCE'
        AND werks = 'UT01'
        AND lgort = 'UT01'
        AND vbeln = '0099999901'
        AND cutoff_date = '20260801'
      INTO @DATA(lv_saved_count).
    cl_abap_unit_assert=>assert_equals( act = lv_saved_count exp = 1 ).
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS orchestrates_and_saves FOR TESTING RAISING zcx_stock_allocation.
    METHODS rechecks_latest_stock FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_concurrent_run FOR TESTING.
    METHODS releases_after_failure FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized_run FOR TESTING.
    METHODS rejects_log_failure FOR TESTING.
    METHODS previews_without_side_effects FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_invalid_scope_first FOR TESTING.
    METHODS rejects_missing_unit FOR TESTING.
    METHODS applies_reserve_buffer FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_negative_reserve FOR TESTING.
    METHODS rejects_duplicate_demands FOR TESTING.
    METHODS applies_selected_strategy FOR TESTING RAISING zcx_stock_allocation.
    METHODS rejects_invalid_strategy_first FOR TESTING.
    METHODS compares_single_snapshot FOR TESTING RAISING zcx_stock_allocation.
    METHODS applies_demand_cutoff FOR TESTING RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD orchestrates_and_saves.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '7' ) ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_authorization) = NEW lcl_authorization( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = lo_authorization
      io_allocation_log = lo_log ).

    DATA(lt_result) = lo_service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001' ).
    DATA(lt_saved) = lo_sink->get_saved( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_saved ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-shortage_qty exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-schedule_line exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_saved[ 1 ]-unit exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_plant( )
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_storage_location( )
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_activity( )
      exp = '16' ).
    cl_abap_unit_assert=>assert_true( lo_log->context_matches(
      iv_stock_qty = '5'
      iv_allocatable_qty = '5'
      iv_reserve = '0'
      iv_unit = 'EA'
      iv_strategy = zif_stock_allocation=>c_strategy_fifo ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_released( ) ).
    cl_abap_unit_assert=>assert_true( lo_lock->request_matches(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001' ) ).
  ENDMETHOD.

  METHOD rechecks_latest_stock.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '7' ) ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '10' iv_latest_quantity = '4' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = NEW lcl_allocation_sink( )
      io_allocation_lock = NEW lcl_allocation_lock( abap_true )
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    DATA(lt_result) = lo_service->run(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty exp = '3' ).
  ENDMETHOD.

  METHOD rejects_concurrent_run.
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_false ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Concurrent run must be rejected' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_released( ) ).
  ENDMETHOD.

  METHOD releases_after_failure.
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = NEW lcl_failing_sink( )
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Sink failure must propagate' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_true( lo_lock->was_released( ) ).
        cl_abap_unit_assert=>assert_true( lo_lock->release_matches(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ) ).
        cl_abap_unit_assert=>assert_bound( lo_error->previous ).
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_unauthorized_run.
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_false )
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Unauthorized run must be rejected' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
  ENDMETHOD.

  METHOD rejects_log_failure.
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = NEW lcl_allocation_log( abap_false ) ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Application log failure must reject the run' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
    cl_abap_unit_assert=>assert_true( lo_lock->was_released( ) ).
  ENDMETHOD.

  METHOD previews_without_side_effects.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '3' ) ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_authorization) = NEW lcl_authorization( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = lo_authorization
      io_allocation_log = lo_log ).

    DATA(lt_result) = lo_service->preview(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
    cl_abap_unit_assert=>assert_false( lo_log->was_called( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_activity( )
      exp = '03' ).
  ENDMETHOD.

  METHOD rejects_invalid_scope_first.
    DATA(lo_authorization) = NEW lcl_authorization( abap_true ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = lo_authorization
      io_allocation_log = lo_log ).

    TRY.
        lo_service->run(
          iv_material = ''
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Invalid allocation scope must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_authorization->was_called( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
    cl_abap_unit_assert=>assert_false( lo_log->was_called( ) ).
    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
  ENDMETHOD.

  METHOD rejects_missing_unit.
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source(
        iv_quantity = '5'
        iv_latest_quantity = '5'
        iv_unit = '' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = lo_log ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Missing material unit must reject the run' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lo_lock->was_released( ) ).
    cl_abap_unit_assert=>assert_false( lo_log->was_called( ) ).
    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
  ENDMETHOD.

  METHOD applies_reserve_buffer.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '8' ) ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '10' iv_latest_quantity = '10' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = NEW lcl_allocation_sink( )
      io_allocation_lock = NEW lcl_allocation_lock( abap_true )
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    DATA(ls_plan) = lo_service->preview_plan(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001'
      iv_reserve = '3' ).
    DATA(lt_result) = ls_plan-allocations.

    cl_abap_unit_assert=>assert_equals( act = ls_plan-stock_qty exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-allocatable_qty exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-reserve_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-unit exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty exp = '7' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-reserve_qty exp = '3' ).
  ENDMETHOD.

  METHOD rejects_negative_reserve.
    DATA(lo_authorization) = NEW lcl_authorization( abap_true ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '10' iv_latest_quantity = '10' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = NEW lcl_allocation_sink( )
      io_allocation_lock = lo_lock
      io_authorization = lo_authorization
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001'
          iv_reserve = '-1' ).
        cl_abap_unit_assert=>fail( 'Negative reserve must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_authorization->was_called( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
  ENDMETHOD.

  METHOD rejects_duplicate_demands.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '2' )
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250102'
        requested_qty = '3' ) ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = lo_log ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001' ).
        cl_abap_unit_assert=>fail( 'Duplicate demand keys must fail' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lo_lock->was_released( ) ).
    cl_abap_unit_assert=>assert_false( lo_log->was_called( ) ).
    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
  ENDMETHOD.

  METHOD applies_selected_strategy.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '2' )
      ( sales_order = '2'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250102'
        requested_qty = '6' ) ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '4' iv_latest_quantity = '4' )
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = lo_log ).

    DATA(ls_plan) = lo_service->run_plan(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001'
      iv_strategy = zif_stock_allocation=>c_strategy_proportional
      iv_cutoff_date = '20250131' ).
    DATA(lt_saved) = lo_sink->get_saved( ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_plan-strategy
      exp = zif_stock_allocation=>c_strategy_proportional ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-allocations[ 1 ]-allocated_qty exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-allocations[ 2 ]-allocated_qty exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_saved[ 1 ]-strategy
      exp = zif_stock_allocation=>c_strategy_proportional ).
    cl_abap_unit_assert=>assert_true( lo_log->context_matches(
      iv_stock_qty = '4'
      iv_allocatable_qty = '4'
      iv_reserve = '0'
      iv_unit = 'EA'
      iv_strategy = zif_stock_allocation=>c_strategy_proportional
      iv_cutoff_date = '20250131' ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_released( ) ).
  ENDMETHOD.

  METHOD rejects_invalid_strategy_first.
    DATA(lo_authorization) = NEW lcl_authorization( abap_true ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '4' iv_latest_quantity = '4' )
      io_demand_source = NEW lcl_demand_source( VALUE #( ) )
      io_allocation_sink = NEW lcl_allocation_sink( )
      io_allocation_lock = lo_lock
      io_authorization = lo_authorization
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    TRY.
        lo_service->run(
          iv_material = 'MAT-1'
          iv_plant = '1000'
          iv_storage_location = '0001'
          iv_strategy = 'X' ).
        cl_abap_unit_assert=>fail( 'Invalid strategy must fail before side effects' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        cl_abap_unit_assert=>assert_not_initial( lo_error->get_text( ) ).
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lo_authorization->was_called( ) ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
  ENDMETHOD.

  METHOD compares_single_snapshot.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '5' )
      ( sales_order = '2'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250102'
        requested_qty = '2' )
      ( sales_order = '3'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250103'
        requested_qty = '3' ) ).
    DATA(lo_stock) = NEW lcl_stock_source(
      iv_quantity = '6'
      iv_latest_quantity = '5' ).
    DATA(lo_sink) = NEW lcl_allocation_sink( ).
    DATA(lo_lock) = NEW lcl_allocation_lock( abap_true ).
    DATA(lo_log) = NEW lcl_allocation_log( abap_true ).
    DATA(lo_authorization) = NEW lcl_authorization( abap_true ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = lo_stock
      io_demand_source = NEW lcl_demand_source( lt_demands )
      io_allocation_sink = lo_sink
      io_allocation_lock = lo_lock
      io_authorization = lo_authorization
      io_allocation_log = lo_log ).

    DATA(lt_plans) = lo_service->preview_all_strategies(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_plans ) exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lo_stock->get_calls( ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_plans[ 1 ]-stock_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plans[ 1 ]-strategy
      exp = zif_stock_allocation=>c_strategy_fifo ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plans[ 4 ]-strategy
      exp = zif_stock_allocation=>c_strategy_smallest_first ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_plans[ 5 ]-strategy
      exp = zif_stock_allocation=>c_strategy_complete_only ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_strategy_selector=>recommend(
        it_plans = lt_plans
        iv_objective = zif_stock_allocation=>c_objective_service )
      exp = zif_stock_allocation=>c_strategy_smallest_first ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_stock_strategy_selector=>recommend(
        it_plans = lt_plans
        iv_objective = zif_stock_allocation=>c_objective_fairness )
      exp = zif_stock_allocation=>c_strategy_proportional ).
    cl_abap_unit_assert=>assert_equals( act = lt_plans[ 1 ]-allocations[ 1 ]-allocated_qty exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_plans[ 4 ]-allocations[ 1 ]-allocated_qty exp = '0' ).
    cl_abap_unit_assert=>assert_false( lo_lock->was_requested( ) ).
    cl_abap_unit_assert=>assert_false( lo_log->was_called( ) ).
    cl_abap_unit_assert=>assert_initial( lo_sink->get_saved( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_authorization->get_activity( )
      exp = '03' ).
  ENDMETHOD.

  METHOD applies_demand_cutoff.
    DATA(lt_demands) = VALUE zif_stock_allocation=>tt_demands(
      ( sales_order = '1'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250101'
        requested_qty = '2' )
      ( sales_order = '2'
        sales_item = '000010'
        schedule_line = '0001'
        delivery_date = '20250201'
        requested_qty = '3' ) ).
    DATA(lo_demands) = NEW lcl_demand_source( lt_demands ).
    DATA(lo_service) = NEW zcl_stock_allocation_service(
      io_stock_source = NEW lcl_stock_source( iv_quantity = '5' iv_latest_quantity = '5' )
      io_demand_source = lo_demands
      io_allocation_sink = NEW lcl_allocation_sink( )
      io_allocation_lock = NEW lcl_allocation_lock( abap_true )
      io_authorization = NEW lcl_authorization( abap_true )
      io_allocation_log = NEW lcl_allocation_log( abap_true ) ).

    DATA(ls_plan) = lo_service->preview_plan(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      iv_storage_location = '0001'
      iv_cutoff_date = '20250131' ).

    cl_abap_unit_assert=>assert_equals( act = lines( ls_plan-allocations ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_plan-cutoff_date exp = '20250131' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_plan-allocations[ 1 ]-cutoff_date
      exp = '20250131' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_demands->get_cutoff_date( )
      exp = '20250131' ).
  ENDMETHOD.
ENDCLASS.
