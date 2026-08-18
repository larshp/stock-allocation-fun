CLASS ltcl_stock_allocator DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_stock_allocator.

    METHODS setup.
    METHODS allocates_by_priority FOR TESTING.
    METHODS allocates_by_due_date FOR TESTING.
    METHODS supports_due_first_strategy FOR TESTING.
    METHODS supports_priority_id_strategy FOR TESTING.
    METHODS rejects_unknown_strategy FOR TESTING.
    METHODS protects_safety_stock FOR TESTING.
    METHODS rejects_all_or_nothing FOR TESTING.
    METHODS partially_allocates FOR TESTING.
    METHODS honors_minimum_fill FOR TESTING.
    METHODS rejects_below_minimum_fill FOR TESTING.
    METHODS rejects_duplicate_id FOR TESTING.
    METHODS rejects_invalid_quantity FOR TESTING.
    METHODS rejects_missing_posting_data FOR TESTING.

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
      RETURNING
        VALUE(rs_request)   TYPE zcl_stock_allocator=>ty_request.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
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

  METHOD stock.
    rt_stock = VALUE #(
      ( material         = 'MAT-1'
        plant            = '1000'
        storage_location = '0001'
        unrestricted_qty = iv_quantity
        safety_stock_qty = iv_safety_stock ) ).
  ENDMETHOD.

  METHOD request.
    rs_request = VALUE #(
      request_id       = iv_id
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      requirement_date = iv_requirement_date
      requested_qty    = iv_quantity
      minimum_fill_pct = iv_minimum_fill_pct
      priority         = iv_priority
      allow_partial    = iv_allow_partial ).
  ENDMETHOD.
ENDCLASS.
