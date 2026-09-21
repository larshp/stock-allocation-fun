CLASS ltcl_stock_avail_validator DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS accepts_consistent_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS accepts_fully_reserved_stock FOR TESTING
      RAISING zcx_stock_allocation.
    METHODS rejects_bad_net_quantity FOR TESTING.
    METHODS rejects_unrequested_resv FOR TESTING.
    METHODS rejects_bad_reservation_split FOR TESTING.
    METHODS rejects_negative_status_qty FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_avail_validator IMPLEMENTATION.
  METHOD accepts_consistent_stock.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.

    ls_available-quantity = 12.
    ls_available-unrestricted_quantity = 12.
    zcl_stock_avail_validator=>validate(
      iv_include_reservations = abap_false
      is_available            = ls_available ).

    ls_available-quantity = 15.
    ls_available-unrestricted_quantity = 20.
    ls_available-reservation_quantity = 5.
    ls_available-unassigned_resv_quantity = 5.
    ls_available-reservations_included = abap_true.
    zcl_stock_avail_validator=>validate(
      iv_include_reservations = abap_true
      is_available            = ls_available ).
  ENDMETHOD.

  METHOD accepts_fully_reserved_stock.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.

    ls_available-quantity = 0.
    ls_available-unrestricted_quantity = 4.
    ls_available-reservation_quantity = 7.
    ls_available-batch_reservation_quantity = 7.
    ls_available-reservations_included = abap_true.
    zcl_stock_avail_validator=>validate(
      iv_include_reservations = abap_true
      is_available            = ls_available ).
  ENDMETHOD.

  METHOD rejects_bad_net_quantity.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_raised TYPE abap_bool.

    ls_available-quantity = 16.
    ls_available-unrestricted_quantity = 20.
    ls_available-reservation_quantity = 5.
    ls_available-unassigned_resv_quantity = 5.
    ls_available-reservations_included = abap_true.
    TRY.
        zcl_stock_avail_validator=>validate(
          iv_include_reservations = abap_true
          is_available            = ls_available ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_unrequested_resv.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_raised TYPE abap_bool.

    ls_available-quantity = 9.
    ls_available-unrestricted_quantity = 10.
    ls_available-reservation_quantity = 1.
    ls_available-unassigned_resv_quantity = 1.
    TRY.
        zcl_stock_avail_validator=>validate(
          iv_include_reservations = abap_false
          is_available            = ls_available ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_split.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_raised TYPE abap_bool.

    ls_available-quantity = 5.
    ls_available-unrestricted_quantity = 10.
    ls_available-reservation_quantity = 5.
    ls_available-batch_reservation_quantity = 0.
    ls_available-unassigned_resv_quantity = 4.
    ls_available-reservations_included = abap_true.
    TRY.
        zcl_stock_avail_validator=>validate(
          iv_include_reservations = abap_true
          is_available            = ls_available ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD rejects_negative_status_qty.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_raised TYPE abap_bool.

    ls_available-quantity = 5.
    ls_available-unrestricted_quantity = 5.
    ls_available-quality_inspection_qty = -1.
    TRY.
        zcl_stock_avail_validator=>validate(
          iv_include_reservations = abap_false
          is_available            = ls_available ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.
