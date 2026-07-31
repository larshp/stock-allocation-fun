CLASS ltcl_stock_movement_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS delegates_to_goods_movement FOR TESTING.
    METHODS rejects_bapi_error FOR TESTING.
    METHODS rejects_commit_failure FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_movement_sap IMPLEMENTATION.
  METHOD delegates_to_goods_movement.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_document TYPE zif_stock_allocation=>ty_order_id.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    lv_document = lo_cut->post_goods_issue(
      iv_material         = 'MATERIAL-GI'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_quantity         = '2'
      iv_unit             = 'EA'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_not_initial( lv_document ).
  ENDMETHOD.

  METHOD rejects_bapi_error.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_commit_failure.
    DATA lo_cut TYPE REF TO zif_stock_movement.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_movement_sap.
    TRY.
        lo_cut->post_goods_issue(
          iv_material         = 'MATERIAL-GI-COMMIT'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '2'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
