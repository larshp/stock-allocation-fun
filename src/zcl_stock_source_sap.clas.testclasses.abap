CLASS lcl_stock_read_auth_fail DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_source_read_authority.
ENDCLASS.

CLASS lcl_stock_read_auth_fail IMPLEMENTATION.
  METHOD zif_source_read_authority~check_stock.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_source_read_authority~check_orders.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_source_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_current_client_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_incomplete_scope FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_output FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_status_flags FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_delete_flags FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_deletion_marked_data FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized_read FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_source_sap IMPLEMENTATION.
  METHOD rejects_unauthorized_read.
    DATA lo_authority TYPE REF TO zif_source_read_authority.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_authority TYPE lcl_stock_read_auth_fail.
    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap
      EXPORTING
        io_authority = lo_authority.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-STOCK'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Stock read authorization failed' ).
  ENDMETHOD.

  METHOD rejects_incomplete_scope.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = ''
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Stock read scope is incomplete' ).
  ENDMETHOD.

  METHOD reads_current_client_stock.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-STOCK'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '12' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_true( ls_available-material_found ).
    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_managed ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-STOCK'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_expiration_date
      exp = '20261231' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_found ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-ZERO' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '0' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_found ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_expiration_date
      exp = '20261231' ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-MISSING'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '0' ).
    cl_abap_unit_assert=>assert_false( ls_available-material_found ).
  ENDMETHOD.

  METHOD rejects_invalid_output.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-NO-BASE'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_base_error).
        lv_raised = abap_true.
        lv_message = lo_base_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Material base unit is missing' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-NEGATIVE'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_quantity_error).
        lv_raised = abap_true.
        lv_message = lo_quantity_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Stock quantity is invalid' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BATCH-NO-MASTER'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'NOMASTER01' ).
      CATCH zcx_stock_allocation INTO DATA(lo_batch_error).
        lv_raised = abap_true.
        lv_message = lo_batch_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Batch master data is missing' ).
  ENDMETHOD.

  METHOD rejects_invalid_status_flags.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BAD-BATCH-FLAG'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_batch_flag_error).
        lv_raised = abap_true.
        lv_message = lo_batch_flag_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Material batch-management flag is invalid' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BAD-RESTRICTION'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BADSTATUS1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_restriction_flag_error).
        lv_raised = abap_true.
        lv_message = lo_restriction_flag_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Batch restriction flag is invalid' ).
  ENDMETHOD.

  METHOD rejects_bad_delete_flags.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BAD-STOCK-DELETE'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_stock_error).
        lv_raised = abap_true.
        lv_message = lo_stock_error->message.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Stock deletion flag is invalid' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BAD-MATERIAL-DELETE'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_material_error).
        lv_raised = abap_true.
        lv_message = lo_material_error->message.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Material deletion flag is invalid' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BAD-BATCH-DELETE'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BADDELETE1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_batch_error).
        lv_raised = abap_true.
        lv_message = lo_batch_error->message.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Batch deletion flag is invalid' ).
  ENDMETHOD.

  METHOD rejects_deletion_marked_data.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-DELETED'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_material_error).
        lv_raised = abap_true.
        lv_message = lo_material_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Material is marked for deletion' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-STOCK-DELETED'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_stock_error).
        lv_raised = abap_true.
        lv_message = lo_stock_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Stock record is marked for deletion' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BATCH-DELETED'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-DEL' ).
      CATCH zcx_stock_allocation INTO DATA(lo_batch_error).
        lv_raised = abap_true.
        lv_message = lo_batch_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Stock record is marked for deletion' ).

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BATCH-MASTER-DELETED'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BATCH-MDEL' ).
      CATCH zcx_stock_allocation INTO DATA(lo_batch_master_error).
        lv_raised = abap_true.
        lv_message = lo_batch_master_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Batch master data is marked for deletion' ).
  ENDMETHOD.
ENDCLASS.
