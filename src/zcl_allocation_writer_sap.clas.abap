CLASS zcl_allocation_writer_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_writer.

    METHODS constructor
      IMPORTING
        io_gateway           TYPE REF TO zif_reservation_gateway
        io_idempotency_store TYPE REF TO zif_idempotency_store
        io_stock_rechecker   TYPE REF TO zif_stock_rechecker
        io_stock_lock        TYPE REF TO zif_stock_lock.

  PRIVATE SECTION.
    DATA mo_gateway TYPE REF TO zif_reservation_gateway.
    DATA mo_idempotency_store TYPE REF TO zif_idempotency_store.
    DATA mo_stock_rechecker TYPE REF TO zif_stock_rechecker.
    DATA mo_stock_lock TYPE REF TO zif_stock_lock.

    METHODS has_error
      IMPORTING
        it_messages         TYPE zif_reservation_gateway=>ty_messages
      RETURNING
        VALUE(rv_has_error) TYPE abap_bool.

    METHODS get_error_text
      IMPORTING
        it_messages          TYPE zif_reservation_gateway=>ty_messages
        iv_fallback          TYPE string
      RETURNING
        VALUE(rv_error_text) TYPE string.

    METHODS get_warning_text
      IMPORTING
        it_messages            TYPE zif_reservation_gateway=>ty_messages
      RETURNING
        VALUE(rv_warning_text) TYPE string.

    METHODS append_message
      IMPORTING
        iv_message TYPE string
      CHANGING
        cv_text    TYPE string.

    METHODS fail_all
      IMPORTING
        iv_message     TYPE string
      CHANGING
        ct_allocations TYPE zcl_stock_allocator=>ty_allocations.

    METHODS rollback_and_release.
ENDCLASS.

