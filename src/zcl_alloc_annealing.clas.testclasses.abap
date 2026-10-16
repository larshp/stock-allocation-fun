CLASS ltcl_alloc_annealing DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_annealing.
    DATA mt_pt  TYPE zcl_alloc_annealing=>ty_point_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i
        iv_score TYPE i.

    METHODS accepts_worse_in_temp FOR TESTING.
    METHODS rejects_beyond_temp    FOR TESTING.
    METHODS zero_temp_stops        FOR TESTING.
    METHODS takes_improvement      FOR TESTING.
    METHODS no_candidate_available FOR TESTING.
    METHODS empty_points           FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_annealing IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_annealing( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_point TYPE zcl_alloc_annealing=>ty_point.

    ls_point-point_value = iv_value.
    ls_point-score = iv_score.
    APPEND ls_point TO mt_pt.
  ENDMETHOD.

  METHOD accepts_worse_in_temp.
    add( iv_value = 0 iv_score = 10 ).
    add( iv_value = 1 iv_score = 5 ).

    DATA(ls_result) = mo_cut->anneal( it_points     = mt_pt
                                      iv_start      = 0
                                      iv_step       = 1
                                      iv_max_steps  = 3
                                      iv_start_temp = 10
                                      iv_cool_pct   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-accepted_worse exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-final_value exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 10 ).
  ENDMETHOD.

  METHOD rejects_beyond_temp.
    add( iv_value = 0 iv_score = 10 ).
    add( iv_value = 1 iv_score = 0 ).

    DATA(ls_result) = mo_cut->anneal( it_points     = mt_pt
                                      iv_start      = 0
                                      iv_step       = 1
                                      iv_max_steps  = 3
                                      iv_start_temp = 3
                                      iv_cool_pct   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-accepted_worse exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-final_value exp = 0 ).
  ENDMETHOD.

  METHOD zero_temp_stops.
    add( iv_value = 0 iv_score = 10 ).
    add( iv_value = 1 iv_score = 5 ).
    add( iv_value = 2 iv_score = 5 ).

    DATA(ls_result) = mo_cut->anneal( it_points     = mt_pt
                                      iv_start      = 1
                                      iv_step       = 1
                                      iv_max_steps  = 3
                                      iv_start_temp = 100
                                      iv_cool_pct   = 100 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-accepted_worse exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-final_value exp = 0 ).
  ENDMETHOD.

  METHOD takes_improvement.
    add( iv_value = 0 iv_score = 1 ).
    add( iv_value = 1 iv_score = 9 ).

    DATA(ls_result) = mo_cut->anneal( it_points     = mt_pt
                                      iv_start      = 0
                                      iv_step       = 1
                                      iv_max_steps  = 3
                                      iv_start_temp = 0
                                      iv_cool_pct   = 0 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 9 ).
  ENDMETHOD.

  METHOD no_candidate_available.
    add( iv_value = 0 iv_score = 5 ).

    DATA(ls_result) = mo_cut->anneal( it_points     = mt_pt
                                      iv_start      = 0
                                      iv_step       = 1
                                      iv_max_steps  = 3
                                      iv_start_temp = 10
                                      iv_cool_pct   = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-final_value exp = 0 ).
  ENDMETHOD.

  METHOD empty_points.
    DATA(ls_result) = mo_cut->anneal( it_points     = mt_pt
                                      iv_start      = 4
                                      iv_step       = 1
                                      iv_max_steps  = 3
                                      iv_start_temp = 10
                                      iv_cool_pct   = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-final_value exp = 4 ).
  ENDMETHOD.

ENDCLASS.
