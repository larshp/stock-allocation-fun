CLASS zcl_alloc_log_bal DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_log.

    "! The application log object the run writes under. It has to exist in the
    "! system, which is a one off in SLG0, see NOTES.md. A log the object of
    "! which is unknown is refused by BAL_LOG_CREATE, and this class then keeps
    "! quiet rather than stopping the run.
    CONSTANTS c_object TYPE bal_s_log-object VALUE 'ZSTOCK_ALLOC'.

    "! <p class="shorttext synchronized">Wire up the log</p>
    "!
    "! @parameter io_commit | <p class="shorttext synchronized">Makes the saved log durable</p>
    METHODS constructor
      IMPORTING
        io_commit TYPE REF TO zif_unit_of_work.

  PRIVATE SECTION.

    CONSTANTS c_msgid TYPE bal_s_msg-msgid VALUE 'ZSTOCK_ALLOC'.

    CONSTANTS c_msg_started   TYPE bal_s_msg-msgno VALUE '008'.
    CONSTANTS c_msg_allocated TYPE bal_s_msg-msgno VALUE '009'.
    CONSTANTS c_msg_short     TYPE bal_s_msg-msgno VALUE '010'.
    CONSTANTS c_msg_failed    TYPE bal_s_msg-msgno VALUE '011'.
    CONSTANTS c_msg_removed   TYPE bal_s_msg-msgno VALUE '012'.
    CONSTANTS c_msg_settings  TYPE bal_s_msg-msgno VALUE '013'.
    CONSTANTS c_msg_finished  TYPE bal_s_msg-msgno VALUE '014'.
    CONSTANTS c_msg_released  TYPE bal_s_msg-msgno VALUE '015'.

    "! BAL problem classes: 1 very important, 2 important, 4 additional
    "! information. SLG1 filters on them, so a night's successes can be hidden
    "! and the material that failed cannot.
    CONSTANTS c_class_error   TYPE bal_s_msg-probclass VALUE '1'.
    CONSTANTS c_class_warning TYPE bal_s_msg-probclass VALUE '2'.
    CONSTANTS c_class_info    TYPE bal_s_msg-probclass VALUE '4'.

    CONSTANTS c_type_success TYPE bal_s_msg-msgty VALUE 'S'.
    CONSTANTS c_type_warning TYPE bal_s_msg-msgty VALUE 'W'.
    CONSTANTS c_type_error   TYPE bal_s_msg-msgty VALUE 'E'.

    "! How much of a message variable BAL carries.
    CONSTANTS c_variable_length TYPE i VALUE 50.

    DATA mo_commit TYPE REF TO zif_unit_of_work.
    DATA mv_handle TYPE balloghndl.

    METHODS add
      IMPORTING
        iv_type      TYPE bal_s_msg-msgty
        iv_number    TYPE bal_s_msg-msgno
        iv_class     TYPE bal_s_msg-probclass
        iv_variable1 TYPE bal_s_msg-msgv1 OPTIONAL
        iv_variable2 TYPE bal_s_msg-msgv2 OPTIONAL
        iv_variable3 TYPE bal_s_msg-msgv3 OPTIONAL
        iv_variable4 TYPE bal_s_msg-msgv4 OPTIONAL.

ENDCLASS.


