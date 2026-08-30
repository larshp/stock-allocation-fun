CLASS zcl_allocation_persistence DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS pending_allocation_is_valid
      IMPORTING
        is_allocation   TYPE zcl_stock_allocator=>ty_allocation
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS document_id_is_valid
      IMPORTING
        iv_document_id  TYPE zcl_stock_allocator=>ty_document_id
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS reservation_request_is_valid
      IMPORTING
        is_request      TYPE zif_reservation_gateway=>ty_request
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    CLASS-METHODS quantity_is_persistable
      IMPORTING
        iv_quantity           TYPE zcl_stock_allocator=>ty_quantity
      RETURNING
        VALUE(rv_persistable) TYPE abap_bool.

  PRIVATE SECTION.
    TYPES ty_persisted_quantity TYPE p LENGTH 7 DECIMALS 3.
ENDCLASS.

CLASS zcl_allocation_persistence IMPLEMENTATION.
  METHOD pending_allocation_is_valid.
    DATA(ls_request) = CORRESPONDING zcl_stock_allocator=>ty_request(
      is_allocation ).
    DATA(lv_account_error) =
      zcl_stock_allocator=>get_account_error( ls_request ).

    rv_valid = xsdbool(
      is_allocation-request_id IS NOT INITIAL
      AND is_allocation-material IS NOT INITIAL
      AND is_allocation-plant IS NOT INITIAL
      AND is_allocation-storage_location IS NOT INITIAL
      AND is_allocation-movement_type IS NOT INITIAL
      AND is_allocation-source_unit_of_measure IS NOT INITIAL
      AND is_allocation-unit_of_measure IS NOT INITIAL
      AND is_allocation-requirement_date IS NOT INITIAL
      AND lv_account_error IS INITIAL
      AND is_allocation-source_requested_qty > 0
      AND quantity_is_persistable(
        is_allocation-source_requested_qty ) = abap_true
      AND is_allocation-minimum_fill_pct >= 0
      AND is_allocation-minimum_fill_pct <= 100
      AND quantity_is_persistable(
        is_allocation-minimum_fill_pct ) = abap_true
      AND is_allocation-priority > 0
      AND ( is_allocation-allow_partial = abap_false
        OR is_allocation-allow_partial = abap_true )
      AND is_allocation-requested_qty > 0
      AND quantity_is_persistable(
        is_allocation-requested_qty ) = abap_true
      AND is_allocation-allocated_qty > 0
      AND is_allocation-allocated_qty <= is_allocation-requested_qty
      AND quantity_is_persistable(
        is_allocation-allocated_qty ) = abap_true
      AND is_allocation-posting_status
        = zcl_stock_allocator=>gc_posting_pending
      AND is_allocation-document_id IS INITIAL
      AND ( is_allocation-replaced_document_id IS INITIAL
        OR document_id_is_valid(
          is_allocation-replaced_document_id ) = abap_true )
      AND ( ( is_allocation-allocated_qty = is_allocation-requested_qty
          AND is_allocation-status = zcl_stock_allocator=>gc_status_allocated )
        OR ( is_allocation-allocated_qty < is_allocation-requested_qty
          AND is_allocation-status = zcl_stock_allocator=>gc_status_partial ) ) ).
  ENDMETHOD.

  METHOD document_id_is_valid.
    rv_valid = xsdbool(
      iv_document_id IS NOT INITIAL
      AND iv_document_id CO '0123456789' ).
  ENDMETHOD.

  METHOD reservation_request_is_valid.
    DATA(ls_request) = CORRESPONDING zcl_stock_allocator=>ty_request(
      is_request ).
    DATA(lv_account_error) =
      zcl_stock_allocator=>get_account_error( ls_request ).

    rv_valid = xsdbool(
      is_request-request_id IS NOT INITIAL
      AND is_request-material IS NOT INITIAL
      AND is_request-plant IS NOT INITIAL
      AND is_request-storage_location IS NOT INITIAL
      AND is_request-movement_type IS NOT INITIAL
      AND is_request-unit_of_measure IS NOT INITIAL
      AND is_request-requirement_date IS NOT INITIAL
      AND lv_account_error IS INITIAL
      AND is_request-quantity > 0
      AND quantity_is_persistable( is_request-quantity ) = abap_true ).
  ENDMETHOD.

  METHOD quantity_is_persistable.
    IF iv_quantity > zcl_stock_allocator=>gc_max_quantity
        OR iv_quantity < - zcl_stock_allocator=>gc_max_quantity.
      RETURN.
    ENDIF.

    DATA lv_persisted TYPE ty_persisted_quantity.
    lv_persisted = iv_quantity.
    rv_persistable = xsdbool( lv_persisted = iv_quantity ).
  ENDMETHOD.
ENDCLASS.
