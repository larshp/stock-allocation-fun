CLASS ltcl_alloc_demand_outlier DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_demand_outlier.
    DATA mt_val TYPE zcl_alloc_demand_outlier=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS filters_outliers FOR TESTING.
    METHODS outlier_rule     FOR TESTING.
    METHODS counts_removed   FOR TESTING.
    METHODS empty_input      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_demand_outlier IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_demand_outlier( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_val.
  ENDMETHOD.

  METHOD filters_outliers.
    DATA lt_values TYPE zcl_alloc_demand_outlier=>ty_values_tt.

    add( 10 ).
    add( 100 ).
    add( 20 ).

    lt_values = mo_cut->filter( it_values = mt_val iv_limit = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_values ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_values[ 1 ] exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_values[ 2 ] exp = 20 ).
  ENDMETHOD.

  METHOD outlier_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_outlier( iv_value = 100 iv_limit = 50 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_outlier( iv_value = 10 iv_limit = 50 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_removed.
    add( 10 ).
    add( 100 ).
    add( 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->removed_count( it_values = mt_val iv_limit = 50 )
      exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    DATA lt_values TYPE zcl_alloc_demand_outlier=>ty_values_tt.

    lt_values = mo_cut->filter( it_values = mt_val iv_limit = 50 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_values ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
