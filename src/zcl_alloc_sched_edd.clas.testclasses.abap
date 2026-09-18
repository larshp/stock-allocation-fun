CLASS ltcl_alloc_sched_edd DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sched_edd.
    DATA mt_job TYPE zcl_alloc_sched_edd=>ty_job_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id   TYPE string
        iv_work TYPE i
        iv_due  TYPE i.

    METHODS empty_jobs       FOR TESTING.
    METHODS earliest_due_first FOR TESTING.
    METHODS back_to_back      FOR TESTING.
    METHODS late_is_reported  FOR TESTING.
    METHODS counts_late_jobs  FOR TESTING.
    METHODS no_lateness       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sched_edd IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sched_edd( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_job TYPE zcl_alloc_sched_edd=>ty_job.

    ls_job-job_id = iv_id.
    ls_job-work_time = iv_work.
    ls_job-due_day = iv_due.
    APPEND ls_job TO mt_job.
  ENDMETHOD.

  METHOD empty_jobs.
    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_slots ) exp = 0 ).
  ENDMETHOD.

  METHOD earliest_due_first.
    add( iv_id = 'LATE_DUE' iv_work = 3 iv_due = 9 ).
    add( iv_id = 'SOON' iv_work = 3 iv_due = 3 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-job_id exp = 'SOON' ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-job_id exp = 'LATE_DUE' ).
  ENDMETHOD.

  METHOD back_to_back.
    add( iv_id = 'A' iv_work = 3 iv_due = 10 ).
    add( iv_id = 'B' iv_work = 4 iv_due = 20 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-start_day exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-finish_day exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-start_day exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-finish_day exp = 7 ).
  ENDMETHOD.

  METHOD late_is_reported.
    add( iv_id = 'A' iv_work = 4 iv_due = 4 ).
    add( iv_id = 'B' iv_work = 3 iv_due = 5 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-is_late exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-is_late exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-late_days exp = 2 ).
  ENDMETHOD.

  METHOD counts_late_jobs.
    add( iv_id = 'A' iv_work = 4 iv_due = 4 ).
    add( iv_id = 'B' iv_work = 3 iv_due = 5 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->late_count( lt_slots ) exp = 1 ).
  ENDMETHOD.

  METHOD no_lateness.
    add( iv_id = 'A' iv_work = 2 iv_due = 10 ).
    add( iv_id = 'B' iv_work = 2 iv_due = 10 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->late_count( lt_slots ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
