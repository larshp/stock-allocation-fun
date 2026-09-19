CLASS ltcl_deduct_reservations DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'DEDUCT-RESB-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    TYPES ty_resb_tab TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    DATA mo_cut TYPE REF TO zif_stock_deduction.

    METHODS setup.
    METHODS teardown.

    METHODS given_reservations
      IMPORTING
        it_resb TYPE ty_resb_tab.

    METHODS held_back
      RETURNING
        VALUE(rv_quantity) TYPE zif_allocation=>ty_quantity.

    METHODS nothing_reserved_is_zero FOR TESTING.
    METHODS open_quantity_is_held_back FOR TESTING.
    METHODS withdrawn_part_is_not_open FOR TESTING.
    METHODS deleted_item_reserves_nothing FOR TESTING.
    METHODS other_plant_is_ignored FOR TESTING.
    METHODS several_items_add_up FOR TESTING.

ENDCLASS.


CLASS ltcl_deduct_reservations IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_deduct_reservations( ).
  ENDMETHOD.

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

  METHOD held_back.
    rv_quantity = mo_cut->quantity(
      iv_matnr = c_matnr
      iv_werks = c_werks ).
  ENDMETHOD.

  METHOD nothing_reserved_is_zero.

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

  METHOD open_quantity_is_held_back.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000001' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '4' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '4' ).

  ENDMETHOD.

  METHOD withdrawn_part_is_not_open.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000002' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '10' enmng = '6' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '4'
      msg = 'stock already withdrawn has left MARD, it must not be held back twice' ).

  ENDMETHOD.

  METHOD deleted_item_reserves_nothing.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000003' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '4' xloek = 'X' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

  METHOD other_plant_is_ignored.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000004' rspos = '0001'
        matnr = c_matnr werks = '2000' lgort = '0001' bdmng = '4' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = 0 ).

  ENDMETHOD.

  METHOD several_items_add_up.

    given_reservations( VALUE #(
      ( mandt = sy-mandt rsnum = '0000000005' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '4' )
      ( mandt = sy-mandt rsnum = '0000000005' rspos = '0002'
        matnr = c_matnr werks = c_werks lgort = '0002' bdmng = '2.5' )
      ( mandt = sy-mandt rsnum = '0000000006' rspos = '0001'
        matnr = c_matnr werks = c_werks lgort = '0001' bdmng = '1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = held_back( )
      exp = '7.5' ).

  ENDMETHOD.

ENDCLASS.
