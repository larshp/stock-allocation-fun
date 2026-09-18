CLASS ltcl_alloc_drift DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drift.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_base         TYPE menge_d
        iv_cur          TYPE menge_d
        iv_tol          TYPE menge_d
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_drift=>ty_input.

    METHODS increase_is_drift FOR TESTING.
    METHODS decrease_is_drift FOR TESTING.
    METHODS within_tolerance  FOR TESTING.
    METHODS flat_no_drift     FOR TESTING.
    METHODS zero_baseline     FOR TESTING.
    METHODS both_zero         FOR TESTING.
    METHODS percent_rounding  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drift IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drift( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-baseline = iv_base.
    rs_input-current = iv_cur.
    rs_input-tolerance = iv_tol.
  ENDMETHOD.

  METHOD increase_is_drift.
    DATA(ls_input) = make_input( iv_base = 100 iv_cur = 120 iv_tol = 10 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-delta exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-direction exp = 'up' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-drift_pct exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-is_drift exp = abap_true ).
  ENDMETHOD.

  METHOD decrease_is_drift.
    DATA(ls_input) = make_input( iv_base = 100 iv_cur = 50 iv_tol = 0 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-delta exp = -50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-direction exp = 'down' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-drift_pct exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-is_drift exp = abap_true ).
  ENDMETHOD.

  METHOD within_tolerance.
    DATA(ls_input) = make_input( iv_base = 100 iv_cur = 95 iv_tol = 10 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-delta exp = -5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-drift_pct exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-is_drift exp = abap_false ).
  ENDMETHOD.

  METHOD flat_no_drift.
    DATA(ls_input) = make_input( iv_base = 100 iv_cur = 100 iv_tol = 0 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-delta exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-direction exp = 'flat' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-is_drift exp = abap_false ).
  ENDMETHOD.

  METHOD zero_baseline.
    DATA(ls_input) = make_input( iv_base = 0 iv_cur = 50 iv_tol = 0 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-drift_pct exp = 100 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-direction exp = 'up' ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-is_drift exp = abap_true ).
  ENDMETHOD.

  METHOD both_zero.
    DATA(ls_input) = make_input( iv_base = 0 iv_cur = 0 iv_tol = 0 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-drift_pct exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = ls_drift-is_drift exp = abap_false ).
  ENDMETHOD.

  METHOD percent_rounding.
    DATA(ls_input) = make_input( iv_base = 300 iv_cur = 310 iv_tol = 0 ).
    DATA(ls_drift) = mo_cut->detect( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_drift-drift_pct exp = 3 ).
  ENDMETHOD.

ENDCLASS.
