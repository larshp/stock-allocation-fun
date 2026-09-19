CLASS lcl_stock_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

    METHODS constructor
      IMPORTING
        it_stock TYPE zif_stock_reader=>ty_stock_line_tab.

  PRIVATE SECTION.
    DATA mt_stock TYPE zif_stock_reader=>ty_stock_line_tab.

ENDCLASS.


CLASS lcl_stock_double IMPLEMENTATION.

  METHOD constructor.
    mt_stock = it_stock.
  ENDMETHOD.

  METHOD zif_stock_reader~read_available_stock.
    rt_stock = mt_stock.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_supply_on_hand DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'MAT-1'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS supply_of
      IMPORTING
        it_stock         TYPE zif_stock_reader=>ty_stock_line_tab
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    METHODS locations_are_one_pool FOR TESTING RAISING cx_static_check.
    METHODS stock_carries_no_date FOR TESTING RAISING cx_static_check.
    METHODS no_stock_is_no_supply FOR TESTING RAISING cx_static_check.
    METHODS empty_locations_are_no_supply FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_on_hand IMPLEMENTATION.

  METHOD supply_of.

    DATA(lo_cut) = NEW zcl_supply_on_hand( NEW lcl_stock_double( it_stock ) ).

    rt_supply = lo_cut->zif_supply_reader~read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD locations_are_one_pool.

    DATA(lt_supply) = supply_of( VALUE #(
      ( matnr = c_matnr werks = c_werks lgort = '0001' available = '4' )
      ( matnr = c_matnr werks = c_werks lgort = '0002' available = '6' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_supply )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_supply[ 1 ]-quantity
      exp = '10' ).

  ENDMETHOD.

  METHOD stock_carries_no_date.

    DATA(lt_supply) = supply_of( VALUE #(
      ( matnr = c_matnr werks = c_werks lgort = '0001' available = '4' ) ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_supply[ 1 ]-avail_date
      msg = 'stock that is there must be able to serve an overdue line' ).

  ENDMETHOD.

  METHOD no_stock_is_no_supply.

    cl_abap_unit_assert=>assert_initial( supply_of( VALUE #( ) ) ).

  ENDMETHOD.

  METHOD empty_locations_are_no_supply.

    cl_abap_unit_assert=>assert_initial( supply_of( VALUE #(
      ( matnr = c_matnr werks = c_werks lgort = '0001' available = 0 ) ) ) ).

  ENDMETHOD.

ENDCLASS.
