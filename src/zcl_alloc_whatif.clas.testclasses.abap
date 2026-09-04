CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        it_supply TYPE zif_supply_reader=>ty_supply_tab.

  PRIVATE SECTION.
    DATA mt_supply TYPE zif_supply_reader=>ty_supply_tab.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mt_supply = it_supply.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    rt_supply = mt_supply.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_demand_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_demand_reader.

    METHODS constructor
      IMPORTING
        it_demand TYPE zif_allocation=>ty_demand_tab.

  PRIVATE SECTION.
    DATA mt_demand TYPE zif_allocation=>ty_demand_tab.

ENDCLASS.


CLASS lcl_demand_double IMPLEMENTATION.

  METHOD constructor.
    mt_demand = it_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~read_open_demand.
    rt_demand = mt_demand.
  ENDMETHOD.

  METHOD zif_demand_reader~materials_with_demand.
    CLEAR rt_matnr.
  ENDMETHOD.

ENDCLASS.


CLASS lcl_authority_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_allocation_authority.

    METHODS constructor
      IMPORTING
        iv_refuse TYPE abap_bool DEFAULT abap_false.

  PRIVATE SECTION.
    DATA mv_refuse TYPE abap_bool.

ENDCLASS.


CLASS lcl_authority_double IMPLEMENTATION.

  METHOD constructor.
    mv_refuse = iv_refuse.
  ENDMETHOD.

  METHOD zif_allocation_authority~check_plant.

    IF mv_refuse = abap_true.
      RAISE EXCEPTION NEW zcx_allocation(
        textid     = zcx_allocation=>not_authorised
        mv_message = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_whatif DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'WHAT-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9901'.
    CONSTANTS c_today TYPE d VALUE '20260601'.

    METHODS cut
      IMPORTING
        it_demand     TYPE zif_allocation=>ty_demand_tab
        iv_supply     TYPE zif_allocation=>ty_quantity
        iv_refuse     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(ro_cut) TYPE REF TO zcl_alloc_whatif.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_priority      TYPE zif_allocation=>ty_priority
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_whatif=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS what_is_left_is_offered FOR TESTING RAISING cx_static_check.
    METHODS a_better_order_displaces FOR TESTING RAISING cx_static_check.
    METHODS the_loser_is_named FOR TESTING RAISING cx_static_check.
    METHODS nothing_is_taken_needlessly FOR TESTING RAISING cx_static_check.
    METHODS the_shortfall_says_why FOR TESTING RAISING cx_static_check.
    METHODS a_hold_is_said_out_loud FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_whatif IMPLEMENTATION.

  METHOD cut.

    DATA(lo_supply) = CAST zif_supply_reader( NEW lcl_supply_double(
      VALUE #( ( quantity = iv_supply ) ) ) ).
    DATA(lo_demand) = CAST zif_demand_reader( NEW lcl_demand_double( it_demand ) ).

    ro_cut = NEW zcl_alloc_whatif(
      io_supply    = lo_supply
      io_demand    = lo_demand
      io_before    = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_after     = NEW zcl_allocation_engine(
        io_supply_reader = lo_supply
        io_demand_reader = lo_demand
        io_strategy      = NEW zcl_alloc_strategy_priority( ) )
      io_authority = NEW lcl_authority_double( iv_refuse ) ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = c_today
      priority  = iv_priority
      customer  = 'CUSTBOOKS' ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD what_is_left_is_offered.

    " sixty on the shelf, forty of it spoken for: an order for thirty behind
    " everybody else takes what is left over and costs nobody anything
    DATA(lt_line) = cut(
      it_demand = VALUE #( ( demand( iv_id       = 'D1'
                                     iv_quantity = 40
                                     iv_priority = '10' ) ) )
      iv_supply = 60 )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 30
        iv_req_date = c_today
        iv_priority = '90' ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `confirmed 20.000 of 30.000` )
      msg = 'an order behind the book gets what the book left' ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `Nobody would lose anything` ) ).

  ENDMETHOD.

  METHOD a_better_order_displaces.

    " the same stock, but the order would be typed in front of the book: the
    " question a salesman asks is exactly this one
    DATA(lt_line) = cut(
      it_demand = VALUE #( ( demand( iv_id       = 'D1'
                                     iv_quantity = 40
                                     iv_priority = '50' ) ) )
      iv_supply = 60 )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 30
        iv_req_date = c_today
        iv_priority = '10' ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `confirmed 30.000 of 30.000` )
      msg = 'an order in front of the book is served first' ).
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `1 line(s) would lose 10.000 between them` )
      msg = 'and what that costs is the whole point of asking' ).

  ENDMETHOD.

  METHOD the_loser_is_named.

    DATA(lt_line) = cut(
      it_demand = VALUE #( ( demand( iv_id       = 'D1'
                                     iv_quantity = 40
                                     iv_priority = '50' ) ) )
      iv_supply = 60 )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 30
        iv_req_date = c_today
        iv_priority = '10' ).

    " somebody has to ring the customer that loses, so the line and the
    " customer are on the list rather than a number at the bottom
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `D1` ) ).
    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `CUSTBOOKS` ) ).

  ENDMETHOD.

  METHOD nothing_is_taken_needlessly.

    " plenty for everybody: the answer must not invent a loser
    DATA(lt_line) = cut(
      it_demand = VALUE #( ( demand( iv_id       = 'D1'
                                     iv_quantity = 40
                                     iv_priority = '50' ) ) )
      iv_supply = 500 )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 30
        iv_req_date = c_today
        iv_priority = '10' ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `Nobody would lose anything` ) ).

  ENDMETHOD.

  METHOD the_shortfall_says_why.

    DATA(lt_line) = cut(
      it_demand = VALUE #( )
      iv_supply = 10 )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 30
        iv_req_date = c_today ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `20.000 short: not enough stock` )
      msg = 'an order that cannot be served says what stopped it' ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        cut( it_demand = VALUE #( )
             iv_supply = 100
             iv_refuse = abap_true )->run(
          iv_matnr    = c_matnr
          iv_werks    = c_werks
          iv_quantity = 30 ).
        cl_abap_unit_assert=>fail( 'what a plant has on its books is the plant''s business' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

  METHOD a_hold_is_said_out_loud.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_hld WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt  = sy-mandt
        werks  = c_werks
        matnr  = c_matnr
        reason = 'quality are looking at the last pallet' ) ).
    INSERT zstock_alloc_hld FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

    DATA(lt_line) = cut(
      it_demand = VALUE #( )
      iv_supply = 100 )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = 30
        iv_req_date = c_today ).

    DELETE FROM zstock_alloc_hld WHERE werks = @c_werks AND matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    " without this the answer is "nothing is waiting", which is true and
    " explains nothing: what the salesman needs to know is that the material
    " is out of every run until somebody lifts the hold
    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `quality are looking at the last pallet` )
      msg = 'a material out of the run says so wherever it is asked about' ).

  ENDMETHOD.
ENDCLASS.
