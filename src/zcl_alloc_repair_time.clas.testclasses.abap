CLASS ltcl_alloc_repair_time DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_repair_time.
    DATA mt_job TYPE zcl_alloc_repair_time=>ty_job_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_start TYPE i
        iv_end   TYPE i.

    METHODS elapsed_read  FOR TESTING.
    METHODS elapsed_floor FOR TESTING.
    METHODS averages      FOR TESTING.
    METHODS average_empty FOR TESTING.
    METHODS on_target     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_repair_time IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_repair_time( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_job TYPE zcl_alloc_repair_time=>ty_job.

    ls_job-start_min = iv_start.
    ls_job-end_min = iv_end.
    APPEND ls_job TO mt_job.
  ENDMETHOD.

  METHOD elapsed_read.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->elapsed( iv_start = 100 iv_end = 130 ) exp = 30 ).
  ENDMETHOD.

  METHOD elapsed_floor.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->elapsed( iv_start = 130 iv_end = 100 ) exp = 0 ).
  ENDMETHOD.

  METHOD averages.
    add( iv_start = 0 iv_end = 30 ).
    add( iv_start = 30 iv_end = 60 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_job ) exp = 30 ).
  ENDMETHOD.

  METHOD average_empty.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->average( mt_job ) exp = 0 ).
  ENDMETHOD.

  METHOD on_target.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_minutes = 30 iv_target = 60 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_minutes = 70 iv_target = 60 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_on_target( iv_minutes = 30 iv_target = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
