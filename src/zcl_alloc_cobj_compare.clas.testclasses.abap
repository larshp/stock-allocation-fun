CLASS ltcl_alloc_cobj_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cobj_compare.

    METHODS setup.

    METHODS chooses_cheaper FOR TESTING.
    METHODS reads_cheaper   FOR TESTING.
    METHODS computes_delta  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cobj_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cobj_compare( ).
  ENDMETHOD.

  METHOD chooses_cheaper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_cost_a = 900 iv_cost_b = 800 )
      exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( iv_cost_a = 800 iv_cost_b = 800 )
      exp = 'SAME' ).
  ENDMETHOD.

  METHOD reads_cheaper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheaper( iv_cost_a = 900 iv_cost_b = 800 )
      exp = 800 ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_cost_a = 900 iv_cost_b = 800 )
      exp = 100 ).
  ENDMETHOD.

ENDCLASS.
