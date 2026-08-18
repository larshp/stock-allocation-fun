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


CLASS ltcl_stock_reader_net DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'NET-STOCK-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    TYPES ty_resb_tab TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    METHODS teardown.

    METHODS given_reservations
      IMPORTING
        it_resb TYPE ty_resb_tab.

    METHODS net_of
      IMPORTING
        it_stock        TYPE zif_stock_reader=>ty_stock_line_tab
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_line_tab.

    METHODS total
      IMPORTING
        it_stock        TYPE zif_stock_reader=>ty_stock_line_tab
      RETURNING
        VALUE(rv_total) TYPE zif_allocation=>ty_quantity.

    METHODS no_reservations_nothing_off FOR TESTING.
    METHODS reservation_reduces_available FOR TESTING.
    METHODS reservation_spans_storage_locs FOR TESTING.
    METHODS withdrawn_part_is_not_open FOR TESTING.
    METHODS deleted_item_reserves_nothing FOR TESTING.
    METHODS other_material_is_ignored FOR TESTING.
    METHODS never_goes_below_zero FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_reader_net IMPLEMENTATION.

  METHOD teardown.
    DELETE FROM resb WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).
  ENDMETHOD.

  METHOD given_reservations.
    INSERT resb FROM TABLE @it_resb.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'reservation fixture could not be inserted' ).
  ENDMETHOD.

  METHOD net_of.
    DATA lo_inner TYPE REF TO zif_stock_reader.

    lo_inner = NEW lcl_stock_double( it_stock ).

    DATA(lo_cut) = NEW zcl_stock_reader_net( lo_inner ).
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

  METHOD no_reservations_nothing_off.

    cl_abap_unit_assert=>assert_equals(
      act = net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) )
      exp = VALUE zif_stock_reader=>ty_stock_line_tab(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) ).

  ENDMETHOD.

  METHOD reservation_reduces_available.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000001' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '4' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) )
      exp = VALUE zif_stock_reader=>ty_stock_line_tab(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '6' ) ) ).

  ENDMETHOD.

  METHOD reservation_spans_storage_locs.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000002' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '7' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '4' )
        ( matnr = c_matnr werks = c_werks lgort = '0002' available = '6' ) ) )
      exp = VALUE zif_stock_reader=>ty_stock_line_tab(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = 0 )
        ( matnr = c_matnr werks = c_werks lgort = '0002' available = '3' ) )
      msg = 'a reservation larger than one location must eat into the next' ).

  ENDMETHOD.

  METHOD withdrawn_part_is_not_open.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000003' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '10' enmng = '6' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total( net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) ) )
      exp = '6'
      msg = 'stock already withdrawn is gone from MARD, it must not be counted twice' ).

  ENDMETHOD.

  METHOD deleted_item_reserves_nothing.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000004' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '4' xloek = 'X' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total( net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) ) )
      exp = '10' ).

  ENDMETHOD.

  METHOD other_material_is_ignored.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000005' rspos = '0001'
        matnr = c_matnr werks = '2000' lgort = '0001' bdmng = '4' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total( net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) ) )
      exp = '10'
      msg = 'a reservation in another plant must not reduce this one' ).

  ENDMETHOD.

  METHOD never_goes_below_zero.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000006' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '99' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = total( net_of( VALUE #(
        ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' ) ) ) )
      exp = 0
      msg = 'over reserved stock must read as nothing available, not as a negative' ).

  ENDMETHOD.

ENDCLASS.
