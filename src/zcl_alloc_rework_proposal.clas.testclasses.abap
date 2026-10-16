CLASS ltcl_alloc_rework_proposal DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rework_proposal.

    METHODS setup.

    METHODS grade_c        FOR TESTING.
    METHODS grade_d        FOR TESTING.
    METHODS no_rework      FOR TESTING.
    METHODS counts_and_hours FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rework_proposal IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rework_proposal( ).
  ENDMETHOD.

  METHOD grade_c.
    DATA lt_steps TYPE zcl_alloc_rework_proposal=>ty_step_tt.

    lt_steps = mo_cut->propose( 'C' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_steps ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 1 ]-step exp = 'CLEAN' ).
    cl_abap_unit_assert=>assert_equals( act = lt_steps[ 2 ]-step exp = 'TEST' ).
  ENDMETHOD.

  METHOD grade_d.
    DATA lt_steps TYPE zcl_alloc_rework_proposal=>ty_step_tt.

    lt_steps = mo_cut->propose( 'D' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_steps ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_steps[ 2 ]-step exp = 'REPLACE_PART' ).
  ENDMETHOD.

  METHOD no_rework.
    DATA lt_steps TYPE zcl_alloc_rework_proposal=>ty_step_tt.

    lt_steps = mo_cut->propose( 'A' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_steps ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_and_hours.
    DATA lt_steps TYPE zcl_alloc_rework_proposal=>ty_step_tt.

    lt_steps = mo_cut->propose( 'D' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->steps( lt_steps ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_hours( lt_steps ) exp = 4 ).
  ENDMETHOD.

ENDCLASS.
