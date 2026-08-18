CLASS ltcl_order_sink_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS changes_schedule_quantity FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_input FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_short_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_zero_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_zero_keys FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bapi_error FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bapi_classic_exception FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_return_type FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bapi_rollback_failure FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_rollback_return FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_commit_failure FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_commit_return_error FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_rollback_failure FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS lcl_fail_order_sink_auth DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_sink_authority.
ENDCLASS.

CLASS lcl_fail_order_sink_auth IMPLEMENTATION.
  METHOD zif_order_sink_authority~check.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_order_sink_sap IMPLEMENTATION.
  METHOD rejects_invalid_input.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = ''
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
      exp = 'Sales-order change input is invalid' ).
  ENDMETHOD.

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

  METHOD rejects_bad_document.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = 'BAD-DOC01'
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
      exp = 'Sales-order change input is invalid' ).
  ENDMETHOD.

  METHOD rejects_short_document.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '123'
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
      exp = 'Sales-order change input is invalid' ).
  ENDMETHOD.

  METHOD rejects_zero_document.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '0000000000'
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
      exp = 'Sales-order change input is invalid' ).
  ENDMETHOD.

  METHOD rejects_zero_keys.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '0000000001'
          iv_sales_document_type = 'OR'
          iv_sales_item          = '000000'
          iv_schedule_line       = '0000'
          iv_quantity            = '4' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Sales-order change input is invalid' ).
  ENDMETHOD.

  METHOD rejects_bapi_error.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999901'
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

  METHOD rejects_bapi_classic_exception.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999905'
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
      exp = 'Sales-order change failed' ).
  ENDMETHOD.

  METHOD rejects_bad_return_type.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999900'
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
      exp = 'Sales-order change BAPI returned invalid status' ).
  ENDMETHOD.

  METHOD rejects_bapi_rollback_failure.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999902'
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
      exp = 'Sales-order change rejected by test double; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_rollback_return.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.
    DATA lv_expected TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999910'
          iv_sales_document_type = 'OR'
          iv_sales_item          = '000010'
          iv_schedule_line       = '0001'
          iv_quantity            = '4' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    CONCATENATE 'Sales-order change rejected by test double'
                'Transaction rollback failed: Transaction rollback rejected by test double'
           INTO lv_expected SEPARATED BY '; '.
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = lv_expected ).

    CLEAR: lv_raised,
           lv_message.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999911'
          iv_sales_document_type = 'OR'
          iv_sales_item          = '000010'
          iv_schedule_line       = '0001'
          iv_quantity            = '4' ).
      CATCH zcx_stock_allocation INTO lo_error.
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    CONCATENATE 'Sales-order change rejected by test double'
                'Transaction rollback failed: Invalid transaction rollback return status'
           INTO lv_expected SEPARATED BY '; ' .
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = lv_expected ).
  ENDMETHOD.

  METHOD rejects_commit_failure.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999903'
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

  METHOD rejects_commit_return_error.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999907'
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
      exp = 'Transaction commit rejected by test double' ).
  ENDMETHOD.

  METHOD rejects_rollback_failure.
    DATA lo_cut TYPE REF TO zif_order_sink.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_sink_sap.
    TRY.
        lo_cut->change_schedule_quantity(
          iv_sales_document      = '9999999904'
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
      exp = 'Sales-order change commit failed; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_unauthorized.
    DATA lo_cut TYPE REF TO zcl_order_sink_sap.
    DATA lo_authority TYPE REF TO lcl_fail_order_sink_auth.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

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
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Sales-order change authorization failed' ).
  ENDMETHOD.
ENDCLASS.
