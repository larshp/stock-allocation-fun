CLASS ltcl_alloc_disposition DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_disposition.
    DATA mt_gra TYPE zcl_alloc_disposition=>ty_grade_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_grade TYPE string.

    METHODS routes_by_grade FOR TESTING.
    METHODS hazard_override  FOR TESTING.
    METHODS unknown_grade    FOR TESTING.
    METHODS counts_targets   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_disposition IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_disposition( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_grade TYPE zcl_alloc_disposition=>ty_grade_item.

    ls_grade-grade = iv_grade.
    APPEND ls_grade TO mt_gra.
  ENDMETHOD.

  METHOD routes_by_grade.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->route( iv_grade = 'A' iv_hazardous = abap_false )
      exp = 'RESTOCK' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->route( iv_grade = 'C' iv_hazardous = abap_false )
      exp = 'REWORK' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->route( iv_grade = 'D' iv_hazardous = abap_false )
      exp = 'REPAIR' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->route( iv_grade = 'F' iv_hazardous = abap_false )
      exp = 'SCRAP' ).
  ENDMETHOD.

  METHOD hazard_override.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->route( iv_grade = 'A' iv_hazardous = abap_true )
      exp = 'SCRAP' ).
  ENDMETHOD.

  METHOD unknown_grade.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->route( iv_grade = 'Z' iv_hazardous = abap_false )
      exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->target_of( 'B' ) exp = 'RESTOCK' ).
  ENDMETHOD.

  METHOD counts_targets.
    DATA lt_counts TYPE zcl_alloc_disposition=>ty_count_tt.

    add( 'A' ).
    add( 'B' ).
    add( 'C' ).
    add( 'F' ).

    lt_counts = mo_cut->count_for( mt_gra ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_counts ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_counts[ 1 ]-target exp = 'RESTOCK' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_counts[ 1 ]-count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_counts[ 2 ]-target exp = 'REWORK' ).
  ENDMETHOD.

ENDCLASS.
