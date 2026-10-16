CLASS ltcl_alloc_yield_loss DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_yield_loss.

    METHODS setup.

    METHODS computes_loss FOR TESTING.
    METHODS lossy_rule    FOR TESTING.
    METHODS reads_percent FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_yield_loss IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_yield_loss( ).
  ENDMETHOD.

  METHOD computes_loss.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loss( iv_good = 95 iv_total = 100 ) exp = 5 ).
  ENDMETHOD.

  METHOD lossy_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_lossy( 5 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_lossy( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loss_percent( iv_good = 95 iv_total = 100 )
      exp = 5 ).
  ENDMETHOD.

ENDCLASS.