CLASS zcl_allocation_writer_sap IMPLEMENTATION.
  METHOD constructor.
    mo_gateway = io_gateway.
    mo_idempotency_store = io_idempotency_store.
    mo_stock_rechecker = io_stock_rechecker.
    mo_stock_lock = io_stock_lock.
  ENDMETHOD.

  METHOD zif_allocation_writer~save_allocations.
    DATA lt_pending_allocations TYPE zcl_stock_allocator=>ty_allocations.
    LOOP AT ct_allocations INTO DATA(ls_pending_allocation)
      WHERE allocated_qty > 0
        AND posting_status = zcl_stock_allocator=>gc_posting_pending.
      APPEND ls_pending_allocation TO lt_pending_allocations.
    ENDLOOP.
    IF lt_pending_allocations IS INITIAL.
      RETURN.
    ENDIF.

    DATA(lt_claim_allocations) = lt_pending_allocations.
    SORT lt_claim_allocations BY request_id ASCENDING.
    LOOP AT lt_claim_allocations INTO DATA(ls_claim_allocation).
      DATA(lv_claim_acquired) = mo_idempotency_store->claim(
        is_allocation           = ls_claim_allocation
        iv_replaced_document_id = ls_claim_allocation-replaced_document_id ).
      IF lv_claim_acquired <> abap_true.
        DATA(lv_claim_message) = COND string(
          WHEN lv_claim_acquired = abap_false
          THEN 'Request ID is already claimed or could not be persisted'
          ELSE 'Idempotency claim returned invalid state' ).
        rollback_and_release( ).
        fail_all(
          EXPORTING
            iv_message     = lv_claim_message
          CHANGING
            ct_allocations = ct_allocations ).
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA(ls_lock) = mo_stock_lock->acquire( lt_pending_allocations ).
    IF ls_lock-acquired <> abap_true.
      DATA(lv_lock_message) = COND string(
        WHEN ls_lock-acquired = abap_false
        THEN ls_lock-message
        ELSE 'Stock lock returned invalid state' ).
      rollback_and_release( ).
      fail_all(
        EXPORTING
          iv_message     = lv_lock_message
        CHANGING
          ct_allocations = ct_allocations ).
      RETURN.
    ENDIF.

    DATA(ls_recheck) = mo_stock_rechecker->recheck( lt_pending_allocations ).
    IF ls_recheck-is_valid <> abap_true.
      DATA(lv_recheck_message) = COND string(
        WHEN ls_recheck-is_valid = abap_false
        THEN ls_recheck-message
        ELSE 'Stock recheck returned invalid state' ).
      rollback_and_release( ).
      fail_all(
        EXPORTING
          iv_message     = lv_recheck_message
        CHANGING
          ct_allocations = ct_allocations ).
      RETURN.
    ENDIF.

    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      WHERE allocated_qty > 0
        AND posting_status = zcl_stock_allocator=>gc_posting_pending.
      DATA(ls_request) = VALUE zif_reservation_gateway=>ty_request(
        request_id       = <ls_allocation>-request_id
        material         = <ls_allocation>-material
        plant            = <ls_allocation>-plant
        storage_location = <ls_allocation>-storage_location
        movement_type    = <ls_allocation>-movement_type
        cost_center      = <ls_allocation>-cost_center
        order_id         = <ls_allocation>-order_id
        wbs_element      = <ls_allocation>-wbs_element
        sales_order      = <ls_allocation>-sales_order
        sales_order_item = <ls_allocation>-sales_order_item
        asset_number     = <ls_allocation>-asset_number
        asset_subnumber  = <ls_allocation>-asset_subnumber
        network_id       = <ls_allocation>-network_id
        network_activity = <ls_allocation>-network_activity
        unit_of_measure  = <ls_allocation>-unit_of_measure
        requirement_date = <ls_allocation>-requirement_date
        quantity         = <ls_allocation>-allocated_qty ).

      mo_gateway->create_reservation(
        EXPORTING
          is_request     = ls_request
        IMPORTING
          ev_document_id = <ls_allocation>-document_id
          et_messages    = DATA(lt_messages) ).

      IF has_error( lt_messages ) = abap_true
          OR <ls_allocation>-document_id IS INITIAL.
        DATA(lv_error_text) = get_error_text(
          it_messages = lt_messages
          iv_fallback = 'Reservation API returned no document ID' ).
        rollback_and_release( ).
        fail_all(
          EXPORTING
            iv_message     = lv_error_text
          CHANGING
            ct_allocations = ct_allocations ).
        RETURN.
      ENDIF.

      DATA(lv_document_updated) = mo_idempotency_store->set_document(
        iv_request_id  = <ls_allocation>-request_id
        iv_document_id = <ls_allocation>-document_id ).
      IF lv_document_updated <> abap_true.
        DATA(lv_update_message) = COND string(
          WHEN lv_document_updated = abap_false
          THEN 'Reservation document could not be persisted'
          ELSE 'Idempotency document update returned invalid state' ).
        rollback_and_release( ).
        fail_all(
          EXPORTING
            iv_message     = lv_update_message
          CHANGING
            ct_allocations = ct_allocations ).
        RETURN.
      ENDIF.

      <ls_allocation>-posting_message = get_warning_text( lt_messages ).
    ENDLOOP.

    DATA(lt_commit_messages) = mo_gateway->commit( ).
    IF has_error( lt_commit_messages ) = abap_true.
      DATA(lv_commit_error) = get_error_text(
        it_messages = lt_commit_messages
        iv_fallback = 'Reservation commit failed' ).
      rollback_and_release( ).
      fail_all(
        EXPORTING
          iv_message     = lv_commit_error
        CHANGING
          ct_allocations = ct_allocations ).
      RETURN.
    ENDIF.
    DATA(lv_commit_warning) = get_warning_text( lt_commit_messages ).

    mo_stock_lock->release( ).

    LOOP AT ct_allocations ASSIGNING <ls_allocation>
      WHERE allocated_qty > 0
        AND posting_status = zcl_stock_allocator=>gc_posting_pending.
      <ls_allocation>-posting_status =
        zcl_stock_allocator=>gc_posting_posted.
      DATA(lv_create_warning) = <ls_allocation>-posting_message.
      CLEAR <ls_allocation>-posting_message.
      IF <ls_allocation>-replaced_document_id IS NOT INITIAL.
        append_message(
          EXPORTING
            iv_message =
              |Cancelled reservation { <ls_allocation>-replaced_document_id } replaced|
          CHANGING
            cv_text    = <ls_allocation>-posting_message ).
      ENDIF.
      append_message(
        EXPORTING
          iv_message = lv_create_warning
        CHANGING
          cv_text    = <ls_allocation>-posting_message ).
      append_message(
        EXPORTING
          iv_message = lv_commit_warning
        CHANGING
          cv_text    = <ls_allocation>-posting_message ).
    ENDLOOP.
  ENDMETHOD.

  METHOD has_error.
    rv_has_error = abap_false.
    LOOP AT it_messages TRANSPORTING NO FIELDS
      WHERE type = 'E'
         OR type = 'A'
         OR type = 'X'.
      rv_has_error = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_error_text.
    LOOP AT it_messages INTO DATA(ls_message)
      WHERE type = 'E'
         OR type = 'A'
         OR type = 'X'.
      rv_error_text = ls_message-message.
      RETURN.
    ENDLOOP.
    rv_error_text = iv_fallback.
  ENDMETHOD.

  METHOD get_warning_text.
    LOOP AT it_messages INTO DATA(ls_message)
      WHERE type = 'W'.
      rv_warning_text = ls_message-message.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

  METHOD append_message.
    IF iv_message IS INITIAL.
      RETURN.
    ENDIF.
    IF cv_text IS INITIAL.
      cv_text = iv_message.
    ELSE.
      cv_text = |{ cv_text }; { iv_message }|.
    ENDIF.
  ENDMETHOD.

  METHOD fail_all.
    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      WHERE allocated_qty > 0
        AND posting_status = zcl_stock_allocator=>gc_posting_pending.
      <ls_allocation>-posting_status =
        zcl_stock_allocator=>gc_posting_failed.
      <ls_allocation>-posting_message = iv_message.
      CLEAR <ls_allocation>-document_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD rollback_and_release.
    mo_gateway->rollback( ).
    mo_stock_lock->release( ).
  ENDMETHOD.
ENDCLASS.
