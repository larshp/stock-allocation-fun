CLASS ltcl_alloc_season_index DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_season_index.
    DATA mt_per TYPE zcl_alloc_season_index=>ty_period_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_period TYPE i
        iv_value  TYPE i.

    METHODS computes_index FOR TESTING.
    METHODS peak_rule      FOR TESTING.
    METHODS finds_peak     FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_season_index IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_season_index( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_period TYPE zcl_alloc_season_index=>ty_period.

    ls_period-period = iv_period.
    ls_period-value = iv_value.
    APPEND ls_period TO mt_per.
  ENDMETHOD.

  METHOD computes_index.
    add( iv_period = 1 iv_value = 100 ).
    add( iv_period = 2 iv_value = 200 ).
    add( iv_period = 3 iv_value = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->index_of( it_periods = mt_per iv_period = 2 )
      exp = 150 ).
  ENDMETHOD.

  METHOD peak_rule.
    add( iv_period = 1 iv_value = 100 ).
    add( iv_period = 2 iv_value = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_peak( it_periods = mt_per iv_period = 2 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_peak( it_periods = mt_per iv_period = 1 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD finds_peak.
    add( iv_period = 1 iv_value = 100 ).
    add( iv_period = 2 iv_value = 200 ).
    add( iv_period = 3 iv_value = 100 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->peak_period( mt_per ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->index_of( it_periods = mt_per iv_period = 1 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->peak_period( mt_per ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
