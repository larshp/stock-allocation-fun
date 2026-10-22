CLASS ltcl_prod_order_read_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_order_items FOR TESTING RAISING cx_static_check.
    METHODS reads_active_order_statuses FOR TESTING RAISING cx_static_check.
    METHODS filters_finish_receipt_state FOR TESTING
      RAISING cx_static_check.
    METHODS reads_confirmations FOR TESTING RAISING cx_static_check.
    METHODS searches_confirmation_window FOR TESTING
      RAISING cx_static_check.
    METHODS filters_deleted_conf_orders FOR TESTING
      RAISING cx_static_check.
    METHODS reads_operations FOR TESTING RAISING cx_static_check.
    METHODS skips_empty_requests FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_prod_order_read_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_afko TYPE STANDARD TABLE OF afko WITH EMPTY KEY.
    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.
    DATA lt_aufk TYPE STANDARD TABLE OF aufk WITH EMPTY KEY.
    DATA lt_afvc TYPE STANDARD TABLE OF afvc WITH EMPTY KEY.
    DATA lt_crhd TYPE STANDARD TABLE OF crhd WITH EMPTY KEY.
    DATA lt_afru TYPE STANDARD TABLE OF afru WITH EMPTY KEY.
    DATA lt_jest TYPE STANDARD TABLE OF jest WITH EMPTY KEY.
    DATA lt_tj02t TYPE STANDARD TABLE OF tj02t WITH EMPTY KEY.
    DATA lt_tj30t TYPE STANDARD TABLE OF tj30t WITH EMPTY KEY.

    APPEND 'AFKO' TO lt_tables.
    APPEND 'AFPO' TO lt_tables.
    APPEND 'AUFK' TO lt_tables.
    APPEND 'AFVC' TO lt_tables.
    APPEND 'CRHD' TO lt_tables.
    APPEND 'AFRU' TO lt_tables.
    APPEND 'PRPS' TO lt_tables.
    APPEND 'JEST' TO lt_tables.
    APPEND 'TJ02T' TO lt_tables.
    APPEND 'TJ30T' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #(
      aufnr = '1001'
      autyp = '10'
      phas1 = 'X'
      phas2 = 'X'
      objnr = 'OBJ1001'
      stsma = 'ZPROD' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = '1002'
      autyp = '40'
      phas1 = 'X'
      phas3 = 'X'
      objnr = 'OBJ1002'
      stsma = 'ZPROC' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = '1003'
      autyp = '20'
      objnr = 'OBJ1003'
      stsma = 'ZOTHER' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = '9004'
      autyp = '10'
      loekz = 'X' ) TO lt_aufk.
    APPEND VALUE #(
      aufnr = '9005'
      autyp = '10' ) TO lt_aufk.

    APPEND VALUE #(
      aufnr = '1001'
      aufpl = '0000000001'
      gstrp = '20260101'
      gltrp = '20260120' ) TO lt_afko.
    APPEND VALUE #(
      aufnr = '1002'
      aufpl = '0000000002'
      gstrp = '20260102'
      gltrp = '20260121' ) TO lt_afko.
    APPEND VALUE #(
      aufnr = '1003'
      aufpl = '0000000003'
      gstrp = '20260103'
      gltrp = '20260122' ) TO lt_afko.

    APPEND VALUE #(
      aufnr = '1001'
      posnr = '0002'
      matnr = 'MAT-1'
      werks = '1000'
      psmng = '10.000'
      wemng = '4.000'
      umrez = 12
      umren = 1
      wepos = 'X'
      amein = 'CS'
      meins = 'EA' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = '1001'
      posnr = '0001'
      matnr = 'MAT-0'
      werks = '1000'
      psmng = '5.000'
      wemng = '1.000'
      umrez = 1
      umren = 1
      meins = 'EA' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = '1002'
      posnr = '0001'
      matnr = 'MAT-2'
      werks = '2000'
      psmng = '7.000'
      wemng = '2.000'
      wepos = 'X'
      elikz = 'X'
      amein = 'BOX'
      meins = 'EA' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = '1003'
      posnr = '0001'
      matnr = 'MAT-3'
      werks = '3000'
      psmng = '3.000' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = '9004'
      posnr = '0001'
      matnr = 'MAT-4'
      werks = '4000'
      psmng = '4.000' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = '9005'
      posnr = '0001'
      matnr = 'MAT-5'
      werks = '5000'
      psmng = '5.000'
      xloek = 'X' ) TO lt_afpo.
    APPEND VALUE #(
      aufnr = '9999'
      posnr = '0001'
      matnr = 'MAT-9'
      werks = '9000'
      psmng = '9.000' ) TO lt_afpo.

    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000002'
      arbid = '00000002'
      plnfl = '000001'
      vornr = '0020'
      ltxa1 = 'Inspect component'
      steus = 'QM01' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000001'
      arbid = '00000001'
      plnfl = '000001'
      vornr = '0010'
      ltxa1 = 'Make component'
      steus = 'PP01' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000003'
      plnfl = '000001'
      vornr = '0020'
      uvorn = '0001'
      ltxa1 = 'Inspect suboperation'
      steus = 'QM01' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000004'
      arbid = '00000004'
      plnfl = '000002'
      vornr = '0020'
      ltxa1 = 'Inspect alternate sequence'
      steus = 'QM02' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000005'
      arbid = '00000005'
      plnfl = '000002'
      vornr = '0030'
      ltxa1 = 'Pack alternate sequence'
      steus = 'PP03' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000002'
      aplzl = '00000001'
      arbid = '00000003'
      plnfl = '000002'
      vornr = '0010'
      ltxa1 = 'Process order operation'
      steus = 'PP02' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000009004'
      aplzl = '00000001'
      vornr = '0010'
      plnfl = '000001'
      ltxa1 = 'Deleted order operation' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000009005'
      aplzl = '00000001'
      vornr = '0010'
      plnfl = '000001'
      ltxa1 = 'Deleted item operation' ) TO lt_afvc.

    APPEND VALUE #(
      objty = 'A' objid = '00000001' arbpl = 'WC-01' werks = '1000' )
      TO lt_crhd.
    APPEND VALUE #(
      objty = 'A' objid = '00000002' arbpl = 'WC-02' werks = '1000' )
      TO lt_crhd.
    APPEND VALUE #(
      objty = 'A' objid = '00000003' arbpl = 'WC-03' werks = '2000' )
      TO lt_crhd.
    APPEND VALUE #(
      objty = 'A' objid = '00000004' arbpl = 'WC-04' werks = '1000' )
      TO lt_crhd.
    APPEND VALUE #(
      objty = 'A' objid = '00000005' arbpl = 'WC-05' werks = '1000' )
      TO lt_crhd.

    APPEND VALUE #(
      rueck = '0000000003'
      rmzhl = '00000002'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000002'
      budat = '20260112'
      erzet = '000000'
      isdd  = '20260109'
      isdz  = '070000'
      iedd  = '20260109'
      iedz  = '080000'
      aueru = 'X'
      stokz = 'X'
      lmnga = '9.000'
      rmnga = '1.000'
      xmnga = '0.500'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000002'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000001'
      budat = '20260112'
      erzet = '120000'
      isdd  = '20260111'
      isdz  = '090000'
      iedd  = '20260111'
      iedz  = '100000'
      lmnga = '8.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000001'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000001'
      budat = '20260110'
      erzet = '170000'
      isdd  = '20260110'
      isdz  = '080000'
      iedd  = '20260110'
      iedz  = '090000'
      lmnga = '6.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000004'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000099'
      budat = '20260114'
      erzet = '170000'
      lmnga = '10.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000005'
      rmzhl = '00000001'
      aufnr = '1002'
      aufpl = '0000000002'
      aplzl = '00000001'
      budat = '20260109'
      erzet = '170000'
      lmnga = '7.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000006'
      rmzhl = '00000001'
      aufnr = '1003'
      aufpl = '0000000003'
      aplzl = '00000001'
      budat = '20260115'
      erzet = '170000'
      lmnga = '3.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000007'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000003'
      budat = '20260112'
      erzet = '170000'
      lmnga = '4.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000008'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000003'
      budat = '20260112'
      erzet = '170000'
      aueru = 'X'
      lmnga = '5.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000010'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000005'
      budat = '20260112'
      erzet = '170000'
      lmnga = '1.000'
      meinh = 'BOX' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000009'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000004'
      budat = '20260112'
      erzet = '170000'
      lmnga = '2.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000094'
      rmzhl = '00000001'
      aufnr = '9004'
      aufpl = '0000009004'
      aplzl = '00000001'
      budat = '20260110'
      erzet = '170000'
      lmnga = '4.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000095'
      rmzhl = '00000001'
      aufnr = '9005'
      aufpl = '0000009005'
      aplzl = '00000001'
      budat = '20260110'
      erzet = '170000'
      lmnga = '5.000'
      meinh = 'EA' ) TO lt_afru.

    APPEND VALUE #(
      objnr = 'OBJ1001'
      stat  = 'I0002'
      chgnr = '001' ) TO lt_jest.
    APPEND VALUE #(
      objnr = 'OBJ1001'
      stat  = 'E0001'
      chgnr = '001' ) TO lt_jest.
    APPEND VALUE #(
      objnr = 'OBJ1001'
      stat  = 'I0001'
      chgnr = '001'
      inact = 'X' ) TO lt_jest.
    APPEND VALUE #(
      objnr = 'OBJ1002'
      stat  = 'I0009'
      chgnr = '001' ) TO lt_jest.
    APPEND VALUE #(
      objnr = 'OBJ1003'
      stat  = 'I0001'
      chgnr = '001' ) TO lt_jest.

    APPEND VALUE #(
      istat = 'I0002'
      spras = 'E'
      txt04 = 'REL'
      txt30 = 'Released' ) TO lt_tj02t.
    APPEND VALUE #(
      istat = 'I0009'
      spras = 'E'
      txt04 = 'PCNF'
      txt30 = 'Partially confirmed' ) TO lt_tj02t.
    APPEND VALUE #(
      istat = 'I0001'
      spras = 'E'
      txt04 = 'CRTD'
      txt30 = 'Created' ) TO lt_tj02t.
    APPEND VALUE #(
      stsma = 'ZPROD'
      estat = 'E0001'
      spras = 'E'
      txt04 = 'HOLD'
      txt30 = 'Material hold' ) TO lt_tj30t.

    mo_environment->insert_test_data( lt_afko ).
    mo_environment->insert_test_data( lt_afpo ).
    mo_environment->insert_test_data( lt_aufk ).
    mo_environment->insert_test_data( lt_afvc ).
    mo_environment->insert_test_data( lt_crhd ).
    mo_environment->insert_test_data( lt_afru ).
    mo_environment->insert_test_data( lt_jest ).
    mo_environment->insert_test_data( lt_tj02t ).
    mo_environment->insert_test_data( lt_tj30t ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_order_items.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(lt_items) = lo_cut->zif_prod_order_read_repo~read_orders(
      it_production_orders = VALUE #(
        ( '1002' )
        ( '1003' )
        ( '1001' )
        ( '1001' )
        ( '9999' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_items[ 1 ]-production_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV afpo-psmng( '10.000' )
      act = lt_items[ production_order = '1001'
                      production_item = '0002' ]-order_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV afpo-wemng( '4.000' )
      act = lt_items[ production_order = '1001'
                      production_item = '0002' ]-received_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 12
      act = lt_items[ production_order = '1001'
                      production_item = '0002' ]-order_to_base_numerator ).
    cl_abap_unit_assert=>assert_equals(
      exp = '40'
      act = lt_items[ production_order = '1002' ]-order_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260121'
      act = lt_items[ production_order = '1002' ]-basic_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = xsdbool( lt_items[ production_order = '1002' ]-delivery_complete
        = 'X' ) ).
  ENDMETHOD.

  METHOD reads_active_order_statuses.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(lt_statuses) = lo_cut->zif_prod_order_read_repo~read_order_statuses(
      it_production_orders = VALUE #(
        ( '1003' )
        ( '1002' )
        ( '1001' )
        ( '1001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_statuses ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_statuses[ production_order = '1001'
                        status_code = 'E0001' ]-is_user_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'HOLD'
      act = lt_statuses[ production_order = '1001'
                        status_code = 'E0001' ]-status_short_name ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Material hold'
      act = lt_statuses[ production_order = '1001'
                        status_code = 'E0001' ]-status_name ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_statuses[ production_order = '1001'
                        status_code = 'I0002' ]-is_user_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'REL'
      act = lt_statuses[ production_order = '1001'
                        status_code = 'I0002' ]-status_short_name ).
    READ TABLE lt_statuses TRANSPORTING NO FIELDS
      WITH KEY production_order = '1001' status_code = 'I0001'.
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = sy-subrc ).
  ENDMETHOD.

  METHOD filters_finish_receipt_state.
    DATA lt_afko TYPE STANDARD TABLE OF afko WITH EMPTY KEY.
    DATA lt_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.
    DATA lt_aufk TYPE STANDARD TABLE OF aufk WITH EMPTY KEY.
    DATA lt_jest TYPE STANDARD TABLE OF jest WITH EMPTY KEY.

    lt_aufk = VALUE #(
      ( aufnr = '1004' autyp = '10' auart = 'PP01' )
      ( aufnr = '1005' autyp = '10' auart = 'PP02'
        objnr = 'OBJ1005' )
      ( aufnr = '1006' autyp = '10' )
      ( aufnr = '1007' autyp = '10' )
      ( aufnr = '1008' autyp = '10' )
      ( aufnr = '1009' autyp = '10' objnr = 'OBJ1009' )
      ( aufnr = '1010' autyp = '10' ) ).
    lt_afko = VALUE #(
      ( aufnr = '1004' gltrp = '20260120' )
      ( aufnr = '1005' gltrp = '20260120' )
      ( aufnr = '1006' gltrp = '20260120' )
      ( aufnr = '1007' gltrp = '20260120' )
      ( aufnr = '1008' gltrp = '20260120' )
      ( aufnr = '1009' gltrp = '20260121' )
      ( aufnr = '1010' gltrp = '20260201' ) ).
    lt_afpo = VALUE #(
      ( aufnr = '1004' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '10.000' wemng = '0.000' )
      ( aufnr = '1005' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '10.000' wemng = '10.000' )
      ( aufnr = '1006' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '10.000' wemng = '11.000' )
      ( aufnr = '1007' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '0.000' wemng = '0.000' )
      ( aufnr = '1008' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '5.000' wemng = '-1.000' )
      ( aufnr = '1009' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '4.000' wemng = '4.000' )
      ( aufnr = '1010' posnr = '0001' matnr = 'MAT-1'
        werks = '1000' psmng = '12.000' wemng = '4.000' ) ).
    lt_jest = VALUE #(
      ( objnr = 'OBJ1005' stat = 'I0002' chgnr = '001' )
      ( objnr = 'OBJ1009' stat = 'I0002' chgnr = '001' ) ).
    mo_environment->insert_test_data( lt_aufk ).
    mo_environment->insert_test_data( lt_afko ).
    mo_environment->insert_test_data( lt_afpo ).
    mo_environment->insert_test_data( lt_jest ).

    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(ls_selection) = VALUE
      zif_prod_order_read_repo=>ty_order_selection(
        material                       = 'MAT-1'
        plant                          = '1000'
        finish_date_from               = '20260101'
        finish_date_to                 = '20260131'
        filter_receipt_progress_status = abap_true
        receipt_progress_status        =
          zcl_prod_order_read_service=>c_receipt_progress_complete
        maximum_results                = 1 ).

    DATA(lt_complete_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_complete_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1005'
      act = lt_complete_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1009'
      act = lt_complete_keys[ 2 ]-production_order ).

    ls_selection-after_finish_date = '20260120'.
    ls_selection-after_order = '1005'.
    DATA(lt_complete_next_page) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_complete_next_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1009'
      act = lt_complete_next_page[ 1 ]-production_order ).

    ls_selection-active_status_code = 'I0002'.
    DATA(lt_active_complete_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_active_complete_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1009'
      act = lt_active_complete_keys[ 1 ]-production_order ).

    CLEAR ls_selection-after_finish_date.
    CLEAR ls_selection-after_order.
    DATA(lt_active_first_page) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_active_first_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1005'
      act = lt_active_first_page[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1009'
      act = lt_active_first_page[ 2 ]-production_order ).

    CLEAR ls_selection-active_status_code.
    ls_selection-maximum_results = 10.
    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_progress_not_started.
    DATA(lt_not_started_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_not_started_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1004'
      act = lt_not_started_keys[ 1 ]-production_order ).

    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_progress_partial.
    DATA(lt_partial_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_partial_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1001'
      act = lt_partial_keys[ 1 ]-production_order ).

    ls_selection-receipt_progress_status =
      zcl_prod_order_read_service=>c_receipt_over_received.
    DATA(lt_over_received_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_over_received_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_over_received_keys[ 1 ]-production_order ).

    CLEAR ls_selection-receipt_progress_status.
    DATA(lt_invalid_quantity_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_invalid_quantity_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1007'
      act = lt_invalid_quantity_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1008'
      act = lt_invalid_quantity_keys[ 2 ]-production_order ).

    CLEAR ls_selection-filter_receipt_progress_status.
    CLEAR ls_selection-receipt_progress_status.
    CLEAR ls_selection-after_finish_date.
    CLEAR ls_selection-after_order.
    ls_selection-maximum_results = 1.
    ls_selection-filter_received_qty_from = abap_true.
    ls_selection-received_qty_from = 0.
    ls_selection-filter_received_qty_to = abap_true.
    ls_selection-received_qty_to = 0.
    DATA(lt_zero_received_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_zero_received_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1004'
      act = lt_zero_received_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1007'
      act = lt_zero_received_keys[ 2 ]-production_order ).

    ls_selection-received_qty_from = '10.000'.
    ls_selection-received_qty_to = '10.000'.
    DATA(lt_exact_received_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_exact_received_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1005'
      act = lt_exact_received_keys[ 1 ]-production_order ).

    CLEAR ls_selection-filter_received_qty_from.
    CLEAR ls_selection-received_qty_from.
    CLEAR ls_selection-filter_received_qty_to.
    CLEAR ls_selection-received_qty_to.
    ls_selection-filter_received_pct_from = abap_true.
    ls_selection-received_pct_from = '100.00'.
    ls_selection-filter_received_pct_to = abap_true.
    ls_selection-received_pct_to = '110.00'.
    DATA(lt_received_pct_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_received_pct_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1005'
      act = lt_received_pct_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_received_pct_keys[ 2 ]-production_order ).

    ls_selection-after_finish_date = '20260120'.
    ls_selection-after_order = '1005'.
    DATA(lt_received_pct_next_page) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_received_pct_next_page[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1009'
      act = lt_received_pct_next_page[ 2 ]-production_order ).

    CLEAR ls_selection-after_finish_date.
    CLEAR ls_selection-after_order.
    ls_selection-filter_received_pct_to = abap_false.
    CLEAR ls_selection-received_pct_to.
    ls_selection-received_pct_from = '110.00'.
    DATA(lt_over_received_pct_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_over_received_pct_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_over_received_pct_keys[ 1 ]-production_order ).

    ls_selection-filter_received_pct_from = abap_false.
    CLEAR ls_selection-received_pct_from.
    ls_selection-filter_received_pct_to = abap_true.
    ls_selection-received_pct_to = 0.
    DATA(lt_zero_received_pct_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_zero_received_pct_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1004'
      act = lt_zero_received_pct_keys[ 1 ]-production_order ).

    CLEAR ls_selection-filter_received_pct_to.
    CLEAR ls_selection-received_pct_to.
    CLEAR ls_selection-filter_received_pct_from.
    CLEAR ls_selection-received_pct_from.
    ls_selection-finish_date_to = '20260228'.
    ls_selection-filter_unreceived_pct_from = abap_true.
    ls_selection-unreceived_pct_from = '60.00'.
    ls_selection-filter_unreceived_pct_to = abap_true.
    ls_selection-unreceived_pct_to = '70.00'.
    DATA(lt_open_pct_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_open_pct_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1001'
      act = lt_open_pct_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1010'
      act = lt_open_pct_keys[ 2 ]-production_order ).

    ls_selection-after_finish_date = '20260120'.
    ls_selection-after_order = '1001'.
    DATA(lt_open_pct_next_page) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_open_pct_next_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1010'
      act = lt_open_pct_next_page[ 1 ]-production_order ).

    CLEAR ls_selection-after_finish_date.
    CLEAR ls_selection-after_order.
    ls_selection-filter_unreceived_pct_to = abap_false.
    CLEAR ls_selection-unreceived_pct_to.
    ls_selection-unreceived_pct_from = '100.00'.
    DATA(lt_open_pct_from_only) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_open_pct_from_only ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1004'
      act = lt_open_pct_from_only[ 1 ]-production_order ).

    ls_selection-filter_unreceived_pct_from = abap_false.
    CLEAR ls_selection-unreceived_pct_from.
    ls_selection-filter_unreceived_pct_to = abap_true.
    ls_selection-unreceived_pct_to = 0.
    DATA(lt_zero_open_pct_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_zero_open_pct_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1005'
      act = lt_zero_open_pct_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_zero_open_pct_keys[ 2 ]-production_order ).

    ls_selection-after_finish_date = '20260120'.
    ls_selection-after_order = '1006'.
    DATA(lt_zero_open_pct_next_page) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_zero_open_pct_next_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1009'
      act = lt_zero_open_pct_next_page[ 1 ]-production_order ).

    CLEAR ls_selection-after_finish_date.
    CLEAR ls_selection-after_order.
    DATA(ls_order_type_selection) = VALUE
      zif_prod_order_read_repo=>ty_order_selection(
        material          = 'MAT-1'
        plant             = '1000'
        finish_date_from  = '20260101'
        finish_date_to    = '20260131'
        filter_order_type = abap_true
        order_type        = 'PP01'
        maximum_results   = 1 ).
    DATA(lt_order_type_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_order_type_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_order_type_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1004'
      act = lt_order_type_keys[ 1 ]-production_order ).

    CLEAR ls_order_type_selection-order_type.
    DATA(lt_blank_order_type_keys) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_order_type_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_blank_order_type_keys ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1001'
      act = lt_blank_order_type_keys[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_blank_order_type_keys[ 2 ]-production_order ).

    ls_order_type_selection-after_finish_date = '20260120'.
    ls_order_type_selection-after_order = '1001'.
    DATA(lt_blank_order_type_next_page) =
      lo_cut->zif_prod_order_read_repo~read_orders_by_finish_window(
        is_selection = ls_order_type_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_blank_order_type_next_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1006'
      act = lt_blank_order_type_next_page[ 1 ]-production_order ).
  ENDMETHOD.

  METHOD reads_confirmations.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(lt_confirmations) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders = VALUE #(
          ( '1003' )
          ( '1002' )
          ( '1001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 8
      act = lines( lt_confirmations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_confirmations[ confirmation = '0000000003' ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_confirmations[ confirmation = '0000000003' ]-confirmation_counter ).
    cl_abap_unit_assert=>assert_equals(
      exp = '10'
      act = lt_confirmations[ confirmation = '0000000003' ]-order_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_confirmations[ confirmation = '0000000003' ]-operation_counter ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_confirmations[ confirmation = '0000000003' ]-resource_object_id ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV afru-lmnga( '9.000' )
      act = lt_confirmations[ confirmation = '0000000003' ]-yield_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_confirmations[ confirmation = '0000000003' ]-is_final ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_confirmations[ confirmation = '0000000003' ]-is_reversed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = lt_confirmations[ confirmation = '0000000003' ]-operation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Inspect component'
      act = lt_confirmations[ confirmation = '0000000003' ]-operation_description ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'QM01'
      act = lt_confirmations[ confirmation = '0000000003' ]-control_key ).
    DATA(ls_confirmation_three) =
      lt_confirmations[ confirmation = '0000000003' ].
    cl_abap_unit_assert=>assert_equals(
      exp = '20260109'
      act = ls_confirmation_three-execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '070000'
      act = ls_confirmation_three-execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260109'
      act = ls_confirmation_three-execution_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '080000'
      act = ls_confirmation_three-execution_finish_time ).

    DATA(lt_box_confirmations) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders = VALUE #( ( '1001' ) )
        iv_quantity_unit     = 'BOX'
        is_page_selection    = VALUE #(
          maximum_results      = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_box_confirmations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000010'
      act = lt_box_confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_box_confirmations[ 1 ]-quantity_unit ).

    DATA(lt_time_confirmations) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders = VALUE #( ( '1001' ) )
        iv_filter_entry_time = abap_true
        iv_entry_time_from   = '000000'
        iv_entry_time_to     = '120000'
        is_page_selection    = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_time_confirmations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_time_confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_time_confirmations[ 2 ]-confirmation ).

    DATA(lt_execution_start_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders           = VALUE #( ( '1001' ) )
        iv_execution_start_date_from   = '20260110'
        iv_execution_start_date_to     = '20260111'
        iv_filter_execution_start_time = abap_true
        iv_execution_start_time_from   = '080000'
        iv_execution_start_time_to     = '090000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_execution_start_range ) ).
    DATA(ls_execution_start_first) =
      lt_execution_start_range[ confirmation = '0000000001' ].
    DATA(ls_execution_start_second) =
      lt_execution_start_range[ confirmation = '0000000002' ].
    cl_abap_unit_assert=>assert_equals(
      exp = '20260110'
      act = ls_execution_start_first-execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '090000'
      act = ls_execution_start_second-execution_start_time ).

    DATA(lt_paged_execution_start_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders           = VALUE #( ( '1001' ) )
        iv_execution_start_date_from   = '20260110'
        iv_execution_start_date_to     = '20260111'
        iv_filter_execution_start_time = abap_true
        iv_execution_start_time_from   = '080000'
        iv_execution_start_time_to     = '090000'
        is_page_selection              = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_execution_start_range ) ).

    DATA(lt_execution_finish_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders          = VALUE #( ( '1001' ) )
        iv_execution_finish_date_from = '20260109'
        iv_execution_finish_date_to   = '20260110'
        iv_filter_exec_finish_time    = abap_true
        iv_execution_finish_time_from = '080000'
        iv_execution_finish_time_to   = '090000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_execution_finish_range ) ).
    DATA(ls_execution_finish_first) =
      lt_execution_finish_range[ confirmation = '0000000001' ].
    cl_abap_unit_assert=>assert_equals(
      exp = '20260110'
      act = ls_execution_finish_first-execution_finish_date ).

    DATA(lt_work_center_confirmation) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders = VALUE #( ( '1001' ) )
        iv_work_center       = 'WC-02' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_work_center_confirmation ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = lt_work_center_confirmation[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_work_center_confirmation[ 1 ]-work_center_plant ).

    DATA(lt_paged_wc_confirmation) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders = VALUE #( ( '1001' ) )
        iv_work_center       = 'WC-02'
        is_page_selection    = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_paged_wc_confirmation ) ).

    DATA(lt_blank_work_center) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders  = VALUE #( ( '1001' ) )
        iv_filter_work_center = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_blank_work_center ) ).
    LOOP AT lt_blank_work_center INTO DATA(ls_blank_work_center).
      cl_abap_unit_assert=>assert_initial( ls_blank_work_center-work_center ).
    ENDLOOP.

    DATA(lt_paged_blank_work_center) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders  = VALUE #( ( '1001' ) )
        iv_filter_work_center = abap_true
        is_page_selection     = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_blank_work_center ) ).

    DATA(lt_blank_work_center_plant) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_filter_work_center_plant = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_blank_work_center_plant ) ).
    LOOP AT lt_blank_work_center_plant INTO DATA(ls_blank_work_center_plant).
      cl_abap_unit_assert=>assert_initial(
        ls_blank_work_center_plant-work_center_plant ).
    ENDLOOP.

    DATA(lt_page_blank_wc_plant) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_filter_work_center_plant = abap_true
        is_page_selection           = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_page_blank_wc_plant ) ).

    DATA(lt_work_center_plant) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders = VALUE #( ( '1002' ) )
        iv_work_center_plant = '2000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_work_center_plant ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-03'
      act = lt_work_center_plant[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_work_center_plant[ 1 ]-work_center_plant ).

    DATA(lt_box_quality_confirmations) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders          = VALUE #( ( '1001' ) )
        iv_quantity_unit              = 'BOX'
        iv_positive_yield_only        = abap_true
        iv_filter_yield_quantity_from = abap_true
        iv_yield_quantity_from        = CONV afru-lmnga( '1.000' )
        iv_filter_yield_quantity_to   = abap_true
        iv_yield_quantity_to          = CONV afru-lmnga( '1.000' )
        is_page_selection             = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_box_quality_confirmations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000010'
      act = lt_box_quality_confirmations[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV afru-lmnga( '1.000' )
      act = lt_box_quality_confirmations[ 1 ]-yield_quantity ).

    DATA(lt_box_quality_unpaged) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders          = VALUE #( ( '1001' ) )
        iv_quantity_unit              = 'BOX'
        iv_positive_yield_only        = abap_true
        iv_filter_yield_quantity_from = abap_true
        iv_yield_quantity_from        = CONV afru-lmnga( '1.000' )
        iv_filter_yield_quantity_to   = abap_true
        iv_yield_quantity_to          = CONV afru-lmnga( '1.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_box_quality_unpaged ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000010'
      act = lt_box_quality_unpaged[ 1 ]-confirmation ).

    DATA lt_additional_afvc TYPE STANDARD TABLE OF afvc WITH EMPTY KEY.
    DATA lt_additional_afru TYPE STANDARD TABLE OF afru WITH EMPTY KEY.
    lt_additional_afvc = VALUE #(
      ( aufpl = '0000000001'
        aplzl = '00000006'
        plnfl = '000001'
        vornr = '0020'
        uvorn = '0002' ) ).
    lt_additional_afru = VALUE #(
      ( rueck = '0000000012'
        rmzhl = '00000001'
        aufnr = '1001'
        aufpl = '0000000001'
        aplzl = '00000006'
        budat = '20260113'
        meinh = 'EA' )
      ( rueck = '0000000099'
        rmzhl = '00000001'
        aufnr = '1001'
        aufpl = '0000000001'
        aplzl = '00000002'
        budat = '20260114'
        meinh = 'EA' ) ).
    mo_environment->insert_test_data( lt_additional_afvc ).
    mo_environment->insert_test_data( lt_additional_afru ).

    DATA(lt_subop_range) = lo_cut->zif_prod_order_read_repo~read_confirmations(
      it_production_orders        = VALUE #( ( '1001' ) )
      iv_operation_number         = '0020'
      iv_suboperation_number_from = '0001'
      iv_suboperation_number_to   = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_subop_range ) ).
    LOOP AT lt_subop_range INTO DATA(ls_subop_row).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_subop_row-operation_suboperation >= '0001'
          AND ls_subop_row-operation_suboperation <= '0002' ) ).
    ENDLOOP.

    DATA(lt_paged_subop_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_operation_number         = '0020'
        iv_suboperation_number_from = '0001'
        iv_suboperation_number_to   = '0002'
        is_page_selection           = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_subop_range ) ).
    LOOP AT lt_paged_subop_range INTO DATA(ls_paged_subop_row).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_paged_subop_row-operation_suboperation >= '0001'
          AND ls_paged_subop_row-operation_suboperation <= '0002' ) ).
    ENDLOOP.

    DATA(lt_subop_intersect) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_operation_number         = '0020'
        iv_suboperation_number      = '0002'
        iv_suboperation_number_from = '0001'
        iv_suboperation_number_to   = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_subop_intersect ) ).

    DATA(lt_vornr_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number_from = '0020'
        iv_operation_number_to   = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( lt_vornr_range ) ).
    LOOP AT lt_vornr_range INTO DATA(ls_vornr_confirmation).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_vornr_confirmation-operation_number >= '0020'
          AND ls_vornr_confirmation-operation_number <= '0030' ) ).
    ENDLOOP.

    DATA(lt_paged_vornr_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number_from = '0020'
        iv_operation_number_to   = '0030'
        is_page_selection        = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_vornr_range ) ).
    LOOP AT lt_paged_vornr_range INTO DATA(ls_paged_vornr_confirmation).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_paged_vornr_confirmation-operation_number >= '0020'
          AND ls_paged_vornr_confirmation-operation_number <= '0030' ) ).
    ENDLOOP.

    DATA(lt_vornr_intersection) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number      = '0030'
        iv_operation_number_from = '0020'
        iv_operation_number_to   = '0030' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_vornr_intersection ) ).

    DATA(lt_sequence_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders       = VALUE #( ( '1001' ) )
        iv_operation_sequence_from = '000001'
        iv_operation_sequence_to   = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 9
      act = lines( lt_sequence_range ) ).
    LOOP AT lt_sequence_range INTO DATA(ls_sequence_row).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_sequence_row-operation_sequence >= '000001'
          AND ls_sequence_row-operation_sequence <= '000002' ) ).
    ENDLOOP.

    DATA(lt_sequence_lower_only) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders       = VALUE #( ( '1001' ) )
        iv_operation_sequence_from = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_sequence_lower_only ) ).
    DATA(lt_sequence_upper_only) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_sequence_to = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( lt_sequence_upper_only ) ).

    DATA(lt_paged_sequence_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders       = VALUE #( ( '1001' ) )
        iv_operation_sequence_from = '000001'
        iv_operation_sequence_to   = '000002'
        is_page_selection          = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_sequence_range ) ).
    LOOP AT lt_paged_sequence_range
        INTO DATA(ls_paged_sequence_row).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_paged_sequence_row-operation_sequence >= '000001'
          AND ls_paged_sequence_row-operation_sequence <= '000002' ) ).
    ENDLOOP.

    DATA(lt_sequence_intersection) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders         = VALUE #( ( '1001' ) )
        iv_filter_operation_sequence = abap_true
        iv_operation_sequence        = '000001'
        iv_operation_sequence_from   = '000000'
        iv_operation_sequence_to     = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( lt_sequence_intersection ) ).

    DATA(lt_counter_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000004' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_counter_range ) ).
    LOOP AT lt_counter_range INTO DATA(ls_counter_confirmation).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_counter_confirmation-operation_counter >= '00000002'
          AND ls_counter_confirmation-operation_counter <= '00000004' ) ).
    ENDLOOP.
    DATA(lt_counter_lower_only) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter_from = '00000005' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_counter_lower_only ) ).
    DATA(lt_counter_upper_only) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders    = VALUE #( ( '1001' ) )
        iv_operation_counter_to = '00000001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_counter_upper_only ) ).
    DATA(lt_paged_counter_range) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000004'
        is_page_selection         = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_counter_range ) ).
    DATA(lt_counter_intersection) =
      lo_cut->zif_prod_order_read_repo~read_confirmations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter      = '00000003'
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000004' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_counter_intersection ) ).
  ENDMETHOD.

  METHOD searches_confirmation_window.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(ls_selection) = VALUE
      zif_prod_order_read_repo=>ty_confirmation_window_selection(
        material          = 'MAT-1'
        plant             = '1000'
        posting_date_from = '20260110'
        posting_date_to   = '20260112'
        maximum_results   = 2 ).

    DATA(lt_first_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_first_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_first_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Make component'
      act = lt_first_page[ 1 ]-operation_description ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000001'
      act = lt_first_page[ 1 ]-operation_counter ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PP01'
      act = lt_first_page[ 1 ]-control_key ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_first_page[ 2 ]-confirmation ).

    DATA(ls_finish_selection) = ls_selection.
    ls_finish_selection-maximum_results = 10.
    ls_finish_selection-execution_finish_date_from = '20260110'.
    ls_finish_selection-execution_finish_date_to = '20260111'.
    DATA(lt_finish_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_finish_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_finish_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260110'
      act = lt_finish_range[ 1 ]-execution_start_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '080000'
      act = lt_finish_range[ 1 ]-execution_start_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20260110'
      act = lt_finish_range[ 1 ]-execution_finish_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = '090000'
      act = lt_finish_range[ 1 ]-execution_finish_time ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_finish_range[ 2 ]-confirmation ).

    CLEAR ls_finish_selection-execution_finish_date_to.
    ls_finish_selection-execution_finish_date_from = '20260111'.
    DATA(lt_finish_lower) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_finish_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_finish_lower ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_finish_lower[ 1 ]-confirmation ).

    CLEAR ls_finish_selection-execution_finish_date_from.
    ls_finish_selection-execution_finish_date_to = '20260110'.
    DATA(lt_finish_upper) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_finish_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_finish_upper ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_finish_upper[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_finish_upper[ 2 ]-confirmation ).

    DATA(ls_start_selection) = ls_selection.
    ls_start_selection-maximum_results = 10.
    ls_start_selection-execution_start_date_from = '20260110'.
    ls_start_selection-execution_start_date_to = '20260111'.
    DATA(lt_start_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_start_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_start_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_start_range[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_start_range[ 2 ]-confirmation ).

    CLEAR ls_start_selection-execution_start_date_to.
    ls_start_selection-execution_start_date_from = '20260111'.
    DATA(lt_start_lower) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_start_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_start_lower ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_start_lower[ 1 ]-confirmation ).

    CLEAR ls_start_selection-execution_start_date_from.
    ls_start_selection-execution_start_date_to = '20260110'.
    DATA(lt_start_upper) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_start_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_start_upper ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_start_upper[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_start_upper[ 2 ]-confirmation ).

    DATA(ls_start_time_selection) = ls_selection.
    ls_start_time_selection-maximum_results = 10.
    ls_start_time_selection-filter_execution_start_time = abap_true.
    ls_start_time_selection-execution_start_time_from = '000000'.
    ls_start_time_selection-execution_start_time_to = '070000'.
    DATA(lt_start_time_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_start_time_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_start_time_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_start_time_range[ 1 ]-confirmation ).

    DATA(ls_finish_time_selection) = ls_selection.
    ls_finish_time_selection-maximum_results = 10.
    ls_finish_time_selection-filter_execution_finish_time = abap_true.
    ls_finish_time_selection-execution_finish_time_from = '090000'.
    ls_finish_time_selection-execution_finish_time_to = '100000'.
    DATA(lt_finish_time_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_finish_time_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_finish_time_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_finish_time_range[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000002'
      act = lt_finish_time_range[ 2 ]-confirmation ).

    DATA(ls_unasgn_sel) = ls_selection.
    ls_unasgn_sel-maximum_results = 10.
    ls_unasgn_sel-confirmation_number = '0000000007'.
    ls_unasgn_sel-filter_resource_object_id = abap_true.
    DATA(lt_unasgn_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_unasgn_sel ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_unasgn_page ) ).
    DATA(ls_unasgn_conf) = lt_unasgn_page[ 1 ].
    cl_abap_unit_assert=>assert_initial(
      ls_unasgn_conf-resource_object_id ).

    ls_selection-work_center = 'WC-02'.
    DATA(lt_work_center_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_work_center_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = lt_work_center_page[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_work_center_page[ 1 ]-confirmation ).
    CLEAR ls_selection-work_center.

    ls_selection-maximum_results = 1.
    ls_selection-filter_work_center = abap_true.
    DATA(lt_blank_work_center) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_blank_work_center ) ).
    LOOP AT lt_blank_work_center INTO DATA(ls_blank_work_center).
      cl_abap_unit_assert=>assert_initial( ls_blank_work_center-work_center ).
    ENDLOOP.
    CLEAR ls_selection-filter_work_center.

    ls_selection-filter_work_center_plant = abap_true.
    DATA(lt_blank_work_center_plant) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_blank_work_center_plant ) ).
    LOOP AT lt_blank_work_center_plant
        INTO DATA(ls_blank_work_center_plant).
      cl_abap_unit_assert=>assert_initial(
        ls_blank_work_center_plant-work_center_plant ).
    ENDLOOP.
    CLEAR ls_selection-filter_work_center_plant.

    ls_selection-material = 'MAT-2'.
    ls_selection-plant = '2000'.
    ls_selection-posting_date_from = '20260101'.
    ls_selection-posting_date_to = '20260131'.
    ls_selection-maximum_results = 10.
    ls_selection-work_center_plant = '2000'.
    DATA(lt_work_center_plant) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_work_center_plant ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lt_work_center_plant[ 1 ]-work_center_plant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000005'
      act = lt_work_center_plant[ 1 ]-confirmation ).
    CLEAR ls_selection-work_center_plant.

    ls_selection-material = 'MAT-1'.
    ls_selection-plant = '1000'.
    ls_selection-posting_date_from = '20260110'.
    ls_selection-posting_date_to = '20260112'.
    ls_selection-operation_number_from = '0020'.
    ls_selection-operation_number_to = '0020'.
    DATA(lt_operation_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_operation_range ) ).
    LOOP AT lt_operation_range INTO DATA(ls_vornr_range_row).
      cl_abap_unit_assert=>assert_equals(
        exp = '0020'
        act = ls_vornr_range_row-operation_number ).
    ENDLOOP.

    ls_selection-maximum_results = 1.
    ls_selection-operation_number_from = '0030'.
    ls_selection-operation_number_to = '0030'.
    DATA(lt_late_operation_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_late_operation_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = lt_late_operation_page[ 1 ]-operation_number ).

    ls_selection-maximum_results = 10.
    ls_selection-operation_number_from = '0020'.
    ls_selection-operation_number_to = '0020'.
    CLEAR ls_selection-operation_number_to.
    DATA(lt_operation_lower) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_operation_lower ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = lt_operation_lower[ 5 ]-operation_number ).

    CLEAR ls_selection-operation_number_from.
    ls_selection-operation_number_to = '0020'.
    DATA(lt_operation_upper) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lines( lt_operation_upper ) ).
    LOOP AT lt_operation_upper INTO DATA(ls_vornr_upper_row).
      cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = xsdbool(
          ls_vornr_upper_row-operation_number <= '0020' ) ).
    ENDLOOP.

    ls_selection-operation_number = '0030'.
    ls_selection-operation_number_from = '0020'.
    ls_selection-operation_number_to = '0030'.
    DATA(lt_operation_intersection) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_operation_intersection ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = lt_operation_intersection[ 1 ]-operation_number ).

    CLEAR ls_selection-operation_number.
    CLEAR ls_selection-operation_number_from.
    CLEAR ls_selection-operation_number_to.
    ls_selection-operation_sequence_from = '000001'.
    ls_selection-operation_sequence_to = '000001'.
    DATA(lt_sequence_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_sequence_range ) ).
    LOOP AT lt_sequence_range INTO DATA(ls_plnfl_range_row).
      cl_abap_unit_assert=>assert_equals(
        exp = '000001'
        act = ls_plnfl_range_row-operation_sequence ).
    ENDLOOP.

    CLEAR ls_selection-operation_sequence_to.
    ls_selection-operation_sequence_from = '000002'.
    DATA(lt_sequence_lower_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_sequence_lower_range ) ).

    CLEAR ls_selection-operation_sequence_from.
    ls_selection-operation_sequence_to = '000001'.
    DATA(lt_sequence_upper_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_sequence_upper_range ) ).

    ls_selection-filter_operation_sequence = abap_true.
    ls_selection-operation_sequence = '000002'.
    ls_selection-operation_sequence_from = '000001'.
    ls_selection-operation_sequence_to = '000002'.
    DATA(lt_sequence_intersection) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_sequence_intersection ) ).

    CLEAR ls_selection-filter_operation_sequence.
    CLEAR ls_selection-operation_sequence.
    CLEAR ls_selection-operation_sequence_from.
    CLEAR ls_selection-operation_sequence_to.
    ls_selection-operation_number = '0020'.
    ls_selection-operation_suboperation_from = '0001'.
    ls_selection-operation_suboperation_to = '0001'.
    DATA(lt_subop_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_subop_range ) ).
    LOOP AT lt_subop_range INTO DATA(ls_uvorn_range_row).
      cl_abap_unit_assert=>assert_equals(
        exp = '0001'
        act = ls_uvorn_range_row-operation_suboperation ).
    ENDLOOP.

    CLEAR ls_selection-operation_suboperation_to.
    ls_selection-operation_suboperation_from = '0001'.
    DATA(lt_subop_lower_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_subop_lower_range ) ).

    CLEAR ls_selection-operation_suboperation_from.
    ls_selection-operation_suboperation_to = '0001'.
    DATA(lt_subop_upper_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_subop_upper_range ) ).

    ls_selection-operation_suboperation = '0001'.
    ls_selection-operation_suboperation_from = '0001'.
    ls_selection-operation_suboperation_to = '0002'.
    DATA(lt_subop_intersection) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_subop_intersection ) ).

    CLEAR ls_selection-operation_number.
    CLEAR ls_selection-operation_suboperation.
    CLEAR ls_selection-operation_suboperation_from.
    CLEAR ls_selection-operation_suboperation_to.
    ls_selection-production_order = '1001'.
    ls_selection-operation_counter_from = '00000003'.
    ls_selection-operation_counter_to = '00000004'.
    DATA(lt_counter_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_counter_range ) ).
    LOOP AT lt_counter_range INTO DATA(ls_counter_range_row).
      cl_abap_unit_assert=>assert_true(
        xsdbool( ls_counter_range_row-operation_counter >= '00000003' ) ).
    ENDLOOP.

    CLEAR ls_selection-operation_counter_to.
    DATA(lt_counter_lower_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_counter_lower_range ) ).

    CLEAR ls_selection-operation_counter_from.
    ls_selection-operation_counter_to = '00000004'.
    DATA(lt_counter_upper_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lines( lt_counter_upper_range ) ).

    ls_selection-operation_counter = '00000004'.
    ls_selection-operation_counter_from = '00000003'.
    ls_selection-operation_counter_to = '00000004'.
    DATA(lt_counter_intersection) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_counter_intersection ) ).

    CLEAR ls_selection-production_order.
    CLEAR ls_selection-operation_counter.
    CLEAR ls_selection-operation_counter_from.
    CLEAR ls_selection-operation_counter_to.
    ls_selection-confirmation_number = '0000000003'.
    ls_selection-confirmation_counter_from = '00000002'.
    ls_selection-confirmation_counter_to = '00000002'.
    DATA(lt_confirmation_counter_range) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_confirmation_counter_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_confirmation_counter_range[ 1 ]-confirmation_counter ).

    ls_selection-confirmation_counter = '00000002'.
    ls_selection-confirmation_counter_from = '00000001'.
    ls_selection-confirmation_counter_to = '00000002'.
    DATA(lt_conf_cnt_intersection) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_conf_cnt_intersection ) ).

    CLEAR ls_selection-confirmation_number.
    CLEAR ls_selection-confirmation_counter.
    CLEAR ls_selection-confirmation_counter_from.
    CLEAR ls_selection-confirmation_counter_to.
    ls_selection-maximum_results = 10.
    ls_selection-after_posting_date = '20260112'.
    ls_selection-after_production_order = '1001'.
    ls_selection-after_confirmation = '0000000002'.
    ls_selection-after_confirmation_counter = '00000001'.
    ls_selection-reversed_only = abap_true.
    DATA(lt_reversed_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_reversed_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_reversed_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_true(
      lt_reversed_page[ 1 ]-is_reversed ).
    CLEAR ls_selection-reversed_only.
    CLEAR ls_selection-after_posting_date.
    CLEAR ls_selection-after_production_order.
    CLEAR ls_selection-after_confirmation.
    CLEAR ls_selection-after_confirmation_counter.
    ls_selection-positive_rework_only = abap_true.
    ls_selection-positive_scrap_only = abap_true.
    ls_selection-maximum_results = 10.
    DATA(lt_quality_confirmation_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_quality_confirmation_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_quality_confirmation_page[ 1 ]-confirmation ).
    CLEAR ls_selection-positive_rework_only.
    CLEAR ls_selection-positive_scrap_only.
    ls_selection-positive_yield_only = abap_true.
    DATA(lt_yield_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = xsdbool( lines( lt_yield_page ) > 0 ) ).
    LOOP AT lt_yield_page INTO DATA(ls_yield_confirmation).
      cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = xsdbool( ls_yield_confirmation-yield_quantity > 0 ) ).
    ENDLOOP.
    CLEAR ls_selection-positive_yield_only.
    ls_selection-quantity_unit = 'EA'.
    ls_selection-filter_yield_quantity_from = abap_true.
    ls_selection-yield_quantity_from = '6.000'.
    ls_selection-filter_yield_quantity_to = abap_true.
    ls_selection-yield_quantity_to = '8.000'.
    DATA(lt_yield_range_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_yield_range_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV afru-lmnga( '6.000' )
      act = lt_yield_range_page[ 1 ]-yield_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV afru-lmnga( '8.000' )
      act = lt_yield_range_page[ 2 ]-yield_quantity ).
    CLEAR ls_selection-filter_yield_quantity_from.
    CLEAR ls_selection-yield_quantity_from.
    DATA(lt_yield_upper_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = xsdbool( lines( lt_yield_upper_page ) > 0 ) ).
    LOOP AT lt_yield_upper_page INTO DATA(ls_yield_upper_confirmation).
      cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = xsdbool(
          ls_yield_upper_confirmation-yield_quantity <= '8.000' ) ).
    ENDLOOP.
    CLEAR ls_selection-filter_yield_quantity_to.
    CLEAR ls_selection-yield_quantity_to.
    ls_selection-filter_yield_quantity_from = abap_true.
    ls_selection-yield_quantity_from = '8.000'.
    DATA(lt_yield_lower_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = xsdbool( lines( lt_yield_lower_page ) > 0 ) ).
    LOOP AT lt_yield_lower_page INTO DATA(ls_yield_range_confirmation).
      cl_abap_unit_assert=>assert_equals(
        exp = abap_true
        act = xsdbool(
          ls_yield_range_confirmation-yield_quantity >= '8.000' ) ).
    ENDLOOP.
    ls_selection-yield_quantity_from = '9.000'.
    ls_selection-maximum_results = 1.
    DATA(lt_yield_late_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_yield_late_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_yield_late_page[ 1 ]-confirmation ).
    CLEAR ls_selection-filter_yield_quantity_from.
    CLEAR ls_selection-yield_quantity_from.
    ls_selection-maximum_results = 10.
    CLEAR ls_selection-quantity_unit.
    ls_selection-quantity_unit = 'EA'.
    ls_selection-filter_rework_quantity_from = abap_true.
    ls_selection-rework_quantity_from = '1.000'.
    ls_selection-filter_rework_quantity_to = abap_true.
    ls_selection-rework_quantity_to = '1.000'.
    DATA(lt_rework_range_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_rework_range_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_rework_range_page[ 1 ]-confirmation ).
    CLEAR ls_selection-filter_rework_quantity_from.
    CLEAR ls_selection-rework_quantity_from.
    CLEAR ls_selection-filter_rework_quantity_to.
    CLEAR ls_selection-rework_quantity_to.
    ls_selection-filter_scrap_quantity_from = abap_true.
    ls_selection-scrap_quantity_from = '0.500'.
    ls_selection-filter_scrap_quantity_to = abap_true.
    ls_selection-scrap_quantity_to = '0.500'.
    DATA(lt_scrap_range_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_scrap_range_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_scrap_range_page[ 1 ]-confirmation ).
    CLEAR ls_selection-filter_scrap_quantity_from.
    CLEAR ls_selection-scrap_quantity_from.
    CLEAR ls_selection-filter_scrap_quantity_to.
    CLEAR ls_selection-scrap_quantity_to.
    CLEAR ls_selection-quantity_unit.
    ls_selection-maximum_results = 2.

    DATA lt_additional_afpo TYPE STANDARD TABLE OF afpo WITH EMPTY KEY.
    DATA lt_additional_afru TYPE STANDARD TABLE OF afru WITH EMPTY KEY.
    lt_additional_afpo = VALUE #(
      ( aufnr = '1002'
        posnr = '0002'
        matnr = 'MAT-1'
        werks = '1000' ) ).
    lt_additional_afru = VALUE #(
      ( rueck = '0000000011'
        rmzhl = '00000001'
        aufnr = '1002'
        aufpl = '0000000002'
        aplzl = '00000001'
        budat = '20260111'
        meinh = 'EA' ) ).
    mo_environment->insert_test_data( lt_additional_afpo ).
    mo_environment->insert_test_data( lt_additional_afru ).
    ls_selection-production_order = '1002'.
    ls_selection-maximum_results = 10.
    DATA(lt_order_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_order_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000011'
      act = lt_order_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1002'
      act = lt_order_page[ 1 ]-production_order ).

    CLEAR ls_selection-production_order.
    ls_selection-confirmation_number = '0000000003'.
    ls_selection-confirmation_counter = '00000002'.
    DATA(lt_exact_confirmation_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_exact_confirmation_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_exact_confirmation_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_exact_confirmation_page[ 1 ]-confirmation_counter ).

    CLEAR ls_selection-confirmation_number.
    CLEAR ls_selection-confirmation_counter.
    ls_selection-order_category = '40'.
    DATA(lt_process_order_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_process_order_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '40'
      act = lt_process_order_page[ 1 ]-order_category ).
    CLEAR ls_selection-order_category.

    ls_selection-production_order = '1001'.
    ls_selection-operation_counter = '00000002'.
    DATA(lt_internal_operation_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_internal_operation_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_internal_operation_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_internal_operation_page[ 1 ]-operation_counter ).
    CLEAR ls_selection-operation_counter.
    CLEAR ls_selection-production_order.
    CLEAR ls_selection-confirmation_number.
    CLEAR ls_selection-confirmation_counter.
    ls_selection-resource_object_id = '00000002'.
    DATA(lt_resource_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_resource_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_resource_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_resource_page[ 1 ]-resource_object_id ).

    CLEAR ls_selection-resource_object_id.
    ls_selection-filter_resource_object_id = abap_true.
    DATA(lt_unassigned_resource_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_unassigned_resource_page ) ).
    LOOP AT lt_unassigned_resource_page
        INTO DATA(ls_unassigned_res_confirmation).
      cl_abap_unit_assert=>assert_initial(
        ls_unassigned_res_confirmation-resource_object_id ).
    ENDLOOP.
    CLEAR ls_selection-filter_resource_object_id.
    ls_selection-maximum_results = 2.
    ls_selection-operation_number = '0020'.
    ls_selection-after_posting_date = '20260112'.
    ls_selection-after_production_order = '1001'.
    ls_selection-after_confirmation = '0000000002'.
    ls_selection-after_confirmation_counter = '00000001'.
    DATA(lt_second_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_second_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000003'
      act = lt_second_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Inspect component'
      act = lt_second_page[ 1 ]-operation_description ).
    cl_abap_unit_assert=>assert_true(
      lt_second_page[ 1 ]-is_reversed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_second_page[ 2 ]-operation_suboperation ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Inspect suboperation'
      act = lt_second_page[ 2 ]-operation_description ).

    CLEAR ls_selection-after_posting_date.
    CLEAR ls_selection-after_production_order.
    CLEAR ls_selection-after_confirmation.
    CLEAR ls_selection-after_confirmation_counter.
    ls_selection-operation_sequence = '000002'.
    DATA(lt_sequence_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_sequence_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000009'
      act = lt_sequence_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000002'
      act = lt_sequence_page[ 1 ]-operation_sequence ).
    CLEAR ls_selection-operation_number.
    ls_selection-production_order = '1001'.
    DATA(lt_sequence_only_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_sequence_only_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000010'
      act = lt_sequence_only_page[ 2 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0030'
      act = lt_sequence_only_page[ 2 ]-operation_number ).

    CLEAR ls_selection-production_order.
    CLEAR ls_selection-operation_number.
    CLEAR ls_selection-operation_sequence.
    CLEAR ls_selection-operation_suboperation.
    ls_selection-control_key = 'PP03'.
    ls_selection-maximum_results = 10.
    DATA(lt_control_key_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_control_key_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000010'
      act = lt_control_key_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PP03'
      act = lt_control_key_page[ 1 ]-control_key ).

    CLEAR ls_selection-control_key.
    ls_selection-quantity_unit = 'BOX'.
    DATA(lt_unit_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_unit_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000010'
      act = lt_unit_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_unit_page[ 1 ]-quantity_unit ).

    CLEAR ls_selection-quantity_unit.
    ls_selection-operation_number = '0020'.
    ls_selection-operation_suboperation = '0001'.
    ls_selection-maximum_results = 1.
    DATA(lt_suboperation_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suboperation_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000007'
      act = lt_suboperation_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_suboperation_page[ 2 ]-operation_suboperation ).

    ls_selection-final_only = abap_true.
    ls_selection-exclude_reversed = abap_true.
    DATA(lt_final_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_final_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000008'
      act = lt_final_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_true(
      lt_final_page[ 1 ]-is_final ).

    CLEAR ls_selection-final_only.
    CLEAR ls_selection-exclude_reversed.
    ls_selection-partial_only = abap_true.
    DATA(lt_partial_page) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_partial_page ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000007'
      act = lt_partial_page[ 1 ]-confirmation ).
    cl_abap_unit_assert=>assert_initial(
      lt_partial_page[ 1 ]-is_final ).
  ENDMETHOD.

  METHOD filters_deleted_conf_orders.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(ls_selection) = VALUE
      zif_prod_order_read_repo=>ty_confirmation_window_selection(
        material          = 'MAT-4'
        plant             = '4000'
        posting_date_from = '20260101'
        posting_date_to   = '20260131'
        maximum_results   = 10 ).

    DATA(lt_deleted_order) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_deleted_order ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_deleted_order[ 1 ]-order_deletion_indicator ).
    ls_selection-exclude_deleted = abap_true.
    DATA(lt_excluded_order) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_initial( lt_excluded_order ).

    ls_selection-material = 'MAT-5'.
    ls_selection-plant = '5000'.
    ls_selection-exclude_deleted = abap_false.
    DATA(lt_deleted_item) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_deleted_item ) ).
    ls_selection-exclude_deleted = abap_true.
    DATA(lt_excluded_item) =
      lo_cut->zif_prod_order_read_repo~search_confirmations_by_window(
        is_selection = ls_selection ).
    cl_abap_unit_assert=>assert_initial( lt_excluded_item ).
  ENDMETHOD.

  METHOD reads_operations.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(lt_operations) = lo_cut->zif_prod_order_read_repo~read_operations(
      it_production_orders = VALUE #(
        ( '1002' )
        ( '1003' )
        ( '1001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lines( lt_operations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_operations[ 1 ]-operation_number ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_operations[ 2 ]-suboperation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_operations[ operation_number = '0020'
                           suboperation_number = '0001' ]-operation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Inspect suboperation'
      act = lt_operations[ operation_counter = '00000003' ]-operation_description ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000002'
      act = lt_operations[ production_order = '1002' ]-operation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000003'
      act = lt_operations[ production_order = '1002' ]-resource_object_id ).

    DATA(lt_resource_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders  = VALUE #( ( '1001' ) )
        iv_resource_object_id = '00000002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_resource_operations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = lt_resource_operations[ 1 ]-operation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_resource_operations[ 1 ]-resource_object_id ).

    DATA(lt_wc_ops) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders = VALUE #( ( '1001' ) )
        iv_work_center       = 'WC-02' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_wc_ops ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = lt_wc_ops[ 1 ]-operation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-02'
      act = lt_wc_ops[ 1 ]-work_center ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_wc_ops[ 1 ]-work_center_plant ).

    DATA(lt_page_wc_ops) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders = VALUE #( ( '1001' ) )
        iv_work_center       = 'WC-04'
        is_page_selection    = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_page_wc_ops ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-04'
      act = lt_page_wc_ops[ 1 ]-work_center ).

    DATA(lt_blank_wc_ops) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders  = VALUE #( ( '1001' ) )
        iv_filter_work_center = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_blank_wc_ops ) ).
    cl_abap_unit_assert=>assert_initial(
      lt_blank_wc_ops[ 1 ]-work_center ).

    DATA(lt_wc_plant_ops) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders = VALUE #( ( '1002' ) )
        iv_work_center_plant = '2000' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_wc_plant_ops ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'WC-03'
      act = lt_wc_plant_ops[ 1 ]-work_center ).

    DATA(lt_blank_wc_plant_ops) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_filter_work_center_plant = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_blank_wc_plant_ops ) ).
    cl_abap_unit_assert=>assert_initial(
      lt_blank_wc_plant_ops[ 1 ]-work_center_plant ).

    DATA(lt_unassigned_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders         = VALUE #( ( '1001' ) )
        iv_filter_resource_object_id = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_unassigned_operations ) ).
    cl_abap_unit_assert=>assert_initial(
      lt_unassigned_operations[ 1 ]-resource_object_id ).

    DATA(lt_ranged_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number_from = '0010'
        iv_operation_number_to   = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_ranged_operations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_ranged_operations[ 1 ]-operation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_ranged_operations[ 3 ]-suboperation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = lt_ranged_operations[ 2 ]-operation_number ).

    DATA(lt_paged_ranged_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number_from = '0010'
        iv_operation_number_to   = '0020'
        is_page_selection        = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_ranged_operations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_paged_ranged_operations[ 1 ]-operation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0020'
      act = lt_paged_ranged_operations[ 2 ]-operation_number ).

    DATA(lt_lower_only_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number_from = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_lower_only_operations ) ).

    DATA(lt_upper_only_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders   = VALUE #( ( '1001' ) )
        iv_operation_number_to = '0010'
        is_page_selection      = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_upper_only_operations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010'
      act = lt_upper_only_operations[ 1 ]-operation_number ).

    DATA(lt_exact_intersection) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_number      = '0020'
        iv_operation_number_from = '0010'
        iv_operation_number_to   = '0020' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_exact_intersection ) ).

    DATA(lt_counter_range_operations) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_counter_range_operations ) ).

    DATA(lt_paged_counter_range) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000003'
        is_page_selection         = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_counter_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_paged_counter_range[ 1 ]-operation_counter ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000003'
      act = lt_paged_counter_range[ 2 ]-operation_counter ).

    DATA(lt_counter_lower_only) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter_from = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_counter_lower_only ) ).

    DATA(lt_counter_upper_only) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders    = VALUE #( ( '1001' ) )
        iv_operation_counter_to = '00000001'
        is_page_selection       = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_counter_upper_only ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000001'
      act = lt_counter_upper_only[ 1 ]-operation_counter ).

    DATA(lt_exact_counter_intersection) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders      = VALUE #( ( '1001' ) )
        iv_operation_counter      = '00000003'
        iv_operation_counter_from = '00000002'
        iv_operation_counter_to   = '00000003' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_exact_counter_intersection ) ).

    DATA(lt_sequence_range) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders       = VALUE #( ( '1001' ) )
        iv_operation_sequence_from = '000001'
        iv_operation_sequence_to   = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_sequence_range ) ).

    DATA(lt_paged_sequence_range) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders       = VALUE #( ( '1001' ) )
        iv_operation_sequence_from = '000001'
        iv_operation_sequence_to   = '000002'
        is_page_selection          = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_sequence_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000001'
      act = lt_paged_sequence_range[ 1 ]-operation_sequence ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000001'
      act = lt_paged_sequence_range[ 2 ]-operation_sequence ).

    DATA(lt_sequence_lower_only) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders       = VALUE #( ( '1001' ) )
        iv_operation_sequence_from = '000002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_sequence_lower_only ) ).

    DATA(lt_sequence_upper_only) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders     = VALUE #( ( '1001' ) )
        iv_operation_sequence_to = '000001'
        is_page_selection        = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_sequence_upper_only ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000001'
      act = lt_sequence_upper_only[ 1 ]-operation_sequence ).

    DATA(lt_sequence_exact_intersection) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders         = VALUE #( ( '1001' ) )
        iv_filter_operation_sequence = abap_true
        iv_operation_sequence        = '000001'
        iv_operation_sequence_from   = '000000'
        iv_operation_sequence_to     = '000001' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_sequence_exact_intersection ) ).

    DATA lt_additional_operations TYPE STANDARD TABLE OF afvc WITH EMPTY KEY.
    lt_additional_operations = VALUE #(
      ( aufpl = '0000000001'
        aplzl = '00000006'
        plnfl = '000001'
        vornr = '0020'
        uvorn = '0002' ) ).
    mo_environment->insert_test_data( lt_additional_operations ).

    DATA(lt_suboperation_range) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_operation_number         = '0020'
        iv_suboperation_number_from = '0001'
        iv_suboperation_number_to   = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_suboperation_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_suboperation_range[ 1 ]-suboperation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_suboperation_range[ 2 ]-suboperation_number ).

    DATA(lt_paged_suboperation_range) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_operation_number         = '0020'
        iv_suboperation_number_from = '0001'
        iv_suboperation_number_to   = '0002'
        is_page_selection           = VALUE #( maximum_results = 1 ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_paged_suboperation_range ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_paged_suboperation_range[ 1 ]-suboperation_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_paged_suboperation_range[ 2 ]-suboperation_number ).

    DATA(lt_subop_intersection) =
      lo_cut->zif_prod_order_read_repo~read_operations(
        it_production_orders        = VALUE #( ( '1001' ) )
        iv_operation_number         = '0020'
        iv_suboperation_number      = '0002'
        iv_suboperation_number_from = '0001'
        iv_suboperation_number_to   = '0002' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_subop_intersection ) ).
  ENDMETHOD.

  METHOD skips_empty_requests.
    DATA(lo_cut) = NEW zcl_prod_order_read_repo( ).
    DATA(lt_items) = lo_cut->zif_prod_order_read_repo~read_orders(
      it_production_orders = VALUE #( ) ).
    DATA(lt_statuses) = lo_cut->zif_prod_order_read_repo~read_order_statuses(
      it_production_orders = VALUE #( ) ).
    DATA(lt_confirmations) = lo_cut->zif_prod_order_read_repo~read_confirmations(
      it_production_orders = VALUE #( ) ).
    DATA(lt_operations) = lo_cut->zif_prod_order_read_repo~read_operations(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial( act = lt_items ).
    cl_abap_unit_assert=>assert_initial( act = lt_statuses ).
    cl_abap_unit_assert=>assert_initial( act = lt_confirmations ).
    cl_abap_unit_assert=>assert_initial( act = lt_operations ).
  ENDMETHOD.
ENDCLASS.
