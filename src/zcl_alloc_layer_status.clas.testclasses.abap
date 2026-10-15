CLASS ltcl_alloc_layer_status DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_status.

    METHODS setup.

    METHODS reads_status  FOR TESTING.
    METHODS empty_rule    FOR TESTING.
    METHODS counts_pending FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_status IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_status( ).
  ENDMETHOD.

  METHOD reads_status.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_remaining = 100 iv_original = 100 )
      exp = 'INTACT' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_remaining = 30 iv_original = 100 )
      exp = 'PARTIAL' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_remaining = 0 iv_original = 100 )
      exp = 'DEPLETED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( iv_remaining = 0 iv_original = 0 )
      exp = 'EMPTY' ).
  ENDMETHOD.

  METHOD empty_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( 0 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( 10 ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pending.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_qty( iv_remaining = 30 iv_original = 100 )
      exp = 70 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_qty( iv_remaining = 100 iv_original = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
