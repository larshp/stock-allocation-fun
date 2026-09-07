CLASS ltcl_supply_production DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE afpo-matnr VALUE 'SUPPLY-PP-01'.
    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.
    CONSTANTS c_other TYPE mard-werks VALUE '2000'.

    DATA mo_cut TYPE REF TO zif_supply_reader.

    METHODS setup.
    METHODS teardown.

    "! A production order delivering IV_QUANTITY of C_MATNR into IV_WERKS.
    METHODS given_order
      IMPORTING
        iv_aufnr     TYPE aufk-aufnr
        iv_quantity  TYPE afpo-psmng
        iv_werks     TYPE afpo-dwerk DEFAULT c_werks
        iv_meins     TYPE afpo-meins DEFAULT 'PC'
        iv_ltrmp     TYPE afpo-ltrmp DEFAULT '20260301'
        iv_gltrs     TYPE afko-gltrs DEFAULT '20260401'
        iv_gltrp     TYPE afko-gltrp DEFAULT '20260501'
        iv_delivered TYPE afpo-wemng DEFAULT 0
        iv_deleted   TYPE abap_bool DEFAULT abap_false
        iv_complete  TYPE abap_bool DEFAULT abap_false.

    METHODS given_status
      IMPORTING
        iv_aufnr TYPE aufk-aufnr
        iv_stat  TYPE jest-stat
        iv_inact TYPE jest-inact DEFAULT space.

    METHODS supply
      RETURNING
        VALUE(rt_supply) TYPE zif_supply_reader=>ty_supply_tab
      RAISING
        zcx_allocation.

    METHODS an_open_order_is_supply FOR TESTING RAISING cx_static_check.
    METHODS delivered_part_is_stock_now FOR TESTING RAISING cx_static_check.
    METHODS fully_delivered_is_no_supply FOR TESTING RAISING cx_static_check.
    METHODS scheduled_finish_is_next FOR TESTING RAISING cx_static_check.
    METHODS basic_finish_is_the_last_word FOR TESTING RAISING cx_static_check.
    METHODS undated_order_is_left_out FOR TESTING RAISING cx_static_check.
    METHODS other_plant_is_not_supply FOR TESTING RAISING cx_static_check.
    METHODS deleted_order_is_out FOR TESTING RAISING cx_static_check.
    METHODS completed_item_is_out FOR TESTING RAISING cx_static_check.
    METHODS technically_complete_is_out FOR TESTING RAISING cx_static_check.
    METHODS closed_order_is_out FOR TESTING RAISING cx_static_check.
    METHODS deletion_flag_is_out FOR TESTING RAISING cx_static_check.
    METHODS an_old_status_does_not_count FOR TESTING RAISING cx_static_check.
    METHODS order_unit_becomes_base_unit FOR TESTING RAISING cx_static_check.
    METHODS every_item_of_an_order_counts FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_supply_production IMPLEMENTATION.

  METHOD setup.

    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    mo_cut = NEW zcl_supply_production( NEW zcl_unit_converter( ) ).

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

    DELETE FROM jest WHERE objnr LIKE 'OR%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM afpo WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM afko WHERE plnbez = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM aufk WHERE aufnr LIKE 'PPO-%'.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_order.

    DATA lt_aufk TYPE STANDARD TABLE OF aufk WITH EMPTY KEY.
    DATA lt_afko TYPE STANDARD TABLE OF afko WITH EMPTY KEY.
    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.

    lt_aufk = VALUE #(
      ( mandt = sy-mandt
        aufnr = iv_aufnr
        auart = 'PP01'
        autyp = '10'
        werks = iv_werks
        objnr = |OR{ iv_aufnr }|
        loekz = COND #( WHEN iv_deleted = abap_true THEN 'X' ) ) ).

    INSERT aufk FROM TABLE @lt_aufk.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'AUFK fixture could not be inserted' ).

    lt_afko = VALUE #(
      ( mandt  = sy-mandt
        aufnr  = iv_aufnr
        plnbez = c_matnr
        gltrp  = iv_gltrp
        gltrs  = iv_gltrs
        gamng  = iv_quantity
        dispo  = '001' ) ).

    INSERT afko FROM TABLE @lt_afko.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'AFKO fixture could not be inserted' ).

    lt_afpo = VALUE #(
      ( mandt = sy-mandt
        aufnr = iv_aufnr
        posnr = '0001'
        matnr = c_matnr
        dwerk = iv_werks
        meins = iv_meins
        psmng = iv_quantity
        wemng = iv_delivered
        ltrmp = iv_ltrmp
        elikz = COND #( WHEN iv_complete = abap_true THEN 'X' ) ) ).

    INSERT afpo FROM TABLE @lt_afpo.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'AFPO fixture could not be inserted' ).

  ENDMETHOD.

  METHOD given_status.

    DATA lt_jest TYPE STANDARD TABLE OF jest WITH EMPTY KEY.

    lt_jest = VALUE #(
      ( mandt = sy-mandt
        objnr = |OR{ iv_aufnr }|
        stat  = iv_stat
        inact = iv_inact
        chgnr = '001' ) ).

    INSERT jest FROM TABLE @lt_jest.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'JEST fixture could not be inserted' ).

  ENDMETHOD.

  METHOD supply.

    rt_supply = mo_cut->read_supply(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

  ENDMETHOD.

  METHOD an_open_order_is_supply.

    given_order(
      iv_aufnr    = 'PPO-0000001'
      iv_quantity = '10' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' ) )
      msg = 'what the plant is about to make can serve demand wanted after it' ).

  ENDMETHOD.

  METHOD delivered_part_is_stock_now.

    given_order(
      iv_aufnr     = 'PPO-0000002'
      iv_quantity  = '10'
      iv_delivered = '4' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '6' ) )
      msg = 'what has been delivered to stock is in MARD and is not counted twice' ).

  ENDMETHOD.

  METHOD fully_delivered_is_no_supply.

    given_order(
      iv_aufnr     = 'PPO-0000003'
      iv_quantity  = '10'
      iv_delivered = '10' ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD scheduled_finish_is_next.

    given_order(
      iv_aufnr    = 'PPO-0000004'
      iv_quantity = '10'
      iv_ltrmp    = '00000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260401' quantity = '10' ) )
      msg = 'without an item date the order is there when scheduling says it is' ).

  ENDMETHOD.

  METHOD basic_finish_is_the_last_word.

    given_order(
      iv_aufnr    = 'PPO-0000005'
      iv_quantity = '10'
      iv_ltrmp    = '00000000'
      iv_gltrs    = '00000000' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260501' quantity = '10' ) )
      msg = 'an order that has not been scheduled is there when it was asked for' ).

  ENDMETHOD.

  METHOD undated_order_is_left_out.

    given_order(
      iv_aufnr    = 'PPO-0000006'
      iv_quantity = '10'
      iv_ltrmp    = '00000000'
      iv_gltrs    = '00000000'
      iv_gltrp    = '00000000' ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'an order nobody has committed to a day must not be promised' ).

  ENDMETHOD.

  METHOD other_plant_is_not_supply.

    given_order(
      iv_aufnr    = 'PPO-0000007'
      iv_quantity = '10'
      iv_werks    = c_other ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD deleted_order_is_out.

    given_order(
      iv_aufnr    = 'PPO-0000008'
      iv_quantity = '10'
      iv_deleted  = abap_true ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD completed_item_is_out.

    given_order(
      iv_aufnr    = 'PPO-0000009'
      iv_quantity = '10'
      iv_complete = abap_true ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a delivery completed item brings nothing more, whatever is open on it' ).

  ENDMETHOD.

  METHOD technically_complete_is_out.

    given_order(
      iv_aufnr    = 'PPO-0000010'
      iv_quantity = '10' ).
    given_status(
      iv_aufnr = 'PPO-0000010'
      iv_stat  = 'I0045' ).

    cl_abap_unit_assert=>assert_initial(
      act = supply( )
      msg = 'a technically complete order will not deliver the rest of its quantity' ).

  ENDMETHOD.

  METHOD closed_order_is_out.

    given_order(
      iv_aufnr    = 'PPO-0000011'
      iv_quantity = '10' ).
    given_status(
      iv_aufnr = 'PPO-0000011'
      iv_stat  = 'I0046' ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD deletion_flag_is_out.

    given_order(
      iv_aufnr    = 'PPO-0000012'
      iv_quantity = '10' ).
    given_status(
      iv_aufnr = 'PPO-0000012'
      iv_stat  = 'I0076' ).

    cl_abap_unit_assert=>assert_initial( supply( ) ).

  ENDMETHOD.

  METHOD an_old_status_does_not_count.

    given_order(
      iv_aufnr    = 'PPO-0000013'
      iv_quantity = '10' ).
    given_status(
      iv_aufnr = 'PPO-0000013'
      iv_stat  = 'I0045'
      iv_inact = 'X' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' ) )
      msg = 'an inactive row is a status the order had and has no longer' ).

  ENDMETHOD.

  METHOD order_unit_becomes_base_unit.

    given_order(
      iv_aufnr    = 'PPO-0000014'
      iv_quantity = '2'
      iv_meins    = 'CAR' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '24' ) )
      msg = 'two cartons of twelve come off the line as twenty four pieces' ).

  ENDMETHOD.

  METHOD every_item_of_an_order_counts.

    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.

    given_order(
      iv_aufnr    = 'PPO-0000015'
      iv_quantity = '10' ).

    lt_afpo = VALUE #(
      ( mandt = sy-mandt
        aufnr = 'PPO-0000015'
        posnr = '0002'
        matnr = c_matnr
        dwerk = c_werks
        meins = 'PC'
        psmng = '5'
        wemng = 0
        ltrmp = '20260315' ) ).

    INSERT afpo FROM TABLE @lt_afpo.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'AFPO fixture could not be inserted' ).

    cl_abap_unit_assert=>assert_equals(
      act = supply( )
      exp = VALUE zif_supply_reader=>ty_supply_tab(
        ( avail_date = '20260301' quantity = '10' )
        ( avail_date = '20260315' quantity = '5' ) )
      msg = 'two items of one order deliver on two days and stay apart' ).

  ENDMETHOD.

ENDCLASS.
