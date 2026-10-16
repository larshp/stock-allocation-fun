CLASS ltcl_alloc_scenario_cmp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut  TYPE REF TO zcl_alloc_scenario_cmp.
    DATA mt_base TYPE zcl_stock_allocator=>ty_result_tt.
    DATA mt_scen TYPE zcl_stock_allocator=>ty_result_tt.

    METHODS setup.

    METHODS add_base
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS add_scen
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS reports_increase  FOR TESTING.
    METHODS reports_decrease  FOR TESTING.
    METHODS skips_unchanged   FOR TESTING.
    METHODS reports_added     FOR TESTING.
    METHODS reports_removed   FOR TESTING.
    METHODS totals_delta      FOR TESTING.
    METHODS identical_is_empty FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scenario_cmp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scenario_cmp( ).
  ENDMETHOD.

  METHOD add_base.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_base.
  ENDMETHOD.

  METHOD add_scen.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_scen.
  ENDMETHOD.

  METHOD reports_increase.
    add_base( iv_id = 'R1' iv_qty = 4 ).
    add_scen( iv_id = 'R1' iv_qty = 9 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-changed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-base_qty exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty exp = 5 ).
  ENDMETHOD.

  METHOD reports_decrease.
    add_base( iv_id = 'R1' iv_qty = 9 ).
    add_scen( iv_id = 'R1' iv_qty = 4 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-changed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty exp = -5 ).
  ENDMETHOD.

  METHOD skips_unchanged.
    add_base( iv_id = 'R1' iv_qty = 4 ).
    add_scen( iv_id = 'R1' iv_qty = 4 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-changed exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 0 ).
  ENDMETHOD.

  METHOD reports_added.
    add_scen( iv_id = 'NEW' iv_qty = 6 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-changed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-base_qty exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty exp = 6 ).
  ENDMETHOD.

  METHOD reports_removed.
    add_base( iv_id = 'OLD' iv_qty = 3 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-changed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lines[ 1 ]-delta_qty exp = -3 ).
  ENDMETHOD.

  METHOD totals_delta.
    add_base( iv_id = 'R1' iv_qty = 4 ).
    add_base( iv_id = 'R2' iv_qty = 10 ).
    add_scen( iv_id = 'R1' iv_qty = 6 ).
    add_scen( iv_id = 'R2' iv_qty = 3 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-changed exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_delta exp = -5 ).
  ENDMETHOD.

  METHOD identical_is_empty.
    add_base( iv_id = 'R1' iv_qty = 4 ).
    add_scen( iv_id = 'R1' iv_qty = 4 ).

    DATA(ls_result) = mo_cut->compare( it_base     = mt_base
                                       it_scenario = mt_scen ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_delta exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lines( ls_result-lines ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
