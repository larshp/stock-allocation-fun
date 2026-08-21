"! Remembers what it was asked to schedule, and can refuse.
CLASS lcl_scheduler_spy DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_job_scheduler.

    TYPES:
      BEGIN OF ty_call,
        werks    TYPE mard-werks,
        package  TYPE i,
        packages TYPE i,
        test     TYPE abap_bool,
        recut    TYPE abap_bool,
      END OF ty_call.
    TYPES ty_call_tab TYPE STANDARD TABLE OF ty_call WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        iv_refuse_at TYPE i DEFAULT 0.

    METHODS get_calls
      RETURNING
        VALUE(rt_call) TYPE ty_call_tab.

  PRIVATE SECTION.
    DATA mt_call      TYPE ty_call_tab.
    DATA mv_refuse_at TYPE i.

ENDCLASS.


CLASS lcl_scheduler_spy IMPLEMENTATION.

  METHOD constructor.
    mv_refuse_at = iv_refuse_at.
  ENDMETHOD.

  METHOD zif_job_scheduler~schedule.

    IF mv_refuse_at > 0 AND iv_package = mv_refuse_at.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>job_failed
        mv_message = |{ iv_package }| ).
    ENDIF.

    APPEND VALUE #(
      werks    = iv_werks
      package  = iv_package
      packages = iv_packages
      test     = iv_test
      recut    = iv_recut ) TO mt_call.

    rv_jobname = |JOB_{ iv_werks }_{ iv_package }|.

  ENDMETHOD.

  METHOD get_calls.
    rt_call = mt_call.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mv_refuse TYPE abap_bool.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_job_split DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9201'.

    DATA mo_spy TYPE REF TO lcl_scheduler_spy.

    METHODS cut
      IMPORTING
        iv_refuse     TYPE abap_bool DEFAULT abap_false
        iv_refuse_at  TYPE i DEFAULT 0
      RETURNING
        VALUE(ro_cut) TYPE REF TO zcl_alloc_job_split.

    METHODS one_job_per_package FOR TESTING RAISING cx_static_check.
    METHODS every_job_knows_the_whole FOR TESTING RAISING cx_static_check.
    METHODS no_split_is_still_one_job FOR TESTING RAISING cx_static_check.
    METHODS the_number_is_capped FOR TESTING RAISING cx_static_check.
    METHODS the_settings_are_passed_on FOR TESTING RAISING cx_static_check.
    METHODS the_names_come_back FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_schedules_none FOR TESTING.
    METHODS a_refused_job_is_said FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_job_split IMPLEMENTATION.

  METHOD cut.

    mo_spy = NEW lcl_scheduler_spy( iv_refuse_at ).

    ro_cut = NEW zcl_alloc_job_split(
      io_scheduler = mo_spy
      io_authority = NEW lcl_authority_double( iv_refuse ) ).

  ENDMETHOD.

  METHOD one_job_per_package.

    cut( )->run(
      iv_werks = c_werks
      iv_jobs  = 4 ).

    DATA(lt_call) = mo_spy->get_calls( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_call )
      exp = 4
      msg = 'a package nobody scheduled is a part of the plant nobody allocates' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_call[ 1 ]-package
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_call[ 4 ]-package
      exp = 4 ).

  ENDMETHOD.

  METHOD every_job_knows_the_whole.

    cut( )->run(
      iv_werks = c_werks
      iv_jobs  = 3 ).

    " which material belongs to which package follows from how many there are,
    " so a job told the wrong total covers the wrong materials
    LOOP AT mo_spy->get_calls( ) INTO DATA(ls_call).
      cl_abap_unit_assert=>assert_equals(
        act = ls_call-packages
        exp = 3 ).
    ENDLOOP.

  ENDMETHOD.

  METHOD no_split_is_still_one_job.

    cut( )->run(
      iv_werks = c_werks
      iv_jobs  = 0 ).

    DATA(lt_call) = mo_spy->get_calls( ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_call )
      exp = 1
      msg = 'a plant that is not being split is one job covering all of it' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_call[ 1 ]-packages
      exp = 1 ).

  ENDMETHOD.

  METHOD the_number_is_capped.

    cut( )->run(
      iv_werks = c_werks
      iv_jobs  = 500 ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_spy->get_calls( ) )
      exp = zcl_alloc_job_split=>c_max_jobs
      msg = 'five hundred jobs on one plant is a way of filling the system' ).

  ENDMETHOD.

  METHOD the_settings_are_passed_on.

    cut( )->run(
      iv_werks = c_werks
      iv_jobs  = 2
      iv_test  = abap_false
      iv_recut = abap_true ).

    DATA(lt_call) = mo_spy->get_calls( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_call[ 2 ]-test
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_call[ 2 ]-recut
      exp = abap_true
      msg = 'a split re-cut where half the jobs add to the allocation is worse than neither' ).

  ENDMETHOD.

  METHOD the_names_come_back.

    DATA(lt_jobname) = cut( )->run(
      iv_werks = c_werks
      iv_jobs  = 2 ).

    " somebody has to be able to find them in SM37 five minutes later
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_jobname )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_jobname[ 1 ]
      exp = |JOB_{ c_werks }_1| ).

  ENDMETHOD.

  METHOD a_closed_plant_schedules_none.

    TRY.
        cut( iv_refuse = abap_true )->run(
          iv_werks = c_werks
          iv_jobs  = 4 ).
        cl_abap_unit_assert=>fail( 'scheduling a run is starting one' ).
      CATCH zcx_allocation.
        cl_abap_unit_assert=>assert_initial(
          act = mo_spy->get_calls( )
          msg = 'and a job that fails the check fails where nobody is looking' ).
    ENDTRY.

  ENDMETHOD.

  METHOD a_refused_job_is_said.

    TRY.
        cut( iv_refuse_at = 3 )->run(
          iv_werks = c_werks
          iv_jobs  = 4 ).
        cl_abap_unit_assert=>fail( 'a plant three quarters scheduled is not scheduled' ).
      CATCH zcx_allocation.
        cl_abap_unit_assert=>assert_equals(
          act = lines( mo_spy->get_calls( ) )
          exp = 2
          msg = 'the jobs before it are already in the queue, and it stops there' ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
