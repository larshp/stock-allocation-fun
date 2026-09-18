CLASS ltcl_alloc_scenario_matrix DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_scenario_matrix.
    DATA mt_sce TYPE zcl_alloc_scenario_matrix=>ty_scenario_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_uplift TYPE i
        iv_stock  TYPE i.

    METHODS empty_scenarios FOR TESTING.
    METHODS unchanged_base  FOR TESTING.
    METHODS uplift_is_short FOR TESTING.
    METHODS more_stock_fills FOR TESTING.
    METHODS scaled_negative FOR TESTING.
    METHODS fill_of_zero    FOR TESTING.
    METHODS one_row_per_scenario FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_scenario_matrix IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_scenario_matrix( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_scenario TYPE zcl_alloc_scenario_matrix=>ty_scenario.

    ls_scenario-scenario_id = iv_id.
    ls_scenario-uplift_pct = iv_uplift.
    ls_scenario-stock_pct = iv_stock.
    APPEND ls_scenario TO mt_sce.
  ENDMETHOD.

  METHOD empty_scenarios.
    DATA(lt_cells) = mo_cut->build( it_scenarios      = mt_sce
                                    iv_base_requested = 100
                                    iv_base_available = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 0 ).
  ENDMETHOD.

  METHOD unchanged_base.
    add( iv_id = 'S0' iv_uplift = 100 iv_stock = 100 ).

    DATA(lt_cells) = mo_cut->build( it_scenarios      = mt_sce
                                    iv_base_requested = 100
                                    iv_base_available = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-requested exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-available exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-allocated exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-shortage exp = 40 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-fill_x100 exp = 60 ).
  ENDMETHOD.

  METHOD uplift_is_short.
    add( iv_id = 'S1' iv_uplift = 150 iv_stock = 100 ).

    DATA(lt_cells) = mo_cut->build( it_scenarios      = mt_sce
                                    iv_base_requested = 100
                                    iv_base_available = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-requested exp = 150 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-allocated exp = 60 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-shortage exp = 90 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-fill_x100 exp = 40 ).
  ENDMETHOD.

  METHOD more_stock_fills.
    add( iv_id = 'S2' iv_uplift = 100 iv_stock = 200 ).

    DATA(lt_cells) = mo_cut->build( it_scenarios      = mt_sce
                                    iv_base_requested = 100
                                    iv_base_available = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-available exp = 120 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-allocated exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-shortage exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_cells[ 1 ]-fill_x100 exp = 100 ).
  ENDMETHOD.

  METHOD scaled_negative.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scaled( iv_base = 100 iv_pct = -50 ) exp = 0 ).
  ENDMETHOD.

  METHOD fill_of_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_of( iv_requested = 0 iv_allocated = 0 ) exp = 0 ).
  ENDMETHOD.

  METHOD one_row_per_scenario.
    add( iv_id = 'S0' iv_uplift = 100 iv_stock = 100 ).
    add( iv_id = 'S1' iv_uplift = 150 iv_stock = 100 ).

    DATA(lt_cells) = mo_cut->build( it_scenarios      = mt_sce
                                    iv_base_requested = 100
                                    iv_base_available = 60 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_cells ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_cells[ 1 ]-scenario_id exp = 'S0' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_cells[ 2 ]-scenario_id exp = 'S1' ).
  ENDMETHOD.

ENDCLASS.
