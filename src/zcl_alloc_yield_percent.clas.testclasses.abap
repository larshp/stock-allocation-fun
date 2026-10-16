CLASS ltcl_alloc_yield_percent DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_percent.

    METHODS setup.

    METHODS reads_percent FOR TESTING.
    METHODS full_rule     FOR TESTING.
    METHODS computes_loss FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_percent IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_percent( ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->yield_percent( iv_good = 95 iv_total = 100 )
      exp = 95 ).
  ENDMETHOD.

  METHOD full_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( 100 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( 95 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_loss.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loss( iv_good = 95 iv_total = 100 ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
