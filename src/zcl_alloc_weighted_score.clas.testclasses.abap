CLASS ltcl_alloc_weighted_score DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_weighted_score.
    DATA mt_row TYPE zcl_alloc_scorecard=>ty_row_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_weight TYPE i
        iv_met    TYPE abap_bool.

    METHODS empty_rows   FOR TESTING.
    METHODS partial_met  FOR TESTING.
    METHODS all_met      FOR TESTING.
    METHODS none_met     FOR TESTING.
    METHODS zero_weights FOR TESTING.
    METHODS grades       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_weighted_score IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_weighted_score( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_row TYPE zcl_alloc_scorecard=>ty_row.

    ls_row-metric_id = iv_id.
    ls_row-weight = iv_weight.
    ls_row-met = iv_met.
    APPEND ls_row TO mt_row.
  ENDMETHOD.

  METHOD empty_rows.
    DATA(ls_result) = mo_cut->score( mt_row ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_weight exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-score_x10000 exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-grade exp = 'D' ).
  ENDMETHOD.

  METHOD partial_met.
    add( iv_id = 'A' iv_weight = 3 iv_met = abap_true ).
    add( iv_id = 'B' iv_weight = 1 iv_met = abap_false ).

    DATA(ls_result) = mo_cut->score( mt_row ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_weight exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-earned exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-score_x10000 exp = 7500 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-grade exp = 'B' ).
  ENDMETHOD.

  METHOD all_met.
    add( iv_id = 'A' iv_weight = 3 iv_met = abap_true ).
    add( iv_id = 'B' iv_weight = 1 iv_met = abap_true ).

    DATA(ls_result) = mo_cut->score( mt_row ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-earned exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-score_x10000 exp = 10000 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-grade exp = 'A' ).
  ENDMETHOD.

  METHOD none_met.
    add( iv_id = 'A' iv_weight = 2 iv_met = abap_false ).

    DATA(ls_result) = mo_cut->score( mt_row ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-earned exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-grade exp = 'D' ).
  ENDMETHOD.

  METHOD zero_weights.
    add( iv_id = 'A' iv_weight = 0 iv_met = abap_true ).
    add( iv_id = 'B' iv_weight = -5 iv_met = abap_true ).

    DATA(ls_result) = mo_cut->score( mt_row ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_weight exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-earned exp = 0 ).
  ENDMETHOD.

  METHOD grades.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->grade_of( 10000 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->grade_of( 9000 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->grade_of( 8999 ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->grade_of( 7500 ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->grade_of( 6000 ) exp = 'C' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->grade_of( 5999 ) exp = 'D' ).
  ENDMETHOD.

ENDCLASS.
