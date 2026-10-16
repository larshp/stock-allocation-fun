CLASS ltcl_alloc_repair_queue DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_repair_queue.
    DATA mt_job TYPE zcl_alloc_repair_queue=>ty_job_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_job_id   TYPE string
        iv_priority TYPE i
        iv_arrival  TYPE i.

    METHODS priority_first FOR TESTING.
    METHODS arrival_tie    FOR TESTING.
    METHODS positions      FOR TESTING.
    METHODS bands          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_repair_queue IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_repair_queue( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_job TYPE zcl_alloc_repair_queue=>ty_job.

    ls_job-job_id = iv_job_id.
    ls_job-priority = iv_priority.
    ls_job-arrival = iv_arrival.
    APPEND ls_job TO mt_job.
  ENDMETHOD.

  METHOD priority_first.
    DATA lt_jobs TYPE zcl_alloc_repair_queue=>ty_job_tt.

    add( iv_job_id = 'J1' iv_priority = 5 iv_arrival = 1 ).
    add( iv_job_id = 'J2' iv_priority = 9 iv_arrival = 2 ).

    lt_jobs = mo_cut->sequence( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_jobs[ 1 ]-job_id exp = 'J2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_jobs[ 2 ]-job_id exp = 'J1' ).
  ENDMETHOD.

  METHOD arrival_tie.
    DATA lt_jobs TYPE zcl_alloc_repair_queue=>ty_job_tt.

    add( iv_job_id = 'J1' iv_priority = 5 iv_arrival = 1 ).
    add( iv_job_id = 'J2' iv_priority = 9 iv_arrival = 2 ).
    add( iv_job_id = 'J3' iv_priority = 5 iv_arrival = 0 ).

    lt_jobs = mo_cut->sequence( mt_job ).

    cl_abap_unit_assert=>assert_equals( act = lt_jobs[ 1 ]-job_id exp = 'J2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_jobs[ 2 ]-job_id exp = 'J3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_jobs[ 3 ]-job_id exp = 'J1' ).
  ENDMETHOD.

  METHOD positions.
    add( iv_job_id = 'J1' iv_priority = 5 iv_arrival = 1 ).
    add( iv_job_id = 'J2' iv_priority = 9 iv_arrival = 2 ).
    add( iv_job_id = 'J3' iv_priority = 5 iv_arrival = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position_of( it_jobs = mt_job iv_job_id = 'J3' )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position_of( it_jobs = mt_job iv_job_id = 'J1' )
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->position_of( it_jobs = mt_job iv_job_id = 'JX' )
      exp = 0 ).
  ENDMETHOD.

  METHOD bands.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority_order( 9 ) exp = 'HIGH' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority_order( 5 ) exp = 'MEDIUM' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->priority_order( 1 ) exp = 'LOW' ).
  ENDMETHOD.

ENDCLASS.
