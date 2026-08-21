CLASS ltcl_so_demand_reader DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr     TYPE vbap-matnr VALUE 'SO-DEMAND-01'.
    CONSTANTS c_matnr_2   TYPE vbap-matnr VALUE 'SO-DEMAND-02'.
    CONSTANTS c_matnr_blk TYPE vbap-matnr VALUE 'SO-DEMAND-03'.
    CONSTANTS c_matnr_crd TYPE vbap-matnr VALUE 'SO-DEMAND-06'.
    CONSTANTS c_matnr_cr2 TYPE vbap-matnr VALUE 'SO-DEMAND-07'.
    CONSTANTS c_matnr_bli TYPE vbap-matnr VALUE 'SO-DEMAND-04'.
    CONSTANTS c_matnr_mto TYPE vbap-matnr VALUE 'SO-DEMAND-05'.
    CONSTANTS c_werks     TYPE vbap-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_demand_reader.

    METHODS setup.
    METHODS teardown.
    METHODS reads_open_items FOR TESTING RAISING cx_static_check.
    METHODS skips_rejected_items FOR TESTING RAISING cx_static_check.
    METHODS skips_blocked_headers FOR TESTING RAISING cx_static_check.
    METHODS skips_credit_blocked FOR TESTING RAISING cx_static_check.
    METHODS credit_blocked_not_listed FOR TESTING.
    METHODS a_released_order_is_read FOR TESTING RAISING cx_static_check.
    METHODS skips_blocked_items FOR TESTING RAISING cx_static_check.
    METHODS skips_blocked_lines FOR TESTING RAISING cx_static_check.
    METHODS all_lines_blocked_is_nothing FOR TESTING RAISING cx_static_check.
    METHODS blocked_item_not_listed FOR TESTING.
    METHODS special_stock_is_not_demand FOR TESTING RAISING cx_static_check.
    METHODS special_stock_not_listed FOR TESTING.
    METHODS skips_other_plants FOR TESTING RAISING cx_static_check.
    METHODS missing_lprio_sorts_last FOR TESTING RAISING cx_static_check.
    METHODS lists_materials_with_demand FOR TESTING.
    METHODS each_material_listed_once FOR TESTING.
    METHODS blocked_material_not_listed FOR TESTING.
    METHODS sales_unit_becomes_base_unit FOR TESTING RAISING cx_static_check.
    METHODS delivered_part_is_off_demand FOR TESTING RAISING cx_static_check.
    METHODS fully_delivered_drops_out FOR TESTING RAISING cx_static_check.
    METHODS deliveries_of_an_item_add_up FOR TESTING RAISING cx_static_check.
    METHODS other_reference_is_ignored FOR TESTING RAISING cx_static_check.
    METHODS complete_delivery_is_flagged FOR TESTING RAISING cx_static_check.
    METHODS each_schedule_line_apart FOR TESTING RAISING cx_static_check.
    METHODS delivered_covers_earliest FOR TESTING RAISING cx_static_check.
    METHODS no_schedule_uses_order_date FOR TESTING RAISING cx_static_check.

    "! A schedule line of order 0000004712 item 000010, whose order quantity is
    "! 7 and whose header asks for 15 January.
    METHODS given_schedule_line
      IMPORTING
        iv_etenr TYPE vbep-etenr
        iv_edatu TYPE vbep-edatu
        iv_wmeng TYPE vbep-wmeng
        iv_posnr TYPE vbep-posnr DEFAULT '000010'
        iv_lifsp TYPE vbep-lifsp DEFAULT space.

    METHODS given_delivery
      IMPORTING
        iv_vbeln TYPE lips-vbeln
        iv_posnr TYPE lips-posnr
        iv_vgbel TYPE lips-vgbel
        iv_vgpos TYPE lips-vgpos
        iv_lgmng TYPE lips-lgmng
        iv_vgtyp TYPE lips-vgtyp DEFAULT 'C'.

ENDCLASS.


