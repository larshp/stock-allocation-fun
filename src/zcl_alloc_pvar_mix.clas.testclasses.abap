CLASS ltcl_alloc_pvar_mix DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pvar_mix.

    METHODS setup.

    METHODS computes_mix  FOR TESTING.
    METHODS adverse_rule  FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pvar_mix IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pvar_mix( ).
  ENDMETHOD.

  METHOD computes_mix.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mix_variance( iv_total_variance = 150 iv_volume_variance = 100 )
      exp = 50 ).
  ENDMETHOD.

  METHOD adverse_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( 50 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_adverse( -50 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_first = 150 iv_second = 100 ) exp = 50 ).
  ENDMETHOD.

ENDCLASS.
