CLASS ltcl_alloc_stdcost_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stdcost_compare.

    METHODS setup.

    METHODS compares_costs FOR TESTING.
    METHODS picks_higher   FOR TESTING.
    METHODS computes_delta FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stdcost_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stdcost_compare( ).
  ENDMETHOD.

  METHOD compares_costs.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_left = 100 iv_right = 120 ) exp = 'LOWER' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_left = 120 iv_right = 100 ) exp = 'HIGHER' ).
  ENDMETHOD.

  METHOD picks_higher.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->higher( iv_left = 100 iv_right = 120 ) exp = 120 ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_left = 120 iv_right = 100 ) exp = 20 ).
  ENDMETHOD.

ENDCLASS.
