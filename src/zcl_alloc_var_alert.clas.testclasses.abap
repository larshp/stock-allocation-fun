CLASS ltcl_alloc_var_alert DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_alert.

    METHODS setup.

    METHODS threshold_rule FOR TESTING.
    METHODS computes_alert FOR TESTING.
    METHODS reads_level    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_alert IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_alert( ).
  ENDMETHOD.

  METHOD threshold_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over_threshold( iv_variance = 150 iv_threshold = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over_threshold( iv_variance = -150 iv_threshold = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over_threshold( iv_variance = 50 iv_threshold = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_alert.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->alert( iv_variance = 150 iv_threshold = 100 )
      exp = 50 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->alert( iv_variance = 50 iv_threshold = 100 )
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_level.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_variance = 250 iv_threshold = 100 )
      exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_variance = 150 iv_threshold = 100 )
      exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level( iv_variance = 50 iv_threshold = 100 )
      exp = 'NONE' ).
  ENDMETHOD.

ENDCLASS.
