FUNCTION factorydate_convert_to_date.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FACTORYDATE) TYPE  FACDATE
*"     VALUE(FACTORY_CALENDAR_ID) TYPE  T001W-FABKL
*"  EXPORTING
*"     VALUE(DATE) TYPE  SY-DATUM
*"  EXCEPTIONS
*"      CALENDAR_BUFFER_NOT_LOADABLE
*"      FACTORYDATE_AFTER_RANGE
*"      FACTORYDATE_BEFORE_RANGE
*"      FACTORY_CALENDAR_NOT_FOUND
*"----------------------------------------------------------------------

  IF factory_calendar_id IS INITIAL.
    RAISE factory_calendar_not_found.
  ENDIF.

  IF factorydate IS INITIAL.
    RAISE factorydate_before_range.
  ENDIF.

  date = cl_stub_calendar=>to_calendar_date( factorydate ).

ENDFUNCTION.
