CLASS ltcl_sales_order_delivery_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_lines_and_fallback FOR TESTING
      RAISING cx_static_check.
    METHODS skips_empty_document_list FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_sales_order_delivery_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    DATA lt_vbap TYPE STANDARD TABLE OF vbap WITH EMPTY KEY.
    DATA lt_vbup TYPE STANDARD TABLE OF vbup WITH EMPTY KEY.
    DATA lt_vbep TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.

    APPEND 'VBAP' TO lt_tables.
    APPEND 'VBUP' TO lt_tables.
    APPEND 'VBEP' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).

    APPEND VALUE #(
      vbeln  = 'SO-1'
      posnr  = '000010'
      kwmeng = '20.000'
      vsmng  = '3.000' ) TO lt_vbap.
    APPEND VALUE #(
      vbeln  = 'SO-1'
      posnr  = '000020'
      kwmeng = '8.000'
      vsmng  = '2.000' ) TO lt_vbap.
    APPEND VALUE #(
      vbeln  = 'SO-2'
      posnr  = '000010'
      kwmeng = '7.000'
      vsmng  = '1.000' ) TO lt_vbap.

    APPEND VALUE #(
      vbeln = 'SO-1'
      posnr = '000010'
      lfsta = 'C' ) TO lt_vbup.
    APPEND VALUE #(
      vbeln = 'SO-2'
      posnr = '000010'
      lfsta = 'A' ) TO lt_vbup.

    APPEND VALUE #(
      vbeln = 'SO-1'
      posnr = '000010'
      etenr = '0002'
      edatu = '20261101'
      mbdat = '20261030'
      wmeng = '6.000'
      bmeng = '4.000'
      vsmng = '1.000' ) TO lt_vbep.
    APPEND VALUE #(
      vbeln = 'SO-1'
      posnr = '000010'
      etenr = '0001'
      edatu = '20261025'
      mbdat = '20261020'
      wmeng = '10.000'
      bmeng = '8.000'
      vsmng = '2.000' ) TO lt_vbep.
    APPEND VALUE #(
      vbeln = 'SO-2'
      posnr = '000010'
      etenr = '0001'
      edatu = '20261203'
      mbdat = '20261201'
      wmeng = '5.000'
      bmeng = '3.000'
      vsmng = '1.000' ) TO lt_vbep.

    mo_environment->insert_test_data( lt_vbap ).
    mo_environment->insert_test_data( lt_vbup ).
    mo_environment->insert_test_data( lt_vbep ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_lines_and_fallback.
    DATA(lo_cut) = NEW zcl_sales_order_delivery_repo( ).
    DATA(lt_items) = lo_cut->zif_sales_order_delivery_repo~get_orders_items(
      VALUE #( ( 'SO-1' ) ( 'SO-2' ) ) ).
    DATA(lt_single_items) = lo_cut->zif_sales_order_delivery_repo~get_order_items(
      iv_sales_document = 'SO-1' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000010'
      act = lt_items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0001'
      act = lt_items[ 1 ]-schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV vbep-edatu( '20261025' )
      act = lt_items[ 1 ]-requested_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV vbep-mbdat( '20261020' )
      act = lt_items[ 1 ]-material_availability_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = lt_items[ 1 ]-ordered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV vbep-bmeng( '8.000' )
      act = lt_items[ 1 ]-confirmed_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 1 ]-delivered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_items[ 1 ]-has_schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'C'
      act = lt_items[ 1 ]-delivery_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_items[ 1 ]-has_status ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0002'
      act = lt_items[ 2 ]-schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = lt_items[ 3 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_items[ 3 ]-ordered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lt_items[ 3 ]-delivered_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_items[ 3 ]-has_schedule_line ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_items[ 3 ]-has_status ).

    cl_abap_unit_assert=>assert_equals(
      exp = 'SO-2'
      act = lt_items[ 4 ]-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'A'
      act = lt_items[ 4 ]-delivery_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_single_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = lt_single_items[ 3 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '8.000' )
      act = lt_single_items[ 3 ]-ordered_quantity ).
  ENDMETHOD.

  METHOD skips_empty_document_list.
    DATA(lo_cut) = NEW zcl_sales_order_delivery_repo( ).
    DATA(lt_items) = lo_cut->zif_sales_order_delivery_repo~get_orders_items(
      VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_items ).
  ENDMETHOD.
ENDCLASS.
