CLASS ltcl_alloc_mrp_status DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mrp_status.
    DATA mt_step TYPE zcl_alloc_mrp_status=>ty_step_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_step TYPE string
        iv_done TYPE abap_bool.

    METHODS statuses      FOR TESTING.
    METHODS complete_rule FOR TESTING.
    METHODS counts_pending FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mrp_status IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mrp_status( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_step TYPE zcl_alloc_mrp_status=>ty_step.

    ls_step-step = iv_step.
    ls_step-done = iv_done.
    APPEND ls_step TO mt_step.
  ENDMETHOD.

  METHOD statuses.
    DATA lt_steps TYPE zcl_alloc_mrp_status=>ty_step_tt.
    DATA ls_step TYPE zcl_alloc_mrp_status=>ty_step.

    ls_step-step = 'INPUT'.
    ls_step-done = abap_true.
    APPEND ls_step TO lt_steps.
    ls_step-step = 'NETTING'.
    ls_step-done = abap_true.
    APPEND ls_step TO lt_steps.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( lt_steps ) exp = 'COMPLETE' ).

    CLEAR lt_steps.
    ls_step-step = 'INPUT'.
    ls_step-done = abap_true.
    APPEND ls_step TO lt_steps.
    ls_step-step = 'NETTING'.
    ls_step-done = abap_false.
    APPEND ls_step TO lt_steps.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( lt_steps ) exp = 'RUNNING' ).

    CLEAR lt_steps.
    ls_step-step = 'INPUT'.
    ls_step-done = abap_false.
    APPEND ls_step TO lt_steps.
    ls_step-step = 'NETTING'.
    ls_step-done = abap_false.
    APPEND ls_step TO lt_steps.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( lt_steps ) exp = 'OPEN' ).
  ENDMETHOD.

  METHOD complete_rule.
    add( iv_step = 'INPUT' iv_done = abap_true ).
    add( iv_step = 'NETTING' iv_done = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( mt_step ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pending.
    add( iv_step = 'INPUT' iv_done = abap_true ).
    add( iv_step = 'NETTING' iv_done = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pending_count( mt_step ) exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->status( mt_step ) exp = 'EMPTY' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_complete( mt_step ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
