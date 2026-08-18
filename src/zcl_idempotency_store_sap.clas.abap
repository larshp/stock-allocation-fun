CLASS zcl_idempotency_store_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_idempotency_store.
ENDCLASS.

CLASS zcl_idempotency_store_sap IMPLEMENTATION.
  METHOD zif_idempotency_store~claim.
    DATA(ls_claim) = VALUE zstock_alloc(
      request_id = iv_request_id
      created_on = sy-datum
      created_at = sy-uzeit
      created_by = sy-uname ).

    INSERT zstock_alloc FROM @ls_claim.
    rv_acquired = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD zif_idempotency_store~set_document.
    UPDATE zstock_alloc
      SET reservation_id = @iv_document_id
      WHERE request_id = @iv_request_id.
    rv_updated = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.
ENDCLASS.
