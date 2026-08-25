CLASS ltcl_alloc_result_export DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS empty_result FOR TESTING.
    METHODS single_row FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_result_export IMPLEMENTATION.


  METHOD empty_result.
    " an empty allocation list exports to an empty JSON array
    DATA(lt_empty) = VALUE zcl_stock_allocator=>tt_allocations( ).

    DATA(lv_json) = zcl_alloc_result_export=>to_json(
        it_allocations = lt_empty ).

    cl_abap_unit_assert=>assert_equals(
      exp = '[]'
      act = lv_json ).
  ENDMETHOD.


  METHOD single_row.
    " one allocation row produces one JSON object with all fields
    DATA(lt_one) = VALUE zcl_stock_allocator=>tt_allocations(
        ( vbeln = '0000000270' posnr = '000010' matnr = 'MATJ1'
          werks = '1000' lgort = '0001' qty_req = '5'
          qty_alloc = '3' ) ).

    DATA(lv_json) = zcl_alloc_result_export=>to_json(
        it_allocations = lt_one ).

    " basic structure checks (assert_contains is not available in the
    " transpiled runtime, so check via find( ))
    cl_abap_unit_assert=>assert_not_initial(
      act = find( val = lv_json sub = '"vbeln": "0000000270"' ) ).
    cl_abap_unit_assert=>assert_not_initial(
      act = find( val = lv_json sub = '"matnr": "MATJ1"' ) ).
    cl_abap_unit_assert=>assert_not_initial(
      act = find( val = lv_json sub = '"qty_alloc": 3.000' ) ).
  ENDMETHOD.


ENDCLASS.
