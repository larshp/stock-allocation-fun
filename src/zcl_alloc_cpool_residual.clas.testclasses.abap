CLASS ltcl_alloc_cpool_residual DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_residual.
    DATA mt_value TYPE zcl_alloc_cpool_residual=>ty_values_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i.

    METHODS computes_residual FOR TESTING.
    METHODS cleared_rule      FOR TESTING.
    METHODS counts_open       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_residual IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_residual( ).

    add( iv_value = 0 ).
    add( iv_value = 100 ).
    add( iv_value = 0 ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_value.
  ENDMETHOD.

  METHOD computes_residual.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( iv_pool = 900 iv_assigned = 800 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->residual( iv_pool = 900 iv_assigned = 900 )
      exp = 0 ).
  ENDMETHOD.

  METHOD cleared_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_cleared( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_cleared( 100 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( mt_value ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
