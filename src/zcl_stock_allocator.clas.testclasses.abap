CLASS ltcl_stock_allocator DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_priority_first FOR TESTING.
    METHODS keeps_deterministic_order FOR TESTING.
    METHODS rejects_negative_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD allocates_priority_first.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator.
    APPEND VALUE #( order_id     = 'LOW'
                    priority     = 1
                    requested_on = '20260101'
                    requested    = '8' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'HIGH'
                    priority     = 10
                    requested_on = '20260102'
                    requested    = '5' ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '7'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'HIGH' ]-allocated
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LOW' ]-allocated
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'HIGH' ]-allocation_status
      exp = 'F' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LOW' ]-allocation_status
      exp = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
  ENDMETHOD.

  METHOD keeps_deterministic_order.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator.
    APPEND VALUE #( order_id       = 'B'
                    priority       = 5
                    requested_on   = '20260101'
                    requested      = '1'
                    reservation_id = 'OLD-RESERVATION' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'A'
                    priority     = 5
                    requested_on = '20260101'
                    requested    = '1' ) TO lt_demands.
    lo_cut->allocate(
      EXPORTING
        iv_available = '1'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'A' ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_demands[ order_id = 'B' ]-reservation_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'B' ]-allocation_status
      exp = 'U' ).
  ENDMETHOD.

  METHOD rejects_negative_stock.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator.
    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_available = '-1'
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_stock_source_stub IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    rs_available-quantity = '10'.
    rs_available-unit = 'EA'.
    rs_available-material_found = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_stock_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_failing_stock_source_stub IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_allocator_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation.
ENDCLASS.

CLASS lcl_failing_allocator_stub IMPLEMENTATION.
  METHOD zif_stock_allocation~allocate.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_lock_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_lock.
    METHODS was_acquired RETURNING VALUE(rv_value) TYPE abap_bool.
    METHODS was_released RETURNING VALUE(rv_value) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_acquired TYPE abap_bool.
    DATA mv_released TYPE abap_bool.
ENDCLASS.

CLASS lcl_failing_authority_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_authority.
ENDCLASS.

CLASS lcl_failing_authority_stub IMPLEMENTATION.
  METHOD zif_stock_allocation_authority~check.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_lock_stub IMPLEMENTATION.
  METHOD zif_stock_allocation_lock~acquire.
    mv_acquired = abap_true.
  ENDMETHOD.

  METHOD zif_stock_allocation_lock~release.
    mv_released = abap_true.
  ENDMETHOD.

  METHOD was_acquired.
    rv_value = mv_acquired.
  ENDMETHOD.

  METHOD was_released.
    rv_value = mv_released.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_lock_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_lock.
ENDCLASS.

CLASS lcl_failing_lock_stub IMPLEMENTATION.
  METHOD zif_stock_allocation_lock~acquire.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_stock_allocation_lock~release.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_order_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_order_source_stub IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'ORDER-1'
                    requested_on = '20260101'
                    requested    = '6' ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_mismatched_order_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_mismatched_order_source_stub IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id   = 'ORDER-BOX'
                    order_unit = 'BOX'
                    requested  = '1' ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_unit_conversion_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_conversion.
ENDCLASS.

CLASS lcl_unit_conversion_stub IMPLEMENTATION.
  METHOD zif_unit_conversion~convert.
    IF iv_unit_from = 'BOX' AND iv_unit_to = 'EA'.
      rv_quantity = iv_quantity * 10.
    ELSEIF iv_unit_from = 'EA' AND iv_unit_to = 'BOX'.
      rv_quantity = iv_quantity / 10.
    ELSE.
      rv_quantity = iv_quantity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_two_order_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_two_order_source_stub IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'ORDER-A'
                    requested_on = '20260101'
                    requested    = '6' ) TO rt_demands.
    APPEND VALUE #( order_id     = 'ORDER-B'
                    requested_on = '20260102'
                    requested    = '6' ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_sink_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
    METHODS was_saved RETURNING VALUE(rv_saved) TYPE abap_bool.
    METHODS reservation_id RETURNING VALUE(rv_id) TYPE zif_stock_allocation=>ty_order_id.
    METHODS run_id RETURNING VALUE(rv_id) TYPE zif_stock_allocation=>ty_run_id.
  PRIVATE SECTION.
    DATA mv_saved TYPE abap_bool.
    DATA mv_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA mv_run_id TYPE zif_stock_allocation=>ty_run_id.
ENDCLASS.

CLASS lcl_allocation_sink_stub IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
    mv_saved = abap_true.
    mv_reservation_id = it_demands[ 1 ]-reservation_id.
    mv_run_id = iv_run_id.
  ENDMETHOD.

  METHOD was_saved.
    rv_saved = mv_saved.
  ENDMETHOD.

  METHOD reservation_id.
    rv_id = mv_reservation_id.
  ENDMETHOD.

  METHOD run_id.
    rv_id = mv_run_id.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_allocation_sink_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
ENDCLASS.

