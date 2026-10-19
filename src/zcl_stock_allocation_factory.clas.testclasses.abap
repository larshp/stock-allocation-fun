CLASS ltcl_stock_allocation_factory DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS creates_production_services FOR TESTING.
    METHODS allocates_using_sap_repository FOR TESTING
      RAISING cx_static_check.
    METHODS allocates_fefo_from_db FOR TESTING
      RAISING cx_static_check.
    METHODS allocates_wbs_fefo_from_db FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_stock_allocation_factory IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'MARD' TO lt_tables.
    APPEND 'RESB' TO lt_tables.
    APPEND 'MCHB' TO lt_tables.
    APPEND 'MCHA' TO lt_tables.
    APPEND 'MCH1' TO lt_tables.
    APPEND 'MARA' TO lt_tables.
    APPEND 'MARC' TO lt_tables.
    APPEND 'MSPR' TO lt_tables.
    APPEND 'PRPS' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD creates_production_services.
    DATA(lo_stock_service) =
      zcl_stock_allocation_factory=>create_stock_service( ).
    DATA(lo_goods_movement_service) =
      zcl_stock_allocation_factory=>create_goods_movement_service( ).
    DATA(lo_reservation_issue_service) =
      zcl_stock_allocation_factory=>create_res_issue_service( ).
    DATA(lo_stock_xfer_order_service) =
      zcl_stock_allocation_factory=>create_sto_order_service( ).
    DATA(lo_sales_alloc_service) =
      zcl_stock_allocation_factory=>create_sales_order_alloc( ).
    DATA(lo_sales_order_service) =
      zcl_stock_allocation_factory=>create_sales_order_service( ).
    DATA(lo_sales_stock_service) =
      zcl_stock_allocation_factory=>create_sales_stock_service( ).
    DATA(lo_so_res_read_service) =
      zcl_stock_allocation_factory=>create_so_res_read_service( ).
    DATA(lo_so_reservation_service) =
      zcl_stock_allocation_factory=>create_so_reservation_service( ).
    DATA(lo_so_fefo_issue_service) =
      zcl_stock_allocation_factory=>create_so_fefo_issue_service( ).
    DATA(lo_project_stock_service) =
      zcl_stock_allocation_factory=>create_project_stock_service( ).
    DATA(lo_project_resv_service) =
      zcl_stock_allocation_factory=>create_project_resv_service( ).
    DATA(lo_stock_transfer_service) =
      zcl_stock_allocation_factory=>create_stock_transfer_service( ).
    DATA(lo_purchase_order_service) =
      zcl_stock_allocation_factory=>create_purchase_order_service( ).
    DATA(lo_planned_order_service) =
      zcl_stock_allocation_factory=>create_planned_order_service( ).
    DATA(lo_planned_order_read_service) =
      zcl_stock_allocation_factory=>create_planned_read_service( ).
    DATA(lo_prod_order_service) =
      zcl_stock_allocation_factory=>create_prod_order_service( ).
    DATA(lo_prod_comp_service) =
      zcl_stock_allocation_factory=>create_prod_comp_service( ).
    DATA(lo_prod_order_read_service) =
      zcl_stock_allocation_factory=>create_prod_order_read_service( ).
    DATA(lo_preq_service) =
      zcl_stock_allocation_factory=>create_preq_service( ).
    DATA(lo_cc_reservation_service) =
      zcl_stock_allocation_factory=>create_cc_reservation_service( ).
    DATA(lo_repl_source_service) =
      zcl_stock_allocation_factory=>create_repl_source_service( ).
    DATA lv_services_bound TYPE abap_bool.

    IF lo_stock_service IS BOUND
        AND lo_goods_movement_service IS BOUND
        AND lo_reservation_issue_service IS BOUND
        AND lo_stock_xfer_order_service IS BOUND
        AND lo_sales_alloc_service IS BOUND
        AND lo_sales_order_service IS BOUND
        AND lo_sales_stock_service IS BOUND
        AND lo_so_res_read_service IS BOUND
        AND lo_so_reservation_service IS BOUND
        AND lo_so_fefo_issue_service IS BOUND
        AND lo_project_stock_service IS BOUND
        AND lo_project_resv_service IS BOUND
        AND lo_stock_transfer_service IS BOUND
        AND lo_purchase_order_service IS BOUND
        AND lo_planned_order_service IS BOUND
        AND lo_planned_order_read_service IS BOUND
        AND lo_prod_order_service IS BOUND
        AND lo_prod_comp_service IS BOUND
        AND lo_prod_order_read_service IS BOUND
        AND lo_preq_service IS BOUND
        AND lo_cc_reservation_service IS BOUND
        AND lo_repl_source_service IS BOUND.
      lv_services_bound = abap_true.
    ENDIF.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_services_bound ).
  ENDMETHOD.

  METHOD allocates_using_sap_repository.
    DATA lt_mard TYPE STANDARD TABLE OF mard WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    lt_mard = VALUE #(
      ( matnr = 'MAT-INTEGRATION' werks = '1000' lgort = '0001'
        labst = '20.000' ) ).
    lt_resb = VALUE #(
      ( rsnum = '0000000789' rspos = '0001' matnr = 'MAT-INTEGRATION'
        werks = '1000' bdmng = '8.000' enmng = '3.000' ) ).
    mo_environment->insert_test_data( lt_mard ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_service) = zcl_stock_allocation_factory=>create_stock_service( ).
    DATA(lt_allocations) = lo_service->allocate_demands(
      it_demands = VALUE #(
        ( request_id = 'FIRST' material = 'MAT-INTEGRATION' plant = '1000'
          requested_quantity = '10.000' )
        ( request_id = 'SECOND' material = 'MAT-INTEGRATION' plant = '1000'
          requested_quantity = '7.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '15.000' )
      act = lt_allocations[ request_id = 'FIRST' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_allocations[ request_id = 'FIRST' ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_allocations[ request_id = 'SECOND' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lt_allocations[ request_id = 'SECOND' ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_allocations[ request_id = 'SECOND' ]-shortfall_quantity ).
  ENDMETHOD.

  METHOD allocates_fefo_from_db.
    DATA lt_mchb TYPE STANDARD TABLE OF mchb WITH EMPTY KEY.
    DATA lt_mcha TYPE STANDARD TABLE OF mcha WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    lt_mchb = VALUE #(
      ( matnr = 'MAT-FEFO-INTEGRATION' werks = '1000' lgort = '0001'
        charg = 'B-EARLY' clabs = '8.000' )
      ( matnr = 'MAT-FEFO-INTEGRATION' werks = '1000' lgort = '0001'
        charg = 'B-LATE' clabs = '10.000' ) ).
    lt_mcha = VALUE #(
      ( matnr = 'MAT-FEFO-INTEGRATION' werks = '1000' charg = 'B-EARLY'
        vfdat = '20261030' )
      ( matnr = 'MAT-FEFO-INTEGRATION' werks = '1000' charg = 'B-LATE'
        vfdat = '20261115' ) ).
    lt_resb = VALUE #(
      ( rsnum = '0000000790' rspos = '0001'
        matnr = 'MAT-FEFO-INTEGRATION' werks = '1000' lgort = '0001'
        charg = 'B-EARLY' bdmng = '5.000' enmng = '1.000' ) ).
    mo_environment->insert_test_data( lt_mchb ).
    mo_environment->insert_test_data( lt_mcha ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_service) = zcl_stock_allocation_factory=>create_stock_service( ).
    DATA(ls_result) = lo_service->allocate_by_expiry(
      it_demands    = VALUE #(
        ( request_id                  = 'FEFO'
          material                    = 'MAT-FEFO-INTEGRATION'
          plant                       = '1000'
          requested_quantity          = '10.000'
          fallback_to_other_locations = abap_false
          require_full_quantity       = abap_false ) )
      iv_as_of_date = '20261017' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = ls_result-allocations[ request_id = 'FEFO' ]-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocations[ request_id = 'FEFO' ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-batch_allocations[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-batch_allocations[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-batch_allocations[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-batch_allocations[ 2 ]-allocated_quantity ).
  ENDMETHOD.
  METHOD allocates_wbs_fefo_from_db.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_mspr TYPE STANDARD TABLE OF mspr WITH EMPTY KEY.
    DATA lt_prps TYPE STANDARD TABLE OF prps WITH EMPTY KEY.
    DATA lt_mcha TYPE STANDARD TABLE OF mcha WITH EMPTY KEY.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    lt_mara = VALUE #(
      ( matnr = 'MAT-WBS-FEFO' meins = 'EA' ) ).
    lt_prps = VALUE #(
      ( pspnr = '00000001' posid = 'PRJ-WBS-FEFO' ) ).
    lt_mspr = VALUE #(
      ( matnr = 'MAT-WBS-FEFO' werks = '1000' lgort = '0001'
        charg = 'B-EARLY' sobkz = 'Q' pspnr = '00000001'
        prlab = '8.000' )
      ( matnr = 'MAT-WBS-FEFO' werks = '1000' lgort = '0002'
        charg = 'B-LATE' sobkz = 'Q' pspnr = '00000001'
        prlab = '10.000' ) ).
    lt_mcha = VALUE #(
      ( matnr = 'MAT-WBS-FEFO' werks = '1000' charg = 'B-EARLY'
        vfdat = '20261030' )
      ( matnr = 'MAT-WBS-FEFO' werks = '1000' charg = 'B-LATE'
        vfdat = '20261115' ) ).
    lt_resb = VALUE #(
      ( rsnum = '0000000800' rspos = '0001' matnr = 'MAT-WBS-FEFO'
        werks = '1000' lgort = '0001' charg = 'B-EARLY' sobkz = 'Q'
        pspel = '00000001' bdter = '20261020' meins = 'EA'
        erfme = 'EA' bdmng = '5.000' enmng = '1.000' ) ).
    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_mspr ).
    mo_environment->insert_test_data( lt_prps ).
    mo_environment->insert_test_data( lt_mcha ).
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_service) =
      zcl_stock_allocation_factory=>create_project_stock_service( ).
    DATA(ls_result) = lo_service->preview_fefo(
      it_demands    = VALUE #( (
        request_id         = 'WBS-FEFO'
        wbs_element        = 'PRJ-WBS-FEFO'
        material           = 'MAT-WBS-FEFO'
        plant              = '1000'
        requested_quantity = '10.000'
        unit               = 'EA' ) )
      iv_as_of_date = '20261017' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-allocation-allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '14.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_result-allocation-allocations[ 1 ]-allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRJ-WBS-FEFO'
      act = ls_result-wbs_assignments[ 1 ]-wbs_element ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( ls_result-allocation-batch_allocations ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-EARLY'
      act = ls_result-allocation-batch_allocations[ 1 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '4.000' )
      act = ls_result-allocation-batch_allocations[ 1 ]-batch_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'B-LATE'
      act = ls_result-allocation-batch_allocations[ 2 ]-batch_allocation-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '6.000' )
      act = ls_result-allocation-batch_allocations[ 2 ]-batch_allocation-allocated_quantity ).
  ENDMETHOD.

ENDCLASS.
