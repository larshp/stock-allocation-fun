CLASS ltcl_alloc_hill_climb DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hill_climb.
    DATA mt_pt  TYPE zcl_alloc_hill_climb=>ty_point_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE i
        iv_score TYPE i.

    METHODS climbs_to_peak    FOR TESTING.
    METHODS flat_no_move      FOR TESTING.
    METHODS max_steps_limits  FOR TESTING.
    METHODS start_unknown     FOR TESTING.
    METHODS step_zero_stops   FOR TESTING.
    METHODS empty_points      FOR TESTING.
    METHODS no_downhill_move  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hill_climb IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hill_climb( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_point TYPE zcl_alloc_hill_climb=>ty_point.

    ls_point-point_value = iv_value.
    ls_point-score = iv_score.
    APPEND ls_point TO mt_pt.
  ENDMETHOD.

  METHOD climbs_to_peak.
    add( iv_value = 0 iv_score = 0 ).
    add( iv_value = 1 iv_score = 2 ).
    add( iv_value = 2 iv_score = 5 ).
    add( iv_value = 3 iv_score = 9 ).
    add( iv_value = 4 iv_score = 9 ).

    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 0
                                     iv_step      = 1
                                     iv_max_steps = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-reached exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 9 ).
  ENDMETHOD.

  METHOD flat_no_move.
    add( iv_value = 0 iv_score = 5 ).
    add( iv_value = 1 iv_score = 5 ).

    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 0
                                     iv_step      = 1
                                     iv_max_steps = 10 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 0 ).
  ENDMETHOD.

  METHOD max_steps_limits.
    add( iv_value = 0 iv_score = 0 ).
    add( iv_value = 1 iv_score = 2 ).
    add( iv_value = 2 iv_score = 5 ).

    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 0
                                     iv_step      = 1
                                     iv_max_steps = 1 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 2 ).
  ENDMETHOD.

  METHOD start_unknown.
    add( iv_value = 0 iv_score = 1 ).

    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 7
                                     iv_step      = 1
                                     iv_max_steps = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-reached exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 7 ).
  ENDMETHOD.

  METHOD step_zero_stops.
    add( iv_value = 0 iv_score = 1 ).
    add( iv_value = 1 iv_score = 9 ).

    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 0
                                     iv_step      = 0
                                     iv_max_steps = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 1 ).
  ENDMETHOD.

  METHOD empty_points.
    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 0
                                     iv_step      = 1
                                     iv_max_steps = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-reached exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 0 ).
  ENDMETHOD.

  METHOD no_downhill_move.
    add( iv_value = 0 iv_score = 10 ).
    add( iv_value = 1 iv_score = 1 ).
    add( iv_value = 2 iv_score = 20 ).

    DATA(ls_result) = mo_cut->climb( it_points    = mt_pt
                                     iv_start     = 2
                                     iv_step      = 1
                                     iv_max_steps = 5 ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-steps exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_value exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-best_score exp = 20 ).
  ENDMETHOD.

ENDCLASS.
