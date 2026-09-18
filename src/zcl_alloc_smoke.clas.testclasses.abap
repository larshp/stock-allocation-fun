CLASS ltcl_alloc_smoke DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_smoke.

    METHODS setup.

    METHODS empty_is_ok      FOR TESTING.
    METHODS all_pass_ok      FOR TESTING.
    METHODS one_failure      FOR TESTING.
    METHODS lists_failed     FOR TESTING.
    METHODS re_add_replaces  FOR TESTING.
    METHODS reset_clears     FOR TESTING.
    METHODS keeps_detail     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_smoke IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_smoke( ).
  ENDMETHOD.

  METHOD empty_is_ok.
    DATA(ls_summary) = mo_cut->run( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-ok exp = abap_true ).
  ENDMETHOD.

  METHOD all_pass_ok.
    mo_cut->add( iv_name = 'APPLOG' iv_passed = abap_true iv_detail = 'writable' ).
    mo_cut->add( iv_name = 'DB' iv_passed = abap_true iv_detail = 'reachable' ).

    DATA(ls_summary) = mo_cut->run( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-passed exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-failed exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-ok exp = abap_true ).
  ENDMETHOD.

  METHOD one_failure.
    mo_cut->add( iv_name = 'A' iv_passed = abap_true iv_detail = '' ).
    mo_cut->add( iv_name = 'B' iv_passed = abap_false iv_detail = 'timeout' ).

    DATA(ls_summary) = mo_cut->run( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-passed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-failed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-ok exp = abap_false ).
  ENDMETHOD.

  METHOD lists_failed.
    mo_cut->add( iv_name = 'A' iv_passed = abap_true iv_detail = '' ).
    mo_cut->add( iv_name = 'B' iv_passed = abap_false iv_detail = 'timeout' ).
    mo_cut->add( iv_name = 'C' iv_passed = abap_false iv_detail = 'denied' ).

    DATA(lt_failed) = mo_cut->failed( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_failed ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_failed[ 1 ]-check_name exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_failed[ 2 ]-check_name exp = 'C' ).
  ENDMETHOD.

  METHOD re_add_replaces.
    mo_cut->add( iv_name = 'A' iv_passed = abap_false iv_detail = 'first' ).
    mo_cut->add( iv_name = 'A' iv_passed = abap_true iv_detail = 'second' ).

    DATA(ls_summary) = mo_cut->run( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-passed exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_summary-ok exp = abap_true ).
  ENDMETHOD.

  METHOD reset_clears.
    mo_cut->add( iv_name = 'A' iv_passed = abap_false iv_detail = '' ).
    mo_cut->reset( ).

    DATA(ls_summary) = mo_cut->run( ).

    cl_abap_unit_assert=>assert_equals( act = ls_summary-total exp = 0 ).
  ENDMETHOD.

  METHOD keeps_detail.
    mo_cut->add( iv_name = 'A' iv_passed = abap_false iv_detail = 'connection refused' ).

    DATA(lt_failed) = mo_cut->failed( ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_failed[ 1 ]-detail exp = 'connection refused' ).
  ENDMETHOD.

ENDCLASS.
