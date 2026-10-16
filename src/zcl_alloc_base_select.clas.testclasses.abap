CLASS ltcl_alloc_base_select DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_select.

    METHODS setup.

    METHODS chooses_base FOR TESTING.
    METHODS direct_rule  FOR TESTING.
    METHODS reads_reason FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_select IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_select( ).
  ENDMETHOD.

  METHOD chooses_base.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->choose( iv_direct = 1000 iv_indirect = 500 )
      exp = 'DIRECT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->choose( iv_direct = 500 iv_indirect = 1000 )
      exp = 'INDIRECT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->choose( iv_direct = 0 iv_indirect = 0 )
      exp = 'NONE' ).
  ENDMETHOD.

  METHOD direct_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_direct( 'DIRECT' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_direct( 'INDIRECT' ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'DIRECT' ) exp = 'traceable' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'INDIRECT' ) exp = 'apportioned' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'NONE' ) exp = 'unassigned' ).
  ENDMETHOD.

ENDCLASS.