CLASS ltcl_so_demand_reader IMPLEMENTATION.

  METHOD setup.

    DATA lt_vbak TYPE STANDARD TABLE OF vbak WITH EMPTY KEY.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    mo_cut = NEW zcl_so_demand_reader( NEW zcl_unit_converter( ) ).

    " the orders below are in PC, which is also the base unit, except for the
    " one item in CAR that proves the conversion happens
    lt_mara = VALUE #(
      ( mandt = sy-mandt matnr = c_matnr mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_2 mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_blk mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_crd mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_cr2 mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_bli mtart = 'FERT' meins = 'PC' )
      ( mandt = sy-mandt matnr = c_matnr_mto mtart = 'FERT' meins = 'PC' ) ).

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

    " every component is spelled out per row on purpose, see ANOMALIES.md
    lt_vbak = VALUE #(
      ( mandt = sy-mandt vbeln = '0000004711' auart = 'TA' vkorg = '1000' vdatu = '20260210' )
      ( mandt = sy-mandt vbeln = '0000004712' auart = 'TA' vkorg = '1000' vdatu = '20260115' )
      ( mandt = sy-mandt vbeln = '0000004713' auart = 'TA' vkorg = '1000' vdatu = '20260120'
        lifsk = '01' )
      ( mandt = sy-mandt vbeln = '0000004714' auart = 'TA' vkorg = '1000' vdatu = '20260125'
        cmgst = 'B' )
      ( mandt = sy-mandt vbeln = '0000004715' auart = 'TA' vkorg = '1000' vdatu = '20260125'
        cmgst = 'C' ) ).

    lt_vbap = VALUE #(
      ( mandt = sy-mandt vbeln = '0000004711' posnr = '000010'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '10' lprio = '02' )
      ( mandt = sy-mandt vbeln = '0000004711' posnr = '000020'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '5' lprio = '01' abgru = '01' )
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000010'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '7' lprio = '01' )
      ( mandt = sy-mandt vbeln = '0000004713' posnr = '000010'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '3' lprio = '01' )
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000020'
        matnr = c_matnr werks = '2000' vrkme = 'PC' kwmeng = '9' lprio = '01' )
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000040'
        matnr = c_matnr_2 werks = c_werks vrkme = 'PC' kwmeng = '2' lprio = '01' )
      ( mandt = sy-mandt vbeln = '0000004713' posnr = '000020'
        matnr = c_matnr_blk werks = c_werks vrkme = 'PC' kwmeng = '2' lprio = '01' )
      ( mandt = sy-mandt vbeln = '0000004711' posnr = '000030'
        matnr = c_matnr_bli werks = c_werks vrkme = 'PC' kwmeng = '6' lprio = '01'
        lifsp = '02' )
      ( mandt = sy-mandt vbeln = '0000004711' posnr = '000040'
        matnr = c_matnr_mto werks = c_werks vrkme = 'PC' kwmeng = '8' lprio = '01'
        sobkz = 'E' )
      ( mandt = sy-mandt vbeln = '0000004714' posnr = '000010'
        matnr = c_matnr_crd werks = c_werks vrkme = 'PC' kwmeng = '4' lprio = '01' )
      ( mandt = sy-mandt vbeln = '0000004715' posnr = '000010'
        matnr = c_matnr_cr2 werks = c_werks vrkme = 'PC' kwmeng = '3' lprio = '01' ) ).

    INSERT vbak FROM TABLE @lt_vbak.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBAK fixture could not be inserted' ).

    INSERT vbap FROM TABLE @lt_vbap.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBAP fixture could not be inserted' ).

  ENDMETHOD.

  METHOD teardown.

    DELETE FROM vbap WHERE matnr IN ( @c_matnr, @c_matnr_2, @c_matnr_blk,
                                   @c_matnr_bli, @c_matnr_mto, @c_matnr_crd,
                                   @c_matnr_cr2 ).
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBAP fixture could not be removed' ).

    DELETE FROM vbak WHERE vbeln IN ( '0000004711', '0000004712', '0000004713',
                                      '0000004714', '0000004715' ).
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBAK fixture could not be removed' ).

    DELETE FROM lips WHERE matnr IN ( @c_matnr, @c_matnr_2, @c_matnr_blk,
                                   @c_matnr_bli, @c_matnr_mto, @c_matnr_crd,
                                   @c_matnr_cr2 ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM vbep WHERE vbeln IN ( '0000004711', '0000004712', '0000004713',
                                      '0000004714', '0000004715' ).
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM marm WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

    DELETE FROM mara WHERE matnr IN ( @c_matnr, @c_matnr_2, @c_matnr_blk,
                                   @c_matnr_bli, @c_matnr_mto, @c_matnr_crd,
                                   @c_matnr_cr2 ).
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'material master fixture could not be removed' ).

  ENDMETHOD.

  METHOD reads_open_items.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand
      exp = VALUE zif_allocation=>ty_demand_tab(
        ( demand_id = '00000047110000100000' matnr = c_matnr werks = c_werks
          quantity = '10' req_date = '20260210' priority = '02' unit_size = '1' )
        ( demand_id = '00000047120000100000' matnr = c_matnr werks = c_werks
          quantity = '7' req_date = '20260115' priority = '01' unit_size = '1' ) ) ).

  ENDMETHOD.

  METHOD skips_rejected_items.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_not_initial( lt_demand ).
    LOOP AT lt_demand INTO DATA(ls_demand).
      cl_abap_unit_assert=>assert_differs(
        act = ls_demand-demand_id
        exp = '00000047110000200000'
        msg = 'item with a reason for rejection must not be returned' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD skips_blocked_headers.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    LOOP AT lt_demand INTO DATA(ls_demand).
      cl_abap_unit_assert=>assert_differs(
        act = ls_demand-demand_id
        exp = '00000047130000100000'
        msg = 'item of a delivery blocked order must not be returned' ).
    ENDLOOP.

  ENDMETHOD.

  METHOD skips_blocked_items.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr_bli
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_demand
      msg = 'a delivery blocked item is not going to ship, so it takes no stock' ).

  ENDMETHOD.

  METHOD skips_blocked_lines.

    given_schedule_line(
      iv_etenr = '0001'
      iv_edatu = '20260120'
      iv_wmeng = '4' ).
    given_schedule_line(
      iv_etenr = '0002'
      iv_edatu = '20260220'
      iv_wmeng = '3'
      iv_lifsp = '01' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100001' ]-quantity
      exp = '4'
      msg = 'a block on one date says nothing about the others' ).
    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_demand[ demand_id = '00000047120000100002' ] ) )
      msg = 'a blocked schedule line must not compete for stock' ).

  ENDMETHOD.

  METHOD all_lines_blocked_is_nothing.

    DATA lt_extra TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    lt_extra = VALUE #(
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000070'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '8' lprio = '01' ) ).
    INSERT vbap FROM TABLE @lt_extra.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).

    given_schedule_line(
      iv_posnr = '000070'
      iv_etenr = '0001'
      iv_edatu = '20260120'
      iv_wmeng = '8'
      iv_lifsp = '01' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_demand[ demand_id = '00000047120000700001' ] ) )
      msg = 'the blocked line itself is out' ).
    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_demand[ demand_id = '00000047120000700000' ] ) )
      msg = 'and the item must not come back as if it had no schedule line at all' ).

  ENDMETHOD.

  METHOD blocked_item_not_listed.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_matnr_bli ] ) )
      msg = 'a material whose only item is delivery blocked has nothing to allocate' ).

  ENDMETHOD.

  METHOD special_stock_is_not_demand.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr_mto
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_demand
      msg = 'an item with a stock segment of its own must not take the free pool' ).

  ENDMETHOD.

  METHOD special_stock_not_listed.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_matnr_mto ] ) )
      msg = 'a material whose only demand is made to order has nothing to allocate' ).

  ENDMETHOD.

  METHOD skips_other_plants.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    LOOP AT lt_demand INTO DATA(ls_demand).
      cl_abap_unit_assert=>assert_equals(
        act = ls_demand-werks
        exp = c_werks ).
    ENDLOOP.

  ENDMETHOD.

  METHOD lists_materials_with_demand.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->materials_with_demand( c_werks )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_matnr ) ( c_matnr_2 ) ( c_matnr_cr2 ) ) ).

  ENDMETHOD.

  METHOD each_material_listed_once.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    " c_matnr is on two open items of two different orders
    cl_abap_unit_assert=>assert_equals(
      act = lines( VALUE zif_demand_reader=>ty_matnr_tab(
        FOR lv_matnr IN lt_matnr WHERE ( table_line = c_matnr ) ( lv_matnr ) ) )
      exp = 1
      msg = 'a material must be allocated once per run, not once per order' ).

  ENDMETHOD.

  METHOD blocked_material_not_listed.

    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_matnr_blk ] ) )
      msg = 'a material whose only order is delivery blocked has nothing to allocate' ).

  ENDMETHOD.

  METHOD sales_unit_becomes_base_unit.

    DATA lt_extra TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    lt_extra = VALUE #(
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000050'
        matnr = c_matnr werks = c_werks vrkme = 'CAR' kwmeng = '3' lprio = '01' ) ).
    INSERT vbap FROM TABLE @lt_extra.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000500000' ]-quantity
      exp = '36'
      msg = 'three cartons of twelve compete for thirty six pieces of stock' ).

  ENDMETHOD.

  METHOD given_delivery.

    DATA lt_lips TYPE STANDARD TABLE OF lips WITH EMPTY KEY.

    lt_lips = VALUE #(
      ( mandt = sy-mandt vbeln = iv_vbeln posnr = iv_posnr
        matnr = c_matnr werks = c_werks vgtyp = iv_vgtyp
        vgbel = iv_vgbel vgpos = iv_vgpos
        lgmng = iv_lgmng meins = 'PC' ) ).

    INSERT lips FROM TABLE @lt_lips.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'LIPS fixture could not be inserted' ).

  ENDMETHOD.

  METHOD delivered_part_is_off_demand.

    given_delivery(
      iv_vbeln = '0080000001'
      iv_posnr = '000010'
      iv_vgbel = '0000004711'
      iv_vgpos = '000010'
      iv_lgmng = '2.5' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047110000100000' ]-quantity
      exp = '7.5'
      msg = 'what has been delivered is no longer waiting for stock' ).

  ENDMETHOD.

  METHOD fully_delivered_drops_out.

    given_delivery(
      iv_vbeln = '0080000002'
      iv_posnr = '000010'
      iv_vgbel = '0000004711'
      iv_vgpos = '000010'
      iv_lgmng = '10' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand
      exp = VALUE zif_allocation=>ty_demand_tab(
        ( demand_id = '00000047120000100000' matnr = c_matnr werks = c_werks
          quantity = '7' req_date = '20260115' priority = '01' unit_size = '1' ) )
      msg = 'an item delivered in full has nothing left to ask for' ).

  ENDMETHOD.

  METHOD deliveries_of_an_item_add_up.

    given_delivery(
      iv_vbeln = '0080000003'
      iv_posnr = '000010'
      iv_vgbel = '0000004712'
      iv_vgpos = '000010'
      iv_lgmng = '3' ).

    given_delivery(
      iv_vbeln = '0080000004'
      iv_posnr = '000010'
      iv_vgbel = '0000004712'
      iv_vgpos = '000010'
      iv_lgmng = '1.5' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100000' ]-quantity
      exp = '2.5'
      msg = 'an item delivered in several goes is netted by all of them' ).

  ENDMETHOD.

  METHOD other_reference_is_ignored.

    " same numbers, but the delivery item was created from something that is
    " not a sales order, so it says nothing about this order item
    given_delivery(
      iv_vbeln = '0080000005'
      iv_posnr = '000010'
      iv_vgbel = '0000004711'
      iv_vgpos = '000010'
      iv_lgmng = '4'
      iv_vgtyp = 'V' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047110000100000' ]-quantity
      exp = '10'
      msg = 'only a delivery of this sales order item may net it off' ).

  ENDMETHOD.

  METHOD complete_delivery_is_flagged.

    DATA lt_extra TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    lt_extra = VALUE #(
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000060'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '4' lprio = '01'
        kztlf = 'C' ) ).
    INSERT vbap FROM TABLE @lt_extra.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000600000' ]-complete
      exp = abap_true
      msg = 'KZTLF = C means the customer takes the item in one delivery' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100000' ]-complete
      exp = abap_false
      msg = 'an item without the indicator may ship in parts' ).

  ENDMETHOD.

  METHOD given_schedule_line.

    DATA lt_vbep TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.

    lt_vbep = VALUE #(
      ( mandt = sy-mandt
        vbeln = '0000004712'
        posnr = iv_posnr
        etenr = iv_etenr
        edatu = iv_edatu
        wmeng = iv_wmeng
        lifsp = iv_lifsp ) ).

    INSERT vbep FROM TABLE @lt_vbep.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBEP fixture could not be inserted' ).

  ENDMETHOD.

  METHOD each_schedule_line_apart.

    given_schedule_line(
      iv_etenr = '0001'
      iv_edatu = '20260120'
      iv_wmeng = '4' ).
    given_schedule_line(
      iv_etenr = '0002'
      iv_edatu = '20260220'
      iv_wmeng = '3' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100001' ]-quantity
      exp = '4'
      msg = 'a quantity wanted on a date is one requirement' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100001' ]-req_date
      exp = '20260120'
      msg = 'and it is wanted on its own date, not the date of the order' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100002' ]-quantity
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100002' ]-req_date
      exp = '20260220'
      msg = 'a line due in a month must not compete as if it were due now' ).

  ENDMETHOD.

  METHOD delivered_covers_earliest.

    given_schedule_line(
      iv_etenr = '0001'
      iv_edatu = '20260120'
      iv_wmeng = '4' ).
    given_schedule_line(
      iv_etenr = '0002'
      iv_edatu = '20260220'
      iv_wmeng = '3' ).

    " five of the seven have gone out already
    given_delivery(
      iv_vbeln = '0080000010'
      iv_posnr = '000010'
      iv_vgbel = '0000004712'
      iv_vgpos = '000010'
      iv_lgmng = '5' ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_demand[ demand_id = '00000047120000100001' ] ) )
      msg = 'the goods leave in date order, so the first line is served first' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000100002' ]-quantity
      exp = '2'
      msg = 'and what is left of the delivery comes off the next line' ).

  ENDMETHOD.

  METHOD no_schedule_uses_order_date.

    " order 0000004711 item 000010 has no schedule line of its own
    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047110000100000' ]-req_date
      exp = '20260210'
      msg = 'an item with no schedule line is wanted when the order asks' ).

  ENDMETHOD.

  METHOD missing_lprio_sorts_last.

    DATA lt_extra TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    lt_extra = VALUE #(
      ( mandt = sy-mandt vbeln = '0000004712' posnr = '000030'
        matnr = c_matnr werks = c_werks vrkme = 'PC' kwmeng = '1' ) ).
    INSERT vbap FROM TABLE @lt_extra.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ demand_id = '00000047120000300000' ]-priority
      exp = '99'
      msg = 'an item without delivery priority must not jump the queue' ).

  ENDMETHOD.

  METHOD skips_credit_blocked.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->read_open_demand( iv_matnr = c_matnr_crd
                                      iv_werks = c_werks )
      msg = 'an order finance has blocked cannot be delivered, so it takes no stock' ).

  ENDMETHOD.

  METHOD credit_blocked_not_listed.

    " assigned first: the parser cannot read an index on a method call, see
    " ANOMALIES.md
    DATA(lt_matnr) = mo_cut->materials_with_demand( c_werks ).

    cl_abap_unit_assert=>assert_false(
      act = xsdbool( line_exists( lt_matnr[ table_line = c_matnr_crd ] ) )
      msg = 'and a material only such an order wants is not worth a run of its own' ).

  ENDMETHOD.

  METHOD a_released_order_is_read.

    " released, not carried out, partly released: everything but B is an order
    " that can ship, and leaving those out would starve half the book
    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr_cr2
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demand )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demand[ 1 ]-demand_id+0(10)
      exp = '0000004715' ).

  ENDMETHOD.

ENDCLASS.
