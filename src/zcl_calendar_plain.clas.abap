CLASS zcl_calendar_plain DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_work_calendar.

    "! <p class="shorttext synchronized">Every day is a day the plant works</p>
    "!
    "! What a plant gets until it says otherwise, and what the solution did
    "! before there was a calendar at all: three days before the tenth is the
    "! seventh, whatever day of the week that turns out to be.

ENDCLASS.


CLASS zcl_calendar_plain IMPLEMENTATION.

  METHOD zif_work_calendar~days_before.

    rv_date = iv_date.

    IF iv_days <= 0 OR iv_date IS INITIAL.
      RETURN.
    ENDIF.

    rv_date = iv_date - iv_days.

  ENDMETHOD.

ENDCLASS.
