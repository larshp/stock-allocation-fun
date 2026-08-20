"! Counts the commits a log asks for, and can refuse one.
CLASS lcl_commit_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_unit_of_work.

    METHODS refuse.

    METHODS get_commits
      RETURNING
        VALUE(rv_commits) TYPE i.

    METHODS get_rollbacks
      RETURNING
        VALUE(rv_rollbacks) TYPE i.

  PRIVATE SECTION.
    DATA mv_commits   TYPE i.
    DATA mv_rollbacks TYPE i.
    DATA mv_refuse    TYPE abap_bool.

ENDCLASS.


CLASS lcl_commit_spy IMPLEMENTATION.

  METHOD refuse.
    mv_refuse = abap_true.
  ENDMETHOD.

  METHOD get_commits.
    rv_commits = mv_commits.
  ENDMETHOD.

  METHOD get_rollbacks.
    rv_rollbacks = mv_rollbacks.
  ENDMETHOD.

  METHOD zif_unit_of_work~commit.

    mv_commits = mv_commits + 1.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation( textid = zcx_allocation=>commit_failed ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_unit_of_work~rollback.
    mv_rollbacks = mv_rollbacks + 1.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_log_bal DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'LOG-BAL-01'.

    DATA mo_cut    TYPE REF TO zif_allocation_log.
    DATA mo_commit TYPE REF TO lcl_commit_spy.

    METHODS setup.
    METHODS teardown.

    "! The IV_INDEXth line of the log the run opened last.
    METHODS message
      IMPORTING
        iv_index      TYPE i
      RETURNING
        VALUE(rs_msg) TYPE bal_s_msg.

    METHODS messages
      RETURNING
        VALUE(rt_msg) TYPE cl_stub_bal=>ty_msg_tab.

    METHODS starting_opens_a_log FOR TESTING.
    METHODS the_plant_is_in_the_log FOR TESTING.
    METHODS an_allocation_is_noted FOR TESTING.
    METHODS a_full_run_says_so_once FOR TESTING.
    METHODS short_lines_are_a_warning FOR TESTING.
    METHODS a_failure_is_an_error FOR TESTING.
    METHODS a_long_reason_is_spread FOR TESTING.
    METHODS nothing_is_logged_unopened FOR TESTING.
    METHODS saving_commits FOR TESTING.
    METHODS an_unopened_log_is_not_saved FOR TESTING.
    METHODS a_refused_commit_is_no_error FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_log_bal IMPLEMENTATION.

  METHOD setup.

    cl_stub_bal=>reset( ).

    mo_commit = NEW lcl_commit_spy( ).
    mo_cut    = NEW zcl_alloc_log_bal( mo_commit ).

  ENDMETHOD.

  METHOD teardown.
    cl_stub_bal=>reset( ).
  ENDMETHOD.

  METHOD messages.
    rt_msg = cl_stub_bal=>messages_of( cl_stub_bal=>last_handle( ) ).
  ENDMETHOD.

  METHOD message.

    DATA(lt_msg) = messages( ).

    rs_msg = lt_msg[ iv_index ].

  ENDMETHOD.

  METHOD starting_opens_a_log.

    mo_cut->start( c_werks ).

    cl_abap_unit_assert=>assert_not_initial(
      act = cl_stub_bal=>last_handle( )
      msg = 'a run that is about to change something opens a log first' ).

  ENDMETHOD.

  METHOD the_plant_is_in_the_log.

    mo_cut->start( c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = message( 1 )-msgv1
      exp = c_werks
      msg = 'the first line of the log says which plant the run covers' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 1 )-msgno
      exp = '008' ).

  ENDMETHOD.

  METHOD an_allocation_is_noted.

    mo_cut->start( c_werks ).
    mo_cut->allocated(
      iv_matnr  = c_matnr
      iv_run_id = 'RUN-0000000000000001' ).

    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgno
      exp = '009' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgv1
      exp = c_matnr ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgv2
      exp = 'RUN-0000000000000001'
      msg = 'the run id is what somebody reading the log looks the result up by' ).

  ENDMETHOD.

  METHOD a_full_run_says_so_once.

    mo_cut->start( c_werks ).
    mo_cut->allocated(
      iv_matnr       = c_matnr
      iv_run_id      = 'RUN-0000000000000001'
      iv_short_lines = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( messages( ) )
      exp = 2
      msg = 'a material that got everything is one line, not two' ).

  ENDMETHOD.

  METHOD short_lines_are_a_warning.

    mo_cut->start( c_werks ).
    mo_cut->allocated(
      iv_matnr       = c_matnr
      iv_run_id      = 'RUN-0000000000000001'
      iv_short_lines = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = message( 3 )-msgty
      exp = 'W'
      msg = 'a line that did not get everything is why somebody opens the log' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 3 )-msgno
      exp = '010' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 3 )-msgv2
      exp = '3' ).

  ENDMETHOD.

  METHOD a_failure_is_an_error.

    mo_cut->start( c_werks ).
    mo_cut->failed(
      iv_matnr  = c_matnr
      iv_reason = 'the material is locked' ).

    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgty
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgno
      exp = '011' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-probclass
      exp = '1'
      msg = 'SLG1 filters on the problem class, and this is the one to keep' ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgv2
      exp = 'the material is locked' ).

  ENDMETHOD.

  METHOD a_long_reason_is_spread.

    mo_cut->start( c_werks ).
    mo_cut->failed(
      iv_matnr  = c_matnr
      iv_reason = |{ repeat( val = 'x' occ = 50 ) }{ repeat( val = 'y' occ = 20 ) }| ).

    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgv2
      exp = repeat( val = 'x' occ = 50 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = message( 2 )-msgv3
      exp = repeat( val = 'y' occ = 20 )
      msg = 'a reason longer than one message variable carries on into the next' ).

  ENDMETHOD.

  METHOD nothing_is_logged_unopened.

    mo_cut->allocated(
      iv_matnr  = c_matnr
      iv_run_id = 'RUN-0000000000000001' ).

    cl_abap_unit_assert=>assert_initial(
      act = cl_stub_bal=>last_handle( )
      msg = 'without a log there is nowhere to write, and nothing is opened late' ).

  ENDMETHOD.

  METHOD saving_commits.

    mo_cut->start( c_werks ).
    mo_cut->save( ).

    cl_abap_unit_assert=>assert_true(
      act = cl_stub_bal=>is_saved( cl_stub_bal=>last_handle( ) )
      msg = 'a log that is never saved is gone when the job ends' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 1
      msg = 'BAL_DB_SAVE puts the log on the update task, so it needs a commit' ).

  ENDMETHOD.

  METHOD an_unopened_log_is_not_saved.

    mo_cut->save( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 0
      msg = 'a run with no log must not commit somebody else work for them' ).

  ENDMETHOD.

  METHOD a_refused_commit_is_no_error.

    mo_commit->refuse( ).

    mo_cut->start( c_werks ).
    mo_cut->save( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_commits( )
      exp = 1
      msg = 'a diary that cannot be committed must not fail a finished run' ).

  ENDMETHOD.

ENDCLASS.
