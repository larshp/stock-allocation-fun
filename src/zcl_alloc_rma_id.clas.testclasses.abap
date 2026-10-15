CLASS ltcl_alloc_rma_id DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rma_id.

    METHODS setup.

    METHODS starts_at_one FOR TESTING.
    METHODS increments    FOR TESTING.
    METHODS reset_restarts FOR TESTING.
    METHODS valid_shape   FOR TESTING.
    METHODS invalid_shape FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rma_id IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rma_id( ).
  ENDMETHOD.

  METHOD starts_at_one.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next( ) exp = 'RMA00000001' ).
  ENDMETHOD.

  METHOD increments.
    mo_cut->next( ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next( ) exp = 'RMA00000002' ).
  ENDMETHOD.

  METHOD reset_restarts.
    mo_cut->next( ).
    mo_cut->next( ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next( ) exp = 'RMA00000001' ).
  ENDMETHOD.

  METHOD valid_shape.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 'RMA00000001' ) exp = abap_true ).
  ENDMETHOD.

  METHOD invalid_shape.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 'RMA0000001' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 'XXX00000001' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_valid( 'RMA0000000A' ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
