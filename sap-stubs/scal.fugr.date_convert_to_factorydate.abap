FUNCTION date_convert_to_factorydate.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(CORRECT_OPTION) TYPE  CALIND
*"     VALUE(DATE) TYPE  SY-DATUM
*"     VALUE(FACTORY_CALENDAR_ID) TYPE  T001W-FABKL
*"  EXPORTING
*"     VALUE(FACTORYDATE) TYPE  FACDATE
*"     VALUE(WORKINGDAY_INDICATOR) TYPE  CALIND
*"  EXCEPTIONS
*"      CALENDAR_BUFFER_NOT_LOADABLE
*"      DATE_AFTER_RANGE
*"      DATE_BEFORE_RANGE
*"      DATE_INVALID
*"      FACTORY_CALENDAR_NOT_FOUND
*"----------------------------------------------------------------------

* declared explicitly: an inline DATA() in a function module body is never
* declared in the transpiled output, see ANOMALIES.md
  DATA ls_answer TYPE cl_stub_calendar=>ty_factory_date.

  IF factory_calendar_id IS INITIAL.
    RAISE factory_calendar_not_found.
  ENDIF.

  ls_answer = cl_stub_calendar=>to_factory_date(
    iv_date    = date
    iv_correct = correct_option ).

  factorydate = ls_answer-factorydate.
  workingday_indicator = ls_answer-indicator.

ENDFUNCTION.
