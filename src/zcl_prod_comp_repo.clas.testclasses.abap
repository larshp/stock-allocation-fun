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
      exp = 'PL-2'
      act = lt_items[ 2 ]-planned_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COMP-2'
      act = lt_items[ 2 ]-material ).
  ENDMETHOD.

  METHOD filters_required_date_range.
    DATA lt_resb TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000010'
      rspos = '0001' bdter = '20261020' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000011'
      rspos = '0001' bdter = '20261021' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000012'
      rspos = '0001' bdter = '20261022' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000013'
      rspos = '0001' bdter = '20261023' ) TO lt_resb.
    APPEND VALUE #( aufnr = 'ORDER-1' rsnum = '0000000014'
      rspos = '0001' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000020'
      rspos = '0001' bdter = '20261020' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000021'
      rspos = '0001' bdter = '20261021' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000022'
      rspos = '0001' bdter = '20261022' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000023'
      rspos = '0001' bdter = '20261023' ) TO lt_resb.
    APPEND VALUE #( plnum = 'PLAN-1' rsnum = '0000000024'
      rspos = '0001' ) TO lt_resb.
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

    ls_range = VALUE #( filter_through = abap_true
      required_date_through            = '20261021' ).
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
      required_date_bucket            = 'U'
      as_of_date                      = '20261021' ).
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
      filter_through                  = abap_true
      required_date_through           = '20261022' ).
    lt_planned_items = lo_cut->zif_prod_comp_repo~get_planned_comp_bulk(
      it_planned_orders      = VALUE #( ( 'PLAN-1' ) )
      is_required_date_range = ls_range ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_planned_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV resb-bdter( '20261022' )
      act = lt_planned_items[ 1 ]-required_date ).

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
