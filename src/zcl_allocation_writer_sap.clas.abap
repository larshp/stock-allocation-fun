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
    DATA(lv_has_work) = abap_false.
    LOOP AT ct_allocations TRANSPORTING NO FIELDS
      WHERE allocated_qty > 0.
      lv_has_work = abap_true.
      EXIT.
    ENDLOOP.
    IF lv_has_work = abap_false.
      RETURN.
    ENDIF.

    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      WHERE allocated_qty > 0.
      IF mo_idempotency_store->claim( <ls_allocation>-request_id ) = abap_false.
        rollback_and_release( ).
        fail_all(
          EXPORTING
            iv_message     = 'Request ID is already claimed or could not be persisted'
          CHANGING
            ct_allocations = ct_allocations ).
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA(ls_lock) = mo_stock_lock->acquire( ct_allocations ).
    IF ls_lock-acquired = abap_false.
      rollback_and_release( ).
      fail_all(
        EXPORTING
          iv_message     = ls_lock-message
        CHANGING
          ct_allocations = ct_allocations ).
      RETURN.
    ENDIF.

    DATA(ls_recheck) = mo_stock_rechecker->recheck( ct_allocations ).
    IF ls_recheck-is_valid = abap_false.
      rollback_and_release( ).
      fail_all(
        EXPORTING
          iv_message     = ls_recheck-message
        CHANGING
          ct_allocations = ct_allocations ).
      RETURN.
    ENDIF.

    LOOP AT ct_allocations ASSIGNING <ls_allocation>
      WHERE allocated_qty > 0.
      DATA(ls_request) = VALUE zif_reservation_gateway=>ty_request(
        request_id       = <ls_allocation>-request_id
        material         = <ls_allocation>-material
        plant            = <ls_allocation>-plant
        storage_location = <ls_allocation>-storage_location
        movement_type    = <ls_allocation>-movement_type
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

      IF mo_idempotency_store->set_document(
          iv_request_id  = <ls_allocation>-request_id
          iv_document_id = <ls_allocation>-document_id ) = abap_false.
        rollback_and_release( ).
        fail_all(
          EXPORTING
            iv_message     = 'Reservation document could not be persisted'
          CHANGING
            ct_allocations = ct_allocations ).
        RETURN.
      ENDIF.
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

    mo_stock_lock->release( ).

    LOOP AT ct_allocations ASSIGNING <ls_allocation>
      WHERE allocated_qty > 0.
      <ls_allocation>-posting_status =
        zcl_stock_allocator=>gc_posting_posted.
      CLEAR <ls_allocation>-posting_message.
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

  METHOD fail_all.
    LOOP AT ct_allocations ASSIGNING FIELD-SYMBOL(<ls_allocation>)
      WHERE allocated_qty > 0.
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
