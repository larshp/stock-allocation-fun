CLASS ltcl_alloc_delivery_win DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_delivery_win.

    METHODS setup.

    METHODS inside_window  FOR TESTING.
    METHODS at_lower_edge  FOR TESTING.
    METHODS at_upper_edge  FOR TESTING.
    METHODS early_read     FOR TESTING.
    METHODS late_read      FOR TESTING.
    METHODS bad_window     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_delivery_win IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_delivery_win( ).
  ENDMETHOD.

  METHOD inside_window.
    DATA ls_res TYPE zcl_alloc_delivery_win=>ty_result.

    ls_res = mo_cut->check( iv_arrival = 100 iv_window_from = 90
                            iv_window_to = 120 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'IN' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_res-in_window exp = abap_true ).
  ENDMETHOD.

  METHOD at_lower_edge.
    DATA ls_res TYPE zcl_alloc_delivery_win=>ty_result.

    ls_res = mo_cut->check( iv_arrival = 90 iv_window_from = 90
                            iv_window_to = 120 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'IN' ).
  ENDMETHOD.

  METHOD at_upper_edge.
    DATA ls_res TYPE zcl_alloc_delivery_win=>ty_result.

    ls_res = mo_cut->check( iv_arrival = 120 iv_window_from = 90
                            iv_window_to = 120 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'IN' ).
  ENDMETHOD.

  METHOD early_read.
    DATA ls_res TYPE zcl_alloc_delivery_win=>ty_result.

    ls_res = mo_cut->check( iv_arrival = 80 iv_window_from = 90
                            iv_window_to = 120 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'EARLY' ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-deviation exp = 10 ).
  ENDMETHOD.

  METHOD late_read.
    DATA ls_res TYPE zcl_alloc_delivery_win=>ty_result.

    ls_res = mo_cut->check( iv_arrival = 150 iv_window_from = 90
                            iv_window_to = 120 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = 'LATE' ).
    cl_abap_unit_assert=>assert_equals( act = ls_res-deviation exp = 30 ).
  ENDMETHOD.

  METHOD bad_window.
    DATA ls_res TYPE zcl_alloc_delivery_win=>ty_result.

    ls_res = mo_cut->check( iv_arrival = 100 iv_window_from = 120
                            iv_window_to = 90 ).

    cl_abap_unit_assert=>assert_equals( act = ls_res-status exp = '' ).
  ENDMETHOD.

ENDCLASS.
