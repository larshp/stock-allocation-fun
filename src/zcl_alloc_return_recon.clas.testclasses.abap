CLASS ltcl_alloc_return_recon DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_recon.
    DATA mt_pair TYPE zcl_alloc_return_recon=>ty_pair_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_authorised TYPE menge_d
        iv_received   TYPE menge_d.

    METHODS net_difference FOR TESTING.
    METHODS netting_trap   FOR TESTING.
    METHODS completeness   FOR TESTING.
    METHODS mismatch_count FOR TESTING.
    METHODS empty_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_recon IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_recon( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_pair TYPE zcl_alloc_return_recon=>ty_pair.

    ls_pair-authorised = iv_authorised.
    ls_pair-received = iv_received.
    APPEND ls_pair TO mt_pair.
  ENDMETHOD.

  METHOD net_difference.
    add( iv_authorised = 10 iv_received = 8 ).
    add( iv_authorised = 5 iv_received = 5 ).
    add( iv_authorised = 4 iv_received = 6 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( mt_pair ) exp = 0 ).
  ENDMETHOD.

  METHOD netting_trap.
    add( iv_authorised = 10 iv_received = 8 ).
    add( iv_authorised = 4 iv_received = 6 ).

    " The net difference is zero, but two lines are wrong.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( mt_pair ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( mt_pair ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mismatch_count( mt_pair ) exp = 2 ).
  ENDMETHOD.

  METHOD completeness.
    add( iv_authorised = 10 iv_received = 10 ).
    add( iv_authorised = 5 iv_received = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( mt_pair ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mismatch_count( mt_pair ) exp = 0 ).
  ENDMETHOD.

  METHOD mismatch_count.
    add( iv_authorised = 10 iv_received = 12 ).
    add( iv_authorised = 5 iv_received = 5 ).
    add( iv_authorised = 4 iv_received = 1 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mismatch_count( mt_pair ) exp = 2 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->difference( mt_pair ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( mt_pair ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mismatch_count( mt_pair ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
