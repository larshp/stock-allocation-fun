CLASS ltcl_so_demand_reader DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_matnr TYPE vbap-matnr VALUE 'SO-DEMAND-01'.
    CONSTANTS c_werks TYPE vbap-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_demand_reader.

    METHODS setup.
    METHODS teardown.
    METHODS reads_open_items FOR TESTING.
    METHODS skips_rejected_items FOR TESTING.
    METHODS skips_blocked_headers FOR TESTING.
    METHODS skips_other_plants FOR TESTING.
    METHODS missing_lprio_sorts_last FOR TESTING.

ENDCLASS.


CLASS ltcl_so_demand_reader IMPLEMENTATION.

  METHOD setup.

    DATA lt_vbak TYPE STANDARD TABLE OF vbak WITH EMPTY KEY.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.

    mo_cut = NEW zcl_so_demand_reader( ).

    lt_vbak = VALUE #(
      mandt = sy-mandt
      auart = 'TA'
      vkorg = '1000'
      ( vbeln = '0000004711' vdatu = '20260210' )
      ( vbeln = '0000004712' vdatu = '20260115' )
      ( vbeln = '0000004713' vdatu = '20260120' lifsk = '01' ) ).

    lt_vbap = VALUE #(
      mandt = sy-mandt
      matnr = c_matnr
      werks = c_werks
      vrkme = 'PC'
      ( vbeln = '0000004711' posnr = '000010' kwmeng = '10' lprio = '02' )
      ( vbeln = '0000004711' posnr = '000020' kwmeng = '5'  lprio = '01' abgru = '01' )
      ( vbeln = '0000004712' posnr = '000010' kwmeng = '7'  lprio = '01' )
      ( vbeln = '0000004713' posnr = '000010' kwmeng = '3'  lprio = '01' )
      ( vbeln = '0000004712' posnr = '000020' kwmeng = '9'  lprio = '01' werks = '2000' ) ).

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

    DELETE FROM vbap WHERE matnr = @c_matnr.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBAP fixture could not be removed' ).

    DELETE FROM vbak WHERE vbeln IN ( '0000004711', '0000004712', '0000004713' ).
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'VBAK fixture could not be removed' ).

  ENDMETHOD.

  METHOD reads_open_items.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demand
      exp = VALUE zif_allocation=>ty_demand_tab(
        matnr = c_matnr
        werks = c_werks
        ( demand_id = '0000004711000010' quantity = '10' req_date = '20260210' priority = '02' )
        ( demand_id = '0000004712000010' quantity = '7'  req_date = '20260115' priority = '01' ) ) ).

  ENDMETHOD.

  METHOD skips_rejected_items.

    DATA(lt_demand) = mo_cut->read_open_demand(
      iv_matnr = c_matnr
      iv_werks = c_werks ).

    cl_abap_unit_assert=>assert_not_initial( lt_demand ).
    LOOP AT lt_demand INTO DATA(ls_demand).
      cl_abap_unit_assert=>assert_differs(
        act = ls_demand-demand_id
        exp = '0000004711000020'
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
        exp = '0000004713000010'
        msg = 'item of a delivery blocked order must not be returned' ).
    ENDLOOP.

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
      act = lt_demand[ demand_id = '0000004712000030' ]-priority
      exp = '99'
      msg = 'an item without delivery priority must not jump the queue' ).

  ENDMETHOD.

ENDCLASS.
