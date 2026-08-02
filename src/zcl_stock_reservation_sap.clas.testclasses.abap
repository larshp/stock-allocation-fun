CLASS ltcl_stock_reservation_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS delegates_to_reservation_bapi FOR TESTING.
    METHODS rejects_non_positive FOR TESTING.
    METHODS rejects_invalid_movement_type FOR TESTING.
    METHODS rejects_bapi_error FOR TESTING.
    METHODS rejects_bapi_rollback_failure FOR TESTING.
    METHODS rejects_commit_failure FOR TESTING.
    METHODS rejects_rollback_failure FOR TESTING.
    METHODS cancels_reservation_bapi FOR TESTING.
    METHODS rejects_cancel_bapi_rollback FOR TESTING.
    METHODS rejects_cancel_rollback FOR TESTING.
    METHODS rejects_cancel_bad_movement FOR TESTING.
    METHODS rejects_unauthorized FOR TESTING.
    METHODS rejects_cancel_unauthorized FOR TESTING.
ENDCLASS.

CLASS lcl_fail_reservation_auth DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation_authority.
ENDCLASS.

CLASS lcl_fail_reservation_auth IMPLEMENTATION.
  METHOD zif_stock_allocation_authority~check.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.

  METHOD zif_stock_allocation_authority~check_cancel.
    RAISE EXCEPTION TYPE zcx_stock_allocation.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_reservation_sap IMPLEMENTATION.
  METHOD delegates_to_reservation_bapi.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_document TYPE zif_stock_allocation=>ty_order_id.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    lv_document = lo_cut->reserve(
      iv_material         = 'MATERIAL-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_quantity         = '3'
      iv_unit             = 'ea'
      iv_required_date    = '20260815'
      iv_batch            = 'BATCH-001' ).

    cl_abap_unit_assert=>assert_not_initial( lv_document ).
  ENDMETHOD.

  METHOD rejects_non_positive.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '0'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation input is invalid' ).
  ENDMETHOD.

  METHOD rejects_invalid_movement_type.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '2A1'
          iv_quantity         = '3'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation input is invalid' ).
  ENDMETHOD.

  METHOD rejects_bapi_error.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '3'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation rejected by test double' ).
  ENDMETHOD.

  METHOD rejects_bapi_rollback_failure.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-ERROR-ROLLBACK'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '3'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation rejected by test double; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_commit_failure.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-COMMIT-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '3'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation commit failed' ).
  ENDMETHOD.

  METHOD rejects_rollback_failure.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-ROLLBACK-ERROR'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '3'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation commit failed; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD cancels_reservation_bapi.
    DATA lo_cut TYPE REF TO zif_stock_reservation.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    lo_cut->cancel(
      iv_document      = '0000000001'
      iv_plant         = '1000'
      iv_movement_type = '201' ).
  ENDMETHOD.

  METHOD rejects_cancel_bapi_rollback.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->cancel(
          iv_document      = 'RESERRRBK1'
          iv_plant         = '1000'
          iv_movement_type = '201' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation deletion rejected by test double; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_cancel_rollback.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->cancel(
          iv_document      = 'RESROLLBK1'
          iv_plant         = '1000'
          iv_movement_type = '201' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation cancellation commit failed; Transaction rollback failed' ).
  ENDMETHOD.

  METHOD rejects_unauthorized.
    DATA lo_cut TYPE REF TO zcl_stock_reservation_sap.
    DATA lo_authority TYPE REF TO lcl_fail_reservation_auth.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_cut
      EXPORTING
        io_authority = lo_authority.
    TRY.
        lo_cut->zif_stock_reservation~reserve(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '3'
          iv_unit             = 'EA'
          iv_required_date    = '20260815' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation authorization failed' ).
  ENDMETHOD.

  METHOD rejects_cancel_unauthorized.
    DATA lo_cut TYPE REF TO zcl_stock_reservation_sap.
    DATA lo_authority TYPE REF TO lcl_fail_reservation_auth.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_authority.
    CREATE OBJECT lo_cut
      EXPORTING
        io_authority = lo_authority.
    TRY.
        lo_cut->zif_stock_reservation~cancel(
          iv_document      = '0000000001'
          iv_plant         = '1000'
          iv_movement_type = '201' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation cancellation authorization failed' ).
  ENDMETHOD.

  METHOD rejects_cancel_bad_movement.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->cancel(
          iv_document      = '0000000001'
          iv_plant         = '1000'
          iv_movement_type = '2A1' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Reservation document is required' ).
  ENDMETHOD.
ENDCLASS.
