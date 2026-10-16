CLASS ltcl_alloc_sched_spt DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_sched_spt.
    DATA mt_job TYPE zcl_alloc_sched_spt=>ty_job_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id   TYPE string
        iv_work TYPE i
        iv_due  TYPE i.

    METHODS empty_jobs        FOR TESTING.
    METHODS shortest_first    FOR TESTING.
    METHODS back_to_back      FOR TESTING.
    METHODS late_after_short  FOR TESTING.
    METHODS counts_late_jobs  FOR TESTING.
    METHODS average_finish    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_sched_spt IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_sched_spt( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_job TYPE zcl_alloc_sched_spt=>ty_job.

    ls_job-job_id = iv_id.
    ls_job-work_time = iv_work.
    ls_job-due_day = iv_due.
    APPEND ls_job TO mt_job.
  ENDMETHOD.

  METHOD empty_jobs.
    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_slots ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->avg_finish( lt_slots ) exp = 0 ).
  ENDMETHOD.

  METHOD shortest_first.
    add( iv_id = 'LONG' iv_work = 9 iv_due = 20 ).
    add( iv_id = 'SHORT' iv_work = 2 iv_due = 20 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-job_id exp = 'SHORT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-job_id exp = 'LONG' ).
  ENDMETHOD.

  METHOD back_to_back.
    add( iv_id = 'A' iv_work = 3 iv_due = 20 ).
    add( iv_id = 'B' iv_work = 4 iv_due = 20 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-start_day exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-finish_day exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-finish_day exp = 7 ).
  ENDMETHOD.

  METHOD late_after_short.
    add( iv_id = 'SHORT' iv_work = 3 iv_due = 5 ).
    add( iv_id = 'LONG' iv_work = 4 iv_due = 4 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-job_id exp = 'SHORT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 1 ]-is_late exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-is_late exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_slots[ 2 ]-late_days exp = 3 ).
  ENDMETHOD.

  METHOD counts_late_jobs.
    add( iv_id = 'SHORT' iv_work = 3 iv_due = 5 ).
    add( iv_id = 'LONG' iv_work = 4 iv_due = 4 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->late_count( lt_slots ) exp = 1 ).
  ENDMETHOD.

  METHOD average_finish.
    add( iv_id = 'A' iv_work = 3 iv_due = 20 ).
    add( iv_id = 'B' iv_work = 4 iv_due = 20 ).

    DATA(lt_slots) = mo_cut->schedule( mt_job ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->avg_finish( lt_slots ) exp = 5 ).
  ENDMETHOD.

ENDCLASS.
