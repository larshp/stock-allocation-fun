CLASS ltcl_alloc_rout_time DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_time.

    METHODS setup.

    METHODS computes_total FOR TESTING.
    METHODS zero_rule      FOR TESTING.
    METHODS computes_unit  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_time IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_time( ).
  ENDMETHOD.

  METHOD computes_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_time( iv_setup = 10 iv_run = 2 iv_qty = 5 )
      exp = 20 ).
  ENDMETHOD.

  METHOD zero_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_zero( 20 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_unit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_time( iv_total = 20 iv_qty = 5 ) exp = 4 ).
  ENDMETHOD.

ENDCLASS.
