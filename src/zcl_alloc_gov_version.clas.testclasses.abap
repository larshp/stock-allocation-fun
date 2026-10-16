CLASS ltcl_alloc_gov_version DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_gov_version.

    METHODS setup.

    METHODS reads_version FOR TESTING.
    METHODS newer_rule    FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_gov_version IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_gov_version( ).
  ENDMETHOD.

  METHOD reads_version.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->version( iv_major = 2 iv_minor = 5 ) exp = 205 ).
  ENDMETHOD.

  METHOD newer_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_newer( iv_version_a = 205 iv_version_b = 200 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_newer( iv_version_a = 200 iv_version_b = 205 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_version_a = 205 iv_version_b = 200 )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
