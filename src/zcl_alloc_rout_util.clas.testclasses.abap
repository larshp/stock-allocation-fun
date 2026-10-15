CLASS ltcl_alloc_rout_util DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_util.

    METHODS setup.

    METHODS reads_utilisation FOR TESTING.
    METHODS idle_rule         FOR TESTING.
    METHODS reads_spare       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_util IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_util( ).
  ENDMETHOD.

  METHOD reads_utilisation.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->utilisation_percent( iv_used = 80 iv_available = 100 )
      exp = 80 ).
  ENDMETHOD.

  METHOD idle_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_idle( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_idle( 80 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_spare.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->spare( iv_available = 100 iv_used = 80 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->spare( iv_available = 100 iv_used = 120 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
