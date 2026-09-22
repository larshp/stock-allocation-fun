CLASS ltcl_comparison DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA comparer TYPE REF TO zcl_stock_alloc_comparison.
    DATA baseline TYPE zif_stock_alloc_types=>ty_allocations.
    DATA scenario TYPE zif_stock_alloc_types=>ty_allocations.
    METHODS setup.
    METHODS compares_quantity_changes FOR TESTING RAISING zcx_stock_alloc.
    METHODS compares_real_runs FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_runs FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_different_requests FOR TESTING.
    METHODS rejects_changed_demand FOR TESTING.
    METHODS rejects_invalid_results FOR TESTING.
    METHODS quantity_boundaries FOR TESTING RAISING zcx_stock_alloc.
    METHODS assert_rejected.
ENDCLASS.

CLASS ltcl_comparison IMPLEMENTATION.
  METHOD setup.
    comparer = NEW #( ).
    baseline = VALUE #(
      ( request_id = 'A' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        required_date = '20260922' requested = '0.300' allocated = '0.100' shortage = '0.200'
        origin = VALUE #( order_id = '000000001000' reservation = '0000000100' reservation_item = '0001' ) )
      ( request_id = 'B' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        required_date = '20260922' requested = '0.300' allocated = '0.300' )
      ( request_id = 'C' material = 'MAT2' plant = '1000' storage = '0001' unit = 'KG'
        required_date = '20260923' requested = 2 shortage = 2 ) ).
    scenario = baseline.
    scenario[ 1 ]-allocated = '0.300'.
    scenario[ 1 ]-shortage = 0.
    scenario[ 2 ]-allocated = '0.100'.
    scenario[ 2 ]-shortage = '0.200'.
  ENDMETHOD.

  METHOD compares_quantity_changes.
    SORT baseline BY request_id DESCENDING.
    DATA(result) = comparer->compare( baseline = baseline
                                      scenario = scenario ).
    cl_abap_unit_assert=>assert_equals( act = lines( result )
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-request_id
                                      exp   = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocation_delta
                                      exp   = '0.200' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-change
                                      exp   = zcl_stock_alloc_comparison=>change_improved ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-origin
                                      exp   = scenario[ 1 ]-origin ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage_before
                                      exp   = '0.200' ).
    cl_abap_unit_assert=>assert_initial( result[ 1 ]-shortage_after ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocation_delta
                                      exp   = '-0.200' ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-change
                                      exp   = zcl_stock_alloc_comparison=>change_reduced ).
    cl_abap_unit_assert=>assert_equals( act = result[ 3 ]-change
                                      exp   = zcl_stock_alloc_comparison=>change_unchanged ).
    cl_abap_unit_assert=>assert_equals( act = result[ 3 ]-unit
                                      exp   = 'KG' ).
    SORT scenario BY request_id DESCENDING.
    cl_abap_unit_assert=>assert_equals( act = comparer->compare( baseline = baseline
                                                               scenario   = scenario )
                                      exp   = result ).
  ENDMETHOD.

  METHOD compares_real_runs.
    DATA(allocator) = NEW zcl_stock_allocator( ).
    DATA(requests) = VALUE zif_stock_alloc_types=>ty_requests(
      ( request_id = 'FIRST' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        required_date = '20260922' quantity = 8 priority = 1 allow_partial = abap_true )
      ( request_id = 'SECOND' material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA'
        required_date = '20260922' quantity = 8 priority = 2 allow_partial = abap_true ) ).
    DATA(stocks) = VALUE zif_stock_alloc_types=>ty_stocks(
      ( material = 'MAT1' plant = '1000' storage = '0001' unit = 'EA' quantity = 10 ) ).
    baseline = allocator->allocate( stocks   = stocks
                                    requests = requests ).
    requests[ 2 ]-priority = 0.
    scenario = allocator->allocate( stocks   = stocks
                                    requests = requests ).
    DATA(result) = comparer->compare( baseline = baseline
                                      scenario = scenario ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated_before
                                      exp   = 8 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated_after
                                      exp   = 2 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocation_delta
                                      exp   = -6 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocation_delta
                                      exp   = 6 ).
  ENDMETHOD.

  METHOD empty_runs.
    CLEAR: baseline, scenario.
    cl_abap_unit_assert=>assert_initial( comparer->compare( baseline = baseline
                                                           scenario  = scenario ) ).
  ENDMETHOD.

  METHOD assert_rejected.
    TRY.
        comparer->compare( baseline = baseline
                           scenario = scenario ).
        cl_abap_unit_assert=>fail( 'Incomparable allocation runs accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_different_requests.
    scenario[ 1 ]-request_id = 'OTHER'.
    assert_rejected( ).
    scenario = baseline.
    DELETE scenario INDEX 1.
    assert_rejected( ).
    scenario = baseline.
    DATA(extra) = scenario[ 1 ].
    extra-request_id = 'EXTRA'.
    APPEND extra TO scenario.
    assert_rejected( ).
  ENDMETHOD.

  METHOD rejects_changed_demand.
    DO 8 TIMES.
      scenario = baseline.
      CASE sy-index.
        WHEN 1.
          scenario[ 1 ]-material = 'MAT2'.
        WHEN 2.
          scenario[ 1 ]-plant = '2000'.
        WHEN 3.
          scenario[ 1 ]-storage = '0002'.
        WHEN 4.
          scenario[ 1 ]-unit = 'KG'.
        WHEN 5.
          scenario[ 1 ]-required_date = '20260923'.
        WHEN 6.
          scenario[ 1 ]-requested = '0.400'.
          scenario[ 1 ]-shortage = '0.300'.
        WHEN 7.
          scenario[ 1 ]-origin-reservation_item = '0002'.
        WHEN 8.
          scenario[ 1 ]-origin-order_id = '000000002000'.
      ENDCASE.
      assert_rejected( ).
    ENDDO.
  ENDMETHOD.

  METHOD rejects_invalid_results.
    scenario[ 2 ]-request_id = scenario[ 1 ]-request_id.
    assert_rejected( ).
    scenario = baseline.
    baseline[ 2 ]-request_id = baseline[ 1 ]-request_id.
    assert_rejected( ).
    baseline = scenario.
    scenario[ 1 ]-shortage = 0.
    assert_rejected( ).
    scenario = baseline.
    baseline[ 1 ]-required_date = '20260229'.
    assert_rejected( ).
  ENDMETHOD.

  METHOD quantity_boundaries.
    DELETE baseline WHERE request_id <> 'A'.
    baseline[ 1 ]-requested = '9999999999.999'.
    baseline[ 1 ]-allocated = 0.
    baseline[ 1 ]-shortage = baseline[ 1 ]-requested.
    scenario = baseline.
    scenario[ 1 ]-allocated = scenario[ 1 ]-requested.
    scenario[ 1 ]-shortage = 0.
    DATA(result) = comparer->compare( baseline = baseline
                                      scenario = scenario ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocation_delta
                                      exp   = '9999999999.999' ).
    result = comparer->compare( baseline = scenario
                               scenario  = baseline ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocation_delta
                                      exp   = '-9999999999.999' ).
  ENDMETHOD.
ENDCLASS.
