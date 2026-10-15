CLASS ltcl_alloc_atp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_atp.
    DATA mt_per TYPE zcl_alloc_atp=>ty_period_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_period TYPE i
        iv_supply TYPE i
        iv_demand TYPE i.

    METHODS computes_atp   FOR TESTING.
    METHODS positive_rule  FOR TESTING.
    METHODS finds_first    FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_atp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_atp( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_period TYPE zcl_alloc_atp=>ty_period.

    ls_period-period = iv_period.
    ls_period-supply = iv_supply.
    ls_period-demand = iv_demand.
    APPEND ls_period TO mt_per.
  ENDMETHOD.

  METHOD computes_atp.
    add( iv_period = 1 iv_supply = 50 iv_demand = 20 ).
    add( iv_period = 2 iv_supply = 0 iv_demand = 40 ).
    add( iv_period = 3 iv_supply = 100 iv_demand = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->atp( it_periods = mt_per iv_period = 1 ) exp = 30 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->atp( it_periods = mt_per iv_period = 2 ) exp = -10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->atp( it_periods = mt_per iv_period = 3 ) exp = 90 ).
  ENDMETHOD.

  METHOD positive_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( 30 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_positive( -10 ) exp = abap_false ).
  ENDMETHOD.

  METHOD finds_first.
    add( iv_period = 1 iv_supply = 50 iv_demand = 20 ).
    add( iv_period = 2 iv_supply = 0 iv_demand = 40 ).
    add( iv_period = 3 iv_supply = 100 iv_demand = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_period( mt_per ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->atp( it_periods = mt_per iv_period = 1 ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_period( mt_per ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
