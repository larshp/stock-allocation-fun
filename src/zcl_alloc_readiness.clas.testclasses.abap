CLASS ltcl_alloc_readiness DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_readiness.
    DATA mt_ind TYPE zcl_alloc_health=>ty_indicator_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name    TYPE string
        iv_healthy TYPE abap_bool.

    METHODS no_checks_not_ready FOR TESTING.
    METHODS all_ok_ready       FOR TESTING.
    METHODS fails_require_all  FOR TESTING.
    METHODS partial_without_all FOR TESTING.
    METHODS none_healthy_no_all FOR TESTING.
    METHODS none_ready_without_all FOR TESTING.
    METHODS reports_counts     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_readiness IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_readiness( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_indicator TYPE zcl_alloc_health=>ty_indicator.

    ls_indicator-indicator = iv_name.
    ls_indicator-is_healthy = iv_healthy.
    APPEND ls_indicator TO mt_ind.
  ENDMETHOD.

  METHOD no_checks_not_ready.
    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-ready exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_probe-reason exp = 'no checks configured' ).
  ENDMETHOD.

  METHOD all_ok_ready.
    add( iv_name = 'DB' iv_healthy = abap_true ).
    add( iv_name = 'QUEUE' iv_healthy = abap_true ).

    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-ready exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_probe-reason exp = 'all checks passed' ).
  ENDMETHOD.

  METHOD fails_require_all.
    add( iv_name = 'DB' iv_healthy = abap_true ).
    add( iv_name = 'QUEUE' iv_healthy = abap_false ).

    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-ready exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_probe-reason exp = 'at least one check failed' ).
  ENDMETHOD.

  METHOD partial_without_all.
    add( iv_name = 'DB' iv_healthy = abap_true ).
    add( iv_name = 'QUEUE' iv_healthy = abap_false ).

    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-ready exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_probe-reason exp = 'at least one check passed' ).
  ENDMETHOD.

  METHOD none_healthy_no_all.
    add( iv_name = 'DB' iv_healthy = abap_false ).
    add( iv_name = 'QUEUE' iv_healthy = abap_false ).

    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-ready exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = ls_probe-reason exp = 'no check passed' ).
  ENDMETHOD.

  METHOD none_ready_without_all.
    add( iv_name = 'DB' iv_healthy = abap_false ).

    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_true ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-ready exp = abap_false ).
  ENDMETHOD.

  METHOD reports_counts.
    add( iv_name = 'A' iv_healthy = abap_true ).
    add( iv_name = 'B' iv_healthy = abap_true ).
    add( iv_name = 'C' iv_healthy = abap_false ).

    DATA(ls_probe) = mo_cut->probe( it_indicators  = mt_ind
                                    iv_require_all = abap_false ).

    cl_abap_unit_assert=>assert_equals( act = ls_probe-checks_run exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = ls_probe-checks_ok exp = 2 ).
  ENDMETHOD.

ENDCLASS.
