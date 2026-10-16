CLASS ltcl_alloc_recon_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_recon_rate.

    METHODS setup.

    METHODS reads_rate    FOR TESTING.
    METHODS reads_percent FOR TESTING.
    METHODS clean_rule    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_recon_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_recon_rate( ).
  ENDMETHOD.

  METHOD reads_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_matched = 90 iv_total = 100 )
      exp = 90 ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->matched_percent( iv_matched = 90 iv_total = 100 )
      exp = 90 ).
  ENDMETHOD.

  METHOD clean_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_clean( iv_matched = 100 iv_total = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_clean( iv_matched = 90 iv_total = 100 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
