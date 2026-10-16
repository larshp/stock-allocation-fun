CLASS ltcl_alloc_stdcost_version DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_version.

    METHODS setup.

    METHODS bumps_version FOR TESTING.
    METHODS newer_rule    FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_version IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_version( ).
  ENDMETHOD.

  METHOD bumps_version.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->version( 1 ) exp = 2 ).
  ENDMETHOD.

  METHOD newer_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_newer( iv_left = 2 iv_right = 1 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_newer( iv_left = 1 iv_right = 2 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_left = 3 iv_right = 1 ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
