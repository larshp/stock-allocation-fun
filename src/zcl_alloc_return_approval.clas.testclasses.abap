CLASS ltcl_alloc_return_approval DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_approval.
    DATA mt_stp TYPE zcl_alloc_return_approval=>ty_step_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_approver TYPE string
        iv_approved TYPE abap_bool.

    METHODS approves_named  FOR TESTING.
    METHODS pending_rule    FOR TESTING.
    METHODS complete_rule   FOR TESTING.
    METHODS empty_input     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_approval IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_approval( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_step TYPE zcl_alloc_return_approval=>ty_step.

    ls_step-approver = iv_approver.
    ls_step-approved = iv_approved.
    APPEND ls_step TO mt_stp.
  ENDMETHOD.

  METHOD approves_named.
    DATA lt_steps TYPE zcl_alloc_return_approval=>ty_step_tt.

    add( iv_approver = 'A' iv_approved = abap_false ).
    add( iv_approver = 'B' iv_approved = abap_false ).

    lt_steps = mo_cut->approve( it_steps = mt_stp iv_approver = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_steps[ 1 ]-approved exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_steps[ 2 ]-approved exp = abap_false ).
  ENDMETHOD.

  METHOD pending_rule.
    DATA lt_steps TYPE zcl_alloc_return_approval=>ty_step_tt.

    add( iv_approver = 'A' iv_approved = abap_true ).
    add( iv_approver = 'B' iv_approved = abap_false ).

    lt_steps = mo_cut->approve( it_steps = mt_stp iv_approver = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( lt_steps ) exp = 1 ).
  ENDMETHOD.

  METHOD complete_rule.
    DATA lt_steps TYPE zcl_alloc_return_approval=>ty_step_tt.

    add( iv_approver = 'A' iv_approved = abap_false ).

    lt_steps = mo_cut->approve( it_steps = mt_stp iv_approver = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( lt_steps ) exp = abap_true ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_approved( mt_stp ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
