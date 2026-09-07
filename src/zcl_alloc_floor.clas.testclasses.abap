"! Hands over whatever it was told to, for whichever lines it was told.
CLASS lcl_floor_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_alloc_floor.

    METHODS constructor
      IMPORTING
        it_floor TYPE zif_alloc_floor=>ty_floor_tab.

  PRIVATE SECTION.
    DATA mt_floor TYPE zif_alloc_floor=>ty_floor_tab.

ENDCLASS.


CLASS lcl_floor_double IMPLEMENTATION.

  METHOD constructor.
    mt_floor = it_floor.
  ENDMETHOD.

  METHOD zif_alloc_floor~floors_for.

    " a source answers about the material it was asked about, and the lines of
    " one material are not the lines of another
    LOOP AT mt_floor INTO DATA(ls_floor).
      IF line_exists( it_demand[ demand_id = ls_floor-demand_id ] ).
        APPEND ls_floor TO rt_floor.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_floor DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'FLOOR-MAT-01'.
    CONSTANTS c_other TYPE mard-matnr VALUE 'FLOOR-MAT-02'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9661'.

    METHODS cut
      IMPORTING
        it_floor      TYPE zif_alloc_floor=>ty_floor_tab
      RETURNING
        VALUE(ro_cut) TYPE REF TO zif_allocation_strategy.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_priority      TYPE zif_allocation=>ty_priority
        iv_matnr         TYPE mard-matnr DEFAULT c_matnr
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS confirmed_of
      IMPORTING
        it_allocation      TYPE zif_allocation=>ty_allocation_tab
        iv_id              TYPE zif_allocation=>ty_demand_id
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS nothing_to_hand_over FOR TESTING.
    METHODS the_floor_comes_first FOR TESTING.
    METHODS the_rest_follows_the_rules FOR TESTING.
    METHODS no_more_than_the_line_asks FOR TESTING.
    METHODS no_more_than_there_is FOR TESTING.
    METHODS every_line_is_answered_once FOR TESTING.
    METHODS the_answer_is_about_the_order FOR TESTING.
    METHODS one_walk_hands_over_once FOR TESTING.
    METHODS another_material_starts_over FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_floor IMPLEMENTATION.

  METHOD cut.

    ro_cut = NEW zcl_alloc_floor(
      io_strategy = NEW zcl_alloc_strategy_priority( )
      io_floor    = NEW lcl_floor_double( it_floor ) ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = iv_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = '20260601'
      priority  = iv_priority
      customer  = 'FLOORCUST' ).

  ENDMETHOD.

  METHOD confirmed_of.

    READ TABLE it_allocation INTO DATA(ls_line)
      WITH KEY demand_id = iv_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_quantity = ls_line-confirmed.

  ENDMETHOD.

  METHOD nothing_to_hand_over.

    DATA(lt_answer) = cut( VALUE #( ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 30
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 10 )
      msg = 'a source with nothing to say leaves the rules exactly as they were' ).

  ENDMETHOD.

  METHOD the_floor_comes_first.

    " the rules would give all ten to the first line; the floor is under the
    " second one
    DATA(lt_answer) = cut( VALUE #( ( demand_id = 'D2' quantity = 6 ) ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 30
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 30
                  iv_priority = '09' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D2' )
      exp = CONV zif_allocation=>ty_quantity( 6 ) ).

  ENDMETHOD.

  METHOD the_rest_follows_the_rules.

    DATA(lt_answer) = cut( VALUE #( ( demand_id = 'D2' quantity = 6 ) ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 30
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 30
                  iv_priority = '09' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 4 )
      msg = 'what is left after the floor is distributed by priority as ever' ).

  ENDMETHOD.

  METHOD no_more_than_the_line_asks.

    " the line was cut back to two pieces since the floor was worked out
    DATA(lt_answer) = cut( VALUE #( ( demand_id = 'D1' quantity = 6 ) ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 2
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 2 ) ).

  ENDMETHOD.

  METHOD no_more_than_there_is.

    DATA(lt_answer) = cut( VALUE #( ( demand_id = 'D1' quantity = 60 ) ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 80
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_answer
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 10 )
      msg = 'a floor decides who gets the stock, not how much of it there is' ).

  ENDMETHOD.

  METHOD every_line_is_answered_once.

    " the whole ten goes to the floor under the second line, so the rules
    " never see anything for the first one
    DATA(lt_answer) = cut( VALUE #( ( demand_id = 'D2' quantity = 10 ) ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D1'
                  iv_quantity = 30
                  iv_priority = '01' ) )
        ( demand( iv_id       = 'D2'
                  iv_quantity = 30
                  iv_priority = '09' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_answer )
      exp = 2 ).

  ENDMETHOD.

  METHOD the_answer_is_about_the_order.

    DATA(lt_answer) = cut( VALUE #( ( demand_id = 'D1' quantity = 6 ) ) )->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 30
                                        iv_priority = '01' ) ) ) ).

    READ TABLE lt_answer INTO DATA(ls_line) WITH KEY demand_id = 'D1'.
    cl_abap_unit_assert=>assert_subrc( ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-requested
      exp = CONV zif_allocation=>ty_quantity( 30 )
      msg = 'the rules saw a smaller line, the customer ordered the whole one' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_line-shortfall
      exp = CONV zif_allocation=>ty_quantity( 20 ) ).

  ENDMETHOD.

  METHOD one_walk_hands_over_once.

    " the engine walks the days of supply and asks once per day, with the
    " demand it has left: the floor is handed over on the first day and must
    " not be handed over again on the second
    DATA(lo_cut) = cut( VALUE #( ( demand_id = 'D1' quantity = 6 ) ) ).

    lo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 30
                                        iv_priority = '01' ) ) ) ).

    DATA(lt_second) = lo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 20
                                        iv_priority = '01' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_second
                          iv_id         = 'D1' )
      exp = CONV zif_allocation=>ty_quantity( 10 )
      msg = 'the second day is stock the rules distribute, the floor is spent' ).

  ENDMETHOD.

  METHOD another_material_starts_over.

    " a plant wide run allocates every material through this same chain: what
    " is left of one material's floors means nothing for the next one, and the
    " demand total cannot tell the two apart because the next material may
    " well be asked for less
    DATA(lo_cut) = cut( VALUE #(
      ( demand_id = 'D1' quantity = 6 )
      ( demand_id = 'D3' quantity = 6 ) ) ).

    lo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #( ( demand( iv_id       = 'D1'
                                        iv_quantity = 100
                                        iv_priority = '01' ) ) ) ).

    DATA(lt_second) = lo_cut->allocate(
      iv_available = 10
      it_demand    = VALUE #(
        ( demand( iv_id       = 'D2'
                  iv_quantity = 30
                  iv_priority = '01'
                  iv_matnr    = c_other ) )
        ( demand( iv_id       = 'D3'
                  iv_quantity = 30
                  iv_priority = '09'
                  iv_matnr    = c_other ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = confirmed_of( it_allocation = lt_second
                          iv_id         = 'D3' )
      exp = CONV zif_allocation=>ty_quantity( 6 )
      msg = 'the second material has floors of its own, and they are not spent' ).

  ENDMETHOD.

ENDCLASS.
