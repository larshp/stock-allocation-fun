CLASS ltcl_alloc_breakeven DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_breakeven.

    METHODS setup.

    METHODS make_input
      IMPORTING
        iv_fixed        TYPE menge_d
        iv_price        TYPE menge_d
        iv_cost         TYPE menge_d
        iv_max          TYPE i
      RETURNING
        VALUE(rs_input) TYPE zcl_alloc_breakeven=>ty_input.

    METHODS exact_units     FOR TESTING.
    METHODS rounds_up_units FOR TESTING.
    METHODS no_margin       FOR TESTING.
    METHODS zero_fixed_cost FOR TESTING.
    METHODS max_units_low   FOR TESTING.
    METHODS margin_reported FOR TESTING.
    METHODS loss_per_unit   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_breakeven IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_breakeven( ).
  ENDMETHOD.

  METHOD make_input.
    rs_input-fixed_cost = iv_fixed.
    rs_input-unit_price = iv_price.
    rs_input-unit_cost = iv_cost.
    rs_input-max_units = iv_max.
  ENDMETHOD.

  METHOD exact_units.
    DATA(ls_input) = make_input( iv_fixed = 1000 iv_price = 10
                                 iv_cost = 6 iv_max = 0 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-break_even_units exp = 250 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_true ).
  ENDMETHOD.

  METHOD rounds_up_units.
    DATA(ls_input) = make_input( iv_fixed = 1000 iv_price = 10
                                 iv_cost = 7 iv_max = 0 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-break_even_units exp = 334 ).
  ENDMETHOD.

  METHOD no_margin.
    DATA(ls_input) = make_input( iv_fixed = 1000 iv_price = 5
                                 iv_cost = 5 iv_max = 0 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-break_even_units exp = 0 ).
  ENDMETHOD.

  METHOD zero_fixed_cost.
    DATA(ls_input) = make_input( iv_fixed = 0 iv_price = 10
                                 iv_cost = 6 iv_max = 0 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-break_even_units exp = 0 ).
  ENDMETHOD.

  METHOD max_units_low.
    DATA(ls_input) = make_input( iv_fixed = 1000 iv_price = 10
                                 iv_cost = 6 iv_max = 100 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-break_even_units exp = 250 ).
  ENDMETHOD.

  METHOD margin_reported.
    DATA(ls_input) = make_input( iv_fixed = 1000 iv_price = 12
                                 iv_cost = 4 iv_max = 0 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-margin_per_unit exp = 8 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-break_even_units exp = 125 ).
  ENDMETHOD.

  METHOD loss_per_unit.
    DATA(ls_input) = make_input( iv_fixed = 100 iv_price = 3
                                 iv_cost = 9 iv_max = 0 ).
    DATA(ls_result) = mo_cut->solve( ls_input ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-margin_per_unit exp = -6 ).
    cl_abap_unit_assert=>assert_equals( act = ls_result-found exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
