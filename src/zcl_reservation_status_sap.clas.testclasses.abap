CLASS ltcl_reservation_status_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_reservation_status_sap.

    METHODS setup.
    METHODS accepts_empty_scope FOR TESTING.
    METHODS rejects_invalid_scope FOR TESTING.
    METHODS rejects_invalid_single_id FOR TESTING.
ENDCLASS.

CLASS ltcl_reservation_status_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD accepts_empty_scope.
    DATA(ls_result) = mo_cut->zif_reservation_status~find_cancelled(
      VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-cancelled_ids ).
  ENDMETHOD.

  METHOD rejects_invalid_scope.
    DATA(ls_result) = mo_cut->zif_reservation_status~find_cancelled(
      VALUE #( ( 'BAD-DOC' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Reservation status lookup scope is invalid' ).
  ENDMETHOD.

  METHOD rejects_invalid_single_id.
    DATA(lv_cancelled) = mo_cut->zif_reservation_status~is_cancelled(
      'BAD-DOC' ).

    cl_abap_unit_assert=>assert_false( lv_cancelled ).
  ENDMETHOD.
ENDCLASS.
