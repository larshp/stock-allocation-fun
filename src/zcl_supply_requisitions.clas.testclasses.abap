CLASS ltcl_supply_requisitions DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE eban-matnr VALUE 'SUPPLY-PR-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_other TYPE mard-werks VALUE '2000'.

    DATA mo_cut TYPE REF TO zif_supply_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_requisition
      IMPORTING
        iv_banfn    TYPE eban-banfn
        iv_quantity TYPE eban-menge
        iv_werks    TYPE eban-werks DEFAULT c_werks
        iv_meins    TYPE eban-meins DEFAULT 'PC'
        iv_lfdat    TYPE eban-lfdat DEFAULT '20260301'
        iv_ordered  TYPE eban-bsmng DEFAULT 0
        iv_deleted  TYPE abap_bool DEFAULT abap_false
        iv_closed   TYPE abap_bool DEFAULT abap_false
        iv_ebeln    TYPE eban-ebeln DEFAULT ''.

    METHODS supply
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    METHODS an_open_requisition_counts FOR TESTING RAISING cx_static_check.
    METHODS an_ordered_part_is_a_receipt FOR TESTING RAISING cx_static_check.
    METHODS a_converted_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS a_deleted_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS a_closed_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS an_undated_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS another_plant_is_not_supply FOR TESTING RAISING cx_static_check.
    METHODS order_unit_becomes_base_unit FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_requisitions IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    mo_cut = NEW zcl_supply_requisitions( NEW zcl_unit_converter( ) ).

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'HAWA' meins = 'PC' ) ).

    lt_marm = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr meinh = 'CAR' umrez = 12 umren = 1 ) ).

    INSERT mara FROM TABLE @lt_mara.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'material master fixture could not be inserted' ).

    INSERT marm FROM TABLE @lt_marm.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'unit of measure fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM eban WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_requisition.

    DATA lt_eban TYPE STANDARD TABLE OF eban WITH EMPTY KEY.

    lt_eban = VALUE #(
      ( mandt = sy-mandt
        banfn = iv_banfn
        bnfpo = '00010'
        matnr = c_matnr
        werks = iv_werks
        menge = iv_quantity
        bsmng = iv_ordered
        meins = iv_meins
        lfdat = iv_lfdat
        ebeln = iv_ebeln
        pstyp = '0'
        loekz = COND #( WHEN iv_deleted = abap_true THEN 'X' )
        ebakz = COND #( WHEN iv_closed = abap_true THEN 'X' ) ) ).

    INSERT eban FROM TABLE @lt_eban.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EBAN fixture could not be inserted' ).

  ENDMETHOD.

  METHOD supply.

    rt_supply = mo_cut->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD an_open_requisition_counts.

    given_requisition(
      iv_banfn    = 'PR-0000001'
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' ) )
      msg = 'what MRP says to buy is the buying half of the same plan' ).

  ENDMETHOD.

  METHOD an_ordered_part_is_a_receipt.

    given_requisition(
      iv_banfn    = 'PR-0000002'
      iv_quantity = '10'
      iv_ordered  = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '6' ) )
      msg = 'the ordered part is a purchase order and is counted there' ).

  ENDMETHOD.

  METHOD a_converted_item_is_out.

    given_requisition(
      iv_banfn    = 'PR-0000003'
      iv_quantity = '10'
      iv_ebeln    = '4500000001' ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD a_deleted_item_is_out.

    given_requisition(
      iv_banfn    = 'PR-0000004'
      iv_quantity = '10'
      iv_deleted  = abap_true ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD a_closed_item_is_out.

    given_requisition(
      iv_banfn    = 'PR-0000005'
      iv_quantity = '10'
      iv_closed   = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a closed item brings nothing more, whatever is open on it' ).

  ENDMETHOD.

  METHOD an_undated_item_is_out.

    given_requisition(
      iv_banfn    = 'PR-0000006'
      iv_quantity = '10'
      iv_lfdat    = '00000000' ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a receipt nobody has committed to a day must not be promised' ).

  ENDMETHOD.

  METHOD another_plant_is_not_supply.

    given_requisition(
      iv_banfn    = 'PR-0000007'
      iv_quantity = '10'
      iv_werks    = c_other ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD order_unit_becomes_base_unit.

    given_requisition(
      iv_banfn    = 'PR-0000008'
      iv_quantity = '2'
      iv_meins    = 'CAR' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '24' ) )
      msg = 'two cartons of twelve are twenty four pieces here as well' ).

  ENDMETHOD.

ENDCLASS.
