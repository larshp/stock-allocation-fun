CLASS ltcl_alloc_scenario DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut   TYPE REF TO zcl_alloc_scenario.
    DATA mt_base  TYPE zcl_stock_allocator=>ty_result_tt.
    DATA mt_adj   TYPE zcl_alloc_scenario=>ty_adjustment_tt.

    METHODS setup.

    METHODS add_base
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS add_adjustment
      IMPORTING
        iv_id  TYPE zcl_stock_allocator=>ty_result-requirement_id
        iv_qty TYPE menge_d.

    METHODS define_keeps_fields FOR TESTING.
    METHODS applies_delta       FOR TESTING.
    METHODS clamps_at_zero      FOR TESTING.
    METHODS ignores_unknown     FOR TESTING.
    METHODS empty_adjustments   FOR TESTING.
    METHODS keeps_line_count    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scenario IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scenario( ).
  ENDMETHOD.

  METHOD add_base.
    DATA ls_result TYPE zcl_stock_allocator=>ty_result.

    ls_result-requirement_id = iv_id.
    ls_result-allocated_qty = iv_qty.
    APPEND ls_result TO mt_base.
  ENDMETHOD.

  METHOD add_adjustment.
    DATA ls_adjustment TYPE zcl_alloc_scenario=>ty_adjustment.

    ls_adjustment-requirement_id = iv_id.
    ls_adjustment-delta_qty = iv_qty.
    APPEND ls_adjustment TO mt_adj.
  ENDMETHOD.

  METHOD define_keeps_fields.
    add_adjustment( iv_id = 'R1' iv_qty = 5 ).

    DATA(ls_scenario) = mo_cut->define( iv_scenario_id = 'S1'
                                        iv_note        = 'uplift'
                                        it_adjustments = mt_adj ).

    cl_abap_unit_assert=>assert_equals( act = ls_scenario-scenario_id exp = 'S1' ).
    cl_abap_unit_assert=>assert_equals( act = ls_scenario-note exp = 'uplift' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_scenario-adjustments ) exp = 1 ).
  ENDMETHOD.

  METHOD applies_delta.
    add_base( iv_id = 'R1' iv_qty = 10 ).
    add_adjustment( iv_id = 'R1' iv_qty = 5 ).

    DATA(ls_scenario) = mo_cut->define( iv_scenario_id = 'S1'
                                        iv_note        = ''
                                        it_adjustments = mt_adj ).
    DATA(lt_result) = mo_cut->apply( is_scenario = ls_scenario
                                     it_result   = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 15 ).
  ENDMETHOD.

  METHOD clamps_at_zero.
    add_base( iv_id = 'R1' iv_qty = 4 ).
    add_adjustment( iv_id = 'R1' iv_qty = -10 ).

    DATA(ls_scenario) = mo_cut->define( iv_scenario_id = 'S1'
                                        iv_note        = ''
                                        it_adjustments = mt_adj ).
    DATA(lt_result) = mo_cut->apply( is_scenario = ls_scenario
                                     it_result   = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 0 ).
  ENDMETHOD.

  METHOD ignores_unknown.
    add_base( iv_id = 'R1' iv_qty = 7 ).
    add_adjustment( iv_id = 'OTHER' iv_qty = 100 ).

    DATA(ls_scenario) = mo_cut->define( iv_scenario_id = 'S1'
                                        iv_note        = ''
                                        it_adjustments = mt_adj ).
    DATA(lt_result) = mo_cut->apply( is_scenario = ls_scenario
                                     it_result   = mt_base ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 7 ).
  ENDMETHOD.

  METHOD empty_adjustments.
    add_base( iv_id = 'R1' iv_qty = 7 ).

    DATA(ls_scenario) = mo_cut->define( iv_scenario_id = 'S1'
                                        iv_note        = ''
                                        it_adjustments = mt_adj ).
    DATA(lt_result) = mo_cut->apply( is_scenario = ls_scenario
                                     it_result   = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocated_qty exp = 7 ).
  ENDMETHOD.

  METHOD keeps_line_count.
    add_base( iv_id = 'R1' iv_qty = 1 ).
    add_base( iv_id = 'R2' iv_qty = 2 ).
    add_base( iv_id = 'R3' iv_qty = 3 ).
    add_adjustment( iv_id = 'R2' iv_qty = 10 ).

    DATA(ls_scenario) = mo_cut->define( iv_scenario_id = 'S1'
                                        iv_note        = ''
                                        it_adjustments = mt_adj ).
    DATA(lt_result) = mo_cut->apply( is_scenario = ls_scenario
                                     it_result   = mt_base ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-allocated_qty exp = 12 ).
  ENDMETHOD.

ENDCLASS.
