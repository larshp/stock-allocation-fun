CLASS ltcl_supply_receipts DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE ekpo-matnr VALUE 'SUPPLY-PO-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_other TYPE mard-werks VALUE '2000'.

    DATA mo_cut TYPE REF TO zif_supply_reader.

    METHODS setup.
    METHODS teardown.

    "! A purchase order bringing IV_MATNR into C_WERKS, with one schedule line
    "! unless IV_SCHEDULED is switched off.
    METHODS given_order
      IMPORTING
        iv_ebeln     TYPE ekko-ebeln
        iv_menge     TYPE ekpo-menge
        iv_werks     TYPE ekpo-werks DEFAULT c_werks
        iv_meins     TYPE ekpo-meins DEFAULT 'PC'
        iv_eindt     TYPE eket-eindt DEFAULT '20260301'
        iv_received  TYPE eket-wemng DEFAULT 0
        iv_scheduled TYPE abap_bool DEFAULT abap_true
        iv_deleted   TYPE abap_bool DEFAULT abap_false
        iv_complete  TYPE abap_bool DEFAULT abap_false
        iv_returns   TYPE abap_bool DEFAULT abap_false.

    METHODS given_schedule_line
      IMPORTING
        iv_ebeln    TYPE eket-ebeln
        iv_etenr    TYPE eket-etenr
        iv_menge    TYPE eket-menge
        iv_eindt    TYPE eket-eindt
        iv_received TYPE eket-wemng DEFAULT 0.

    METHODS supply
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    METHODS an_open_order_is_supply FOR TESTING RAISING cx_static_check.
    METHODS received_part_is_stock_now FOR TESTING RAISING cx_static_check.
    METHODS fully_received_is_no_supply FOR TESTING RAISING cx_static_check.
    METHODS each_schedule_line_apart FOR TESTING RAISING cx_static_check.
    METHODS undated_item_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS other_plant_is_not_supply FOR TESTING RAISING cx_static_check.
    METHODS deleted_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS completed_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS returns_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS order_unit_becomes_base_unit FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_receipts IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    mo_cut = NEW zcl_supply_receipts( NEW zcl_unit_converter( ) ).

    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' ) ).

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

    DELETE FROM eket WHERE ebeln LIKE 'POS-%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekpo WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM ekko WHERE ebeln LIKE 'POS-%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_order.

    DATA lt_ekko TYPE STANDARD TABLE OF ekko WITH EMPTY KEY.
    DATA lt_ekpo TYPE STANDARD TABLE OF ekpo WITH EMPTY KEY.

    lt_ekko = VALUE #(
      ( mandt = sy-mandt
        ebeln = iv_ebeln
        bsart = 'NB'
        reswk = ''
        loekz = '' ) ).

    INSERT ekko FROM TABLE @lt_ekko.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EKKO fixture could not be inserted' ).

    lt_ekpo = VALUE #(
      ( mandt = sy-mandt
        ebeln = iv_ebeln
        ebelp = '00010'
        matnr = c_matnr
        werks = iv_werks
        menge = iv_menge
        meins = iv_meins
        loekz = COND #( WHEN iv_deleted = abap_true THEN 'L' )
        elikz = COND #( WHEN iv_complete = abap_true THEN 'X' )
        retpo = COND #( WHEN iv_returns = abap_true THEN 'X' ) ) ).

    INSERT ekpo FROM TABLE @lt_ekpo.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EKPO fixture could not be inserted' ).

    IF iv_scheduled = abap_false.
      RETURN.
    ENDIF.

    given_schedule_line(
      iv_ebeln    = iv_ebeln
      iv_etenr    = '0001'
      iv_menge    = iv_menge
      iv_eindt    = iv_eindt
      iv_received = iv_received ).

  ENDMETHOD.

  METHOD given_schedule_line.

    DATA lt_eket TYPE STANDARD TABLE OF eket WITH EMPTY KEY.

    lt_eket = VALUE #(
      ( mandt = sy-mandt
        ebeln = iv_ebeln
        ebelp = '00010'
        etenr = iv_etenr
        eindt = iv_eindt
        menge = iv_menge
        wemng = iv_received ) ).

    INSERT eket FROM TABLE @lt_eket.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'EKET fixture could not be inserted' ).

  ENDMETHOD.

  METHOD supply.

    rt_supply = mo_cut->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD an_open_order_is_supply.

    given_order(
      iv_ebeln = 'POS-000001'
      iv_menge = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' ) )
      msg = 'stock on its way can serve demand wanted after it arrives' ).

  ENDMETHOD.

  METHOD received_part_is_stock_now.

    given_order(
      iv_ebeln    = 'POS-000002'
      iv_menge    = '10'
      iv_received = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '6' ) )
      msg = 'what has arrived is in MARD and must not be counted twice' ).

  ENDMETHOD.

  METHOD fully_received_is_no_supply.

    given_order(
      iv_ebeln    = 'POS-000003'
      iv_menge    = '10'
      iv_received = '10' ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD each_schedule_line_apart.

    given_order(
      iv_ebeln = 'POS-000004'
      iv_menge = '4'
      iv_eindt = '20260301' ).
    given_schedule_line(
      iv_ebeln = 'POS-000004'
      iv_etenr = '0002'
      iv_menge = '6'
      iv_eindt = '20260315' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '4' )
        ( avail_date = '20260315' quantity = '6' ) )
      msg = 'two deliveries of one item arrive on two days and stay apart' ).

  ENDMETHOD.

  METHOD undated_item_is_left_out.

    given_order(
      iv_ebeln     = 'POS-000005'
      iv_menge     = '10'
      iv_scheduled = abap_false ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a receipt nobody has committed to a day must not be promised' ).

  ENDMETHOD.

  METHOD other_plant_is_not_supply.

    given_order(
      iv_ebeln = 'POS-000006'
      iv_menge = '10'
      iv_werks = c_other ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD deleted_item_is_out.

    given_order(
      iv_ebeln   = 'POS-000007'
      iv_menge   = '10'
      iv_deleted = abap_true ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD completed_item_is_out.

    given_order(
      iv_ebeln    = 'POS-000008'
      iv_menge    = '10'
      iv_complete = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a delivery completed item brings nothing more, whatever is open on it' ).

  ENDMETHOD.

  METHOD returns_item_is_out.

    given_order(
      iv_ebeln   = 'POS-000009'
      iv_menge   = '10'
      iv_returns = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a returns item sends stock back to the vendor, it brings none in' ).

  ENDMETHOD.

  METHOD order_unit_becomes_base_unit.

    given_order(
      iv_ebeln = 'POS-000010'
      iv_menge = '2'
      iv_meins = 'CAR' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '24' ) )
      msg = 'two cartons of twelve arrive as twenty four pieces' ).

  ENDMETHOD.

ENDCLASS.
