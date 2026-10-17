CLASS ltcl_prod_comp_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_bulk_components FOR TESTING RAISING cx_static_check.
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

  METHOD skips_empty_order_list.
    DATA(lo_cut) = NEW zcl_prod_comp_repo( ).
    DATA(lt_items) = lo_cut->zif_prod_comp_repo~get_components_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_items ).
  ENDMETHOD.
ENDCLASS.
