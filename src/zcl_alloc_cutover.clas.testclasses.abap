CLASS ltcl_alloc_cutover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cutover.
    DATA mt_step TYPE zcl_alloc_cutover=>ty_step_tt.

    METHODS setup.

    METHODS add_step
      IMPORTING
        iv_id   TYPE i
        iv_name TYPE string
        iv_done TYPE abap_bool.

    METHODS all_done_ready     FOR TESTING.
    METHODS partial_progress   FOR TESTING.
    METHODS empty_is_ready     FOR TESTING.
    METHODS lists_open_steps   FOR TESTING.
    METHODS no_open_when_done  FOR TESTING.
    METHODS progress_truncates FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cutover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cutover( ).
  ENDMETHOD.

  METHOD add_step.
    DATA ls_step TYPE zcl_alloc_cutover=>ty_step.

    ls_step-step_id = iv_id.
    ls_step-step_name = iv_name.
    ls_step-owner = 'OPS'.
    ls_step-done = iv_done.
    APPEND ls_step TO mt_step.
  ENDMETHOD.

  METHOD all_done_ready.
    add_step( iv_id = 1 iv_name = 'FREEZE' iv_done = abap_true ).
    add_step( iv_id = 2 iv_name = 'LOAD' iv_done = abap_true ).

    DATA(ls_checklist) = mo_cut->build( mt_step ).

    cl_abap_unit_assert=>assert_equals( act = ls_checklist-total_steps exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-open_steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-progress_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-ready exp = abap_true ).
  ENDMETHOD.

  METHOD partial_progress.
    add_step( iv_id = 1 iv_name = 'FREEZE' iv_done = abap_true ).
    add_step( iv_id = 2 iv_name = 'LOAD' iv_done = abap_false ).

    DATA(ls_checklist) = mo_cut->build( mt_step ).

    cl_abap_unit_assert=>assert_equals( act = ls_checklist-done_steps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-open_steps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-progress_pct exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-ready exp = abap_false ).
  ENDMETHOD.

  METHOD empty_is_ready.
    DATA(ls_checklist) = mo_cut->build( mt_step ).

    cl_abap_unit_assert=>assert_equals( act = ls_checklist-total_steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-progress_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_checklist-ready exp = abap_true ).
  ENDMETHOD.

  METHOD lists_open_steps.
    add_step( iv_id = 1 iv_name = 'FREEZE' iv_done = abap_true ).
    add_step( iv_id = 2 iv_name = 'LOAD' iv_done = abap_false ).
    add_step( iv_id = 3 iv_name = 'VERIFY' iv_done = abap_false ).

    DATA(lt_open) = mo_cut->open_steps( mt_step ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_open ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 1 ]-step_name exp = 'LOAD' ).
    cl_abap_unit_assert=>assert_equals( act = lt_open[ 2 ]-step_name exp = 'VERIFY' ).
  ENDMETHOD.

  METHOD no_open_when_done.
    add_step( iv_id = 1 iv_name = 'FREEZE' iv_done = abap_true ).

    DATA(lt_open) = mo_cut->open_steps( mt_step ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_open ) exp = 0 ).
  ENDMETHOD.

  METHOD progress_truncates.
    add_step( iv_id = 1 iv_name = 'A' iv_done = abap_true ).
    add_step( iv_id = 2 iv_name = 'B' iv_done = abap_false ).
    add_step( iv_id = 3 iv_name = 'C' iv_done = abap_false ).

    DATA(ls_checklist) = mo_cut->build( mt_step ).

    cl_abap_unit_assert=>assert_equals( act = ls_checklist-progress_pct exp = 33 ).
  ENDMETHOD.

ENDCLASS.
