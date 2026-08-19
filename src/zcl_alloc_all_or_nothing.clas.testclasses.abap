CLASS ltcl_all_or_nothing DEFINITION FINAL FOR TESTING
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
        iv_complete      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS complete_line_that_fits_wins FOR TESTING.
    METHODS a_part_is_as_good_as_none FOR TESTING.
    METHODS freed_stock_goes_to_the_next FOR TESTING.
    METHODS a_plain_line_still_gets_a_part FOR TESTING.
    METHODS every_line_is_answered_once FOR TESTING.
    METHODS several_lines_may_have_to_go FOR TESTING.
    METHODS lowest_priority_goes_first FOR TESTING.
    METHODS no_stock_is_not_a_dropped_line FOR TESTING.
    METHODS no_demand_gives_empty_result FOR TESTING.

ENDCLASS.


CLASS ltcl_all_or_nothing IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_all_or_nothing( NEW zcl_alloc_strategy_priority( ) ).
  ENDMETHOD.

  METHOD demand.
    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = 'MAT-1'
      werks     = '1000'
      quantity  = iv_quantity
      req_date  = '20260101'
      priority  = iv_priority
      complete  = iv_complete ).
  ENDMETHOD.

  METHOD complete_line_that_fits_wins.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_complete = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' req_date = '20260101' requested = '10' confirmed = '10' shortfall = 0 ) )
      msg = 'a complete delivery line that fits is served like any other' ).

  ENDMETHOD.

  METHOD a_part_is_as_good_as_none.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '6'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_complete = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'D1' ]-confirmed
      exp = 0
      msg = 'six of ten cannot ship, so confirming six only ties stock up' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'D1' ]-shortfall
      exp = '10'
      msg = 'the whole line is short, not the part that was not confirmed' ).

  ENDMETHOD.

  METHOD freed_stock_goes_to_the_next.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '6'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'FIRST'
                  iv_quantity = '10'
                  iv_priority = '01'
                  iv_complete = abap_true ) )
        ( demand( iv_id       = 'SECOND'
                  iv_quantity = '4'
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'SECOND' ]-confirmed
      exp = '4'
      msg = 'stock a complete delivery line cannot use is offered to the rest' ).

  ENDMETHOD.

  METHOD a_plain_line_still_gets_a_part.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '6'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'D1' ]-confirmed
      exp = '6'
      msg = 'an item that may ship in parts is still confirmed in part' ).

  ENDMETHOD.

  METHOD every_line_is_answered_once.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '6'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'DROPPED'
                  iv_quantity = '10'
                  iv_priority = '01'
                  iv_complete = abap_true ) )
        ( demand( iv_id       = 'SERVED'
                  iv_quantity = '4'
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result )
      exp = 2
      msg = 'the strategy contract is one allocation line per demand line' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( VALUE zif_allocation=>ty_allocation_tab(
        FOR ls_line IN lt_result WHERE ( demand_id = 'DROPPED' ) ( ls_line ) ) )
      exp = 1
      msg = 'a dropped line is answered once, not twice and not never' ).

  ENDMETHOD.

  METHOD several_lines_may_have_to_go.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = '5'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'BIG'
                  iv_quantity = '10'
                  iv_priority = '01'
                  iv_complete = abap_true ) )
        ( demand( iv_id       = 'MIDDLE'
                  iv_quantity = '8'
                  iv_priority = '02'
                  iv_complete = abap_true ) )
        ( demand( iv_id       = 'SMALL'
                  iv_quantity = '5'
                  iv_priority = '03' ) ) ) ).

    " BIG takes the stock and cannot use it, then MIDDLE takes it and cannot
    " use it either. Only the third pass has a line that can be served.
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'BIG' ]-confirmed
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'MIDDLE' ]-confirmed
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'SMALL' ]-confirmed
      exp = '5'
      msg = 'the stock ends up with the only line that can actually ship it' ).

  ENDMETHOD.

  METHOD lowest_priority_goes_first.

    " fair share leaves both lines equally short, so which one to drop is a
    " tie. The one the strategy served last is the one it favoured least.
    DATA(lo_cut) = NEW zcl_alloc_all_or_nothing( NEW zcl_alloc_strategy_fairshare( ) ).

    DATA(lt_result) = lo_cut->zif_allocation_strategy~allocate(
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'FIRST'
                  iv_quantity = '8'
                  iv_priority = '01'
                  iv_complete = abap_true ) )
        ( demand( iv_id       = 'SECOND'
                  iv_quantity = '8'
                  iv_priority = '02'
                  iv_complete = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'FIRST' ]-confirmed
      exp = '8'
      msg = 'the higher priority line keeps the stock' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'SECOND' ]-confirmed
      exp = 0 ).

  ENDMETHOD.

  METHOD no_stock_is_not_a_dropped_line.

    DATA(lt_result) = mo_cut->allocate(
      iv_available = 0
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = '10'
                  iv_complete = abap_true ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result
      exp = VALUE zif_allocation=>ty_allocation_tab(
        ( demand_id = 'D1' req_date = '20260101' requested = '10' confirmed = 0 shortfall = '10' ) )
      msg = 'a line that got nothing anyway needs no second pass' ).

  ENDMETHOD.

  METHOD no_demand_gives_empty_result.

    cl_abap_unit_assert=>assert_initial( mo_cut->allocate(
      iv_available = '100'
      it_demand    = VALUE #( ) ) ).

  ENDMETHOD.

ENDCLASS.
