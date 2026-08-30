CLASS ltcl_reservation_status_eval DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS classifies_cancelled_document FOR TESTING.
    METHODS keeps_mixed_document_active FOR TESTING.
    METHODS keeps_missing_document_active FOR TESTING.
    METHODS rejects_invalid_scope FOR TESTING.
    METHODS rejects_unexpected_item FOR TESTING.
    METHODS rejects_bad_deletion_flag FOR TESTING.
ENDCLASS.

CLASS ltcl_reservation_status_eval IMPLEMENTATION.
  METHOD classifies_cancelled_document.
    DATA(ls_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = VALUE #( ( '0000000041' ) )
      it_items        = VALUE #(
        ( document_id   = '0000000041'
          deletion_flag = abap_true )
        ( document_id   = '0000000041'
          deletion_flag = abap_true ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_true( xsdbool(
      line_exists( ls_result-cancelled_ids[
        table_line = '0000000041' ] ) ) ).
  ENDMETHOD.

  METHOD keeps_mixed_document_active.
    DATA(ls_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = VALUE #( ( '0000000041' ) )
      it_items        = VALUE #(
        ( document_id   = '0000000041'
          deletion_flag = abap_true )
        ( document_id   = '0000000041'
          deletion_flag = abap_false ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-cancelled_ids ).
  ENDMETHOD.

  METHOD keeps_missing_document_active.
    DATA(ls_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = VALUE #( ( '0000000041' ) )
      it_items        = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_initial( ls_result-cancelled_ids ).
  ENDMETHOD.

  METHOD rejects_invalid_scope.
    DATA(ls_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = VALUE #( ( 'BAD-DOC' ) )
      it_items        = VALUE #( ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Reservation status lookup scope is invalid' ).
  ENDMETHOD.

  METHOD rejects_unexpected_item.
    DATA(ls_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = VALUE #( ( '0000000041' ) )
      it_items        = VALUE #(
        ( document_id   = '0000000042'
          deletion_flag = abap_true ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Reservation status evidence is invalid' ).
  ENDMETHOD.

  METHOD rejects_bad_deletion_flag.
    DATA(ls_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = VALUE #( ( '0000000041' ) )
      it_items        = VALUE #(
        ( document_id   = '0000000041'
          deletion_flag = 'Y' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Reservation status evidence is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-cancelled_ids ).
  ENDMETHOD.
ENDCLASS.