CLASS lcl_failing_allocation_sink_stub IMPLEMENTATION.
  METHOD zif_allocation_sink~get_allocations.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_reservation_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
    METHODS was_called RETURNING VALUE(rv_called) TYPE abap_bool.
    METHODS quantity RETURNING VALUE(rv_quantity) TYPE zif_stock_allocation=>ty_quantity.
    METHODS required_date RETURNING VALUE(rv_date) TYPE d.
    METHODS was_cancelled RETURNING VALUE(rv_cancelled) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_called TYPE abap_bool.
    DATA mv_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA mv_required_date TYPE d.
    DATA mv_cancelled TYPE abap_bool.
ENDCLASS.

CLASS lcl_stock_reservation_stub IMPLEMENTATION.
  METHOD zif_stock_reservation~reserve.
    mv_called = abap_true.
    mv_quantity = iv_quantity.
    mv_required_date = iv_required_date.
    rv_document = 'RES-1'.
  ENDMETHOD.

  METHOD zif_stock_reservation~cancel.
    mv_cancelled = abap_true.
  ENDMETHOD.

  METHOD was_called.
    rv_called = mv_called.
  ENDMETHOD.

  METHOD quantity.
    rv_quantity = mv_quantity.
  ENDMETHOD.

  METHOD required_date.
    rv_date = mv_required_date.
  ENDMETHOD.

  METHOD was_cancelled.
    rv_cancelled = mv_cancelled.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_failing_reservation_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
    METHODS was_cancelled RETURNING VALUE(rv_cancelled) TYPE abap_bool.
  PRIVATE SECTION.
    DATA mv_reserve_calls TYPE i.
    DATA mv_cancelled TYPE abap_bool.
ENDCLASS.

CLASS lcl_failing_reservation_stub IMPLEMENTATION.
  METHOD zif_stock_reservation~reserve.
    mv_reserve_calls = mv_reserve_calls + 1.
    IF mv_reserve_calls > 1.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    rv_document = 'RES-1'.
  ENDMETHOD.

  METHOD zif_stock_reservation~cancel.
    mv_cancelled = abap_true.
  ENDMETHOD.

  METHOD was_cancelled.
    rv_cancelled = mv_cancelled.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_audit_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_audit.
    METHODS was_finished RETURNING VALUE(rv_finished) TYPE abap_bool.
    METHODS status RETURNING VALUE(rv_status) TYPE zif_allocation_audit=>ty_run_status.
    METHODS message RETURNING VALUE(rv_message) TYPE zif_allocation_audit=>ty_message.
    METHODS rejection_was_recorded RETURNING VALUE(rv_recorded) TYPE abap_bool.
    METHODS fail_finish.
  PRIVATE SECTION.
    DATA mv_finished TYPE abap_bool.
    DATA mv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA mv_message TYPE zif_allocation_audit=>ty_message.
    DATA mv_rejection_recorded TYPE abap_bool.
    DATA mv_fail_finish TYPE abap_bool.
ENDCLASS.

CLASS lcl_allocation_audit_stub IMPLEMENTATION.
  METHOD zif_allocation_audit~get_runs.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_summary.
  ENDMETHOD.

  METHOD zif_allocation_audit~purge_runs_before.
  ENDMETHOD.

  METHOD zif_allocation_audit~record_rejection.
    mv_rejection_recorded = abap_true.
    rv_run_id = 'RUN-REJECTED'.
  ENDMETHOD.

  METHOD zif_allocation_audit~start_run.
    rv_run_id = 'RUN-1'.
  ENDMETHOD.

  METHOD zif_allocation_audit~finish_run.
    IF mv_fail_finish = abap_true.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    mv_finished = abap_true.
    mv_status = iv_status.
    mv_message = iv_message.
  ENDMETHOD.

  METHOD was_finished.
    rv_finished = mv_finished.
  ENDMETHOD.

  METHOD status.
    rv_status = mv_status.
  ENDMETHOD.

  METHOD message.
    rv_message = mv_message.
  ENDMETHOD.

  METHOD rejection_was_recorded.
    rv_recorded = mv_rejection_recorded.
  ENDMETHOD.

  METHOD fail_finish.
    mv_fail_finish = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_partial_reservation_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
ENDCLASS.

