CLASS ltcl_alloc_rate_limit DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rate_limit.

    METHODS setup.

    METHODS allows_within_limit    FOR TESTING.
    METHODS rejects_over_limit     FOR TESTING.
    METHODS exhausts_exactly       FOR TESTING.
    METHODS reset_restores_budget  FOR TESTING.
    METHODS zero_units_allowed     FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_rate_limit IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rate_limit( iv_limit = 10 ).
  ENDMETHOD.

  METHOD allows_within_limit.
    DATA lv_allowed TYPE abap_bool.

    lv_allowed = mo_cut->consume( 4 ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 6 ).
  ENDMETHOD.

  METHOD rejects_over_limit.
    DATA lv_allowed TYPE abap_bool.

    lv_allowed = mo_cut->consume( 4 ).
    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_true ).

    lv_allowed = mo_cut->consume( 7 ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 6 ).
  ENDMETHOD.

  METHOD exhausts_exactly.
    DATA lv_allowed TYPE abap_bool.

    lv_allowed = mo_cut->consume( 10 ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 0 ).

    lv_allowed = mo_cut->consume( 1 ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_false ).
  ENDMETHOD.

  METHOD reset_restores_budget.
    DATA lv_allowed TYPE abap_bool.

    lv_allowed = mo_cut->consume( 10 ).
    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_true ).

    mo_cut->reset( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 10 ).
  ENDMETHOD.

  METHOD zero_units_allowed.
    DATA lv_allowed TYPE abap_bool.

    lv_allowed = mo_cut->consume( 0 ).

    cl_abap_unit_assert=>assert_equals( act = lv_allowed exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 10 ).
  ENDMETHOD.

ENDCLASS.
