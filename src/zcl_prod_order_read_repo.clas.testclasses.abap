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
    METHODS reads_confirmations FOR TESTING RAISING cx_static_check.
    METHODS searches_confirmation_window FOR TESTING
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
    DATA lt_afru TYPE STANDARD TABLE OF afru WITH EMPTY KEY.
    DATA lt_jest TYPE STANDARD TABLE OF jest WITH EMPTY KEY.
    DATA lt_tj02t TYPE STANDARD TABLE OF tj02t WITH EMPTY KEY.
    DATA lt_tj30t TYPE STANDARD TABLE OF tj30t WITH EMPTY KEY.

    APPEND 'AFKO' TO lt_tables.
    APPEND 'AFPO' TO lt_tables.
    APPEND 'AUFK' TO lt_tables.
    APPEND 'AFVC' TO lt_tables.
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
      aufnr = '9999'
      posnr = '0001'
      matnr = 'MAT-9'
      werks = '9000'
      psmng = '9.000' ) TO lt_afpo.

    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000002'
      plnfl = '000001'
      vornr = '0020'
      ltxa1 = 'Inspect component'
      steus = 'QM01' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000001'
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
      plnfl = '000002'
      vornr = '0020'
      ltxa1 = 'Inspect alternate sequence'
      steus = 'QM02' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000001'
      aplzl = '00000005'
      plnfl = '000002'
      vornr = '0030'
      ltxa1 = 'Pack alternate sequence'
      steus = 'PP03' ) TO lt_afvc.
    APPEND VALUE #(
      aufpl = '0000000002'
      aplzl = '00000001'
      plnfl = '000002'
      vornr = '0010'
      ltxa1 = 'Process order operation'
      steus = 'PP02' ) TO lt_afvc.

    APPEND VALUE #(
      rueck = '0000000003'
      rmzhl = '00000002'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000002'
      budat = '20260112'
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
      lmnga = '8.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000001'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000001'
      budat = '20260110'
      lmnga = '6.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000004'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000099'
      budat = '20260114'
      lmnga = '10.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000005'
      rmzhl = '00000001'
      aufnr = '1002'
      aufpl = '0000000002'
      aplzl = '00000001'
      budat = '20260109'
      lmnga = '7.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000006'
      rmzhl = '00000001'
      aufnr = '1003'
      aufpl = '0000000003'
      aplzl = '00000001'
      budat = '20260115'
      lmnga = '3.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000007'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000003'
      budat = '20260112'
      lmnga = '4.000'
      meinh = 'EA' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000008'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000003'
      budat = '20260112'
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
      lmnga = '1.000'
      meinh = 'BOX' ) TO lt_afru.
    APPEND VALUE #(
      rueck = '0000000009'
      rmzhl = '00000001'
      aufnr = '1001'
      aufpl = '0000000001'
      aplzl = '00000004'
      budat = '20260112'
      lmnga = '2.000'
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
