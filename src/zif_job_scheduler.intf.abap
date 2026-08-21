INTERFACE zif_job_scheduler PUBLIC.

  "! <p class="shorttext synchronized">Schedule one allocation job</p>
  "!
  "! One package of a plant, as a background job that starts as soon as a work
  "! process is free. Behind an interface because scheduling is the one thing
  "! in the split that talks to the system, and everything worth testing about
  "! it -- how many jobs, which packages, what they are called -- is on this
  "! side of it.
  "!
  "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
  "! @parameter iv_package     | <p class="shorttext synchronized">Package this job covers</p>
  "! @parameter iv_packages    | <p class="shorttext synchronized">Jobs sharing the plant</p>
  "! @parameter iv_test        | <p class="shorttext synchronized">The job changes nothing</p>
  "! @parameter iv_recut       | <p class="shorttext synchronized">The job gives earlier allocations back first</p>
  "! @parameter iv_carry_on    | <p class="shorttext synchronized">The job leaves out what a run covered today</p>
  "! @parameter rv_jobname     | <p class="shorttext synchronized">Name the job was scheduled under</p>
  "! @raising   zcx_allocation | <p class="shorttext synchronized">Job could not be scheduled</p>
  METHODS schedule
    IMPORTING
      iv_werks          TYPE mard-werks
      iv_package        TYPE i
      iv_packages       TYPE i
      iv_test           TYPE abap_bool DEFAULT abap_true
      iv_recut          TYPE abap_bool DEFAULT abap_false
      iv_carry_on       TYPE abap_bool DEFAULT abap_false
    RETURNING
      VALUE(rv_jobname) TYPE btcjob
    RAISING
      zcx_allocation.

ENDINTERFACE.
