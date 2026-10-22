CLASS ltcl_prod_comp_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_bulk_components FOR TESTING RAISING cx_static_check.
    METHODS reads_planned_order_components FOR TESTING
      RAISING cx_static_check.
    METHODS filters_required_date_range FOR TESTING
      RAISING cx_static_check.
    METHODS skips_empty_order_list FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_prod_comp_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'RESB' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_bulk_components.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #(
      aufnr = 'ORDER-1'
      rsnum = '0000000001'
      rspos = '0002'
      matnr = 'COMP-2'
      potx1 = 'Bearing housing'
      werks = '1000'
      lgort = '0001'
      charg = 'BATCH-2'
      bwart = '261'
      bdter = '20261021'
      bdmng = '10.000'
      enmng = '3.000'
      meins = 'EA'
      kzear = 'X' ) TO lt_resb.
    APPEND VALUE #(
      aufnr = 'ORDER-1'
      rsnum = '0000000001'
      rspos = '0001'
      matnr = 'COMP-1'
      werks = '1000'
      lgort = '0002'
      bwart = '261'
      bdter = '20261020'
      bdmng = '5.000'
      enmng = '1.000'
      meins = 'KG'
      xloek = 'X' ) TO lt_resb.
    APPEND VALUE #(
      aufnr = 'ORDER-2'
      rsnum = '0000000002'
      rspos = '0010'
      matnr = 'COMP-3'
      werks = '2000'
      lgort = '0003'
      bwart = '261'
      bdter = '20261022'
      bdmng = '2.500'
      enmng = '0.500'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #(
      aufnr = 'ORDER-3'
      rsnum = '0000000003'
      rspos = '0001'
      matnr = 'UNREQUESTED'
      werks = '1000'
      bwart = '261' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_cut) = NEW zcl_prod_comp_repo( ).
    DATA(lt_items) = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders = VALUE #(
        ( 'ORDER-2' )
        ( 'ORDER-1' )
        ( 'ORDER-1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-aufnr( 'ORDER-1' )
      act = lt_items[ 1 ]-production_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-rspos( '0001' )
      act = lt_items[ 1 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-matnr( 'COMP-1' )
      act = lt_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-xloek( 'X' )
      act = lt_items[ 1 ]-is_deleted ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-rspos( '0002' )
      act = lt_items[ 2 ]-reservation_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-charg( 'BATCH-2' )
      act = lt_items[ 2 ]-batch ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Bearing housing'
      act = lt_items[ 2 ]-bom_item_text ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '10.000' )
      act = lt_items[ 2 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '3.000' )
      act = lt_items[ 2 ]-withdrawn_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-kzear( 'X' )
      act = lt_items[ 2 ]-is_final_issue ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-aufnr( 'ORDER-2' )
      act = lt_items[ 3 ]-production_order ).

    DATA(lt_single_items) = lo_cut->zif_prod_comp_repo~get_components(
      iv_production_order = 'ORDER-1' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_single_items ) ).
  ENDMETHOD.

  METHOD reads_planned_order_components.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #(
      plnum = 'PL-2'
      rsnum = '0000000002'
      rspos = '0002'
      matnr = 'COMP-2'
      werks = '2000'
      bdter = '20261022'
      bdmng = '4.000'
      enmng = '1.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #(
      plnum = 'PL-1'
      rsnum = '0000000001'
      rspos = '0001'
      matnr = 'COMP-1'
      potx1 = 'Pump rotor'
      werks = '1000'
      bdter = '20261021'
      bdmng = '8.000'
      enmng = '2.000'
      meins = 'KG' ) TO lt_resb.
    APPEND VALUE #(
      plnum = 'PL-3'
      rsnum = '0000000003'
      rspos = '0001'
      matnr = 'UNREQUESTED'
      werks = '1000' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_cut) = NEW zcl_prod_comp_repo( ).
    DATA(lt_items) = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders = VALUE #(
        ( 'PL-2' )
        ( 'PL-1' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PL-1'
      act = lt_items[ 1 ]-planned_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COMP-1'
      act = lt_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'Pump rotor'
      act = lt_items[ 1 ]-bom_item_text ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PL-2'
      act = lt_items[ 2 ]-planned_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COMP-2'
      act = lt_items[ 2 ]-material ).
  ENDMETHOD.

  METHOD filters_required_date_range.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000010'
      rspos = '0001' matnr = 'MAT-A' werks = '1000'
      lgort = '0001' charg = 'BATCH-A' bwart = '261'
      bdter = '20261020' bdmng = '5.000' enmng = '3.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000011'
      rspos = '0001' kdauf = '0000500001' kdpos = '000010'
      kdein = '0000' sobkz = 'E'
      bdart = 'SB'
      berkz = '1'
      no_disp = '1'
      pspel = '00000001'
      matnr = 'MAT-A' werks = '1000'
      lgort = '0001' charg = 'BATCH-A' bwart = '261'
      bdter = '20261021' bdmng = '6.000' enmng = '1.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000012'
      rspos = '0002' werks = '1000'
      bwart = '262' bdter = '20261022'
      bdmng = '7.000' enmng = '2.000' meins = 'KG' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000013'
      rspos = '0001' kdauf = '0000500001' kdpos = '000020'
      kdein = '0002' sobkz = 'Q'
      bdart = 'AR'
      berkz = '2'
      pspel = '00000002'
      matnr = 'MAT-A' lgort = '0002'
      charg = 'BATCH-B' bwart = '262'
      bdter = '20261023' bdmng = '8.000' enmng = '0.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000014'
      rspos = '0001' matnr = 'MAT-A' werks = '1000'
      lgort = '0001' bdmng = '9.000' enmng = '0.000' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000020'
      rspos = '0001' matnr = 'MAT-A' werks = '1000'
      lgort = '0001' charg = 'BATCH-A' bwart = '261'
      bdter = '20261020' bdmng = '5.000' enmng = '3.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000021'
      rspos = '0001' kdauf = '0000500001' kdpos = '000010'
      kdein = '0000' sobkz = 'E'
      bdart = 'SB'
      berkz = '1'
      no_disp = '1'
      pspel = '00000001'
      matnr = 'MAT-A' werks = '1000'
      lgort = '0001' charg = 'BATCH-A' bwart = '261'
      bdter = '20261021' bdmng = '6.000' enmng = '1.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000022'
      rspos = '0002' werks = '1000'
      bwart = '262' bdter = '20261022'
      bdmng = '7.000' enmng = '2.000' meins = 'KG' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000023'
      rspos = '0001' kdauf = '0000500001' kdpos = '000020'
      kdein = '0002' sobkz = 'Q'
      bdart = 'AR'
      berkz = '2'
      pspel = '00000002'
      matnr = 'MAT-A' lgort = '0002'
      charg = 'BATCH-B' bwart = '262'
      bdter = '20261023' bdmng = '8.000' enmng = '0.000'
      meins = 'EA' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000024'
      rspos = '0001' matnr = 'MAT-A' werks = '1000'
      lgort = '0001' bdmng = '9.000' enmng = '0.000' ) TO lt_resb.
    mo_environment->insert_test_data( lt_resb ).

    DATA(lo_cut) = NEW zcl_prod_comp_repo( ).
    DATA(ls_range) = VALUE zif_prod_comp_repo=>ty_required_date_range(
      filter_from           = abap_true
      required_date_from    = '20261021'
      filter_through        = abap_true
      required_date_through = '20261022' ).
    DATA(lt_production_items) =
      lo_cut->zif_prod_comp_repo~get_components_bulk(
        it_production_orders   = VALUE #( ( 'ORDER-1' ) )
        is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261021' )
      act = lt_production_items[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261022' )
      act = lt_production_items[ 2 ]-required_date ).
    DATA(lt_single_production_items) = lo_cut->zif_prod_comp_repo~get_components(
      iv_production_order    = 'ORDER-1'
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_single_production_items ) ).

    DATA(lt_planned_items) =
      lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
        it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
        is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261021' )
      act = lt_planned_items[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261022' )
      act = lt_planned_items[ 2 ]-required_date ).
    DATA(lt_single_planned_items) = lo_cut->zif_prod_comp_repo~get_planned_comp(
      iv_planned_order       = 'PLAN-1'
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_single_planned_items ) ).

    ls_range = VALUE #( filter_from = abap_true
      required_date_from            = '20261022' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    ls_range-include_undated = abap_true.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 3 ]-required_date ).

    ls_range = VALUE #( filter_through = abap_true
      required_date_through            = '20261021' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).
    ls_range-include_undated = abap_true.
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_planned_items[ 3 ]-required_date ).

    ls_range = VALUE #(
      filter_material = abap_true
      material        = 'MAT-A'
      filter_plant    = abap_true
      plant           = '1000' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-A'
      act = lt_production_items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lt_production_items[ 1 ]-plant ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_material = abap_true
      filter_plant    = abap_true
      plant           = '1000' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261022'
      act = lt_production_items[ 1 ]-required_date ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_unit = abap_true unit = 'KG' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-meins( 'KG' )
      act = lt_production_items[ 1 ]-unit ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_unit = abap_true ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-unit ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_reservation_number = abap_true
      reservation_number        = '0000000011' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000011'
      act = lt_production_items[ 1 ]-reservation_number ).
    ls_range-reservation_number = '0000000021'.
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_sales_order_item = abap_true
      sales_order_number      = '0000500001'
      sales_order_item        = '000010' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000010'
      act = lt_production_items[ 1 ]-sales_order_item ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000500001'
      act = lt_planned_items[ 1 ]-sales_order_number ).

    ls_range-sales_order_item = '000020'.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000013'
      act = lt_production_items[ 1 ]-reservation_number ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000023'
      act = lt_planned_items[ 1 ]-reservation_number ).

    ls_range                     = VALUE #(
      filter_sales_order_item    = abap_true
      sales_order_number         = '0000500001'
      sales_order_item           = '000020'
      filter_sales_schedule_line = abap_true
      sales_order_schedule_line  = '0002' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_production_items[ 1 ]-sales_order_schedule_line ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_planned_items[ 1 ]-sales_order_schedule_line ).

    ls_range-sales_order_item = '000010'.
    ls_range-sales_order_schedule_line = space.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-sales_order_schedule_line ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_planned_items[ 1 ]-sales_order_schedule_line ).

    ls_range = VALUE #(
      filter_special_stock_indicator = abap_true
      special_stock_indicator        = 'E' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = lt_production_items[ 1 ]-special_stock_indicator ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = lt_planned_items[ 1 ]-special_stock_indicator ).

    ls_range-special_stock_indicator = space.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-special_stock_indicator ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
        filter_requirement_type = abap_true
               requirement_type = 'SB' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SB'
      act = lt_production_items[ 1 ]-requirement_type ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'SB'
      act = lt_planned_items[ 1 ]-requirement_type ).

    ls_range-requirement_type = space.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-requirement_type ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
       filter_staging_indicator = abap_true
              staging_indicator = '1' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_production_items[ 1 ]-staging_indicator ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_planned_items[ 1 ]-staging_indicator ).

    ls_range-staging_indicator = space.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-staging_indicator ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
       filter_mrp_relevance = abap_true
              mrp_relevance = '1' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_production_items[ 1 ]-mrp_relevance ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_planned_items[ 1 ]-mrp_relevance ).

    ls_range-mrp_relevance = space.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-mrp_relevance ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4 act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_wbs_internal_id = abap_true
      wbs_internal_id        = '00000002' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_production_items[ 1 ]-wbs_internal_id ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1 act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00000002'
      act = lt_planned_items[ 1 ]-wbs_internal_id ).

    ls_range-wbs_internal_id = space.
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-wbs_internal_id ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3 act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_res_num_from        = abap_true
      reservation_number_from    = '0000000011'
      filter_res_num_through     = abap_true
      reservation_number_through = '0000000013' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( lt_production_items[
        reservation_number = '0000000011' ] ) ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( lt_production_items[
        reservation_number = '0000000013' ] ) ).
    ls_range = VALUE #(
      filter_res_num_from     = abap_true
      reservation_number_from = '0000000013' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    ls_range = VALUE #(
      filter_res_num_through     = abap_true
      reservation_number_through = '0000000011' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).

    ls_range = VALUE #(
      filter_res_num_from        = abap_true
      reservation_number_from    = '0000000021'
      filter_res_num_through     = abap_true
      reservation_number_through = '0000000023' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( lt_planned_items[
        reservation_number = '0000000021' ] ) ).
    cl_abap_unit_assert=>assert_true(
      act = line_exists( lt_planned_items[
        reservation_number = '0000000023' ] ) ).
    ls_range = VALUE #(
      filter_res_num_from     = abap_true
      reservation_number_from = '0000000023' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).
    ls_range = VALUE #(
      filter_res_num_through     = abap_true
      reservation_number_through = '0000000021' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_reservation_item = abap_true
      reservation_item        = '0002' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_production_items[ 1 ]-reservation_item ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_res_item_from     = abap_true
      reservation_item_from    = '0002'
      filter_res_item_through  = abap_true
      reservation_item_through = '0002' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_production_items[ 1 ]-reservation_item ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_planned_items[ 1 ]-reservation_item ).

    ls_range = VALUE #(
      filter_required_qty_from    = abap_true
      required_quantity_from      = '6.000'
      filter_required_qty_through = abap_true
      required_quantity_through   = '7.000' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '6.000' )
      act = lt_production_items[ 1 ]-required_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdmng( '7.000' )
      act = lt_production_items[ 2 ]-required_quantity ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_withdrawn_qty_from    = abap_true
      withdrawn_quantity_from      = '1.000'
      filter_withdrawn_qty_through = abap_true
      withdrawn_quantity_through   = '2.000' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '1.000' )
      act = lt_production_items[ 1 ]-withdrawn_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-enmng( '2.000' )
      act = lt_production_items[ 2 ]-withdrawn_quantity ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_batch = abap_true
      batch        = 'BATCH-A' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BATCH-A'
      act = lt_production_items[ 1 ]-batch ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_batch = abap_true ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-batch ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 2 ]-batch ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_movement_type = abap_true
      movement_type        = '261' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '261'
      act = lt_production_items[ 1 ]-movement_type ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_movement_type = abap_true ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-movement_type ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_material = abap_true
      material        = 'MAT-A'
      filter_plant    = abap_true ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261023'
      act = lt_production_items[ 1 ]-required_date ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_storage_location = abap_true
      storage_location        = '0001' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_production_items ) ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_storage_location = abap_true ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-storage_location ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #(
      filter_material         = abap_true
      material                = 'MAT-A'
      filter_plant            = abap_true
      plant                   = '1000'
      filter_storage_location = abap_true
      storage_location        = '0001'
      filter_from             = abap_true
      required_date_from      = '20261021'
      include_undated         = abap_true ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261021'
      act = lt_production_items[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 2 ]-required_date ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'O'
      as_of_date                      = '20261021' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261020' )
      act = lt_production_items[ 1 ]-required_date ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'T'
      as_of_date                      = '20261021' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261021' )
      act = lt_production_items[ 1 ]-required_date ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'F'
      as_of_date                      = '20261021' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'U' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_production_items[ 1 ]-required_date ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'N'
      required_date_horizon_days      = 2
      as_of_date                      = '20261021' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261022' )
      act = lt_production_items[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261023' )
      act = lt_production_items[ 2 ]-required_date ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'N'
      required_date_horizon_days      = 2
      as_of_date                      = '20261021'
      include_undated                 = abap_true
      filter_through                  = abap_true
      required_date_through           = '20261022' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261022' )
      act = lt_planned_items[ 1 ]-required_date ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_planned_items[ 2 ]-required_date ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'R'
      required_date_horizon_days      = 1
      as_of_date                      = '20261021' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_production_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261020' )
      act = lt_production_items[ 1 ]-required_date ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261020' )
      act = lt_planned_items[ 1 ]-required_date ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'D' ).
    lt_production_items = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders   = VALUE #( ( 'ORDER-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_production_items ) ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_planned_items ) ).

    ls_range = VALUE #( filter_bucket = abap_true
      required_date_bucket            = 'U'
      as_of_date                      = '20261021' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_planned_items[ 1 ]-required_date ).
  ENDMETHOD.

  METHOD skips_empty_order_list.
    DATA(lo_cut) = NEW zcl_prod_comp_repo( ).
    DATA(lt_items) = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_items ).
  ENDMETHOD.
ENDCLASS.
