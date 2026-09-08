CLASS ltcl_reservation_gateway_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_reservation_gateway_sap.

    METHODS setup.
    METHODS rejects_incomplete_request FOR TESTING.
    METHODS rejects_imprecise_quantity FOR TESTING.
    METHODS rejects_missing_assignment FOR TESTING.
    METHODS rejects_missing_bapi_document FOR TESTING.
    METHODS accepts_empty_commit_response FOR TESTING.

    METHODS request
      RETURNING
        VALUE(rs_request) TYPE zif_reservation_gateway=>ty_request.
ENDCLASS.

CLASS ltcl_reservation_gateway_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD rejects_incomplete_request.
    mo_cut->zif_reservation_gateway~create_reservation(
      EXPORTING
        is_request     = VALUE #( )
      IMPORTING
        ev_document_id = DATA(lv_document_id)
        et_messages    = DATA(lt_messages) ).

    cl_abap_unit_assert=>assert_initial( lv_document_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_messages[ 1 ]-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_messages[ 1 ]-message
      exp = 'Reservation request is invalid' ).
  ENDMETHOD.

  METHOD rejects_imprecise_quantity.
    DATA(ls_request) = request( ).
    ls_request-quantity = '1.0001'.

    mo_cut->zif_reservation_gateway~create_reservation(
      EXPORTING
        is_request     = ls_request
      IMPORTING
        ev_document_id = DATA(lv_document_id)
        et_messages    = DATA(lt_messages) ).

    cl_abap_unit_assert=>assert_initial( lv_document_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_messages[ 1 ]-message
      exp = 'Reservation request is invalid' ).
  ENDMETHOD.

  METHOD rejects_missing_assignment.
    DATA(ls_request) = request( ).
    CLEAR ls_request-cost_center.

    mo_cut->zif_reservation_gateway~create_reservation(
      EXPORTING
        is_request     = ls_request
      IMPORTING
        ev_document_id = DATA(lv_document_id)
        et_messages    = DATA(lt_messages) ).

    cl_abap_unit_assert=>assert_initial( lv_document_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_messages[ 1 ]-message
      exp = 'Reservation request is invalid' ).
  ENDMETHOD.

  METHOD rejects_missing_bapi_document.
    mo_cut->zif_reservation_gateway~create_reservation(
      EXPORTING
        is_request     = request( )
      IMPORTING
        ev_document_id = DATA(lv_document_id)
        et_messages    = DATA(lt_messages) ).

    cl_abap_unit_assert=>assert_initial( lv_document_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_messages[ 1 ]-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_messages[ 1 ]-message
      exp = 'Reservation API returned invalid document ID' ).
  ENDMETHOD.

  METHOD accepts_empty_commit_response.
    DATA(lt_messages) = mo_cut->zif_reservation_gateway~commit( ).

    cl_abap_unit_assert=>assert_initial( lt_messages ).
  ENDMETHOD.

  METHOD request.
    rs_request = VALUE #(
      request_id       = 'REQUEST-1'
      material         = 'MAT-1'
      plant            = '1000'
      storage_location = '0001'
      movement_type    = '201'
      cost_center      = 'CC1000'
      unit_of_measure  = 'EA'
      requirement_date = '20260818'
      quantity         = 5 ).
  ENDMETHOD.
ENDCLASS.
