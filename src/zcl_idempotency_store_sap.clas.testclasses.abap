CLASS ltcl_idempotency_store_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_idempotency_store_sap.

    METHODS setup.
    METHODS rejects_invalid_lookup_scope FOR TESTING.
    METHODS rejects_invalid_claim_payload FOR TESTING.
    METHODS rejects_mismatched_replacement FOR TESTING.
    METHODS rejects_bad_document_update FOR TESTING.
    METHODS rejects_initial_update_request FOR TESTING.

    METHODS allocation
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_allocator=>ty_allocation.
ENDCLASS.

CLASS ltcl_idempotency_store_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD rejects_invalid_lookup_scope.
    DATA(ls_result) = mo_cut->zif_idempotency_store~find_many(
      VALUE #( ( '' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Idempotency lookup scope is invalid' ).
    cl_abap_unit_assert=>assert_initial( ls_result-records ).
  ENDMETHOD.

  METHOD rejects_invalid_claim_payload.
    DATA(lv_acquired) = mo_cut->zif_idempotency_store~claim(
      is_allocation = VALUE #( request_id = 'INCOMPLETE' ) ).

    cl_abap_unit_assert=>assert_false( lv_acquired ).
  ENDMETHOD.

  METHOD rejects_mismatched_replacement.
    DATA(ls_allocation) = allocation( ).
    ls_allocation-replaced_document_id = '0000000041'.

    DATA(lv_acquired) = mo_cut->zif_idempotency_store~claim(
      is_allocation           = ls_allocation
      iv_replaced_document_id = '0000000042' ).

    cl_abap_unit_assert=>assert_false( lv_acquired ).
  ENDMETHOD.

  METHOD rejects_bad_document_update.
    DATA(lv_updated) = mo_cut->zif_idempotency_store~set_document(
      iv_request_id  = 'REQUEST-1'
      iv_document_id = 'BAD-DOC' ).

    cl_abap_unit_assert=>assert_false( lv_updated ).
  ENDMETHOD.

  METHOD rejects_initial_update_request.
    DATA(lv_updated) = mo_cut->zif_idempotency_store~set_document(
      iv_request_id  = ''
      iv_document_id = '0000000042' ).

    cl_abap_unit_assert=>assert_false( lv_updated ).
  ENDMETHOD.

  METHOD allocation.
    rs_allocation = VALUE #(
      request_id             = 'REQUEST-1'
      material               = 'MAT-1'
      plant                  = '1000'
      storage_location       = '0001'
      movement_type          = '201'
      cost_center            = 'CC1000'
      source_requested_qty   = 5
      source_unit_of_measure = 'EA'
      minimum_fill_pct       = 80
      priority               = 1
      allow_partial          = abap_true
      unit_of_measure        = 'EA'
      requirement_date       = '20260818'
      requested_qty          = 5
      allocated_qty          = 5
      status                 = zcl_stock_allocator=>gc_status_allocated
      posting_status         = zcl_stock_allocator=>gc_posting_pending ).
  ENDMETHOD.
ENDCLASS.
