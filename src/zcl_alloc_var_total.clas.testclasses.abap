CLASS ltcl_alloc_var_total DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_var_total.

    METHODS setup.

    METHODS computes_variance FOR TESTING.
    METHODS adverse_rule     FOR TESTING.
    METHODS splits_variance  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_var_total IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_var_total( ).
  ENDMETHOD.

  METHOD computes_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->variance( iv_actual_total   = 1200
                              iv_standard_total = 1000 )
      exp = 200 ).
  ENDMETHOD.

  METHOD adverse_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( iv_actual_total   = 1200
                                iv_standard_total = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( iv_actual_total   = 900
                                iv_standard_total = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD splits_variance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->split( iv_total_variance = 200 iv_price_variance = 150 )
      exp = 50 ).
  ENDMETHOD.

ENDCLASS.
