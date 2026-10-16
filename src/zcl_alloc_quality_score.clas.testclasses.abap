CLASS ltcl_alloc_quality_score DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_quality_score.
    DATA mt_cri TYPE zcl_alloc_quality_score=>ty_criterion_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_weight TYPE i
        iv_score  TYPE i.

    METHODS weighted_avg   FOR TESTING.
    METHODS equal_weights  FOR TESTING.
    METHODS no_weights     FOR TESTING.
    METHODS ignores_range  FOR TESTING.
    METHODS grade_a        FOR TESTING.
    METHODS grade_d        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_quality_score IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_quality_score( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_cri TYPE zcl_alloc_quality_score=>ty_criterion.

    ls_cri-weight = iv_weight.
    ls_cri-score = iv_score.
    APPEND ls_cri TO mt_cri.
  ENDMETHOD.

  METHOD weighted_avg.
    add( iv_weight = 3 iv_score = 100 ).
    add( iv_weight = 1 iv_score = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( mt_cri ) exp = 75 ).
  ENDMETHOD.

  METHOD equal_weights.
    add( iv_weight = 1 iv_score = 80 ).
    add( iv_weight = 1 iv_score = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( mt_cri ) exp = 85 ).
  ENDMETHOD.

  METHOD no_weights.
    add( iv_weight = 0 iv_score = 90 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( mt_cri ) exp = 0 ).
  ENDMETHOD.

  METHOD ignores_range.
    add( iv_weight = 1 iv_score = 150 ).
    add( iv_weight = 1 iv_score = 50 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( mt_cri ) exp = 50 ).
  ENDMETHOD.

  METHOD grade_a.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( iv_score = 95 ) exp = 'A' ).
  ENDMETHOD.

  METHOD grade_d.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( iv_score = 40 ) exp = 'D' ).
  ENDMETHOD.

ENDCLASS.
