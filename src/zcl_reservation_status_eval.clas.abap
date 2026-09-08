CLASS zcl_reservation_status_eval DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_item,
        document_id   TYPE zcl_stock_allocator=>ty_document_id,
        deletion_flag TYPE resb-xloek,
      END OF ty_item.
    TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.

    CLASS-METHODS evaluate
      IMPORTING
        it_document_ids  TYPE zif_reservation_status=>ty_document_ids
        it_items         TYPE ty_items
      RETURNING
        VALUE(rs_result) TYPE zif_reservation_status=>ty_result.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_document_status,
        document_id     TYPE zcl_stock_allocator=>ty_document_id,
        has_active_item TYPE abap_bool,
      END OF ty_document_status.
    TYPES ty_document_statuses TYPE HASHED TABLE OF ty_document_status
      WITH UNIQUE KEY document_id.
ENDCLASS.

CLASS zcl_reservation_status_eval IMPLEMENTATION.
  METHOD evaluate.
    LOOP AT it_document_ids INTO DATA(lv_document_id).
      IF zcl_allocation_persistence=>document_id_is_valid(
          lv_document_id ) = abap_false.
        rs_result-message = 'Reservation status lookup scope is invalid'.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA lt_statuses TYPE ty_document_statuses.
    LOOP AT it_items INTO DATA(ls_item).
      IF zcl_allocation_persistence=>document_id_is_valid(
          ls_item-document_id ) = abap_false
          OR NOT line_exists( it_document_ids[
            table_line = ls_item-document_id ] )
          OR ( ls_item-deletion_flag <> abap_false
            AND ls_item-deletion_flag <> abap_true ).
        rs_result-message = 'Reservation status evidence is invalid'.
        RETURN.
      ENDIF.

      READ TABLE lt_statuses ASSIGNING FIELD-SYMBOL(<ls_status>)
        WITH TABLE KEY document_id = ls_item-document_id.
      IF sy-subrc <> 0.
        INSERT VALUE #( document_id = ls_item-document_id )
          INTO TABLE lt_statuses ASSIGNING <ls_status>.
      ENDIF.
      IF ls_item-deletion_flag = abap_false.
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