CLASS lcl_partial_reservation_stub IMPLEMENTATION.
  METHOD zif_stock_reservation~reserve.
    IF iv_quantity = '6'.
      rv_document = 'RES-PARTIAL'.
    ELSE.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_reservation~cancel.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_and_persists FOR TESTING.
    METHODS previews_without_side_effects FOR TESTING.
    METHODS locks_allocation FOR TESTING.
    METHODS rejects_missing_runtime_input FOR TESTING.
    METHODS rejects_missing_dependency FOR TESTING.
    METHODS converts_mismatched_unit FOR TESTING.
    METHODS converts_stock_unit FOR TESTING.
    METHODS cancels_on_reservation_failure FOR TESTING.
    METHODS cancels_on_sink_failure FOR TESTING.
    METHODS records_partial_cleanup FOR TESTING.
    METHODS rejects_unauthorized FOR TESTING.
    METHODS audits_allocator_failure FOR TESTING.
    METHODS audits_lock_failure FOR TESTING.
    METHODS surfaces_audit_failure FOR TESTING.
    METHODS audits_stock_read_failure FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD allocates_and_persists.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '4' ).
    cl_abap_unit_assert=>assert_true( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_true( lo_reservation->was_called( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_reservation->quantity( )
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_reservation->required_date( )
      exp = '20260101' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_sink->reservation_id( )
      exp = 'RES-1' ).
    cl_abap_unit_assert=>assert_not_initial( lo_sink->run_id( ) ).
    cl_abap_unit_assert=>assert_true( lo_audit->was_finished( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'S' ).
  ENDMETHOD.

  METHOD previews_without_side_effects.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_authority TYPE REF TO lcl_failing_authority_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_allocator    = lo_allocator
        io_authority    = lo_authority
        io_audit        = lo_audit.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA'
      iv_preview          = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '4' ).
    cl_abap_unit_assert=>assert_true( lo_audit->was_finished( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'S' ).
  ENDMETHOD.

  METHOD locks_allocation.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_lock TYPE REF TO lcl_stock_lock_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_lock.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_lock         = lo_lock
        io_audit        = lo_audit.

    lo_cut->allocate(
      iv_material         = 'MATERIAL-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_true( lo_lock->was_acquired( ) ).
    cl_abap_unit_assert=>assert_true( lo_lock->was_released( ) ).
  ENDMETHOD.

  METHOD rejects_missing_runtime_input.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = ''
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true(
      lo_audit->rejection_was_recorded( ) ).
  ENDMETHOD.

  METHOD rejects_missing_dependency.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true(
      lo_audit->rejection_was_recorded( ) ).
  ENDMETHOD.

  METHOD converts_mismatched_unit.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_mismatched_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_unit_converter TYPE REF TO lcl_unit_conversion_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_unit_converter.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_sink           = lo_sink
        io_allocator      = lo_allocator
        io_reservation    = lo_reservation
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_false( lv_raised ).
    cl_abap_unit_assert=>assert_true( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_true( lo_reservation->was_called( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_reservation->quantity( )
      exp = '10' ).
    cl_abap_unit_assert=>assert_true( lo_audit->was_finished( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'S' ).
  ENDMETHOD.

  METHOD converts_stock_unit.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_unit_converter TYPE REF TO lcl_unit_conversion_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_unit_converter.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source   = lo_stock_source
        io_order_source   = lo_order_source
        io_sink           = lo_sink
        io_allocator      = lo_allocator
        io_reservation    = lo_reservation
        io_unit_converter = lo_unit_converter
        io_audit          = lo_audit.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-BOX'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'BOX' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_reservation->quantity( )
      exp = '1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'P' ).
  ENDMETHOD.

  METHOD cancels_on_reservation_failure.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_two_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_failing_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true( lo_reservation->was_cancelled( ) ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->message( )
      exp = 'Reservation failed' ).
  ENDMETHOD.

  METHOD cancels_on_sink_failure.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_failing_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true( lo_reservation->was_cancelled( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'E' ).
  ENDMETHOD.

  METHOD records_partial_cleanup.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_two_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_partial_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->status( )
      exp = 'P' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_audit->message( )
      exp = 'Reservation cleanup incomplete' ).
  ENDMETHOD.

  METHOD rejects_unauthorized.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_authority TYPE REF TO lcl_failing_authority_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_authority    = lo_authority
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true(
      lo_audit->rejection_was_recorded( ) ).
    cl_abap_unit_assert=>assert_false( lo_reservation->was_called( ) ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
  ENDMETHOD.

  METHOD audits_allocator_failure.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO lcl_failing_allocator_stub.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true(
      lo_audit->rejection_was_recorded( ) ).
    cl_abap_unit_assert=>assert_false( lo_reservation->was_called( ) ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
  ENDMETHOD.

  METHOD audits_lock_failure.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_lock TYPE REF TO lcl_failing_lock_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_lock.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_lock         = lo_lock
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true(
      lo_audit->rejection_was_recorded( ) ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_false( lo_reservation->was_called( ) ).
  ENDMETHOD.

  METHOD surfaces_audit_failure.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    lo_audit->fail_finish( ).
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA'
          iv_preview          = abap_true ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_false( lo_reservation->was_called( ) ).
  ENDMETHOD.

  METHOD audits_stock_read_failure.
    DATA lo_stock_source TYPE REF TO lcl_failing_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_audit TYPE REF TO lcl_allocation_audit_stub.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_audit.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    TRY.
        lo_cut->allocate(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_true(
      lo_audit->rejection_was_recorded( ) ).
    cl_abap_unit_assert=>assert_false( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_false( lo_reservation->was_called( ) ).
  ENDMETHOD.
ENDCLASS.
