CLASS ltcl_fairshare DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zif_allocation_strategy.

    METHODS setup.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_priority      TYPE zif_allocation=>ty_priority DEFAULT '01'
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS total_confirmed
      IMPORTING
        it_allocation   TYPE zif_allocation=>ty_allocation_tab
      RETURNING
        VALUE(rv_total) TYPE zif_allocation=>ty_quantity.

    METHODS serves_everything_if_enough FOR TESTING.
    METHODS splits_in_equal_proportions FOR TESTING.
    METHODS splits_by_requested_share FOR TESTING.
    METHODS rounding_never_overallocates FOR TESTING.
    METHODS never_confirms_more_than_asked FOR TESTING.
    METHODS no_stock_confirms_nothing FOR TESTING.
    METHODS zero_demand_confirms_nothing FOR TESTING.
    METHODS negative_demand_is_no_demand FOR TESTING.

ENDCLASS.


CLASS ltcl_fairshare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_strategy_fairshare( ).
  ENDMETHOD.

  METHOD demand.
    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = 'MAT-1'
      werks     = '1000'
      quantity  = iv_quantity
      req_date  = '20260101'
      priority  = iv_priority ).
  ENDMETHOD.

  METHOD total_confirmed.
    rv_total = REDUCE zif_allocation=>ty_quantity(
      INIT lv_sum = CONV zif_allocation=>ty_quantity( 0 )
      FOR ls_line IN it_allocation
      NEXT lv_sum = lv_sum + ls_line-confirmed ).
  ENDMETHOD.

  METHOD serves_everything_if_enough.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '100'
      it_demand    = VALUE #(
        ( demand( iv_id = 'D1' iv_quantity = '30' ) )
        ( demand( iv_id = 'D2' iv_quantity = '20' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' req_date = '20260101' requested = '30' confirmed = '30' shortfall = 0 )
        ( demand_id = 'D2' req_date = '20260101' requested = '20' confirmed = '20' shortfall = 0 ) ) ).

  ENDMETHOD.

  METHOD splits_by_requested_share.

    " 10 available against 5 + 15 requested, so a quarter and three quarters
    DATA(lt_result) = mo_cut->allocate(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id = 'SMALL' iv_quantity = '5' ) )
        ( demand( iv_id = 'LARGE' iv_quantity = '15' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'LARGE' req_date = '20260101' requested = '15' confirmed = '7.5' shortfall = '7.5' )
        ( demand_id = 'SMALL' req_date = '20260101' requested = '5'  confirmed = '2.5' shortfall = '2.5' ) ) ).

  ENDMETHOD.

  METHOD splits_in_equal_proportions.

    " 10 available against three lines of 10 does not divide evenly; the
    " leftover thousandth goes to the line that sorts last
    DATA(lt_result) = mo_cut->allocate(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id = 'A' iv_quantity = '10' ) )
        ( demand( iv_id = 'B' iv_quantity = '10' ) )
        ( demand( iv_id = 'C' iv_quantity = '10' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'A' req_date = '20260101' requested = '10' confirmed = '3.333' shortfall = '6.667' )
        ( demand_id = 'B' req_date = '20260101' requested = '10' confirmed = '3.333' shortfall = '6.667' )
        ( demand_id = 'C' req_date = '20260101' requested = '10' confirmed = '3.334' shortfall = '6.666' ) ) ).

  ENDMETHOD.

  METHOD rounding_never_overallocates.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '1'
      it_demand    = VALUE #(
        ( demand( iv_id = 'A' iv_quantity = '1' ) )
        ( demand( iv_id = 'B' iv_quantity = '1' ) )
        ( demand( iv_id = 'C' iv_quantity = '1' ) )
        ( demand( iv_id = 'D' iv_quantity = '1' ) )
        ( demand( iv_id = 'E' iv_quantity = '1' ) )
        ( demand( iv_id = 'F' iv_quantity = '1' ) )
        ( demand( iv_id = 'G' iv_quantity = '1' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total_confirmed( lt_result )
      exp = '1'
      msg = 'the confirmed quantities must add up to exactly what was available' ).

  ENDMETHOD.

  METHOD never_confirms_more_than_asked.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '100'
      it_demand    = VALUE #(
        ( demand( iv_id = 'A' iv_quantity = '1' ) )
        ( demand( iv_id = 'B' iv_quantity = '2' ) ) ) ).

    LOOP AT lt_result INTO DATA(ls_line).
      cl_abap_unit_assert=>assert_equals(
        act = ls_line-confirmed
        exp = ls_line-requested ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      act = total_confirmed( lt_result )
      exp = '3'
      msg = 'surplus stock must not be handed out' ).

  ENDMETHOD.

  METHOD no_stock_confirms_nothing.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = 0
      it_demand    = VALUE #( ( demand( iv_id = 'A' iv_quantity = '7' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'A' req_date = '20260101' requested = '7' confirmed = 0 shortfall = '7' ) ) ).

  ENDMETHOD.

  METHOD zero_demand_confirms_nothing.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '10'
      it_demand    = VALUE #( ( demand( iv_id = 'A' iv_quantity = 0 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'A' req_date = '20260101' requested = 0 confirmed = 0 shortfall = 0 ) ) ).

  ENDMETHOD.

  METHOD negative_demand_is_no_demand.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '6'
      it_demand    = VALUE #(
        ( demand( iv_id = 'CREDIT' iv_quantity = '-3' ) )
        ( demand( iv_id = 'NORMAL' iv_quantity = '12' iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'CREDIT' ]-confirmed
      exp = 0
      msg = 'a negative requirement must not confirm anything' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'CREDIT' ]-shortfall
      exp = 0
      msg = 'shortfall must never be negative' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'NORMAL' ]-confirmed
      exp = '6'
      msg = 'a negative requirement must not dilute the share of the others' ).

  ENDMETHOD.

ENDCLASS.
