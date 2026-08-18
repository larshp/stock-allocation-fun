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


CLASS lcl_deduction_double DEFINITION FINAL.

  PUBLIC SECTION.
    INTERFACES zif_stock_deduction.

    METHODS constructor
      IMPORTING
        iv_quantity TYPE zif_allocation=>ty_quantity.

  PRIVATE SECTION.
    DATA mv_quantity TYPE zif_allocation=>ty_quantity.

ENDCLASS.


CLASS lcl_deduction_double IMPLEMENTATION.

  METHOD constructor.
    mv_quantity = iv_quantity.
  ENDMETHOD.

  METHOD zif_stock_deduction~quantity.
    rv_quantity = mv_quantity.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_stock_reader_net DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'NET-STOCK-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    METHODS net_of
      IMPORTING
        it_stock        TYPE zif_stock_reader=>ty_stock_line_tab
        it_deduction    TYPE zcl_stock_reader_net=>ty_deduction_tab
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_line_tab.

    METHODS total
      IMPORTING
        it_stock        TYPE zif_stock_reader=>ty_stock_line_tab
      RETURNING
        VALUE(rv_total) TYPE zif_allocation=>ty_quantity.

    METHODS no_deductions_nothing_off FOR TESTING.
    METHODS deduction_reduces_available FOR TESTING.
    METHODS deduction_spans_storage_locs FOR TESTING.
    METHODS deductions_add_up FOR TESTING.
    METHODS never_goes_below_zero FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_reader_net IMPLEMENTATION.

  METHOD net_of.

    DATA lo_inner TYPE REF TO zif_stock_reader.

    lo_inner = NEW lcl_stock_double( it_stock ).

    DATA(lo_cut) = NEW zcl_stock_reader_net(
      io_stock     = lo_inner
      it_deduction = it_deduction ).

    rt_stock = lo_cut->zif_stock_reader~read_available_stock(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD total.
    rv_total = REDUCE zif_allocation=>ty_quantity(
      INIT lv_sum = CONV zif_allocation=>ty_quantity( 0 )
      FOR ls_line IN it_stock
      NEXT lv_sum = lv_sum + ls_line-available ).
  ENDMETHOD.

  METHOD no_deductions_nothing_off.

    cl_abap_unit_assert=>assert_equals(
      act = net_of(
        it_stock     = VALUE #(
          ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) )
        it_deduction = VALUE #( ) )
      exp = VALUE zif_stock_reader=>ty_stock_line_tab(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) ).

  ENDMETHOD.

  METHOD deduction_reduces_available.

    cl_abap_unit_assert=>assert_equals(
      act = net_of(
        it_stock     = VALUE #(
          ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) )
        it_deduction = VALUE #( ( NEW lcl_deduction_double( '4' ) ) ) )
      exp = VALUE zif_stock_reader=>ty_stock_line_tab(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '6' ) ) ).

  ENDMETHOD.

  METHOD deduction_spans_storage_locs.

    cl_abap_unit_assert=>assert_equals(
      act = net_of(
        it_stock     = VALUE #(
          ( matnr = c_matnr werks = c_werks lgort = '0001' available = '4' )
          ( matnr = c_matnr werks = c_werks lgort = '0002' available = '6' ) )
        it_deduction = VALUE #( ( NEW lcl_deduction_double( '7' ) ) ) )
      exp = VALUE zif_stock_reader=>ty_stock_line_tab(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = 0 )
        ( matnr = c_matnr werks = c_werks lgort = '0002' available = '3' ) )
      msg = 'a deduction larger than one location must eat into the next' ).

  ENDMETHOD.

  METHOD deductions_add_up.

    cl_abap_unit_assert=>assert_equals(
      act = total( net_of(
        it_stock     = VALUE #(
          ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) )
        it_deduction = VALUE #(
          ( NEW lcl_deduction_double( '3' ) )
          ( NEW lcl_deduction_double( '2' ) ) ) ) )
      exp = '5'
      msg = 'every reason to hold stock back must count' ).

  ENDMETHOD.

  METHOD never_goes_below_zero.

    cl_abap_unit_assert=>assert_equals(
      act = total( net_of(
        it_stock     = VALUE #(
          ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) )
        it_deduction = VALUE #( ( NEW lcl_deduction_double( '99' ) ) ) ) )
      exp = 0
      msg = 'over committed stock must read as nothing available, not as a negative' ).

  ENDMETHOD.

ENDCLASS.
