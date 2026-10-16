CLASS ltcl_alloc_return_carrier DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_carrier.
    DATA mt_car TYPE zcl_alloc_return_carrier=>ty_carrier_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_carrier  TYPE string
        iv_capacity TYPE i
        iv_cost     TYPE i.

    METHODS picks_cheapest_fit FOR TESTING.
    METHODS no_fit            FOR TESTING.
    METHODS cheapest_overall  FOR TESTING.
    METHODS fit_rule          FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_carrier IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_carrier( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_carrier TYPE zcl_alloc_return_carrier=>ty_carrier.

    ls_carrier-carrier = iv_carrier.
    ls_carrier-capacity = iv_capacity.
    ls_carrier-cost = iv_cost.
    APPEND ls_carrier TO mt_car.
  ENDMETHOD.

  METHOD picks_cheapest_fit.
    add( iv_carrier = 'C1' iv_capacity = 5 iv_cost = 20 ).
    add( iv_carrier = 'C2' iv_capacity = 10 iv_cost = 30 ).
    add( iv_carrier = 'C3' iv_capacity = 2 iv_cost = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_carriers = mt_car iv_quantity = 4 )
      exp = 'C1' ).
  ENDMETHOD.

  METHOD no_fit.
    add( iv_carrier = 'C1' iv_capacity = 5 iv_cost = 20 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->select( it_carriers = mt_car iv_quantity = 12 )
      exp = '' ).
  ENDMETHOD.

  METHOD cheapest_overall.
    add( iv_carrier = 'C1' iv_capacity = 5 iv_cost = 20 ).
    add( iv_carrier = 'C3' iv_capacity = 2 iv_cost = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cheapest( mt_car ) exp = 'C3' ).
  ENDMETHOD.

  METHOD fit_rule.
    DATA ls_carrier TYPE zcl_alloc_return_carrier=>ty_carrier.

    ls_carrier-carrier = 'C1'.
    ls_carrier-capacity = 5.
    ls_carrier-cost = 20.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( is_carrier = ls_carrier iv_quantity = 4 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( is_carrier = ls_carrier iv_quantity = 6 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fits( is_carrier = ls_carrier iv_quantity = 0 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
