CLASS ltcl_alloc_sched_cr DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sched_cr.
    DATA mt_job TYPE zcl_alloc_sched_cr=>ty_job_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id   TYPE string
        iv_work TYPE i
        iv_due  TYPE i.

    METHODS empty_jobs        FOR TESTING.
    METHODS urgent_job_first  FOR TESTING.
    METHODS reports_ratio     FOR TESTING.
    METHODS zero_work_last    FOR TESTING.
    METHODS counts_late_jobs  FOR TESTING.
    METHODS no_lateness       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sched_cr IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sched_cr( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_job TYPE zcl_alloc_sched_cr=>ty_job.

    ls_job-job_id = iv_id.
    ls_job-work_time = iv_work.
    ls_job-due_day = iv_due.
    APPEND ls_job TO mt_job.
  ENDMETHOD.

  METHOD empty_jobs.
    DATA(lt_slots) = mo_cut->schedule( it_jobs  = mt_job
                                       iv_today = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_slots ) exp = 0 ).
  ENDMETHOD.

  METHOD urgent_job_first.
    add( iv_id = 'SLACK' iv_work = 2 iv_due = 10 ).
    add( iv_id = 'URGENT' iv_work = 5 iv_due = 10 ).

    DATA(lt_slots) = mo_cut->schedule( it_jobs  = mt_job
                                       iv_today = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-job_id exp = 'URGENT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-job_id exp = 'SLACK' ).
  ENDMETHOD.

  METHOD reports_ratio.
    add( iv_id = 'SLACK' iv_work = 2 iv_due = 10 ).
    add( iv_id = 'URGENT' iv_work = 5 iv_due = 10 ).

    DATA(lt_slots) = mo_cut->schedule( it_jobs  = mt_job
                                       iv_today = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-cr_x100 exp = 200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-cr_x100 exp = 500 ).
  ENDMETHOD.

  METHOD zero_work_last.
    add( iv_id = 'NO_WORK' iv_work = 0 iv_due = 1 ).
    add( iv_id = 'REAL' iv_work = 4 iv_due = 10 ).

    DATA(lt_slots) = mo_cut->schedule( it_jobs  = mt_job
                                       iv_today = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-job_id exp = 'NO_WORK' ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-cr_x100 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-finish_day exp = 4 ).
  ENDMETHOD.

  METHOD counts_late_jobs.
    add( iv_id = 'A' iv_work = 6 iv_due = 2 ).
    add( iv_id = 'B' iv_work = 2 iv_due = 10 ).

    DATA(lt_slots) = mo_cut->schedule( it_jobs  = mt_job
                                       iv_today = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->late_count( lt_slots ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-late_days exp = 4 ).
  ENDMETHOD.

  METHOD no_lateness.
    add( iv_id = 'A' iv_work = 2 iv_due = 10 ).
    add( iv_id = 'B' iv_work = 3 iv_due = 20 ).

    DATA(lt_slots) = mo_cut->schedule( it_jobs  = mt_job
                                       iv_today = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->late_count( lt_slots ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
