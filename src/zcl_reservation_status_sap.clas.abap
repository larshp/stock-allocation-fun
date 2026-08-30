CLASS zcl_reservation_status_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_reservation_status.
ENDCLASS.

CLASS zcl_reservation_status_sap IMPLEMENTATION.
  METHOD zif_reservation_status~is_cancelled.
    DATA(lt_document_ids) = VALUE zif_reservation_status=>ty_document_ids(
      ( iv_document_id ) ).
    DATA(ls_result) = zif_reservation_status~find_cancelled(
      lt_document_ids ).
    rv_is_cancelled = xsdbool(
      ls_result-is_success = abap_true
      AND line_exists( ls_result-cancelled_ids[
        table_line = iv_document_id ] ) ).
  ENDMETHOD.

  METHOD zif_reservation_status~find_cancelled.
    DATA(ls_scope_result) = zcl_reservation_status_eval=>evaluate(
      it_document_ids = it_document_ids
      it_items        = VALUE #( ) ).
    IF ls_scope_result-is_success = abap_false
        OR it_document_ids IS INITIAL.
      rs_result = ls_scope_result.
      RETURN.
    ENDIF.

    DATA lt_items TYPE zcl_reservation_status_eval=>ty_items.
    SELECT rsnum AS document_id,
           xloek AS deletion_flag
      FROM resb
      FOR ALL ENTRIES IN @it_document_ids
      WHERE rsnum = @it_document_ids-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_items.
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      rs_result-message = 'Reservation status lookup failed'.
      RETURN.
    ENDIF.

    rs_result = zcl_reservation_status_eval=>evaluate(
      it_document_ids = it_document_ids
      it_items        = lt_items ).
  ENDMETHOD.
ENDCLASS.
