"! Stands in for one of the two transaction BAPIs, counts what it was called
"! with and answers with whatever the test wants it to say.
CLASS lcl_bapi_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES if_ftd_invocation_answer.

    METHODS constructor
      IMPORTING
        iv_has_wait TYPE abap_bool DEFAULT abap_false.

    METHODS answers_with
      IMPORTING
        is_return TYPE bapiret2.

    METHODS get_calls
      RETURNING
        VALUE(rv_calls) TYPE i.

    METHODS get_wait
      RETURNING
        VALUE(rv_wait) TYPE bapita-wait.

  PRIVATE SECTION.
    DATA mv_has_wait TYPE abap_bool.
    DATA mv_calls    TYPE i.
    DATA mv_wait     TYPE bapita-wait.
    DATA ms_return   TYPE bapiret2.

ENDCLASS.


CLASS lcl_bapi_double IMPLEMENTATION.

  METHOD constructor.
    mv_has_wait = iv_has_wait.
  ENDMETHOD.

  METHOD answers_with.
    ms_return = is_return.
  ENDMETHOD.

  METHOD get_calls.
    rv_calls = mv_calls.
  ENDMETHOD.

  METHOD get_wait.
    rv_wait = mv_wait.
  ENDMETHOD.

  METHOD if_ftd_invocation_answer~answer.

    DATA lr_wait TYPE REF TO data.

    FIELD-SYMBOLS <lv_wait> TYPE bapita-wait.

    mv_calls = mv_calls + 1.

    IF mv_has_wait = abap_true.
      lr_wait = arguments->get_importing_parameter( 'WAIT' ).
      ASSIGN lr_wait->* TO <lv_wait>.
      ASSERT sy-subrc = 0.
      mv_wait = <lv_wait>.
    ENDIF.

    result->get_output_configuration( )->set_exporting_parameter(
      name  = 'RETURN'
      value = ms_return ).

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_unit_of_work DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_commit   TYPE sxco_fm_name VALUE 'BAPI_TRANSACTION_COMMIT'.
    CONSTANTS c_rollback TYPE sxco_fm_name VALUE 'BAPI_TRANSACTION_ROLLBACK'.

    DATA mi_env      TYPE REF TO if_function_test_environment.
    DATA mo_cut      TYPE REF TO zif_unit_of_work.
    DATA mo_commit   TYPE REF TO lcl_bapi_double.
    DATA mo_rollback TYPE REF TO lcl_bapi_double.

    METHODS setup.
    METHODS teardown.

    METHODS commit_calls_the_bapi FOR TESTING RAISING cx_static_check.
    METHODS commit_waits_for_the_update FOR TESTING RAISING cx_static_check.
    METHODS an_error_raises FOR TESTING.
    METHODS a_warning_is_no_error FOR TESTING RAISING cx_static_check.
    METHODS rollback_calls_the_bapi FOR TESTING.

ENDCLASS.


CLASS ltcl_unit_of_work IMPLEMENTATION.

  METHOD setup.

    DATA lt_deps TYPE if_function_test_environment=>tt_function_dependencies.

    mo_cut      = NEW zcl_unit_of_work( ).
    mo_commit   = NEW #( iv_has_wait = abap_true ).
    mo_rollback = NEW #( ).

    INSERT c_commit INTO TABLE lt_deps.
    INSERT c_rollback INTO TABLE lt_deps.
    mi_env = cl_function_test_environment=>create( lt_deps ).
    mi_env->get_double( c_commit )->configure_call( )->ignore_all_parameters( )->then_answer( mo_commit ).
    mi_env->get_double( c_rollback )->configure_call( )->ignore_all_parameters( )->then_answer( mo_rollback ).

  ENDMETHOD.

  METHOD teardown.
    mi_env->clear_doubles( ).
  ENDMETHOD.

  METHOD commit_calls_the_bapi.

    mo_cut->commit( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_calls( )
      exp = 1
      msg = 'nothing a run writes is on the database until this is called' ).

  ENDMETHOD.

  METHOD commit_waits_for_the_update.

    mo_cut->commit( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_wait( )
      exp = abap_true
      msg = 'the next material reads the reservation this one created' ).

  ENDMETHOD.

  METHOD an_error_raises.

    mo_commit->answers_with( VALUE #(
      type = 'E' id = 'MB' number = '001' message = 'Update terminated' ) ).

    TRY.
        mo_cut->commit( ).
        cl_abap_unit_assert=>fail( 'a commit that did not happen must not read as one that did' ).
      CATCH zcx_allocation INTO DATA(lx_error).
        cl_abap_unit_assert=>assert_char_cp(
          act = lx_error->get_text( )
          exp = '*Update terminated*' ).
    ENDTRY.

  ENDMETHOD.

  METHOD a_warning_is_no_error.

    mo_commit->answers_with( VALUE #(
      type = 'W' id = 'MB' number = '002' message = 'Something to note' ) ).

    mo_cut->commit( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_commit->get_calls( )
      exp = 1 ).

  ENDMETHOD.

  METHOD rollback_calls_the_bapi.

    mo_cut->rollback( ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_rollback->get_calls( )
      exp = 1 ).

  ENDMETHOD.

ENDCLASS.
