CLASS ltcl_stock_snapshot_netting DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS nets_within_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS caps_and_reports_overflow FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_negative_quantity FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_snapshot_netting IMPLEMENTATION.
  METHOD nets_within_stock.
    DATA ls_result TYPE zcl_stock_snapshot_netting=>ty_result.

    ls_result = zcl_stock_snapshot_netting=>calculate(
      iv_unbacked_quantity = 30
      iv_stock_quantity    = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-deduction_quantity
      exp = 30 ).
    cl_abap_unit_assert=>assert_false( ls_result-overflow ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-overflow_quantity
      exp = 0 ).
  ENDMETHOD.

  METHOD caps_and_reports_overflow.
    DATA ls_result TYPE zcl_stock_snapshot_netting=>ty_result.

    ls_result = zcl_stock_snapshot_netting=>calculate(
      iv_unbacked_quantity = 90
      iv_stock_quantity    = 70 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-deduction_quantity
      exp = 70 ).
    cl_abap_unit_assert=>assert_true( ls_result-overflow ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-overflow_quantity
      exp = 20 ).
  ENDMETHOD.

  METHOD rejects_negative_quantity.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    TRY.
        zcl_stock_snapshot_netting=>calculate(
          iv_unbacked_quantity = -1
          iv_stock_quantity    = 10 ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Snapshot netting quantity is invalid' ).
  ENDMETHOD.
ENDCLASS.
