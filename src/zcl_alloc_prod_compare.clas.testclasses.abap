CLASS ltcl_alloc_prod_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prod_compare.

    METHODS setup.

    METHODS compares_costs FOR TESTING.
    METHODS picks_cheaper  FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prod_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prod_compare( ).
  ENDMETHOD.

  METHOD compares_costs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_left = 100 iv_right = 120 ) exp = 'LOWER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_left = 120 iv_right = 100 ) exp = 'HIGHER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_left = 100 iv_right = 100 ) exp = 'EQUAL' ).
  ENDMETHOD.

  METHOD picks_cheaper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_left = 100 iv_right = 120 ) exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_left = 120 iv_right = 100 ) exp = 100 ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_left = 120 iv_right = 100 ) exp = 20 ).
  ENDMETHOD.

ENDCLASS.
