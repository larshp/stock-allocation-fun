CLASS lcl_unit_converter DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_unit_converter.
    DATA ms_result TYPE zif_unit_converter=>ty_result.
    DATA mv_use_result TYPE abap_bool.
    DATA mv_material TYPE zif_unit_converter=>ty_material.
    DATA mv_quantity TYPE zif_unit_converter=>ty_quantity.
    DATA mv_source_unit TYPE zif_unit_converter=>ty_unit.
    DATA mv_base_unit TYPE zif_unit_converter=>ty_unit.
ENDCLASS.

CLASS lcl_unit_converter IMPLEMENTATION.
  METHOD zif_unit_converter~to_base.
    mv_material = iv_material.
    mv_quantity = iv_quantity.
    mv_source_unit = iv_source_unit.
    mv_base_unit = iv_base_unit.
    IF mv_use_result = abap_true.
      rs_result = ms_result.
    ELSE.
      rs_result-is_success = abap_true.
      rs_result-quantity = iv_quantity.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocator DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_stock_allocator.
    DATA mo_converter TYPE REF TO lcl_unit_converter.

    METHODS setup.
    METHODS allocates_by_priority FOR TESTING.
    METHODS allocates_by_due_date FOR TESTING.
    METHODS supports_due_first_strategy FOR TESTING.
    METHODS supports_priority_id_strategy FOR TESTING.
    METHODS rejects_unknown_strategy FOR TESTING.
    METHODS protects_safety_stock FOR TESTING.
    METHODS shares_plant_safety_stock FOR TESTING.
    METHODS rejects_all_or_nothing FOR TESTING.
    METHODS partially_allocates FOR TESTING.
    METHODS honors_minimum_fill FOR TESTING.
    METHODS rejects_below_minimum_fill FOR TESTING.
    METHODS rejects_duplicate_id FOR TESTING.
    METHODS rejects_invalid_quantity FOR TESTING.
    METHODS rejects_missing_posting_data FOR TESTING.
    METHODS rejects_missing_unit FOR TESTING.
    METHODS converts_alternative_unit FOR TESTING.
    METHODS rejects_missing_conversion FOR TESTING.
    METHODS rejects_missing_cost_center FOR TESTING.
    METHODS accepts_order_assignment FOR TESTING.
    METHODS accepts_wbs_assignment FOR TESTING.
    METHODS rejects_missing_sales_item FOR TESTING.
    METHODS accepts_sales_assignment FOR TESTING.
    METHODS rejects_missing_asset_sub FOR TESTING.
    METHODS accepts_asset_assignment FOR TESTING.
    METHODS accepts_sales_cost_center FOR TESTING.
    METHODS accepts_network_assignment FOR TESTING.

    METHODS stock
      IMPORTING
        iv_quantity     TYPE zcl_stock_allocator=>ty_quantity
        iv_safety_stock TYPE zcl_stock_allocator=>ty_quantity DEFAULT 0
      RETURNING
        VALUE(rt_stock) TYPE zcl_stock_allocator=>ty_stock_balances.

    METHODS request
      IMPORTING
        iv_id               TYPE zcl_stock_allocator=>ty_request_id
        iv_quantity         TYPE zcl_stock_allocator=>ty_quantity
        iv_priority         TYPE i DEFAULT 100
        iv_requirement_date TYPE d DEFAULT '20260818'
        iv_minimum_fill_pct TYPE zcl_stock_allocator=>ty_quantity DEFAULT 0
        iv_allow_partial    TYPE abap_bool DEFAULT abap_false
        iv_storage_location TYPE zcl_stock_allocator=>ty_storage_location DEFAULT '0001'
        iv_unit_of_measure  TYPE zcl_stock_allocator=>ty_unit DEFAULT 'EA'
      RETURNING
        VALUE(rs_request)   TYPE zcl_stock_allocator=>ty_request.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD setup.
    mo_converter = NEW #( ).
    mo_converter->ms_result-message =
      'No material-specific unit conversion is maintained'.
    mo_cut = NEW #( mo_converter ).
  ENDMETHOD.

  METHOD allocates_by_priority.
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request(
          iv_id       = 'LOW'
          iv_quantity = 7
          iv_priority = 20 ) )
      ( request(
          iv_id       = 'HIGH'
          iv_quantity = 7
          iv_priority = 10 ) ) ).

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = lt_requests
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-request_id
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-source_requested_qty
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-source_unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
  ENDMETHOD.

  METHOD protects_safety_stock.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id            = 'SAFETY'
            iv_quantity      = 8
            iv_allow_partial = abap_true ) ) )
      it_stock_balances = stock(
        iv_quantity     = 10
        iv_safety_stock = 4 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall_qty
      exp = 2 ).
  ENDMETHOD.

  METHOD shares_plant_safety_stock.
    DATA(lt_stock) = VALUE zcl_stock_allocator=>ty_stock_balances(
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
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request(
          iv_id               = 'LOCATION-1'
          iv_quantity         = 5
          iv_priority         = 10
          iv_storage_location = '0001' ) )
      ( request(
          iv_id               = 'LOCATION-2'
          iv_quantity         = 5
          iv_priority         = 20
          iv_allow_partial    = abap_true
          iv_storage_location = '0002' ) ) ).

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = lt_requests
      it_stock_balances = lt_stock ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-allocated_qty
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-status
      exp = zcl_stock_allocator=>gc_status_partial ).
  ENDMETHOD.

  METHOD allocates_by_due_date.
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request(
          iv_id               = 'LATER'
          iv_quantity         = 7
          iv_requirement_date = '20260820' ) )
      ( request(
          iv_id               = 'EARLIER'
          iv_quantity         = 7
          iv_requirement_date = '20260819' ) ) ).

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = lt_requests
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-request_id
      exp = 'EARLIER' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
  ENDMETHOD.

  METHOD supports_due_first_strategy.
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request(
          iv_id               = 'HIGH-LATER'
          iv_quantity         = 7
          iv_priority         = 10
          iv_requirement_date = '20260820' ) )
      ( request(
          iv_id               = 'LOW-EARLIER'
          iv_quantity         = 7
          iv_priority         = 20
          iv_requirement_date = '20260819' ) ) ).

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = lt_requests
      it_stock_balances = stock( 10 )
      iv_strategy       = zcl_stock_allocator=>gc_strategy_due_priority ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-request_id
      exp = 'LOW-EARLIER' ).
  ENDMETHOD.

  METHOD supports_priority_id_strategy.
    DATA(lt_requests) = VALUE zcl_stock_allocator=>ty_requests(
      ( request(
          iv_id               = 'A-LATER'
          iv_quantity         = 7
          iv_requirement_date = '20260820' ) )
      ( request(
          iv_id               = 'Z-EARLIER'
          iv_quantity         = 7
          iv_requirement_date = '20260819' ) ) ).

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = lt_requests
      it_stock_balances = stock( 10 )
      iv_strategy       = zcl_stock_allocator=>gc_strategy_priority_id ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-request_id
      exp = 'A-LATER' ).
  ENDMETHOD.

  METHOD rejects_unknown_strategy.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id       = 'BAD-STRATEGY'
            iv_quantity = 1 ) ) )
      it_stock_balances = stock( 10 )
      iv_strategy       = 'UNSUPPORTED' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_config_error ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Unsupported allocation strategy' ).
  ENDMETHOD.

  METHOD rejects_all_or_nothing.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id       = 'FIRST'
            iv_quantity = 11
            iv_priority = 10 ) )
        ( request(
            iv_id       = 'SECOND'
            iv_quantity = 5
            iv_priority = 20 ) ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-allocated_qty
      exp = 5 ).
  ENDMETHOD.

  METHOD partially_allocates.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id            = 'PARTIAL'
            iv_quantity      = 12
            iv_allow_partial = abap_true ) ) )
      it_stock_balances = stock( 9 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty
      exp = 9 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_partial ).
  ENDMETHOD.

  METHOD honors_minimum_fill.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id               = 'MINIMUM-MET'
            iv_quantity         = 10
            iv_minimum_fill_pct = 60
            iv_allow_partial    = abap_true ) ) )
      it_stock_balances = stock( 6 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_partial ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty
      exp = 6 ).
  ENDMETHOD.

  METHOD rejects_below_minimum_fill.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id               = 'BELOW-MINIMUM'
            iv_quantity         = 10
            iv_minimum_fill_pct = 70
            iv_allow_partial    = abap_true ) ) )
      it_stock_balances = stock( 6 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_rejected ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_duplicate_id.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id       = 'DUPLICATE'
            iv_quantity = 2 ) )
        ( request(
            iv_id       = 'DUPLICATE'
            iv_quantity = 2 ) ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
  ENDMETHOD.

  METHOD rejects_invalid_quantity.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id       = 'INVALID'
            iv_quantity = 0 ) ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
  ENDMETHOD.

  METHOD rejects_missing_posting_data.
    DATA(ls_request) = request(
      iv_id       = 'MISSING-MOVE-TYPE'
      iv_quantity = 1 ).
    CLEAR ls_request-movement_type.
    DATA lt_requests TYPE zcl_stock_allocator=>ty_requests.
    APPEND ls_request TO lt_requests.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = lt_requests
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_not_required ).
  ENDMETHOD.

  METHOD rejects_missing_unit.
    DATA(ls_request) = request(
      iv_id       = 'MISSING-UNIT'
      iv_quantity = 1 ).
    CLEAR ls_request-unit_of_measure.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
  ENDMETHOD.

  METHOD converts_alternative_unit.
    mo_converter->mv_use_result = abap_true.
    mo_converter->ms_result = VALUE #(
      is_success = abap_true
      quantity   = 10 ).

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id              = 'BOXES'
            iv_quantity        = 2
            iv_unit_of_measure = 'BOX' ) ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-requested_qty
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-source_requested_qty
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-source_unit_of_measure
      exp = 'BOX' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_converter->mv_base_unit
      exp = 'EA' ).
  ENDMETHOD.

  METHOD rejects_missing_conversion.
    mo_converter->mv_use_result = abap_true.
    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #(
        ( request(
            iv_id              = 'WRONG-UNIT'
            iv_quantity        = 1
            iv_unit_of_measure = 'KG' ) ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'No material-specific unit conversion is maintained' ).
  ENDMETHOD.

  METHOD rejects_missing_cost_center.
    DATA(ls_request) = request(
      iv_id       = 'NO-COST-CENTER'
      iv_quantity = 1 ).
    CLEAR ls_request-cost_center.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Movement type 201 requires a cost center' ).
  ENDMETHOD.

  METHOD accepts_order_assignment.
    DATA(ls_request) = request(
      iv_id       = 'ORDER-CONSUMPTION'
      iv_quantity = 1 ).
    ls_request-movement_type = '261'.
    CLEAR ls_request-cost_center.
    ls_request-order_id = '000001234567'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-order_id
      exp = '000001234567' ).
  ENDMETHOD.

  METHOD accepts_wbs_assignment.
    DATA(ls_request) = request(
      iv_id       = 'PROJECT-CONSUMPTION'
      iv_quantity = 1 ).
    ls_request-movement_type = '221'.
    CLEAR ls_request-cost_center.
    ls_request-wbs_element = 'PROJECT-001'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-wbs_element
      exp = 'PROJECT-001' ).
  ENDMETHOD.

  METHOD rejects_missing_sales_item.
    DATA(ls_request) = request(
      iv_id       = 'NO-SALES-ITEM'
      iv_quantity = 1 ).
    ls_request-movement_type = '231'.
    CLEAR ls_request-cost_center.
    ls_request-sales_order = '0000123456'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Movement type 231 requires a sales order item' ).
  ENDMETHOD.

  METHOD accepts_sales_assignment.
    DATA(ls_request) = request(
      iv_id       = 'SALES-CONSUMPTION'
      iv_quantity = 1 ).
    ls_request-movement_type = '231'.
    CLEAR ls_request-cost_center.
    ls_request-sales_order = '0000123456'.
    ls_request-sales_order_item = '000010'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-sales_order_item
      exp = '000010' ).
  ENDMETHOD.

  METHOD rejects_missing_asset_sub.
    DATA(ls_request) = request(
      iv_id       = 'NO-ASSET-SUBNUMBER'
      iv_quantity = 1 ).
    ls_request-movement_type = '241'.
    CLEAR ls_request-cost_center.
    ls_request-asset_number = '000000123456'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_invalid ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-posting_message
      exp = 'Movement type 241 requires an asset subnumber' ).
  ENDMETHOD.

  METHOD accepts_asset_assignment.
    DATA(ls_request) = request(
      iv_id       = 'ASSET-CONSUMPTION'
      iv_quantity = 1 ).
    ls_request-movement_type = '241'.
    CLEAR ls_request-cost_center.
    ls_request-asset_number = '000000123456'.
    ls_request-asset_subnumber = '0000'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-asset_number
      exp = '000000123456' ).
  ENDMETHOD.

  METHOD accepts_sales_cost_center.
    DATA(ls_request) = request(
      iv_id       = 'SALES-COST-CENTER'
      iv_quantity = 1 ).
    ls_request-movement_type = '251'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-cost_center
      exp = 'CC1000' ).
  ENDMETHOD.

  METHOD accepts_network_assignment.
    DATA(ls_request) = request(
      iv_id       = 'NETWORK-CONSUMPTION'
      iv_quantity = 1 ).
    ls_request-movement_type = '281'.
    CLEAR ls_request-cost_center.
    ls_request-network_id = '000001234567'.
    ls_request-network_activity = '0010'.

    DATA(lt_result) = mo_cut->allocate(
      it_requests       = VALUE #( ( ls_request ) )
      it_stock_balances = stock( 10 ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-status
      exp = zcl_stock_allocator=>gc_status_allocated ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-network_activity
      exp = '0010' ).
  ENDMETHOD.

  METHOD stock.
    rt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        base_unit        = 'EA'
        unrestricted_qty = iv_quantity
        safety_stock_qty = iv_safety_stock ) ).
  ENDMETHOD.

  METHOD request.
    rs_request = VALUE #(
      request_id       = iv_id
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = iv_storage_location
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = iv_unit_of_measure
      requirement_date = iv_requirement_date
      requested_qty    = iv_quantity
      minimum_fill_pct = iv_minimum_fill_pct
      priority         = iv_priority
      allow_partial    = iv_allow_partial ).
  ENDMETHOD.
ENDCLASS.
