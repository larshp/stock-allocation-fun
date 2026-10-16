CLASS ltcl_alloc_nrv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_nrv.

    METHODS setup.

    METHODS computes_nrv     FOR TESTING.
    METHODS impaired_rule    FOR TESTING.
    METHODS computes_write_down FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_nrv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_nrv( ).
  ENDMETHOD.

  METHOD computes_nrv.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->nrv( iv_selling_price = 120 iv_selling_cost = 20 )
      exp = 100 ).
  ENDMETHOD.

  METHOD impaired_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_impaired( iv_cost = 110 iv_nrv = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_impaired( iv_cost = 90 iv_nrv = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_write_down.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->write_down( iv_cost = 110 iv_nrv = 100 )
      exp = 10 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->write_down( iv_cost = 90 iv_nrv = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
