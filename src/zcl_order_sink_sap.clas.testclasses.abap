CLASS ltcl_order_sink_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS changes_schedule_quantity FOR TESTING.
    METHODS rejects_bapi_error FOR TESTING.
    METHODS rejects_commit_failure FOR TESTING.
ENDCLASS.

CLASS ltcl_order_sink_sap IMPLEMENTATION.
  METHOD changes_schedule_quantity.
    DATA lo_cut TYPE REF TO zif_order_sink.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    lo_cut->change_schedule_quantity(
      iv_sales_document = '0000000001'
      iv_sales_item     = '000010'
      iv_schedule_line  = '0001'
      iv_quantity       = '4' ).
  ENDMETHOD.

  METHOD rejects_bapi_error.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document = 'ORDERERR01'
          iv_sales_item     = '000010'
          iv_schedule_line  = '0001'
          iv_quantity       = '4' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_commit_failure.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document = 'ORDCOMMIT1'
          iv_sales_item     = '000010'
          iv_schedule_line  = '0001'
          iv_quantity       = '4' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
