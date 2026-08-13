CLASS ltcl_stock_movement_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
    PRIVATE SECTION.
    METHODS delegates_to_goods_movement FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_input FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_movement_type FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_zero_movement_type FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bapi_error FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bapi_classic_exception FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_return_type FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_short_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_zero_document FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_missing_document_year FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_zero_document_year FOR TESTING
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

CLASS lcl_failing_movement_authority DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_movement_authority.
ENDCLASS.

CLASS lcl_failing_movement_authority IMPLEMENTATION.
  METHOD zif_stock_movement_authority~check.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_movement_sap IMPLEMENTATION.
  METHOD rejects_invalid_input.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '0'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement input is invalid' ).
  ENDMETHOD.

  METHOD rejects_invalid_movement_type.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '20'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement input is invalid' ).
  ENDMETHOD.

  METHOD rejects_zero_movement_type.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '000'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement input is invalid' ).
  ENDMETHOD.

  METHOD delegates_to_goods_movement.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA ls_document TYPE zif_stock_movement=>ty_document.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    ls_document = lo_cut->post_goods_issue(
      iv_material         = 'MATERIAL-GI'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_quantity         = '2'
      iv_unit             = 'ea'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_not_initial( ls_document-number ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_document-year
      exp = '2026' ).
  ENDMETHOD.

  METHOD rejects_bapi_error.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement rejected by test double' ).
  ENDMETHOD.

  METHOD rejects_bapi_classic_exception.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-FM-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement failed' ).
  ENDMETHOD.

  METHOD rejects_bad_return_type.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-BAD-RETURN-TYPE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement BAPI returned invalid status' ).
  ENDMETHOD.

  METHOD rejects_bad_document.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-BAD-DOCUMENT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement document returned by SAP is invalid' ).
  ENDMETHOD.

  METHOD rejects_short_document.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-SHORT-DOCUMENT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement document returned by SAP is invalid' ).
  ENDMETHOD.

  METHOD rejects_zero_document.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ZERO-DOCUMENT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement document returned by SAP is invalid' ).
  ENDMETHOD.

  METHOD rejects_missing_document_year.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-NO-YEAR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement failed' ).
  ENDMETHOD.

  METHOD rejects_zero_document_year.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ZERO-YEAR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement failed' ).
  ENDMETHOD.

  METHOD rejects_bapi_rollback_failure.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ERROR-ROLLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement rejected by test double; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_rollback_return.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.
    DATA lv_expected TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ERROR-ROLLBACK-RETURN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    CONCATENATE 'Goods movement rejected by test double'
                'Transaction rollback failed: Transaction rollback rejected by test double'
           INTO lv_expected SEPARATED BY '; '.
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = lv_expected ).

    CLEAR: lv_raised,
           lv_message.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ROLLBACK-BAD-RETURN'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO lo_error.
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    CONCATENATE 'Goods movement rejected by test double'
                'Transaction rollback failed: Invalid transaction rollback return status'
           INTO lv_expected SEPARATED BY '; ' .
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = lv_expected ).
  ENDMETHOD.

  METHOD rejects_commit_failure.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-COMMIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement commit failed' ).
  ENDMETHOD.

  METHOD rejects_commit_return_error.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-COMMIT-RETURN-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
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
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ROLLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement commit failed; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_unauthorized.
    DATA lo_cut TYPE REF TO zcl_stock_movement_sap.
    DATA lo_authority TYPE REF TO lcl_failing_movement_authority.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_cut
      EXPORTING
        io_authority = lo_authority.
    TRY.
        lo_cut->zif_stock_movement~post_goods_issue(
          iv_material         = 'MATERIAL-GI'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Goods movement authorization failed' ).
  ENDMETHOD.
ENDCLASS.
