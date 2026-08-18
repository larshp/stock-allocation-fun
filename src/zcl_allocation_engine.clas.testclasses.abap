CLASS lcl_stock_reader_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS constructor
      IMPORTING
        it_stock TYPE zif_stock_reader=>ty_stock_line_tab.

    METHODS get_last_matnr
      RETURNING
        VALUE(rv_matnr) TYPE mard-matnr.

    METHODS get_last_werks
      RETURNING
        VALUE(rv_werks) TYPE mard-werks.

  PRIVATE SECTION.
    DATA mt_stock      TYPE zif_stock_reader=>ty_stock_line_tab.
    DATA mv_last_matnr TYPE mard-matnr.
    DATA mv_last_werks TYPE mard-werks.

ENDCLASS.


CLASS lcl_stock_reader_double IMPLEMENTATION.

  METHOD constructor.
    mt_stock = it_stock.
  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.
    mv_last_matnr = iv_matnr.
    mv_last_werks = iv_werks.
    rt_stock = mt_stock.
  ENDMETHOD.

  METHOD get_last_matnr.
    rv_matnr = mv_last_matnr.
  ENDMETHOD.

  METHOD get_last_werks.
    rv_werks = mv_last_werks.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_engine DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS pools_stock_of_all_lgort FOR TESTING.
    METHODS passes_selection_to_reader FOR TESTING.
    METHODS no_stock_confirms_nothing FOR TESTING.

    METHODS given_stock
      IMPORTING
        it_stock         TYPE zif_stock_reader=>ty_stock_line_tab
      RETURNING
        VALUE(ro_double) TYPE REF TO lcl_stock_reader_double.

ENDCLASS.


CLASS ltcl_engine IMPLEMENTATION.

  METHOD given_stock.
    ro_double = NEW #( it_stock ).
  ENDMETHOD.

  METHOD pools_stock_of_all_lgort.

    DATA(lo_engine) = NEW zcl_allocation_engine(
      io_stock_reader = given_stock( VALUE #(
        ( matnr = 'MAT-1' werks = '1000' lgort = '0001' available = '4' )
        ( matnr = 'MAT-1' werks = '1000' lgort = '0002' available = '6' ) ) )
      io_strategy     = NEW zcl_alloc_strategy_priority( ) ).

    DATA(lt_result) = lo_engine->allocate(
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = 'MAT-1' werks = '1000' quantity = '10' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = '10'
      msg = 'stock of both storage locations must be pooled' ).

  ENDMETHOD.

  METHOD passes_selection_to_reader.

    DATA(lo_double) = given_stock( VALUE #( ) ).

    DATA(lo_engine) = NEW zcl_allocation_engine(
      io_stock_reader = lo_double
      io_strategy     = NEW zcl_alloc_strategy_priority( ) ).

    lo_engine->allocate(
      iv_matnr  = 'MAT-2'
      iv_werks  = '2000'
      it_demand = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lo_double->get_last_matnr( )
      exp = 'MAT-2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_double->get_last_werks( )
      exp = '2000' ).

  ENDMETHOD.

  METHOD no_stock_confirms_nothing.

    DATA(lo_engine) = NEW zcl_allocation_engine(
      io_stock_reader = given_stock( VALUE #( ) )
      io_strategy     = NEW zcl_alloc_strategy_priority( ) ).

    DATA(lt_result) = lo_engine->allocate(
      iv_matnr  = 'MAT-1'
      iv_werks  = '1000'
      it_demand = VALUE #(
        ( demand_id = 'D1' matnr = 'MAT-1' werks = '1000' quantity = '3' priority = '01' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-confirmed
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-shortfall
      exp = '3' ).

  ENDMETHOD.

ENDCLASS.
