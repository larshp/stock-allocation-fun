CLASS ltcl_priority DEFINITION FINAL FOR TESTING
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
        iv_req_date      TYPE d DEFAULT '20260101'
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS serves_everything_if_enough FOR TESTING.
    METHODS highest_priority_wins FOR TESTING.
    METHODS partial_confirmation FOR TESTING.
    METHODS earlier_date_wins_within_prio FOR TESTING.
    METHODS no_stock_confirms_nothing FOR TESTING.
    METHODS negative_stock_confirms_zero FOR TESTING.
    METHODS no_demand_gives_empty_result FOR TESTING.

ENDCLASS.


CLASS ltcl_priority IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_strategy_priority( ).
  ENDMETHOD.

  METHOD demand.
    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = 'MAT-1'
      werks     = '1000'
      quantity  = iv_quantity
      req_date  = iv_req_date
      priority  = iv_priority ).
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
        ( demand_id = 'D1' requested = '30' confirmed = '30' shortfall = 0 )
        ( demand_id = 'D2' requested = '20' confirmed = '20' shortfall = 0 ) ) ).

  ENDMETHOD.

  METHOD highest_priority_wins.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id = 'LOW'  iv_quantity = '10' iv_priority = '09' ) )
        ( demand( iv_id = 'HIGH' iv_quantity = '10' iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'HIGH' requested = '10' confirmed = '10' shortfall = 0 )
        ( demand_id = 'LOW'  requested = '10' confirmed = 0    shortfall = '10' ) ) ).

  ENDMETHOD.

  METHOD partial_confirmation.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '12'
      it_demand    = VALUE #(
        ( demand( iv_id = 'D1' iv_quantity = '10' iv_priority = '01' ) )
        ( demand( iv_id = 'D2' iv_quantity = '10' iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' requested = '10' confirmed = '10' shortfall = 0 )
        ( demand_id = 'D2' requested = '10' confirmed = '2'  shortfall = '8' ) ) ).

  ENDMETHOD.

  METHOD earlier_date_wins_within_prio.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '5'
      it_demand    = VALUE #(
        ( demand( iv_id = 'LATE'  iv_quantity = '5' iv_req_date = '20260210' ) )
        ( demand( iv_id = 'EARLY' iv_quantity = '5' iv_req_date = '20260115' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-demand_id
      exp = 'EARLY' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 2 ]-confirmed
      exp = 0 ).

  ENDMETHOD.

  METHOD no_stock_confirms_nothing.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = 0
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = '7' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' requested = '7' confirmed = 0 shortfall = '7' ) ) ).

  ENDMETHOD.

  METHOD negative_stock_confirms_zero.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '-4'
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = '7' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = 0
      msg = 'negative book stock must never confirm anything' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall
      exp = '7' ).

  ENDMETHOD.

  METHOD no_demand_gives_empty_result.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '100'
      it_demand    = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( lt_result ).

  ENDMETHOD.

ENDCLASS.
