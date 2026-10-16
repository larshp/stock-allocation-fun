CLASS ltcl_alloc_integrity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_integrity.
    DATA mo_sum  TYPE REF TO zcl_alloc_checksum.
    DATA mt_line TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_line
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS intact_when_equal   FOR TESTING.
    METHODS broken_when_differs FOR TESTING.
    METHODS counts_lines        FOR TESTING.
    METHODS empty_result_zero   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_integrity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_integrity( ).
    mo_sum = NEW zcl_alloc_checksum( ).

    add_line( iv_id = 'R1' iv_qty = 5 ).
    add_line( iv_id = 'R2' iv_qty = 3 ).
  ENDMETHOD.

  METHOD add_line.
    DATA ls_line TYPE zcl_stock_allocator=>ty_result.

    ls_line-requirement_id = iv_id.
    ls_line-allocated_qty = iv_qty.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD intact_when_equal.
    DATA lv_expected TYPE i.

    lv_expected = mo_sum->of_result( mt_line ).

    DATA(ls_report) = mo_cut->check( it_result   = mt_line
                                     iv_expected = lv_expected ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-is_intact exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-expected exp = lv_expected ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-actual exp = lv_expected ).
  ENDMETHOD.

  METHOD broken_when_differs.
    DATA lv_expected TYPE i.

    lv_expected = mo_sum->of_result( mt_line ) + 1.

    DATA(ls_report) = mo_cut->check( it_result   = mt_line
                                     iv_expected = lv_expected ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-is_intact exp = abap_false ).
  ENDMETHOD.

  METHOD counts_lines.
    DATA lv_expected TYPE i.

    lv_expected = mo_sum->of_result( mt_line ).

    DATA(ls_report) = mo_cut->check( it_result   = mt_line
                                     iv_expected = lv_expected ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-line_count exp = 2 ).
  ENDMETHOD.

  METHOD empty_result_zero.
    DATA lt_empty TYPE zcl_stock_allocator=>ty_result_tt.

    DATA(ls_report) = mo_cut->check( it_result   = lt_empty
                                     iv_expected = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-is_intact exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-line_count exp = 0 ).
  ENDMETHOD.

ENDCLASS.
