CLASS ltcl_alloc_quota DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'QTA-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9701'.
    CONSTANTS c_big   TYPE vbak-kunnr VALUE 'CUST-BIG'.
    CONSTANTS c_small TYPE vbak-kunnr VALUE 'CUST-SML'.

    CONSTANTS c_january TYPE d VALUE '20260101'.
    CONSTANTS c_jan_end TYPE d VALUE '20260131'.
    CONSTANTS c_february TYPE d VALUE '20260201'.
    CONSTANTS c_feb_end TYPE d VALUE '20260228'.

    DATA mo_cut TYPE REF TO zif_allocation_strategy.

    METHODS setup.
    METHODS teardown.

    METHODS given_quota
      IMPORTING
        iv_quantity TYPE zif_allocation=>ty_quantity
        iv_kunnr    TYPE zstock_alloc_qta-kunnr DEFAULT c_big
        iv_from     TYPE d DEFAULT c_january
        iv_to       TYPE d DEFAULT c_jan_end.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_kunnr         TYPE vbak-kunnr DEFAULT c_big
        iv_date          TYPE d DEFAULT c_january
        iv_priority      TYPE zif_allocation=>ty_priority DEFAULT '10'
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS confirmed_of
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_id              TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS no_quota_changes_nothing FOR TESTING.
    METHODS a_quota_cuts_the_customer FOR TESTING.
    METHODS the_rest_is_left_for_others FOR TESTING.
    METHODS the_urgent_line_is_kept FOR TESTING.
    METHODS a_period_stands_on_its_own FOR TESTING.
    METHODS outside_every_period_is_free FOR TESTING.
    METHODS a_transfer_has_no_quota FOR TESTING.
    METHODS the_house_quota_applies FOR TESTING.
    METHODS an_own_quota_beats_the_house FOR TESTING.
    METHODS the_line_says_it_was_the_quota FOR TESTING.
    METHODS what_was_asked_for_is_kept FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_quota IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_quota( NEW zcl_alloc_strategy_priority( ) ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_qta WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_quota.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_qta WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt     = sy-mandt
        werks     = c_werks
        matnr     = c_matnr
        kunnr     = iv_kunnr
        date_from = iv_from
        date_to   = iv_to
        quantity  = iv_quantity ) ).

    INSERT zstock_alloc_qta FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = iv_date
      priority  = iv_priority
      customer  = iv_kunnr ).

  ENDMETHOD.

  METHOD confirmed_of.

    READ TABLE it_allocation INTO DATA(ls_line)
      WITH KEY demand_id = iv_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_line-confirmed.

  ENDMETHOD.

  METHOD no_quota_changes_nothing.

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = 80 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 80 )
      msg = 'a material nobody agreed a quota for is distributed as before' ).

  ENDMETHOD.

  METHOD a_quota_cuts_the_customer.

    given_quota( 30 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = 80 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 30 )
      msg = 'a customer gets what it agreed, not what happens to be on the shelf' ).

  ENDMETHOD.

  METHOD the_rest_is_left_for_others.

    given_quota( 30 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 80 ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 80
                  iv_kunnr    = c_small
                  iv_priority = '20' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D2' )
      exp = CONV zif_allocation=>ty_quantity( 70 )
      msg = 'what one customer may not take is there for the next one' ).

  ENDMETHOD.

  METHOD the_urgent_line_is_kept.

    given_quota( 50 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 50
                  iv_priority = '10' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 50
                  iv_priority = '90' ) ) ) ).

    " a customer keeps its urgent lines whole and loses the far end of its
    " book, rather than getting a shaving off each of them
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 50 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D2' )
      exp = CONV zif_allocation=>ty_quantity( 0 ) ).

  ENDMETHOD.

  METHOD a_period_stands_on_its_own.

    given_quota( 30 ).
    given_quota(
      iv_quantity = 30
      iv_from     = c_february
      iv_to       = c_feb_end ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 80 ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 80
                  iv_date     = c_february
                  iv_priority = '20' ) ) ) ).

    " a month's quota is a month's: what January did not allow is not
    " borrowed from February, and February starts again at its own figure
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 30 ) ).
    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D2' )
      exp = CONV zif_allocation=>ty_quantity( 30 ) ).

  ENDMETHOD.

  METHOD outside_every_period_is_free.

    given_quota( 30 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 80
                  iv_date     = c_february ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 80 )
      msg = 'a quota says nothing about the months it does not cover' ).

  ENDMETHOD.

  METHOD a_transfer_has_no_quota.

    given_quota(
      iv_quantity = 30
      iv_kunnr    = '' ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 80
                  iv_kunnr    = '' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 80 )
      msg = 'a stock transport order is not a customer and agreed nothing' ).

  ENDMETHOD.

  METHOD the_house_quota_applies.

    given_quota(
      iv_quantity = 30
      iv_kunnr    = '' ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = 80 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 30 )
      msg = 'a row naming no customer is the rule of the house' ).

  ENDMETHOD.

  METHOD an_own_quota_beats_the_house.

    given_quota(
      iv_quantity = 30
      iv_kunnr    = '' ).
    given_quota( 60 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = 80 ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 60 )
      msg = 'what was agreed with one customer replaces the house rule' ).

  ENDMETHOD.

  METHOD the_line_says_it_was_the_quota.

    given_quota( 30 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = 80 ) ) ) ).

    READ TABLE lt_answer INTO DATA(ls_line) WITH KEY demand_id = 'D1'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-reason
      exp = zif_allocation=>c_reason-quota
      msg = 'a planner ringing the customer has to know it was not the stock' ).

  ENDMETHOD.

  METHOD what_was_asked_for_is_kept.

    given_quota( 30 ).

    DATA(lt_answer) = mo_cut->allocate(
      iv_available = 100
      it_demand    = VALUE #( ( demand( iv_id = 'D1' iv_quantity = 80 ) ) ) ).

    READ TABLE lt_answer INTO DATA(ls_line) WITH KEY demand_id = 'D1'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-requested
      exp = CONV zif_allocation=>ty_quantity( 80 )
      msg = 'the answer is about the order, not about the quota it was cut to' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-shortfall
      exp = CONV zif_allocation=>ty_quantity( 50 ) ).

  ENDMETHOD.

ENDCLASS.
