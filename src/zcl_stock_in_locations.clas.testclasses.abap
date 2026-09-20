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


CLASS ltcl_stock_in_locations DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'LGORT-TEST-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_inner TYPE REF TO zif_stock_reader.

    METHODS setup.

    METHODS stock_of
      IMPORTING
        it_lgort        TYPE zcl_stock_in_locations=>ty_lgort_tab OPTIONAL
      RETURNING
        VALUE(rt_stock) TYPE zif_stock_reader=>ty_stock_line_tab.

    METHODS no_list_keeps_everything FOR TESTING.
    METHODS only_listed_locations_count FOR TESTING.
    METHODS unknown_location_adds_nothing FOR TESTING.
    METHODS nothing_matching_is_no_stock FOR TESTING.

ENDCLASS.


CLASS ltcl_stock_in_locations IMPLEMENTATION.

  METHOD setup.

    mo_inner = NEW lcl_stock_double( VALUE #(
      ( matnr = c_matnr werks = c_werks lgort = '0001' available = '10' )
      ( matnr = c_matnr werks = c_werks lgort = '0002' available = '4' )
      ( matnr = c_matnr werks = c_werks lgort = 'RET1' available = '7' ) ) ).

  ENDMETHOD.

  METHOD stock_of.

    DATA(lo_cut) = NEW zcl_stock_in_locations(
      io_stock = mo_inner
      it_lgort = it_lgort ).

    rt_stock = lo_cut->zif_stock_reader~read_available_stock(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD no_list_keeps_everything.

    cl_abap_unit_assert=>assert_equals(
      act = lines( stock_of( ) )
      exp = 3
      msg = 'a plant that has not said which locations to use means all of them' ).

  ENDMETHOD.

  METHOD only_listed_locations_count.

    DATA(lt_stock) = stock_of( VALUE #( ( '0001' ) ( '0002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_stock )
      exp = 2 ).
    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_stock[ lgort = 'RET1' ] ) )
      msg = 'stock in a location that is out of the list may not be given away' ).

  ENDMETHOD.

  METHOD unknown_location_adds_nothing.

    cl_abap_unit_assert=>assert_equals(
      act = lines( stock_of( VALUE #( ( '0001' ) ( '9999' ) ) ) )
      exp = 1
      msg = 'a location the material is not stocked in holds nothing' ).

  ENDMETHOD.

  METHOD nothing_matching_is_no_stock.

    cl_abap_unit_assert=>assert_initial(
      act = stock_of( VALUE #( ( '9999' ) ) )
      msg = 'no stock in the listed locations is nothing to allocate' ).

  ENDMETHOD.

ENDCLASS.
