CLASS ltcl_stock_reservation_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS delegates_to_reservation_bapi FOR TESTING.
    METHODS rejects_non_positive FOR TESTING.
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
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_document
      exp = 'STUB-RESERVATION' ).
  ENDMETHOD.

  METHOD rejects_non_positive.
    DATA lo_cut TYPE REF TO zif_stock_reservation.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_reservation_sap.
    TRY.
        lo_cut->reserve(
          iv_material         = 'MATERIAL-1'
          iv_plant            = '1000'
          iv_storage_location = '0001'
          iv_movement_type    = '201'
          iv_quantity         = '0'
          iv_unit             = 'EA' ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
