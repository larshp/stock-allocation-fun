CLASS lcl_stock_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
    DATA mt_stock TYPE zcl_stock_allocator=>ty_stock_balances.
    DATA mt_requests TYPE zcl_stock_allocator=>ty_requests.
ENDCLASS.

CLASS lcl_stock_reader IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    mt_requests = it_requests.
    rt_stock = mt_stock.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_idempotency_store DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_idempotency_store.
    TYPES ty_records TYPE STANDARD TABLE OF
      zif_idempotency_store=>ty_record WITH EMPTY KEY.
    DATA mt_records TYPE ty_records.
ENDCLASS.

CLASS lcl_idempotency_store IMPLEMENTATION.
  METHOD zif_idempotency_store~find.
    READ TABLE mt_records INTO rs_record
      WITH KEY request_id = iv_request_id.
  ENDMETHOD.

  METHOD zif_idempotency_store~claim.
    rv_acquired = abap_true.
  ENDMETHOD.

  METHOD zif_idempotency_store~set_document.
    rv_updated = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_unit_converter DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_converter.
    DATA ms_result TYPE zif_unit_converter=>ty_result.
    DATA mv_use_result TYPE abap_bool.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_unit_converter IMPLEMENTATION.
  METHOD zif_unit_converter~to_base.
    mv_calls = mv_calls + 1.
    IF mv_use_result = abap_true.
      rs_result = ms_result.
    ELSE.
      rs_result-is_success = abap_true.
      rs_result-quantity = iv_quantity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_writer DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_writer.
    DATA mt_saved TYPE zcl_stock_allocator=>ty_allocations.
    DATA mv_call_count TYPE i.
    DATA mv_fail TYPE abap_bool.
ENDCLASS.

