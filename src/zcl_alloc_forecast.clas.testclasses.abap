CLASS ltcl_alloc_forecast DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_forecast.

    METHODS setup.

    METHODS add
      IMPORTING
        it_qty        TYPE zcl_alloc_forecast=>ty_qty_tt
        iv_quantity   TYPE menge_d
      RETURNING
        VALUE(rt_qty) TYPE zcl_alloc_forecast=>ty_qty_tt.

    METHODS empty_returns_zero FOR TESTING.
    METHODS last_two_average   FOR TESTING.
    METHODS window_one_is_last FOR TESTING.
    METHODS window_above_series FOR TESTING.
    METHODS window_zero_is_one FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_forecast IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_forecast( ).
  ENDMETHOD.

  METHOD add.
    rt_qty = it_qty.
    APPEND iv_quantity TO rt_qty.
  ENDMETHOD.

  METHOD empty_returns_zero.
    DATA lt_qty TYPE zcl_alloc_forecast=>ty_qty_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_quantity( lt_qty ) exp = '0' ).
  ENDMETHOD.

  METHOD last_two_average.
    DATA lt_qty TYPE zcl_alloc_forecast=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '30' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_quantity( it_quantities = lt_qty
                                   iv_window     = 2 )
      exp = '25' ).
  ENDMETHOD.

  METHOD window_one_is_last.
    DATA lt_qty TYPE zcl_alloc_forecast=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_quantity( it_quantities = lt_qty
                                   iv_window     = 1 )
      exp = '20' ).
  ENDMETHOD.

  METHOD window_above_series.
    DATA lt_qty TYPE zcl_alloc_forecast=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_quantity( it_quantities = lt_qty
                                   iv_window     = 5 )
      exp = '15' ).
  ENDMETHOD.

  METHOD window_zero_is_one.
    DATA lt_qty TYPE zcl_alloc_forecast=>ty_qty_tt.

    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '10' ).
    lt_qty = add( it_qty      = lt_qty
                  iv_quantity = '20' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->next_quantity( it_quantities = lt_qty
                                   iv_window     = 0 )
      exp = '20' ).
  ENDMETHOD.

ENDCLASS.
