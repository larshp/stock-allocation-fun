CLASS lcl_recheck_stock_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
    DATA mt_stock TYPE zcl_stock_allocator=>ty_stock_balances.
    DATA mt_requests TYPE zcl_stock_allocator=>ty_requests.
ENDCLASS.

CLASS lcl_recheck_stock_reader IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    mt_requests = it_requests.
    rt_stock = mt_stock.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_rechecker_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_recheck_stock_reader.
    DATA mo_cut TYPE REF TO zcl_stock_rechecker_sap.

    METHODS setup.
    METHODS accepts_fresh_stock FOR TESTING.
    METHODS rejects_aggregate_shortage FOR TESTING.
    METHODS rejects_missing_stock FOR TESTING.
    METHODS accepts_shared_plant_safety FOR TESTING.
    METHODS rejects_plant_safety_shortage FOR TESTING.
    METHODS rejects_changed_base_unit FOR TESTING.

    METHODS allocations
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.

    METHODS multi_location_allocations
      IMPORTING
        iv_second_quantity    TYPE zcl_stock_allocator=>ty_quantity
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS ltcl_stock_rechecker_sap IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_cut = NEW #( mo_reader ).
  ENDMETHOD.

  METHOD accepts_fresh_stock.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 10
        safety_stock_qty = 1 ) ).

    DATA(ls_result) = mo_cut->zif_stock_rechecker~recheck( allocations( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_reader->mt_requests )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mt_requests[ 1 ]-cost_center
      exp = 'CC1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mt_requests[ 1 ]-sales_order_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mt_requests[ 1 ]-network_activity
      exp = '0010' ).
  ENDMETHOD.

  METHOD rejects_aggregate_shortage.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 8 ) ).

    DATA(ls_result) = mo_cut->zif_stock_rechecker~recheck( allocations( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Available stock changed during allocation posting' ).
  ENDMETHOD.

  METHOD rejects_missing_stock.
    DATA(ls_result) = mo_cut->zif_stock_rechecker~recheck( allocations( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Stock disappeared during allocation posting' ).
  ENDMETHOD.

  METHOD accepts_shared_plant_safety.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 4 )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 4 ) ).

    DATA(ls_result) = mo_cut->zif_stock_rechecker~recheck(
      multi_location_allocations( 1 ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_valid ).
  ENDMETHOD.

  METHOD rejects_plant_safety_shortage.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 4 )
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        base_unit        = 'EA'
        unrestricted_qty = 5
        safety_stock_qty = 4 ) ).

    DATA(ls_result) = mo_cut->zif_stock_rechecker~recheck(
      multi_location_allocations( 2 ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Available stock changed during allocation posting' ).
  ENDMETHOD.

  METHOD rejects_changed_base_unit.
    mo_reader->mt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'KG'
        unrestricted_qty = 10 ) ).

    DATA(ls_result) = mo_cut->zif_stock_rechecker~recheck( allocations( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_valid ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Material base unit changed during allocation posting' ).
  ENDMETHOD.

  METHOD allocations.
    rt_allocations = VALUE #(
      ( request_id       = 'REQUEST-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        cost_center      = 'CC1000'
        sales_order      = '0000123456'
        sales_order_item = '000010'
        asset_number     = '000000123456'
        asset_subnumber  = '0000'
        network_id       = '000001234567'
        network_activity = '0010'
        unit_of_measure  = 'EA'
        requirement_date = '20260818'
        allocated_qty    = 4
        posting_status   = zcl_stock_allocator=>gc_posting_pending )
      ( request_id       = 'REQUEST-2'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        cost_center      = 'CC1000'
        unit_of_measure  = 'EA'
        requirement_date = '20260818'
        allocated_qty    = 5
        posting_status   = zcl_stock_allocator=>gc_posting_pending ) ).
  ENDMETHOD.

  METHOD multi_location_allocations.
    rt_allocations = VALUE #(
      ( request_id       = 'LOCATION-1'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        movement_type    = '201'
        cost_center      = 'CC1000'
        unit_of_measure  = 'EA'
        requirement_date = '20260818'
        allocated_qty    = 5
        posting_status   = zcl_stock_allocator=>gc_posting_pending )
      ( request_id       = 'LOCATION-2'
        material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0002'
        movement_type    = '201'
        cost_center      = 'CC1000'
        unit_of_measure  = 'EA'
        requirement_date = '20260818'
        allocated_qty    = iv_second_quantity
        posting_status   = zcl_stock_allocator=>gc_posting_pending ) ).
  ENDMETHOD.
ENDCLASS.
