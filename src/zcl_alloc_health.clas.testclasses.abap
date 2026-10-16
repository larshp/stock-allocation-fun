CLASS ltcl_alloc_health DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_health.
    DATA mt_ind TYPE zcl_alloc_health=>ty_indicator_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name    TYPE string
        iv_healthy TYPE abap_bool.

    METHODS no_indicators_unknown FOR TESTING.
    METHODS all_healthy_up         FOR TESTING.
    METHODS mixed_is_degraded      FOR TESTING.
    METHODS all_unhealthy_down     FOR TESTING.
    METHODS counts_indicators      FOR TESTING.
    METHODS lists_unhealthy_names  FOR TESTING.
    METHODS empty_names            FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_health IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_health( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_indicator TYPE zcl_alloc_health=>ty_indicator.

    ls_indicator-indicator = iv_name.
    ls_indicator-is_healthy = iv_healthy.
    APPEND ls_indicator TO mt_ind.
  ENDMETHOD.

  METHOD no_indicators_unknown.
    DATA(ls_report) = mo_cut->check( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-total exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-status exp = 'unknown' ).
  ENDMETHOD.

  METHOD all_healthy_up.
    add( iv_name = 'DB' iv_healthy = abap_true ).
    add( iv_name = 'QUEUE' iv_healthy = abap_true ).

    DATA(ls_report) = mo_cut->check( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-healthy exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-unhealthy exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-status exp = 'up' ).
  ENDMETHOD.

  METHOD mixed_is_degraded.
    add( iv_name = 'DB' iv_healthy = abap_true ).
    add( iv_name = 'QUEUE' iv_healthy = abap_false ).

    DATA(ls_report) = mo_cut->check( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-status exp = 'degraded' ).
  ENDMETHOD.

  METHOD all_unhealthy_down.
    add( iv_name = 'DB' iv_healthy = abap_false ).
    add( iv_name = 'QUEUE' iv_healthy = abap_false ).

    DATA(ls_report) = mo_cut->check( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-healthy exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-status exp = 'down' ).
  ENDMETHOD.

  METHOD counts_indicators.
    add( iv_name = 'A' iv_healthy = abap_true ).
    add( iv_name = 'B' iv_healthy = abap_true ).
    add( iv_name = 'C' iv_healthy = abap_false ).

    DATA(ls_report) = mo_cut->check( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = ls_report-total exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-healthy exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_report-unhealthy exp = 1 ).
  ENDMETHOD.

  METHOD lists_unhealthy_names.
    add( iv_name = 'A' iv_healthy = abap_true ).
    add( iv_name = 'B' iv_healthy = abap_false ).
    add( iv_name = 'C' iv_healthy = abap_false ).

    DATA(lt_names) = mo_cut->unhealthy_names( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_names ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_names[ 1 ] exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_names[ 2 ] exp = 'C' ).
  ENDMETHOD.

  METHOD empty_names.
    DATA(lt_names) = mo_cut->unhealthy_names( mt_ind ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_names ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
