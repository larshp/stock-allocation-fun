CLASS ltcl_alloc_lph DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lph.
    DATA mt_pic TYPE zcl_alloc_lph=>ty_pick_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_start TYPE i
        iv_end   TYPE i
        iv_lines TYPE i.

    METHODS sums_lines      FOR TESTING.
    METHODS sums_minutes    FOR TESTING.
    METHODS flips_span      FOR TESTING.
    METHODS lph_read        FOR TESTING.
    METHODS lph_zero_time   FOR TESTING.
    METHODS achievement     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lph IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lph( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_pick TYPE zcl_alloc_lph=>ty_pick.

    ls_pick-start_min = iv_start.
    ls_pick-end_min = iv_end.
    ls_pick-lines = iv_lines.
    APPEND ls_pick TO mt_pic.
  ENDMETHOD.

  METHOD sums_lines.
    add( iv_start = 0 iv_end = 30 iv_lines = 100 ).
    add( iv_start = 30 iv_end = 60 iv_lines = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_lines( mt_pic ) exp = 180 ).
  ENDMETHOD.

  METHOD sums_minutes.
    add( iv_start = 0 iv_end = 30 iv_lines = 100 ).
    add( iv_start = 30 iv_end = 60 iv_lines = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_minutes( mt_pic ) exp = 60 ).
  ENDMETHOD.

  METHOD flips_span.
    add( iv_start = 60 iv_end = 30 iv_lines = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_minutes( mt_pic ) exp = 0 ).
  ENDMETHOD.

  METHOD lph_read.
    add( iv_start = 0 iv_end = 30 iv_lines = 100 ).
    add( iv_start = 30 iv_end = 60 iv_lines = 80 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lines_per_hour( mt_pic ) exp = 180 ).
  ENDMETHOD.

  METHOD lph_zero_time.
    add( iv_start = 60 iv_end = 60 iv_lines = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lines_per_hour( mt_pic ) exp = 0 ).
  ENDMETHOD.

  METHOD achievement.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->achievement_percent( iv_actual = 180 iv_target = 200 )
      exp = 90 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->achievement_percent( iv_actual = 180 iv_target = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
