CLASS ltcl_deduct_deliveries DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'DEDUCT-LIPS-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    "! Outbound delivery, the only kind that takes stock out of the plant.
    CONSTANTS c_outbound TYPE lips-vbeln VALUE '0080000001'.
    "! Inbound delivery, stock arriving against a purchase order.
    CONSTANTS c_inbound  TYPE lips-vbeln VALUE '0080000002'.
    "! Returns delivery, stock coming back from a customer.
    CONSTANTS c_returns  TYPE lips-vbeln VALUE '0080000003'.

    DATA mo_cut TYPE REF TO zif_stock_deduction.

    METHODS setup.
    METHODS teardown.

    "! One item of a delivery whose header is already in the fixture.
    METHODS given_item
      IMPORTING
        iv_vbeln TYPE lips-vbeln DEFAULT c_outbound
        iv_posnr TYPE lips-posnr
        iv_lgmng TYPE lips-lgmng
        iv_wbsta TYPE lips-wbsta DEFAULT 'A'
        iv_werks TYPE lips-werks DEFAULT c_werks.

    METHODS held_back
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS no_delivery_holds_nothing FOR TESTING.
    METHODS open_item_holds_its_quantity FOR TESTING.
    METHODS goods_issued_item_is_gone FOR TESTING.
    METHODS status_not_set_still_holds FOR TESTING.
    METHODS inbound_delivery_brings_stock FOR TESTING.
    METHODS returns_delivery_brings_stock FOR TESTING.
    METHODS other_plant_is_ignored FOR TESTING.
    METHODS several_items_add_up FOR TESTING.

ENDCLASS.


CLASS ltcl_deduct_deliveries IMPLEMENTATION.

  METHOD setup.

    DATA lt_likp TYPE STANDARD TABLE OF likp WITH EMPTY KEY.

    mo_cut = NEW zcl_deduct_deliveries( ).

    " every component is spelled out per row on purpose, see ANOMALIES.md
    lt_likp = VALUE #(
      ( mandt = sy-mandt vbeln = c_outbound vbtyp = 'J' lfdat = '20260210' )
      ( mandt = sy-mandt vbeln = c_inbound  vbtyp = '7' lfdat = '20260210' )
      ( mandt = sy-mandt vbeln = c_returns  vbtyp = 'T' lfdat = '20260210' ) ).

    INSERT likp FROM TABLE @lt_likp.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'delivery header fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM lips WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM likp WHERE vbeln IN ( @c_outbound, @c_inbound, @c_returns ).
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'delivery header fixture could not be removed' ).

  ENDMETHOD.

  METHOD given_item.

    DATA lt_lips TYPE STANDARD TABLE OF lips WITH EMPTY KEY.

    lt_lips = VALUE #(
      ( mandt = sy-mandt vbeln = iv_vbeln posnr = iv_posnr
        matnr = c_matnr werks = iv_werks lgort = '0001'
        lgmng = iv_lgmng meins = 'PC' wbsta = iv_wbsta ) ).

    INSERT lips FROM TABLE @lt_lips.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'delivery item fixture could not be inserted' ).

  ENDMETHOD.

  METHOD held_back.

    rv_quantity = mo_cut->quantity(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD no_delivery_holds_nothing.

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

  METHOD open_item_holds_its_quantity.

    given_item(
      iv_posnr = '000010'
      iv_lgmng = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '4'
      msg = 'stock on a delivery waiting for its goods issue is committed' ).

  ENDMETHOD.

  METHOD goods_issued_item_is_gone.

    given_item(
      iv_posnr = '000010'
      iv_lgmng = '4'
      iv_wbsta = 'C' ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0
      msg = 'stock that has been issued has left MARD, holding it back doubles it' ).

  ENDMETHOD.

  METHOD status_not_set_still_holds.

    given_item(
      iv_posnr = '000010'
      iv_lgmng = '3'
      iv_wbsta = space ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '3'
      msg = 'only a posted goods issue releases the stock' ).

  ENDMETHOD.

  METHOD inbound_delivery_brings_stock.

    given_item(
      iv_vbeln = c_inbound
      iv_posnr = '000010'
      iv_lgmng = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0
      msg = 'an inbound delivery adds stock, it does not commit any' ).

  ENDMETHOD.

  METHOD returns_delivery_brings_stock.

    given_item(
      iv_vbeln = c_returns
      iv_posnr = '000010'
      iv_lgmng = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0
      msg = 'a return comes back into the plant, it does not commit any stock' ).

  ENDMETHOD.

  METHOD other_plant_is_ignored.

    given_item(
      iv_posnr = '000010'
      iv_lgmng = '4'
      iv_werks = '2000' ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

  METHOD several_items_add_up.

    given_item(
      iv_posnr = '000010'
      iv_lgmng = '4' ).
    given_item(
      iv_posnr = '000020'
      iv_lgmng = '2.5' ).
    given_item(
      iv_vbeln = c_returns
      iv_posnr = '000010'
      iv_lgmng = '8' ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '6.5' ).

  ENDMETHOD.

ENDCLASS.
