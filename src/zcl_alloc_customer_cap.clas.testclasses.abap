CLASS ltcl_customer_cap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_big   TYPE vbak-kunnr VALUE '0000010001'.
    CONSTANTS c_small TYPE vbak-kunnr VALUE '0000010002'.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_customer      TYPE vbak-kunnr OPTIONAL
        iv_priority      TYPE zif_allocation=>ty_priority DEFAULT '01'
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS allocate
      IMPORTING
        iv_percent           TYPE i
        it_demand            TYPE zif_allocation=>ty_demand_tab
        iv_available         TYPE zif_allocation=>ty_quantity DEFAULT '100'
      RETURNING
        VALUE(rt_allocation) TYPE zif_allocation=>ty_allocation_tab.

    METHODS one_customer_is_held_back FOR TESTING.
    METHODS the_rest_is_still_there FOR TESTING.
    METHODS a_customer_under_it_is_left FOR TESTING.
    METHODS no_cap_changes_nothing FOR TESTING.
    METHODS the_answer_is_the_real_demand FOR TESTING.
    METHODS lines_of_a_customer_add_up FOR TESTING.
    METHODS urgent_line_is_cut_back_last FOR TESTING.
    METHODS no_customer_is_no_share FOR TESTING.
    METHODS a_share_is_never_rounded_up FOR TESTING.

ENDCLASS.


CLASS ltcl_customer_cap IMPLEMENTATION.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = 'MAT-1'
      werks     = '1000'
      quantity  = iv_quantity
      req_date  = '20260101'
      priority  = iv_priority
      customer  = iv_customer ).

  ENDMETHOD.

  METHOD allocate.

    DATA(lo_cut) = NEW zcl_alloc_customer_cap(
      io_strategy = NEW zcl_alloc_strategy_priority( )
      iv_percent  = iv_percent ).

    rt_allocation = lo_cut->zif_allocation_strategy~allocate(
      iv_available = iv_available
      it_demand    = it_demand ).

  ENDMETHOD.

  METHOD one_customer_is_held_back.

    DATA(lt_result) = allocate(
      iv_percent = 40
      it_demand  = VALUE #(
        ( demand( iv_id       = 'BIG'
                  iv_quantity = '100'
                  iv_customer = c_big ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'BIG' ]-confirmed
      exp = '40'
      msg = 'a single order must not be able to take the whole pool' ).

  ENDMETHOD.

  METHOD the_rest_is_still_there.

    DATA(lt_result) = allocate(
      iv_percent = 40
      it_demand  = VALUE #(
        ( demand( iv_id       = 'BIG'
                  iv_quantity = '100'
                  iv_customer = c_big
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'SMALL'
                  iv_quantity = '30'
                  iv_customer = c_small
                  iv_priority = '09' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'SMALL' ]-confirmed
      exp = '30'
      msg = 'what the cap holds back is there for the others to be served from' ).

  ENDMETHOD.

  METHOD a_customer_under_it_is_left.

    DATA(lt_result) = allocate(
      iv_percent = 40
      it_demand  = VALUE #(
        ( demand( iv_id       = 'MODEST'
                  iv_quantity = '5'
                  iv_customer = c_small ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'MODEST' ]-confirmed
      exp = '5'
      msg = 'a customer asking for less than its share is not touched' ).

  ENDMETHOD.

  METHOD no_cap_changes_nothing.

    DATA(lt_result) = allocate(
      iv_percent = zcl_alloc_customer_cap=>c_no_cap
      it_demand  = VALUE #(
        ( demand( iv_id       = 'BIG'
                  iv_quantity = '100'
                  iv_customer = c_big ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'BIG' ]-confirmed
      exp = '100'
      msg = 'a plant that has not asked for a cap does not get one' ).

  ENDMETHOD.

  METHOD the_answer_is_the_real_demand.

    DATA(lt_result) = allocate(
      iv_percent = 40
      it_demand  = VALUE #(
        ( demand( iv_id       = 'BIG'
                  iv_quantity = '100'
                  iv_customer = c_big ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'BIG' ]-requested
      exp = '100'
      msg = 'the order asked for a hundred, whatever the cap allowed' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'BIG' ]-shortfall
      exp = '60'
      msg = 'and the part it did not get is short, cap or no stock' ).

  ENDMETHOD.

  METHOD lines_of_a_customer_add_up.

    " one customer on three lines still gets one share between them
    DATA(lt_result) = allocate(
      iv_percent = 30
      it_demand  = VALUE #(
        ( demand( iv_id       = 'L1'
                  iv_quantity = '40'
                  iv_customer = c_big ) )
        ( demand( iv_id       = 'L2'
                  iv_quantity = '40'
                  iv_customer = c_big ) )
        ( demand( iv_id       = 'L3'
                  iv_quantity = '40'
                  iv_customer = c_big ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'L1' ]-confirmed
        + lt_result[ demand_id = 'L2' ]-confirmed
        + lt_result[ demand_id = 'L3' ]-confirmed
      exp = '30'
      msg = 'the cap is per customer, not per line' ).

  ENDMETHOD.

  METHOD urgent_line_is_cut_back_last.

    DATA(lt_result) = allocate(
      iv_percent = 50
      it_demand  = VALUE #(
        ( demand( iv_id       = 'URGENT'
                  iv_quantity = '50'
                  iv_customer = c_big
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'LATER'
                  iv_quantity = '50'
                  iv_customer = c_big
                  iv_priority = '09' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'URGENT' ]-confirmed
      exp = '50'
      msg = 'what a customer loses to its own cap is its least urgent line' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'LATER' ]-confirmed
      exp = 0 ).

  ENDMETHOD.

  METHOD a_share_is_never_rounded_up.

    " a third of ten is not a whole thousandth, and a share must not come out
    " above what it is a share of
    DATA(lt_result) = allocate(
      iv_percent   = 33
      iv_available = '10'
      it_demand    = VALUE #(
        ( demand( iv_id       = 'BIG'
                  iv_quantity = '10'
                  iv_customer = c_big ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'BIG' ]-confirmed
      exp = '3.3'
      msg = 'the share is truncated to whole thousandths, never rounded up' ).

  ENDMETHOD.

  METHOD no_customer_is_no_share.

    " two transfers, neither of which belongs to a customer: they must not be
    " lumped together into one share
    DATA(lt_result) = allocate(
      iv_percent = 40
      it_demand  = VALUE #(
        ( demand( iv_id       = 'PTRANSFER1'
                  iv_quantity = '50' ) )
        ( demand( iv_id       = 'PTRANSFER2'
                  iv_quantity = '50' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ demand_id = 'PTRANSFER1' ]-confirmed
        + lt_result[ demand_id = 'PTRANSFER2' ]-confirmed
      exp = '100'
      msg = 'a requirement with no customer is not part of a customer share' ).

  ENDMETHOD.

ENDCLASS.
