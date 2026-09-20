CLASS cl_stub_calendar DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! What DATE_CONVERT_TO_FACTORYDATE answers about one day.
    TYPES:
      BEGIN OF ty_factory_date,
        factorydate TYPE facdate,
        indicator   TYPE calind,
      END OF ty_factory_date.

    "! Move a date that is not a working day back to the one before it.
    CONSTANTS c_backwards TYPE calind VALUE '-'.

    "! <p class="shorttext synchronized">Calendar date to factory calendar date</p>
    "!
    "! Carries the part of the factory calendar the custom code depends on: a
    "! week of five working days, Monday to Friday, with no public holidays.
    "! What a real calendar adds -- the holidays of a country, a plant that
    "! works Saturdays, a shutdown fortnight in August -- changes which days
    "! come back, not what the code does with them.
    "!
    "! @parameter iv_date    | <p class="shorttext synchronized">Calendar date</p>
    "! @parameter iv_correct | <p class="shorttext synchronized">Which way to move a non working day</p>
    "! @parameter rs_answer  | <p class="shorttext synchronized">Factory date and whether it was one</p>
    CLASS-METHODS to_factory_date
      IMPORTING
        iv_date          TYPE d
        iv_correct       TYPE calind
      RETURNING
        VALUE(rs_answer) TYPE ty_factory_date.

    "! <p class="shorttext synchronized">Factory calendar date to calendar date</p>
    "!
    "! @parameter iv_factorydate | <p class="shorttext synchronized">Factory date</p>
    "! @parameter rv_date        | <p class="shorttext synchronized">Calendar date</p>
    CLASS-METHODS to_calendar_date
      IMPORTING
        iv_factorydate TYPE facdate
      RETURNING
        VALUE(rv_date) TYPE d.

  PRIVATE SECTION.

    "! A Monday, and early enough that nothing this solution deals with falls
    "! before it.
    CONSTANTS c_epoch TYPE d VALUE '19000101'.

    CONSTANTS c_days_in_week    TYPE i VALUE 7.
    CONSTANTS c_working_in_week TYPE i VALUE 5.

ENDCLASS.


CLASS cl_stub_calendar IMPLEMENTATION.

  METHOD to_factory_date.

    DATA lv_days    TYPE i.
    DATA lv_weeks   TYPE i.
    DATA lv_rest    TYPE i.
    DATA lv_factory TYPE i.

    lv_days  = iv_date - c_epoch.
    lv_weeks = lv_days DIV c_days_in_week.
    lv_rest  = lv_days MOD c_days_in_week.

    IF lv_rest >= c_working_in_week.
      " a Saturday or a Sunday: it counts as the working days of the week that
      " are behind it, and the answer says it was not one of them
      lv_factory = lv_weeks * c_working_in_week + c_working_in_week.
      IF iv_correct = c_backwards.
        lv_factory = lv_factory - 1.
      ENDIF.
      CLEAR rs_answer-indicator.
    ELSE.
      lv_factory = lv_weeks * c_working_in_week + lv_rest.
      rs_answer-indicator = abap_true.
    ENDIF.

    IF lv_factory < 0.
      CLEAR lv_factory.
    ENDIF.

    rs_answer-factorydate = lv_factory.

  ENDMETHOD.

  METHOD to_calendar_date.

    DATA lv_factory TYPE i.
    DATA lv_weeks   TYPE i.
    DATA lv_rest    TYPE i.

    lv_factory = iv_factorydate.
    lv_weeks   = lv_factory DIV c_working_in_week.
    lv_rest    = lv_factory MOD c_working_in_week.

    rv_date = c_epoch + lv_weeks * c_days_in_week + lv_rest.

  ENDMETHOD.

ENDCLASS.
