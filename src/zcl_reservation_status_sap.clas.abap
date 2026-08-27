CLASS zcl_reservation_status_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_reservation_status.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_item,
        document_id   TYPE zcl_stock_allocator=>ty_document_id,
        deletion_flag TYPE resb-xloek,
      END OF ty_item.
    TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_document_status,
        document_id     TYPE zcl_stock_allocator=>ty_document_id,
        has_active_item TYPE abap_bool,
      END OF ty_document_status.
    TYPES ty_document_statuses TYPE HASHED TABLE OF ty_document_status
      WITH UNIQUE KEY document_id.
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
    IF it_document_ids IS INITIAL.
      rs_result-is_success = abap_true.
      rs_result-message = 'Reservation status lookup completed'.
      RETURN.
    ENDIF.

    DATA lt_items TYPE ty_items.
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

    DATA lt_statuses TYPE ty_document_statuses.
    LOOP AT lt_items INTO DATA(ls_item).
      READ TABLE lt_statuses ASSIGNING FIELD-SYMBOL(<ls_status>)
        WITH TABLE KEY document_id = ls_item-document_id.
      IF sy-subrc <> 0.
        INSERT VALUE #( document_id = ls_item-document_id )
          INTO TABLE lt_statuses ASSIGNING <ls_status>.
      ENDIF.
      IF ls_item-deletion_flag IS INITIAL.
        <ls_status>-has_active_item = abap_true.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_statuses INTO DATA(ls_status)
      WHERE has_active_item = abap_false.
      INSERT ls_status-document_id INTO TABLE rs_result-cancelled_ids.
    ENDLOOP.
    rs_result-is_success = abap_true.
    rs_result-message = 'Reservation status lookup completed'.
  ENDMETHOD.
ENDCLASS.
