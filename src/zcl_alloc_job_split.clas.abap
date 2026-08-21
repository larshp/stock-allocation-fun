CLASS zcl_alloc_job_split DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_jobname_tab TYPE STANDARD TABLE OF btcjob WITH EMPTY KEY.

    "! More jobs than this on one plant is not a split, it is a way of filling
    "! every background work process the system has with one plant's night.
    CONSTANTS c_max_jobs TYPE i VALUE 20.

    "! <p class="shorttext synchronized">Split wired up the way a plain SAP system needs it</p>
    "!
    "! @parameter ro_split | <p class="shorttext synchronized">Ready to use split</p>
    CLASS-METHODS create_default
      RETURNING
        VALUE(ro_split) TYPE REF TO zcl_alloc_job_split.

    "! <p class="shorttext synchronized">Wire up the split</p>
    "!
    "! @parameter io_scheduler | <p class="shorttext synchronized">Puts one job into the background</p>
    "! @parameter io_authority | <p class="shorttext synchronized">Decides who may allocate where</p>
    METHODS constructor
      IMPORTING
        io_scheduler TYPE REF TO zif_job_scheduler
        io_authority TYPE REF TO zif_allocation_authority.

    "! <p class="shorttext synchronized">Put a plant's night into several jobs at once</p>
    "!
    "! Feature 58 made a plant splittable: schedule the allocation several
    "! times, each job told which package of the plant it covers. Doing that by
    "! hand in SM36 means creating eight jobs, each with its own variant, each
    "! of which has to be found and changed again when anything about the run
    "! changes -- and one of them quietly not scheduled is a part of the plant
    "! nobody allocates, which nothing in the result reports would show.
    "!
    "! This schedules all of them in one go, and either every job is scheduled
    "! or the caller is told which one could not be.
    "!
    "! @parameter iv_werks       | <p class="shorttext synchronized">Plant</p>
    "! @parameter iv_jobs        | <p class="shorttext synchronized">How many jobs to share it between</p>
    "! @parameter iv_test        | <p class="shorttext synchronized">The jobs change nothing</p>
    "! @parameter iv_recut       | <p class="shorttext synchronized">The jobs give earlier allocations back first</p>
    "! @parameter rt_jobname     | <p class="shorttext synchronized">What the jobs were scheduled as</p>
    "! @raising   zcx_allocation | <p class="shorttext synchronized">A job could not be scheduled</p>
    METHODS run
      IMPORTING
        iv_werks          TYPE mard-werks
        iv_jobs           TYPE i
        iv_test           TYPE abap_bool DEFAULT abap_true
        iv_recut          TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_jobname) TYPE ty_jobname_tab
      RAISING
        zcx_allocation.

  PRIVATE SECTION.

    DATA mo_scheduler TYPE REF TO zif_job_scheduler.
    DATA mo_authority TYPE REF TO zif_allocation_authority.

ENDCLASS.


CLASS zcl_alloc_job_split IMPLEMENTATION.

  METHOD create_default.

    ro_split = NEW zcl_alloc_job_split(
      io_scheduler = NEW zcl_job_scheduler( )
      io_authority = NEW zcl_authority_alloc( ) ).

  ENDMETHOD.

  METHOD constructor.

    mo_scheduler = io_scheduler.
    mo_authority = io_authority.

  ENDMETHOD.

  METHOD run.

    DATA lv_jobs TYPE i.

    " scheduling a run is starting one, so it is guarded like one. It is
    " checked here rather than left to the jobs: a job that fails the check
    " fails in the background, where nobody is looking.
    mo_authority->check_plant( iv_werks ).

    " none, or one, is a plant that is not being split, and both mean one job
    " covering all of it: a package of 1 of 1 is what a plain run is
    lv_jobs = iv_jobs.
    IF lv_jobs < 1.
      lv_jobs = 1.
    ENDIF.
    IF lv_jobs > c_max_jobs.
      lv_jobs = c_max_jobs.
    ENDIF.

    DO lv_jobs TIMES.

      APPEND mo_scheduler->schedule(
        iv_werks    = iv_werks
        iv_package  = sy-index
        iv_packages = lv_jobs
        iv_test     = iv_test
        iv_recut    = iv_recut ) TO rt_jobname.

    ENDDO.

  ENDMETHOD.

ENDCLASS.
