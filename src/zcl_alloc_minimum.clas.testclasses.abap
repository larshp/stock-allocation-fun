CLASS ltcl_alloc_minimum DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'MIN-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9641'.

    METHODS cut
      IMPORTING
        iv_percent    TYPE i
      RETURNING
        VALUE(ro_cut) TYPE REF TO zif_allocation_strategy.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_priority      TYPE zif_allocation=>ty_priority
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS confirmed_of
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_id              TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS no_minimum_changes_nothing FOR TESTING.
    METHODS a_thin_line_gets_nothing FOR TESTING.
    METHODS what_it_had_goes_to_the_next FOR TESTING.
    METHODS a_line_over_the_bar_is_kept FOR TESTING.
    METHODS a_full_line_is_always_kept FOR TESTING.
    METHODS every_line_is_answered_once FOR TESTING.
    METHODS the_line_says_why FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_minimum IMPLEMENTATION.

  METHOD cut.

    ro_cut = NEW zcl_alloc_minimum(
      io_strategy = NEW zcl_alloc_strategy_priority( )
      iv_percent  = iv_percent ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = '20260601'
      priority  = iv_priority
      customer  = 'MINCUST' ).

  ENDMETHOD.

  METHOD confirmed_of.

    READ TABLE it_allocation INTO DATA(ls_line)
      WITH KEY demand_id = iv_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_line-confirmed.

  ENDMETHOD.

  METHOD no_minimum_changes_nothing.

    DATA(lt_answer) = cut( 0 )->allocate(
      iv_available = 5
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 100
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 5 )
      msg = 'a plant that has not asked for a bar takes what it can get' ).

  ENDMETHOD.

  METHOD a_thin_line_gets_nothing.

    " five of a hundred is a delivery, a lorry and an invoice for something
    " the customer cannot use
    DATA(lt_answer) = cut( 25 )->allocate(
      iv_available = 5
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 100
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 0 ) ).

  ENDMETHOD.

  METHOD what_it_had_goes_to_the_next.

    " the big line cannot clear the bar with what is there; the small one
    " behind it can be served in full
    DATA(lt_answer) = cut( 25 )->allocate(
      iv_available = 5
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 100
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 5
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D2' )
      exp = CONV zif_allocation=>ty_quantity( 5 )
      msg = 'stock nobody could ship goes to somebody who can' ).

  ENDMETHOD.

  METHOD a_line_over_the_bar_is_kept.

    DATA(lt_answer) = cut( 25 )->allocate(
      iv_available = 40
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 100
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 40 )
      msg = 'forty of a hundred is a part delivery worth making' ).

  ENDMETHOD.

  METHOD a_full_line_is_always_kept.

    DATA(lt_answer) = cut( 90 )->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 10
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 10 ) ).

  ENDMETHOD.

  METHOD every_line_is_answered_once.

    DATA(lt_answer) = cut( 50 )->allocate(
      iv_available = 5
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 100
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 100
                  iv_priority = '02' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_answer )
      exp = 2 ).

  ENDMETHOD.

  METHOD the_line_says_why.

    DATA(lt_answer) = cut( 25 )->allocate(
      iv_available = 5
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 100
                                        iv_priority = '01' ) ) ) ).

    READ TABLE lt_answer INTO DATA(ls_line) WITH KEY demand_id = 'D1'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-reason
      exp = zif_allocation=>c_reason-too_little
      msg = 'a line held back by the plant''s own bar is not short of stock' ).

  ENDMETHOD.

ENDCLASS.