CLASS zcl_alloc_log_bal IMPLEMENTATION.

  METHOD constructor.
    mo_commit = io_commit.
  ENDMETHOD.

  METHOD zif_allocation_log~start.

    DATA ls_log      TYPE bal_s_log.
    DATA lv_handle   TYPE balloghndl.
    DATA lv_settings TYPE c LENGTH 200.

    " the external number is what somebody scanning SLG1 sees first, so it says
    " which plant and when rather than repeating the object name.
    "
    " The date, time, user and program are left initial on purpose:
    " BAL_LOG_CREATE fills each of them with the running values when they are
    " not given, which is the same answer without four ways of getting it
    " wrong. It also keeps SY-REPID out of the code, which the transpiler does
    " not implement (ANOMALIES.md 2l).
    ls_log-object    = c_object.
    ls_log-extnumber = |{ iv_werks } { sy-datum DATE = USER }|.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log
      IMPORTING
        e_log_handle            = lv_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      " no log object in the system, or no log to be had. The run goes on
      " without one; this class then does nothing at all.
      CLEAR mv_handle.
      RETURN.
    ENDIF.

    mv_handle = lv_handle.

    add(
      iv_type      = c_type_success
      iv_number    = c_msg_started
      iv_class     = c_class_info
      iv_variable1 = CONV #( iv_werks ) ).

    " what the run was told to do, next to what it did. Half the questions
    " asked about a night's allocation are really questions about the variant
    " it ran with, and the variant can be changed by then.
    IF iv_settings IS INITIAL.
      RETURN.
    ENDIF.

    lv_settings = iv_settings.

    add(
      iv_type      = c_type_success
      iv_number    = c_msg_settings
      iv_class     = c_class_info
      iv_variable1 = CONV #( lv_settings+0(c_variable_length) )
      iv_variable2 = CONV #( lv_settings+50(c_variable_length) )
      iv_variable3 = CONV #( lv_settings+100(c_variable_length) )
      iv_variable4 = CONV #( lv_settings+150(c_variable_length) ) ).

  ENDMETHOD.

  METHOD zif_allocation_log~finished.

    " a night with something wrong in it says so at the class SLG1 filters on,
    " so a list of logs shows which ones are worth opening
    add(
      iv_type      = COND #( WHEN iv_failed > 0
                             THEN c_type_warning
                             ELSE c_type_success )
      iv_number    = c_msg_finished
      iv_class     = COND #( WHEN iv_failed > 0
                             THEN c_class_warning
                             ELSE c_class_info )
      iv_variable1 = |{ iv_materials }|
      iv_variable2 = |{ iv_short }|
      iv_variable3 = |{ iv_failed }| ).

  ENDMETHOD.

  METHOD zif_allocation_log~allocated.

    add(
      iv_type      = c_type_success
      iv_number    = c_msg_allocated
      iv_class     = c_class_info
      iv_variable1 = CONV #( iv_matnr )
      iv_variable2 = CONV #( iv_run_id ) ).

    " a run that confirmed everything says so once. One that did not is the
    " reason somebody opens the log at all, so it gets a line of its own, at a
    " problem class SLG1 can filter on.
    IF iv_short_lines > 0.
      add(
        iv_type      = c_type_warning
        iv_number    = c_msg_short
        iv_class     = c_class_warning
        iv_variable1 = CONV #( iv_matnr )
        iv_variable2 = |{ iv_short_lines }| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_allocation_log~failed.

    " the reason is a sentence and a message variable holds fifty characters,
    " so it is spread over the three that are left rather than cut short. It
    " goes through a fixed length field first: a shorter reason then pads
    " instead of reading past its own end.
    DATA lv_reason TYPE c LENGTH 150.

    lv_reason = iv_reason.

    add(
      iv_type      = c_type_error
      iv_number    = c_msg_failed
      iv_class     = c_class_error
      iv_variable1 = CONV #( iv_matnr )
      iv_variable2 = CONV #( lv_reason+0(c_variable_length) )
      iv_variable3 = CONV #( lv_reason+50(c_variable_length) )
      iv_variable4 = CONV #( lv_reason+100(c_variable_length) ) ).

  ENDMETHOD.

  METHOD zif_allocation_log~released.

    " at the class a night's successes can be hidden behind: stock taken off
    " a customer is not routine, whatever the run thinks of it
    add(
      iv_type      = c_type_warning
      iv_number    = c_msg_released
      iv_class     = c_class_warning
      iv_variable1 = CONV #( iv_matnr )
      iv_variable2 = |{ iv_reservation }| ).

  ENDMETHOD.

  METHOD zif_allocation_log~removed.

    add(
      iv_type      = c_type_success
      iv_number    = c_msg_removed
      iv_class     = c_class_info
      iv_variable1 = CONV #( iv_run_id ) ).

  ENDMETHOD.

  METHOD zif_allocation_log~save.

    DATA lt_handle TYPE bal_t_logh.

    IF mv_handle IS INITIAL.
      RETURN.
    ENDIF.

    APPEND mv_handle TO lt_handle.

    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_t_log_handle   = lt_handle
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      CLEAR mv_handle.
      RETURN.
    ENDIF.

    " BAL_DB_SAVE puts the log on the update task like any other BAPI, so it is
    " not there until somebody commits. The run's own commits are per material
    " and happened before this; the log is its own unit of work.
    TRY.
        mo_commit->commit( ).
      CATCH zcx_allocation.
        " a log that could not be committed is not worth failing a finished
        " run for. Everything it describes is already durable.
        CLEAR mv_handle.
    ENDTRY.

  ENDMETHOD.

  METHOD add.

    DATA ls_msg TYPE bal_s_msg.

    IF mv_handle IS INITIAL.
      RETURN.
    ENDIF.

    ls_msg-msgid     = c_msgid.
    ls_msg-msgty     = iv_type.
    ls_msg-msgno     = iv_number.
    ls_msg-msgv1     = iv_variable1.
    ls_msg-msgv2     = iv_variable2.
    ls_msg-msgv3     = iv_variable3.
    ls_msg-msgv4     = iv_variable4.
    ls_msg-probclass = iv_class.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = mv_handle
        i_s_msg          = ls_msg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      " the log is gone or will take no more. Trying again for every material
      " left in the run would cost a round trip each to be told the same thing.
      CLEAR mv_handle.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
