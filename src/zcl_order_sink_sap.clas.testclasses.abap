CLASS ltcl_order_sink_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS changes_schedule_quantity FOR TESTING.
    METHODS rejects_bapi_error FOR TESTING.
    METHODS rejects_commit_failure FOR TESTING.
    METHODS rejects_unauthorized FOR TESTING.
ENDCLASS.

CLASS lcl_failing_order_sink_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_sink_authority.
ENDCLASS.

CLASS lcl_failing_order_sink_authority IMPLEMENTATION.
  METHOD zif_order_sink_authority~check.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_order_sink_sap IMPLEMENTATION.
  METHOD changes_schedule_quantity.
    DATA lo_cut TYPE REF TO zif_order_sink.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    lo_cut->change_schedule_quantity(
      iv_sales_document      = '0000000001'
      iv_sales_document_type = 'OR'
      iv_sales_item          = '000010'
      iv_schedule_line       = '0001'
      iv_quantity            = '4' ).
  ENDMETHOD.

  METHOD rejects_bapi_error.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = 'ORDERERR01'
          iv_sales_document_type = 'OR'
          iv_sales_item          = '000010'
          iv_schedule_line       = '0001'
          iv_quantity            = '4' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Sales-order change rejected by test double' ).
  ENDMETHOD.

  METHOD rejects_commit_failure.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = 'ORDCOMMIT1'
          iv_sales_document_type = 'OR'
          iv_sales_item          = '000010'
          iv_schedule_line       = '0001'
          iv_quantity            = '4' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Sales-order change commit failed' ).
  ENDMETHOD.

  METHOD rejects_unauthorized.
    DATA lo_cut TYPE REF TO zcl_order_sink_sap.
    DATA lo_authority TYPE REF TO lcl_failing_order_sink_authority.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_cut
      EXPORTING
        io_authority = lo_authority.
    TRY.
        lo_cut->zif_order_sink~change_schedule_quantity(
          iv_sales_document      = '0000000001'
          iv_sales_document_type = 'OR'
          iv_sales_item          = '000010'
          iv_schedule_line       = '0001'
          iv_quantity            = '4' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
