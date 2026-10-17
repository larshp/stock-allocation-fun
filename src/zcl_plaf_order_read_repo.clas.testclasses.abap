CLASS ltcl_plaf_order_read_repo DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_environment TYPE REF TO if_osql_test_environment.
    METHODS setup RAISING cx_static_check.
    METHODS teardown RAISING cx_static_check.
    METHODS reads_planned_order_metadata FOR TESTING RAISING cx_static_check.
    METHODS skips_empty_order_list FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_plaf_order_read_repo IMPLEMENTATION.
  METHOD setup.
    DATA lt_tables TYPE if_osql_test_environment=>ty_t_sobjnames.
    APPEND 'PLAF' TO lt_tables.
    APPEND 'MARA' TO lt_tables.
    APPEND 'MARM' TO lt_tables.
    mo_environment = cl_osql_test_environment=>create( lt_tables ).
  ENDMETHOD.

  METHOD teardown.
    IF mo_environment IS BOUND.
      mo_environment->destroy( ).
      CLEAR mo_environment.
    ENDIF.
  ENDMETHOD.

  METHOD reads_planned_order_metadata.
    DATA lt_plaf TYPE STANDARD TABLE OF plaf WITH EMPTY KEY.
    DATA lt_mara TYPE STANDARD TABLE OF mara WITH EMPTY KEY.
    DATA lt_marm TYPE STANDARD TABLE OF marm WITH EMPTY KEY.

    APPEND VALUE #(
      plnum = '1001'
      matnr = 'MAT-1'
      pwwrk = '1000'
      psttr = '20261001'
      pedtr = '20261005'
      gsmng = '5.000'
      meins = 'CS'
      auffx = 'X'
      plscn = '001'
      sobkz = 'E'
      kdauf = 'SO-1' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = '1002'
      matnr = 'MAT-2'
      pwwrk = '2000'
      psttr = '20261002'
      pedtr = '20261006'
      gsmng = '3.000'
      meins = 'EA' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = '1003'
      matnr = 'MAT-3'
      meins = 'KG' ) TO lt_plaf.
    APPEND VALUE #(
      plnum = '1004'
      matnr = 'MAT-4'
      meins = 'EA' ) TO lt_plaf.
    APPEND VALUE #( matnr = 'MAT-1' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #( matnr = 'MAT-2' meins = 'EA' ) TO lt_mara.
    APPEND VALUE #(
      matnr = 'MAT-1'
      meinh = 'CS'
      umrez = 12
      umren = 1 ) TO lt_marm.

    mo_environment->insert_test_data( lt_plaf ).
    mo_environment->insert_test_data( lt_mara ).
    mo_environment->insert_test_data( lt_marm ).

    DATA(lo_cut) = NEW zcl_plaf_order_read_repo( ).
    DATA(lt_orders) = lo_cut->zif_planned_order_read_repo~read_orders(
      it_planned_orders = VALUE #(
        ( '1003' )
        ( '1001' )
        ( '1002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_orders ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV plaf-plnum( '1001' )
      act = lt_orders[ 1 ]-planned_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mara-meins( 'EA' )
      act = lt_orders[ 1 ]-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marm-umrez( '12' )
      act = lt_orders[ 1 ]-unit_to_base_numerator ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV marm-umren( '1' )
      act = lt_orders[ 1 ]-unit_to_base_denominator ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV plaf-gsmng( '5.000' )
      act = lt_orders[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV plaf-kdauf( 'SO-1' )
      act = lt_orders[ 1 ]-sales_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV plaf-plnum( '1002' )
      act = lt_orders[ 2 ]-planned_order ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_orders[ 2 ]-unit_to_base_numerator ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV plaf-plnum( '1003' )
      act = lt_orders[ 3 ]-planned_order ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_orders[ 3 ]-base_unit ).
  ENDMETHOD.

  METHOD skips_empty_order_list.
    DATA(lo_cut) = NEW zcl_plaf_order_read_repo( ).
    DATA(lt_orders) = lo_cut->zif_planned_order_read_repo~read_orders(
      it_planned_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_initial(
      act = lt_orders ).
  ENDMETHOD.
ENDCLASS.
