CLASS ltcl_stock_preview_summary DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS summarizes_preview_lines FOR TESTING.
    METHODS handles_empty_preview FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_preview_summary IMPLEMENTATION.
  METHOD summarizes_preview_lines.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_summary TYPE zcl_stock_preview_summary=>ty_summary.

    APPEND VALUE #( requested         = 5
                    allocated         = 5
                    shortage          = 0
                    allocation_status = 'F' ) TO lt_demands.
    APPEND VALUE #( requested         = 4
                    allocated         = 2
                    shortage          = 2
                    allocation_status = 'P' ) TO lt_demands.
    APPEND VALUE #( requested         = 3
                    allocated         = 0
                    shortage          = 3
                    allocation_status = 'U' ) TO lt_demands.

    ls_summary = zcl_stock_preview_summary=>calculate(
      it_demands            = lt_demands
      iv_remaining_quantity = 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-remaining_quantity
      exp = 6 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-requested_quantity
      exp = 12 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-allocated_quantity
      exp = 7 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-shortage_quantity
      exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-coverage_pct
      exp = '58.33' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-demand_count
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-full_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-partial_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-unallocated_count
      exp = 1 ).
  ENDMETHOD.

  METHOD handles_empty_preview.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA ls_summary TYPE zcl_stock_preview_summary=>ty_summary.

    ls_summary = zcl_stock_preview_summary=>calculate(
      it_demands            = lt_demands
      iv_remaining_quantity = '1.25' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-remaining_quantity
      exp = '1.25' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-coverage_pct
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_summary-demand_count
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
