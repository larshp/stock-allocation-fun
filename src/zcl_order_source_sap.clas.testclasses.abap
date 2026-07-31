CLASS ltcl_order_source_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_delivery_priority FOR TESTING.
ENDCLASS.

CLASS ltcl_order_source_sap IMPLEMENTATION.
  METHOD maps_delivery_priority.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    lt_demands = lo_cut->get_open_demands(
      iv_material = 'MATERIAL-PRIO'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-priority
      exp = 99 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-sales_document
      exp = 'PRIO000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-sales_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-schedule_line
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-order_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-requested
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100002' ]-requested
      exp = '2' ).
  ENDMETHOD.
ENDCLASS.
