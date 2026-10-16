CLASS ltcl_alloc_improve_log DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_improve_log.

    METHODS setup.

    METHODS numbers_steps    FOR TESTING.
    METHODS best_is_highest  FOR TESTING.
    METHODS first_is_initial FOR TESTING.
    METHODS gain_positive    FOR TESTING.
    METHODS gain_never_less  FOR TESTING.
    METHODS empty_log        FOR TESTING.
    METHODS copies_entries   FOR TESTING.
    METHODS reset_clears     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_improve_log IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_improve_log( ).
  ENDMETHOD.

  METHOD numbers_steps.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add( iv_description = 'start' iv_score = 5 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add( iv_description = 'swap' iv_score = 7 ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 2 ).
  ENDMETHOD.

  METHOD best_is_highest.
    mo_cut->add( iv_description = 'A' iv_score = 5 ).
    mo_cut->add( iv_description = 'B' iv_score = 9 ).
    mo_cut->add( iv_description = 'C' iv_score = 2 ).

    DATA(ls_best) = mo_cut->best( ).

    cl_abap_unit_assert=>assert_equals( act = ls_best-description exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_best-score exp = 9 ).
    cl_abap_unit_assert=>assert_equals( act = ls_best-step exp = 2 ).
  ENDMETHOD.

  METHOD first_is_initial.
    mo_cut->add( iv_description = 'A' iv_score = 1 ).
    mo_cut->add( iv_description = 'B' iv_score = 9 ).

    DATA(ls_first) = mo_cut->first( ).

    cl_abap_unit_assert=>assert_equals( act = ls_first-description exp = 'A' ).
  ENDMETHOD.

  METHOD gain_positive.
    mo_cut->add( iv_description = 'A' iv_score = 5 ).
    mo_cut->add( iv_description = 'B' iv_score = 9 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->gain( ) exp = 4 ).
  ENDMETHOD.

  METHOD gain_never_less.
    mo_cut->add( iv_description = 'A' iv_score = 9 ).
    mo_cut->add( iv_description = 'B' iv_score = 4 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->gain( ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_log.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->gain( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->best( )-score exp = 0 ).
  ENDMETHOD.

  METHOD copies_entries.
    mo_cut->add( iv_description = 'A' iv_score = 1 ).
    mo_cut->add( iv_description = 'B' iv_score = 2 ).

    DATA(lt_entries) = mo_cut->entries( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-step exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 2 ]-step exp = 2 ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->add( iv_description = 'A' iv_score = 1 ).
    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->count( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add( iv_description = 'B' iv_score = 3 ) exp = 1 ).
  ENDMETHOD.

ENDCLASS.
