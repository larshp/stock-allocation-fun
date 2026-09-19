CLASS lcl_supply_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_supply_reader.

    METHODS constructor
      IMPORTING
        iv_quantity TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mv_quantity TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_supply_double IMPLEMENTATION.

  METHOD constructor.
    mv_quantity = iv_quantity.
  ENDMETHOD.

  METHOD zif_supply_reader~read_supply.
    rt_supply = VALUE #( ( quantity = mv_quantity ) ).
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
        textid   = zcx_allocation=>not_authorised
        mv_werks = |{ iv_werks }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.


CLASS ltcl_alloc_if_supply DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_matnr TYPE mard-matnr VALUE 'IF-MAT-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '9611'.
    CONSTANTS c_today TYPE d VALUE '20260601'.

    METHODS lines_of
      IMPORTING
        it_demand      TYPE zif_allocation=>ty_demand_tab
        iv_on_hand     TYPE zif_allocation=>ty_quantity DEFAULT 10
        iv_extra       TYPE zif_allocation=>ty_quantity DEFAULT 50
        iv_date        TYPE d OPTIONAL
        iv_refuse      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_line) TYPE zcl_alloc_if_supply=>ty_line_tab
      RAISING
        zcx_allocation.

    METHODS demand
      IMPORTING
        iv_id            TYPE zif_allocation=>ty_demand_id
        iv_quantity      TYPE zif_allocation=>ty_quantity
        iv_date          TYPE d DEFAULT c_today
      RETURNING
        VALUE(rs_demand) TYPE zif_allocation=>ty_demand.

    METHODS says
      IMPORTING
        it_line       TYPE zcl_alloc_if_supply=>ty_line_tab
        iv_text       TYPE string
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS nothing_waiting_says_so FOR TESTING RAISING cx_static_check.
    METHODS a_short_line_would_gain FOR TESTING RAISING cx_static_check.
    METHODS a_served_line_gains_none FOR TESTING RAISING cx_static_check.
    METHODS what_lands_too_late FOR TESTING RAISING cx_static_check.
    METHODS the_rest_goes_to_nobody FOR TESTING RAISING cx_static_check.
    METHODS a_closed_plant_is_refused FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_if_supply IMPLEMENTATION.

  METHOD lines_of.

    rt_line = NEW zcl_alloc_if_supply(
      io_supply    = NEW lcl_supply_double( iv_on_hand )
      io_demand    = NEW lcl_demand_double( it_demand )
      io_strategy  = NEW zcl_alloc_strategy_priority( )
      io_authority = NEW lcl_authority_double( iv_refuse ) )->run(
        iv_matnr    = c_matnr
        iv_werks    = c_werks
        iv_quantity = iv_extra
        iv_date     = iv_date ).

  ENDMETHOD.

  METHOD demand.

    rs_demand = VALUE #(
      demand_id = iv_id
      matnr     = c_matnr
      werks     = c_werks
      quantity  = iv_quantity
      req_date  = iv_date
      priority  = '10'
      customer  = 'IFCUST' ).

  ENDMETHOD.

  METHOD says.

    LOOP AT it_line INTO DATA(lv_line).
      IF lv_line CS iv_text.
        rv_has = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD nothing_waiting_says_so.

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lines_of( VALUE #( ) )
                  iv_text = `Nothing is waiting for this material` )
      msg = 'a delivery for a material nobody wants fixes nothing, and says so' ).

  ENDMETHOD.

  METHOD a_short_line_would_gain.

    DATA(lt_line) = lines_of( VALUE #( ( demand( iv_id       = 'D1'
                                                 iv_quantity = 40 ) ) ) ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `1 line(s) would gain 30.000` ) ).

  ENDMETHOD.

  METHOD a_served_line_gains_none.

    " ten on the shelf and a line wanting eight: the delivery buys nothing
    DATA(lt_line) = lines_of( VALUE #( ( demand( iv_id       = 'D1'
                                                 iv_quantity = 8 ) ) ) ).

    cl_abap_unit_assert=>assert_true( says( it_line = lt_line
                                            iv_text = `Nobody would be any better off` ) ).

  ENDMETHOD.

  METHOD what_lands_too_late.

    " the line is wanted on the first of June and the delivery lands in July
    DATA(lt_line) = lines_of(
      it_demand = VALUE #( ( demand( iv_id       = 'D1'
                                     iv_quantity = 40 ) ) )
      iv_date   = '20260701' ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `Nobody would be any better off` )
      msg = 'stock that lands after the line ships is not an answer to the shortage' ).

  ENDMETHOD.

  METHOD the_rest_goes_to_nobody.

    " forty of the fifty is all anybody can take
    DATA(lt_line) = lines_of(
      it_demand  = VALUE #( ( demand( iv_id       = 'D1'
                                      iv_quantity = 40 ) ) )
      iv_on_hand = 0 ).

    cl_abap_unit_assert=>assert_true(
      act = says( it_line = lt_line
                  iv_text = `10.000 of the delivery would go to nobody` )
      msg = 'whether a delivery is the right size is half the question' ).

  ENDMETHOD.

  METHOD a_closed_plant_is_refused.

    TRY.
        lines_of( it_demand = VALUE #( )
                  iv_refuse = abap_true ).
        cl_abap_unit_assert=>fail( 'a plant is not obliged to say what it would do with stock' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
