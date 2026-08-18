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
      it_allocations = allocations( )
      iv_simulation  = abap_true ).

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
      iv_simulation  = abap_false ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_current[ 1 ]-run_mode
      exp = 'P' ).
  ENDMETHOD.

  METHOD allocations.
    rt_allocations = VALUE #(
      ( request_id             = 'LOG-1'
        cost_center            = 'CC1000'
        sales_order            = '0000123456'
        sales_order_item       = '000010'
        asset_number           = '000000123456'
        asset_subnumber        = '0000'
        network_id             = '000001234567'
        network_activity       = '0010'
        allocated_qty          = 5
        requested_qty          = 5
        unit_of_measure        = 'EA'
        source_requested_qty   = 1
        source_unit_of_measure = 'BOX'
        status                 = zcl_stock_allocator=>gc_status_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_posted
        document_id            = '0000000001' )
      ( request_id             = 'LOG-2'
        allocated_qty          = 2
        requested_qty          = 2
        unit_of_measure        = 'EA'
        source_requested_qty   = 2
        source_unit_of_measure = 'EA'
        status                 = zcl_stock_allocator=>gc_status_partial
        posting_status         = zcl_stock_allocator=>gc_posting_simulated
        posting_message        = 'Simulation only' ) ).
  ENDMETHOD.
ENDCLASS.
