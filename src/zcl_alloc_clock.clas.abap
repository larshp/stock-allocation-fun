CLASS zcl_alloc_clock DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    "! <p class="shorttext synchronized">The zone the days of this solution are counted in</p>
    "!
    "! Recorded runs are stamped in UTC, because a time stamp that is not is a
    "! time stamp nobody can compare. Everything a person reads is in days,
    "! and their days start where they are: a run that finished at half past
    "! midnight in Frankfurt finished today, and a report that says yesterday
    "! because the stamp was still on the other side of midnight in UTC is a
    "! report that sends somebody looking for a job that ran.
    "!
    "! @parameter rv_zone | <p class="shorttext synchronized">Time zone the day boundaries use</p>
    CLASS-METHODS zone
      RETURNING
        VALUE(rv_zone) TYPE timezone.

    "! <p class="shorttext synchronized">The day a recorded stamp belongs to</p>
    "!
    "! @parameter iv_stamp | <p class="shorttext synchronized">UTC time stamp, as the runs are recorded</p>
    "! @parameter rv_date  | <p class="shorttext synchronized">The day it was, where the system is</p>
    CLASS-METHODS date_of
      IMPORTING
        iv_stamp       TYPE zstock_alloc_res-created_at
      RETURNING
        VALUE(rv_date) TYPE d.

    "! <p class="shorttext synchronized">The stamp a day starts at</p>
    "!
    "! @parameter iv_date  | <p class="shorttext synchronized">A day, where the system is</p>
    "! @parameter iv_time  | <p class="shorttext synchronized">Time of day, midnight by default</p>
    "! @parameter rv_stamp | <p class="shorttext synchronized">UTC time stamp of that moment</p>
    CLASS-METHODS stamp_of
      IMPORTING
        iv_date         TYPE d
        iv_time         TYPE t DEFAULT '000000'
      RETURNING
        VALUE(rv_stamp) TYPE zstock_alloc_res-created_at.

  PRIVATE SECTION.

    "! What a system that has not told anybody where it is gets. UTC is the
    "! zone the stamps are in, so the two at least agree with each other.
    CONSTANTS c_fallback TYPE timezone VALUE 'UTC'.

ENDCLASS.


CLASS zcl_alloc_clock IMPLEMENTATION.

  METHOD zone.

    rv_zone = sy-zonlo.
    IF rv_zone IS INITIAL.
      rv_zone = c_fallback.
    ENDIF.

  ENDMETHOD.

  METHOD date_of.

    DATA lv_date TYPE d.

    CONVERT TIME STAMP iv_stamp TIME ZONE zone( )
      INTO DATE lv_date.

    rv_date = lv_date.

  ENDMETHOD.

  METHOD stamp_of.

    DATA lv_stamp TYPE zstock_alloc_res-created_at.

    CONVERT DATE iv_date TIME iv_time
      INTO TIME STAMP lv_stamp TIME ZONE zone( ).

    rv_stamp = lv_stamp.

  ENDMETHOD.

ENDCLASS.
