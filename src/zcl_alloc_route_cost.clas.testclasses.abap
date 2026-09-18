CLASS ltcl_alloc_route_cost DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_route_cost.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_distance     TYPE i
        iv_rate         TYPE menge_d
        iv_stops        TYPE i
        iv_fixed        TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_route_cost=>ty_input.

    METHODS distance_only   FOR TESTING.
    METHODS stops_only      FOR TESTING.
    METHODS combines_both   FOR TESTING.
    METHODS zero_distance   FOR TESTING.
    METHODS negative_ignored FOR TESTING.
    METHODS no_lines        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_route_cost IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_route_cost( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-distance = iv_distance.
    rs_input-cost_per_km = iv_rate.
    rs_input-stop_count = iv_stops.
    rs_input-fixed_per_stop = iv_fixed.
  ENDMETHOD.

  METHOD distance_only.
    DATA(ls_input) = make_input( iv_distance = 100 iv_rate = '0.5'
                                 iv_stops = 0 iv_fixed = 0 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-distance_cost exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-stop_cost exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 50 ).
  ENDMETHOD.

  METHOD stops_only.
    DATA(ls_input) = make_input( iv_distance = 0 iv_rate = 0
                                 iv_stops = 3 iv_fixed = 10 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-distance_cost exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-stop_cost exp = 30 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 30 ).
  ENDMETHOD.

  METHOD combines_both.
    DATA(ls_input) = make_input( iv_distance = 100 iv_rate = '0.5'
                                 iv_stops = 3 iv_fixed = 10 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 80 ).
  ENDMETHOD.

  METHOD zero_distance.
    DATA(ls_input) = make_input( iv_distance = 0 iv_rate = '2.0'
                                 iv_stops = 0 iv_fixed = 0 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
  ENDMETHOD.

  METHOD negative_ignored.
    DATA(ls_input) = make_input( iv_distance = -50 iv_rate = '1.0'
                                 iv_stops = -2 iv_fixed = 5 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-distance_cost exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-stop_cost exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
  ENDMETHOD.

  METHOD no_lines.
    DATA(ls_input) = make_input( iv_distance = 10 iv_rate = 0
                                 iv_stops = 2 iv_fixed = 0 ).
    DATA(ls_result) = mo_cut->estimate( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-total_cost exp = 0 ).
  ENDMETHOD.

ENDCLASS.
