CLASS lcl_allocation_log_store DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_log_store.
    DATA mt_current TYPE zif_allocation_log_store=>ty_current_entries.
    DATA mt_history TYPE zif_allocation_log_store=>ty_history_entries.
    DATA mv_saved TYPE abap_bool VALUE abap_true.
ENDCLASS.

CLASS lcl_allocation_log_store IMPLEMENTATION.
  METHOD zif_allocation_log_store~save.
    mt_current = it_current.
    mt_history = it_history.
    rv_saved = mv_saved.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_logger_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO lcl_allocation_log_store.
    DATA mo_cut TYPE REF TO zcl_allocation_logger_sap.

    METHODS setup.
    METHODS writes_current_and_history FOR TESTING.
    METHODS propagates_store_failure FOR TESTING.

    METHODS allocations
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS ltcl_allocation_logger_sap IMPLEMENTATION.
  METHOD setup.
    mo_store = NEW #( ).
    mo_cut = NEW #( mo_store ).
  ENDMETHOD.

  METHOD writes_current_and_history.
    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations        = allocations( )
      iv_simulation         = abap_true
      iv_run_id             = '00112233445566778899AABBCCDDEEFF'
      iv_strategy           = zcl_stock_allocator=>gc_strategy_due_priority
      iv_horizon_date       = '20260831'
      iv_require_full_batch = abap_true ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_current )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_store->mt_history )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_mode
      exp = 'S' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_id
      exp = '00112233445566778899AABBCCDDEEFF' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 2 ]-run_id
      exp = mo_store->mt_current[ 1 ]-run_id ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-source_requested_qty
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-source_unit
      exp = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-requested_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-cost_center
      exp = 'CC1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-sales_order_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-network_activity
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-storage_location
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-minimum_fill_pct
      exp = 75 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-allocation_strategy
      exp = zcl_stock_allocator=>gc_strategy_due_priority ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-horizon_date
      exp = '20260831' ).
    cl_abap_unit_assert=>assert_true(
      mo_store->mt_history[ 1 ]-require_full_batch ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-prior_reservation_id
      exp = '0000000041' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_history[ 1 ]-decision_code
      exp = zcl_stock_allocator=>gc_decision_fully_allocated ).
    cl_abap_unit_assert=>assert_not_initial(
      act = mo_store->mt_history[ 1 ]-log_uuid ).
    cl_abap_unit_assert=>assert_differs(
      act = mo_store->mt_history[ 1 ]-log_uuid
      exp = mo_store->mt_history[ 2 ]-log_uuid ).
  ENDMETHOD.

  METHOD propagates_store_failure.
    mo_store->mv_saved = abap_false.

    DATA(lv_saved) = mo_cut->zif_allocation_logger~write(
      it_allocations = allocations( )
      iv_simulation  = abap_false
      iv_run_id      = 'FFEEDDCCBBAA99887766554433221100'
      iv_strategy    = zcl_stock_allocator=>gc_strategy_priority_due ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_mode
      exp = 'P' ).
  ENDMETHOD.

  METHOD allocations.
    rt_allocations = VALUE #(
      ( request_id             = 'LOG-1'
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        sales_order            = '0000123456'
        sales_order_item       = '000010'
        asset_number           = '000000123456'
        asset_subnumber        = '0000'
        network_id             = '000001234567'
        network_activity       = '0010'
        requirement_date       = '20260818'
        minimum_fill_pct       = 75
        priority               = 10
        allow_partial          = abap_true
        allocated_qty          = 5
        requested_qty          = 5
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'BOX'
        status                 = zcl_stock_allocator=>gc_status_allocated
        decision_code          = zcl_stock_allocator=>gc_decision_fully_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = '0000000001'
        replaced_document_id   = '0000000041' )
      ( request_id             = 'LOG-2'
        allocated_qty          = 2
        requested_qty          = 2
        unit_of_measure        = 'EA'
        source_requested_qty   = 2
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_partial
        decision_code          = zcl_stock_allocator=>gc_decision_partial
        posting_status         = zcl_stock_allocator=>gc_posting_simulated
        posting_message        = 'Simulation only' ) ).
  ENDMETHOD.
ENDCLASS.
