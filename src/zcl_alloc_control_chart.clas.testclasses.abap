CLASS ltcl_alloc_control_chart DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_control_chart.
    DATA mt_ser TYPE zcl_alloc_control_chart=>ty_series_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_value TYPE menge_d.

    METHODS empty_series FOR TESTING.
    METHODS steady_chart FOR TESTING.
    METHODS limits_steady  FOR TESTING.
    METHODS flags_spike    FOR TESTING.
    METHODS flags_low      FOR TESTING.
    METHODS single_point   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_control_chart IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_control_chart( ).
  ENDMETHOD.

  METHOD add.
    APPEND iv_value TO mt_ser.
  ENDMETHOD.

  METHOD empty_series.
    DATA(ls_result) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-centre exp = 0 ).
  ENDMETHOD.

  METHOD steady_chart.
    add( iv_value = 10 ).
    add( iv_value = 12 ).
    add( iv_value = 14 ).

    DATA(ls_result) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-points exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-centre exp = 12 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-avg_mr exp = 2 ).
  ENDMETHOD.

  METHOD limits_steady.
    add( iv_value = 10 ).
    add( iv_value = 12 ).
    add( iv_value = 14 ).

    DATA(ls_result) = mo_cut->build( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-ucl exp = 17 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-lcl exp = 7 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-mr_ucl exp = 6 ).

    DATA(lt_hits) = mo_cut->out_of_control( it_values = mt_ser
                                            is_result = ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
  ENDMETHOD.

  METHOD flags_spike.
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 10 ).
    add( iv_value = 100 ).

    DATA(ls_result) = mo_cut->build( mt_ser ).
    DATA(lt_hits) = mo_cut->out_of_control( it_values = mt_ser
                                            is_result = ls_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-centre exp = 28 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-ucl exp = 86 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-rank exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-above exp = abap_true ).
  ENDMETHOD.

  METHOD flags_low.
    add( iv_value = 100 ).
    add( iv_value = 100 ).
    add( iv_value = 100 ).
    add( iv_value = 100 ).
    add( iv_value = 10 ).

    DATA(ls_result) = mo_cut->build( mt_ser ).
    DATA(lt_hits) = mo_cut->out_of_control( it_values = mt_ser
                                            is_result = ls_result ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_hits[ 1 ]-above exp = abap_false ).
  ENDMETHOD.

  METHOD single_point.
    add( iv_value = 42 ).

    DATA(ls_result) = mo_cut->build( mt_ser ).
    DATA(lt_hits) = mo_cut->out_of_control( it_values = mt_ser
                                            is_result = ls_result ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-centre exp = 42 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-avg_mr exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-ucl exp = 42 ).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_hits ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
