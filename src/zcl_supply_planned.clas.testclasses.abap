CLASS ltcl_supply_planned DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE plaf-matnr VALUE 'SUPPLY-PLAF-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_other TYPE mard-werks VALUE '2000'.

    METHODS setup.
    METHODS teardown.

    "! A planned order for C_MATNR, firmed unless IV_FIRMED is switched off.
    METHODS given_order
      IMPORTING
        iv_plnum     TYPE plaf-plnum
        iv_quantity  TYPE plaf-gsmng
        iv_werks     TYPE plaf-plwrk DEFAULT c_werks
        iv_meins     TYPE plaf-meins DEFAULT 'PC'
        iv_pedtr     TYPE plaf-pedtr DEFAULT '20260301'
        iv_firmed    TYPE abap_bool DEFAULT abap_true
        iv_scenario  TYPE plaf-plscn DEFAULT '000'
        iv_converted TYPE abap_bool DEFAULT abap_false.

    METHODS supply
      IMPORTING
        iv_firm_only     TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    METHODS a_firmed_order_is_supply FOR TESTING RAISING cx_static_check.
    METHODS a_proposal_is_not FOR TESTING RAISING cx_static_check.
    METHODS a_proposal_counts_if_asked FOR TESTING RAISING cx_static_check.
    METHODS a_converted_order_is_out FOR TESTING RAISING cx_static_check.
    METHODS simulative_planning_is_out FOR TESTING RAISING cx_static_check.
    METHODS undated_order_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS other_plant_is_not_supply FOR TESTING RAISING cx_static_check.
    METHODS order_unit_becomes_base_unit FOR TESTING RAISING cx_static_check.
    METHODS every_order_is_its_own_day FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_planned IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

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

    DELETE FROM plaf WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_order.

    DATA lt_plaf TYPE STANDARD TABLE OF plaf WITH EMPTY KEY.

    lt_plaf = VALUE #(
      ( mandt = sy-mandt
        plnum = iv_plnum
        matnr = c_matnr
        plwrk = iv_werks
        gsmng = iv_quantity
        meins = iv_meins
        pedtr = iv_pedtr
        plscn = iv_scenario
        paart = 'LA'
        auffx = COND #( WHEN iv_firmed = abap_true THEN 'X' )
        umskz = COND #( WHEN iv_converted = abap_true THEN 'X' ) ) ).

    INSERT plaf FROM TABLE @lt_plaf.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'PLAF fixture could not be inserted' ).

  ENDMETHOD.

  METHOD supply.

    DATA(lo_cut) = CAST zif_supply_reader( NEW zcl_supply_planned(
      io_converter = NEW zcl_unit_converter( )
      iv_firm_only = iv_firm_only ) ).

    rt_supply = lo_cut->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD a_firmed_order_is_supply.

    given_order(
      iv_plnum    = 'PLA-000001'
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' ) )
      msg = 'a firmed order is one somebody has agreed to make' ).

  ENDMETHOD.

  METHOD a_proposal_is_not.

    given_order(
      iv_plnum    = 'PLA-000002'
      iv_quantity = '10'
      iv_firmed   = abap_false ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'the next planning run can move or delete an unfirmed proposal' ).

  ENDMETHOD.

  METHOD a_proposal_counts_if_asked.

    given_order(
      iv_plnum    = 'PLA-000003'
      iv_quantity = '10'
      iv_firmed   = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( iv_firm_only = abap_false )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' ) )
      msg = 'a plant that trusts its plan may allocate against all of it' ).

  ENDMETHOD.

  METHOD a_converted_order_is_out.

    given_order(
      iv_plnum     = 'PLA-000004'
      iv_quantity  = '10'
      iv_converted = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'what it proposed is a real order now, and is read there' ).

  ENDMETHOD.

  METHOD simulative_planning_is_out.

    given_order(
      iv_plnum    = 'PLA-000005'
      iv_quantity = '10'
      iv_scenario = '001' ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'long term planning describes a future nobody has committed to' ).

  ENDMETHOD.

  METHOD undated_order_is_left_out.

    given_order(
      iv_plnum    = 'PLA-000006'
      iv_quantity = '10'
      iv_pedtr    = '00000000' ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'an order nobody has committed to a day must not be promised' ).

  ENDMETHOD.

  METHOD other_plant_is_not_supply.

    given_order(
      iv_plnum    = 'PLA-000007'
      iv_quantity = '10'
      iv_werks    = c_other ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD order_unit_becomes_base_unit.

    given_order(
      iv_plnum    = 'PLA-000008'
      iv_quantity = '2'
      iv_meins    = 'CAR' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '24' ) )
      msg = 'two cartons of twelve are planned as twenty four pieces' ).

  ENDMETHOD.

  METHOD every_order_is_its_own_day.

    given_order(
      iv_plnum    = 'PLA-000009'
      iv_quantity = '4' ).
    given_order(
      iv_plnum    = 'PLA-000010'
      iv_quantity = '6'
      iv_pedtr    = '20260315' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '4' )
        ( avail_date = '20260315' quantity = '6' ) )
      msg = 'two orders finishing on two days stay apart' ).

  ENDMETHOD.

ENDCLASS.
