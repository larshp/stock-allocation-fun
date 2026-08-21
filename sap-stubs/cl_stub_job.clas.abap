CLASS cl_stub_job DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_jobname_tab TYPE STANDARD TABLE OF btcjob WITH EMPTY KEY.

    "! <p class="shorttext synchronized">Open a background job and hand out its number</p>
    "!
    "! Carries the part of JOB_OPEN the custom code depends on: a job that was
    "! opened has a number, and the numbers differ.
    "!
    "! @parameter iv_jobname     | <p class="shorttext synchronized">Name of the job</p>
    "! @parameter rv_jobcount    | <p class="shorttext synchronized">Number of the job</p>
    CLASS-METHODS open
      IMPORTING
        iv_jobname         TYPE btcjob
      RETURNING
        VALUE(rv_jobcount) TYPE btcjobcnt.

    "! <p class="shorttext synchronized">Names of the jobs opened so far</p>
    "!
    "! @parameter rt_jobname | <p class="shorttext synchronized">One entry per job opened</p>
    CLASS-METHODS opened
      RETURNING
        VALUE(rt_jobname) TYPE ty_jobname_tab.

    "! <p class="shorttext synchronized">Release a background job</p>
    "!
    "! @parameter iv_jobname     | <p class="shorttext synchronized">Name of the job</p>
    "! @parameter iv_jobcount    | <p class="shorttext synchronized">Number of the job</p>
    "! @parameter iv_immediate   | <p class="shorttext synchronized">Start it now</p>
    "! @parameter rv_released    | <p class="shorttext synchronized">Whether it was released</p>
    CLASS-METHODS close
      IMPORTING
        iv_jobname         TYPE btcjob
        iv_jobcount        TYPE btcjobcnt
        iv_immediate       TYPE abap_bool
      RETURNING
        VALUE(rv_released) TYPE abap_bool.

  PRIVATE SECTION.

    CLASS-DATA gv_counter TYPE i.
    CLASS-DATA gt_jobname TYPE ty_jobname_tab.

ENDCLASS.


CLASS cl_stub_job IMPLEMENTATION.

  METHOD open.

    gv_counter = gv_counter + 1.
    rv_jobcount = |{ gv_counter WIDTH = 8 PAD = '0' ALIGN = RIGHT }|.

    APPEND iv_jobname TO gt_jobname.

  ENDMETHOD.

  METHOD opened.
    rt_jobname = gt_jobname.
  ENDMETHOD.

  METHOD close.

    " a job released to start now, or one released to start later: either way
    " the real function module answers that it was released
    rv_released = xsdbool( iv_jobname IS NOT INITIAL
                       AND iv_jobcount IS NOT INITIAL
                       AND ( iv_immediate = abap_true OR iv_immediate = abap_false ) ).

  ENDMETHOD.

ENDCLASS.
