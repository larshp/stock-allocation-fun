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

  METHOD zif_source_read_authority~check_sales_document.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_source_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PUBLIC SECTION.
    INTERFACES zif_source_read_authority.
  PRIVATE SECTION.
    DATA mv_authorized_plant TYPE zif_stock_allocation=>ty_plant.
    DATA mv_authorized_batch TYPE zif_stock_allocation=>ty_batch.
    METHODS reads_current_client_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS subtracts_open_reservations FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_reservation_qty FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS forwards_stock_scope FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_incomplete_scope FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unknown_sloc FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_output FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_invalid_status_flags FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_delete_flags FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_deletion_marked_data FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_expiry_date FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_unauthorized_read FOR TESTING
      RAISING zcx_stock_allocation.
ENDCLASS.

CLASS ltcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_source_read_authority~check_stock.
    mv_authorized_plant = iv_plant.
    mv_authorized_batch = iv_batch.
  ENDMETHOD.

  METHOD zif_source_read_authority~check_orders.
  ENDMETHOD.

  METHOD zif_source_read_authority~check_sales_document.
  ENDMETHOD.

  METHOD forwards_stock_scope.
    DATA lo_authority TYPE REF TO zif_source_read_authority.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.

    lo_authority ?= me.
    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap
      EXPORTING
        io_authority = lo_authority.
    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '4' ).
    cl_abap_unit_assert=>assert_equals(
      act = mv_authorized_plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mv_authorized_batch
      exp = 'BATCH-001' ).
  ENDMETHOD.

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
          iv_material             = 'MATERIAL-STOCK'
          iv_plant                = '1000'
          iv_storage_location     = '0001'
          iv_include_reservations = abap_true ).
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

  METHOD rejects_unknown_sloc.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-STOCK'
          iv_plant            = '1000'
          iv_storage_location = '0099' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Storage location is invalid for plant' ).
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
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quality_inspection_qty
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-restricted_use_qty
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-blocked_stock_qty
      exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-transfer_stock_qty
      exp = 5 ).
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
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quality_inspection_qty
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-restricted_use_qty
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-blocked_stock_qty
      exp = 3 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-transfer_stock_qty
      exp = 4 ).

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
      iv_material         = 'MATERIAL-GLOBAL-BATCH'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'GLOBAL0001' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_found ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_expiration_date
      exp = '20271231' ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-GLOBAL-RESTRICTED'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'GLBRESTR01' ).
    cl_abap_unit_assert=>assert_true( ls_available-batch_restricted ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_expiration_date
      exp = '20270101' ).

    ls_available = lo_cut->get_available(
      iv_material         = 'MATERIAL-MISSING'
      iv_plant            = '1000'
      iv_storage_location = '0001' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '0' ).
    cl_abap_unit_assert=>assert_false( ls_available-material_found ).
  ENDMETHOD.

  METHOD subtracts_open_reservations.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_reservation_id TYPE zif_stock_allocation=>ty_reservation_id.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    ls_available = lo_cut->get_available(
      iv_material             = 'MATERIAL-RESERVED'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_include_reservations = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '15' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unrestricted_quantity
      exp = '20' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-reservation_quantity
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_reservation_quantity
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unassigned_resv_quantity
      exp = '5' ).
    cl_abap_unit_assert=>assert_true( ls_available-reservations_included ).

    ls_available = lo_cut->get_available(
      iv_material             = 'MATERIAL-RESERVED-BATCH'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_include_reservations = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '8' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-reservation_quantity
      exp = '12' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_reservation_quantity
      exp = '10' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unassigned_resv_quantity
      exp = '2' ).

    " Selected batch plus unassigned reservations, excluding other batches.
    ls_available = lo_cut->get_available(
      iv_material             = 'MATERIAL-RESERVED-BATCH'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_batch                = 'BATCH-RES'
      iv_include_reservations = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '7' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-reservation_quantity
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-batch_reservation_quantity
      exp = '3' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-unassigned_resv_quantity
      exp = '2' ).

    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    lv_reservation_id = lo_reservation->reserve(
      iv_material         = 'MATERIAL-RESERVED'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_quantity         = '2'
      iv_unit             = 'EA'
      iv_required_date    = '20260930' ).
    cl_abap_unit_assert=>assert_not_initial( lv_reservation_id ).

    ls_available = lo_cut->get_available(
      iv_material             = 'MATERIAL-RESERVED'
      iv_plant                = '1000'
      iv_storage_location     = '0001'
      iv_include_reservations = abap_true
      it_app_reservation_ids  = VALUE #(
        ( '9999999970' )
        ( '9999999971' )
        ( '9999999972' )
        ( lv_reservation_id ) ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-quantity
      exp = '13' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_available-reusable_reservations[
        reservation_id = lv_reservation_id ]-quantity
      exp = '2' ).
    cl_abap_unit_assert=>assert_true( line_exists(
      ls_available-sap_accounted_reservations[
        table_line = '9999999970' ] ) ).
    cl_abap_unit_assert=>assert_false( line_exists(
      ls_available-sap_accounted_reservations[
        table_line = '9999999971' ] ) ).
    cl_abap_unit_assert=>assert_true( line_exists(
      ls_available-sap_accounted_reservations[
        table_line = '9999999972' ] ) ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_qty.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material             = 'MATERIAL-BAD-RESERVATION'
          iv_plant                = '1000'
          iv_storage_location     = '0001'
          iv_include_reservations = abap_true ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation quantity is invalid' ).
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
          iv_material         = 'MATERIAL-NEGATIVE-STATUS'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_status_quantity_error).
        lv_raised = abap_true.
        lv_message = lo_status_quantity_error->message.
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

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-PLANT-MISSING'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_plant_data_error).
        lv_raised = abap_true.
        lv_message = lo_plant_data_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Plant material data is missing' ).
  ENDMETHOD.

  METHOD rejects_bad_expiry_date.
    DATA lo_cut TYPE REF TO zif_stock_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_source_sap.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-BATCH'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'BADDATE01' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Batch expiration date is invalid' ).
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

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-GLOBAL-BAD-STATUS'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'GLBBADST01' ).
      CATCH zcx_stock_allocation INTO DATA(lo_global_flag_error).
        lv_raised = abap_true.
        lv_message = lo_global_flag_error->message.
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
          iv_material         = 'MATERIAL-BAD-PLANT-DELETE'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_plant_flag_error).
        lv_raised = abap_true.
        lv_message = lo_plant_flag_error->message.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Plant material deletion flag is invalid' ).

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
          iv_material         = 'MATERIAL-PLANT-DELETED'
          iv_plant            = '1000'
          iv_storage_location = '0001' ).
      CATCH zcx_stock_allocation INTO DATA(lo_plant_deletion_error).
        lv_raised = abap_true.
        lv_message = lo_plant_deletion_error->message.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Material is marked for deletion at plant' ).

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

    CLEAR: lv_raised, lv_message.
    TRY.
        lo_cut->get_available(
          iv_material         = 'MATERIAL-GLOBAL-DELETED'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_batch            = 'GLBDELETE1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_global_batch_master_error).
        lv_raised = abap_true.
        lv_message = lo_global_batch_master_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Batch master data is marked for deletion' ).
  ENDMETHOD.
ENDCLASS.