CLASS lcl_allocation_writer IMPLEMENTATION.
  METHOD zif_allocation_writer~save_allocations.
    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>).
      IF mv_fail = abap_true.
        <ls_allocation>-posting_status = zcl_stock_allocator=>gc_posting_failed.
        <ls_allocation>-posting_message = 'Posting failed'.
      ELSE.
        <ls_allocation>-posting_status = zcl_stock_allocator=>gc_posting_posted.
        <ls_allocation>-document_id = '0000000042'.
      ENDIF.
    ENDLOOP.
    mt_saved = ct_allocations.
    mv_call_count = mv_call_count + 1.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_stock_reader.
    DATA mo_writer TYPE REF TO lcl_allocation_writer.
    DATA mo_converter TYPE REF TO lcl_unit_converter.
    DATA mo_store TYPE REF TO lcl_idempotency_store.
    DATA mo_cut TYPE REF TO zcl_stock_allocation_service.

    METHODS setup.
    METHODS simulation_does_not_write FOR TESTING.
    METHODS writes_successful_allocations FOR TESTING.
    METHODS returns_posting_failure FOR TESTING.
    METHODS skips_empty_write FOR TESTING.
    METHODS converts_before_write FOR TESTING.
    METHODS replays_completed_request FOR TESTING.
    METHODS replay_does_not_reduce_stock FOR TESTING.
    METHODS rejects_reused_id_changes FOR TESTING.
    METHODS rejects_reused_assignment FOR TESTING.
    METHODS rejects_reused_sales_order FOR TESTING.
    METHODS rejects_legacy_replay FOR TESTING.
    METHODS simulation_ignores_replay FOR TESTING.

    METHODS requests
      IMPORTING
        iv_quantity        TYPE zcl_stock_allocator=>ty_quantity
        iv_allow_partial   TYPE abap_bool DEFAULT abap_false
        iv_unit_of_measure TYPE zcl_stock_allocator=>ty_unit DEFAULT 'EA'
      RETURNING
        VALUE(rt_requests) TYPE zcl_stock_allocator=>ty_requests.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_writer = NEW #( ).
    mo_converter = NEW #( ).
    mo_store = NEW #( ).
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 10 ) ).
    mo_cut = NEW #(
      io_stock_reader      = mo_reader
      io_allocation_writer = mo_writer
      io_unit_converter    = mo_converter
      io_idempotency_store = mo_store ).
  ENDMETHOD.

  METHOD simulation_does_not_write.
    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_simulated ).
  ENDMETHOD.

  METHOD writes_successful_allocations.
    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-allocated_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-document_id
      exp = '0000000042' ).
  ENDMETHOD.

  METHOD skips_empty_write.
    DATA(lt_result) = mo_cut->execute( requests( 11 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD returns_posting_failure.
    mo_writer->mv_fail = abap_true.

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Posting failed' ).
  ENDMETHOD.

  METHOD converts_before_write.
    mo_converter->mv_use_result = abap_true.
    mo_converter->ms_result = VALUE #(
      is_success = abap_true
      quantity   = 10 ).

    DATA(lt_result) = mo_cut->execute(
      requests(
        iv_quantity        = 2
        iv_unit_of_measure = 'BOX' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-allocated_qty
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-source_requested_qty
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD replays_completed_request.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        minimum_fill_pct     = 0
        priority             = 100
        allow_partial        = abap_false
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-document_id
      exp = '0000000042' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Existing reservation reused' ).
  ENDMETHOD.

  METHOD replay_does_not_reduce_stock.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000041' ) ).
    DATA(lt_requests) = requests( 5 ).
    APPEND VALUE #(
      request_id       = 'REQUEST-2'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      requested_qty    = 10
      priority         = 200 ) TO lt_requests.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ request_id = 'REQUEST-2' ]-allocated_qty
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_writer->mt_saved )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mt_saved[ 1 ]-request_id
      exp = 'REQUEST-2' ).
  ENDMETHOD.

  METHOD rejects_reused_id_changes.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC1000'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 6 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Request ID was already used with different input' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_reused_assignment.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        cost_center          = 'CC9999'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Request ID was already used with different input' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_reused_sales_order.
    mo_store->mt_records = VALUE #(
      ( is_found             = abap_true
        payload_version      = zcl_stock_allocator=>gc_payload_version
        request_id           = 'REQUEST-1'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '231'
        sales_order          = '0000123456'
        sales_order_item     = '000010'
        requirement_date     = '20260818'
        source_requested_qty = 5
        source_unit          = 'EA'
        priority             = 100
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        document_id          = '0000000042' ) ).
    DATA(lt_requests) = requests( 5 ).
    lt_requests[ 1 ]-movement_type = '231'.
    CLEAR lt_requests[ 1 ]-cost_center.
    lt_requests[ 1 ]-sales_order = '0000123456'.
    lt_requests[ 1 ]-sales_order_item = '000020'.

    DATA(lt_result) = mo_cut->execute( lt_requests ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Request ID was already used with different input' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_legacy_replay.
    mo_store->mt_records = VALUE #(
      ( is_found   = abap_true
        request_id = 'REQUEST-1' ) ).

    DATA(lt_result) = mo_cut->execute( requests( 5 ) ).

    cl_abap_unit_assert=>assert_initial( mo_reader->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_not_required ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Stored request payload version is unsupported' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_writer->mv_call_count
      exp = 0 ).
  ENDMETHOD.

  METHOD simulation_ignores_replay.
    mo_store->mt_records = VALUE #(
      ( is_found    = abap_true
        request_id  = 'REQUEST-1'
        document_id = '0000000042' ) ).

    DATA(lt_result) = mo_cut->execute(
      it_requests   = requests( 5 )
      iv_simulation = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_simulated ).
  ENDMETHOD.

  METHOD requests.
    rt_requests = VALUE #(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        cost_center      = 'CC1000'
        unit_of_measure  = iv_unit_of_measure
        requirement_date = '20260818'
        requested_qty    = iv_quantity
        priority         = 100
        allow_partial    = iv_allow_partial ) ).
  ENDMETHOD.
ENDCLASS.
