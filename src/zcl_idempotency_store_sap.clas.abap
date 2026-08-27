CLASS zcl_idempotency_store_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_idempotency_store.
ENDCLASS.

CLASS zcl_idempotency_store_sap IMPLEMENTATION.
  METHOD zif_idempotency_store~find.
    DATA(lt_request_ids) = VALUE zif_idempotency_store=>ty_request_ids(
      ( iv_request_id ) ).
    DATA(ls_result) = zif_idempotency_store~find_many( lt_request_ids ).
    IF ls_result-is_success = abap_true.
      READ TABLE ls_result-records INTO rs_record
        WITH TABLE KEY request_id = iv_request_id.
    ENDIF.
  ENDMETHOD.

  METHOD zif_idempotency_store~find_many.
    IF it_request_ids IS INITIAL.
      rs_result-is_success = abap_true.
      rs_result-message = 'Idempotency lookup completed'.
      RETURN.
    ENDIF.

    SELECT payload_version,
           request_id,
           material,
           plant,
           storage_location,
           movement_type,
           cost_center,
           order_id,
           wbs_element,
           sales_order,
           sales_order_item,
           asset_number,
           asset_subnumber,
           network_id,
           network_activity,
           requirement_date,
           source_requested_qty,
           source_unit,
           minimum_fill_pct,
           priority,
           allow_partial,
           requested_qty,
           allocated_qty,
           unit_of_measure,
           reservation_id AS document_id
      FROM zstock_alloc
      FOR ALL ENTRIES IN @it_request_ids
      WHERE request_id = @it_request_ids-table_line
      INTO CORRESPONDING FIELDS OF TABLE @rs_result-records.
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      rs_result-message = 'Idempotency lookup failed'.
      RETURN.
    ENDIF.

    LOOP AT rs_result-records ASSIGNING FIELD-SYMBOL(<ls_record>).
      <ls_record>-is_found = abap_true.
    ENDLOOP.
    rs_result-is_success = abap_true.
    rs_result-message = 'Idempotency lookup completed'.
  ENDMETHOD.

  METHOD zif_idempotency_store~claim.
    IF iv_replaced_document_id IS NOT INITIAL.
      DELETE FROM zstock_alloc
        WHERE request_id = @is_allocation-request_id
          AND reservation_id = @iv_replaced_document_id.
      IF sy-subrc <> 0.
        rv_acquired = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(ls_claim) = VALUE zstock_alloc(
      payload_version      = zcl_stock_allocator=>gc_payload_version
      request_id           = is_allocation-request_id
      material             = is_allocation-material
      plant                = is_allocation-plant
      storage_location     = is_allocation-storage_location
      movement_type        = is_allocation-movement_type
      cost_center          = is_allocation-cost_center
      order_id             = is_allocation-order_id
      wbs_element          = is_allocation-wbs_element
      sales_order          = is_allocation-sales_order
      sales_order_item     = is_allocation-sales_order_item
      asset_number         = is_allocation-asset_number
      asset_subnumber      = is_allocation-asset_subnumber
      network_id           = is_allocation-network_id
      network_activity     = is_allocation-network_activity
      requirement_date     = is_allocation-requirement_date
      source_requested_qty = is_allocation-source_requested_qty
      source_unit          = is_allocation-source_unit_of_measure
      minimum_fill_pct     = is_allocation-minimum_fill_pct
      priority             = is_allocation-priority
      allow_partial        = is_allocation-allow_partial
      requested_qty        = is_allocation-requested_qty
      allocated_qty        = is_allocation-allocated_qty
      unit_of_measure      = is_allocation-unit_of_measure
      created_on           = sy-datum
      created_at           = sy-uzeit
      created_by           = sy-uname ).

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
