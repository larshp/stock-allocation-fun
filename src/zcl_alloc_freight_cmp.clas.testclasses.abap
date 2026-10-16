CLASS ltcl_alloc_freight_cmp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_freight_cmp.
    DATA mt_quo TYPE zcl_alloc_freight_cmp=>ty_quote_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_carrier TYPE string
        iv_cost    TYPE i.

    METHODS finds_cheapest  FOR TESTING.
    METHODS first_wins_tie  FOR TESTING.
    METHODS savings_spread  FOR TESTING.
    METHODS savings_one     FOR TESTING.
    METHODS empty_list      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_freight_cmp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_freight_cmp( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_quote TYPE zcl_alloc_freight_cmp=>ty_quote.

    ls_quote-carrier = iv_carrier.
    ls_quote-cost_cents = iv_cost.
    APPEND ls_quote TO mt_quo.
  ENDMETHOD.

  METHOD finds_cheapest.
    add( iv_carrier = 'A' iv_cost = 900 ).
    add( iv_carrier = 'B' iv_cost = 700 ).
    add( iv_carrier = 'C' iv_cost = 800 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheapest( mt_quo ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheapest_cost( mt_quo ) exp = 700 ).
  ENDMETHOD.

  METHOD first_wins_tie.
    add( iv_carrier = 'A' iv_cost = 700 ).
    add( iv_carrier = 'B' iv_cost = 700 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheapest( mt_quo ) exp = 'A' ).
  ENDMETHOD.

  METHOD savings_spread.
    add( iv_carrier = 'A' iv_cost = 900 ).
    add( iv_carrier = 'B' iv_cost = 700 ).
    add( iv_carrier = 'C' iv_cost = 850 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->savings( mt_quo ) exp = 200 ).
  ENDMETHOD.

  METHOD savings_one.
    add( iv_carrier = 'A' iv_cost = 900 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->savings( mt_quo ) exp = 0 ).
  ENDMETHOD.

  METHOD empty_list.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheapest( mt_quo ) exp = '' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->savings( mt_quo ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
