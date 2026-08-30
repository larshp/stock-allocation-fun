CLASS ltcl_allocation_persistence DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    METHODS accepts_complete_pending FOR TESTING.
    METHODS rejects_imprecise_source FOR TESTING.
    METHODS rejects_invalid_minimum FOR TESTING.
    METHODS rejects_invalid_partial_flag FOR TESTING.
    METHODS rejects_bad_replacement FOR TESTING.
    METHODS validates_document_id FOR TESTING.
    METHODS accepts_reservation_request FOR TESTING.
    METHODS rejects_bad_reservation_qty FOR TESTING.
    METHODS rejects_bad_reservation_rule FOR TESTING.

    METHODS allocation
      RETURNING
        VALUE(rs_allocation) TYPE zcl_stock_allocator=>ty_allocation.
ENDCLASS.

CLASS ltcl_allocation_persistence IMPLEMENTATION.
  METHOD accepts_complete_pending.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_persistence=>pending_allocation_is_valid(
        allocation( ) ) ).
  ENDMETHOD.

  METHOD rejects_imprecise_source.
    DATA(ls_allocation) = allocation( ).
    ls_allocation-source_requested_qty = '5.0001'.

    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>pending_allocation_is_valid(
        ls_allocation ) ).
  ENDMETHOD.

  METHOD rejects_invalid_minimum.
    DATA(ls_allocation) = allocation( ).
    ls_allocation-minimum_fill_pct = '100.001'.

    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>pending_allocation_is_valid(
        ls_allocation ) ).
  ENDMETHOD.

  METHOD rejects_invalid_partial_flag.
    DATA(ls_allocation) = allocation( ).
    ls_allocation-allow_partial = 'Y'.

    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>pending_allocation_is_valid(
        ls_allocation ) ).
  ENDMETHOD.

  METHOD rejects_bad_replacement.
    DATA(ls_allocation) = allocation( ).
    ls_allocation-replaced_document_id = 'BAD-DOC'.

    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>pending_allocation_is_valid(
        ls_allocation ) ).
  ENDMETHOD.

  METHOD validates_document_id.
    cl_abap_unit_assert=>assert_true(
      zcl_allocation_persistence=>document_id_is_valid( '0000000042' ) ).
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>document_id_is_valid( 'BAD-DOC' ) ).
    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>document_id_is_valid( '' ) ).
  ENDMETHOD.

  METHOD accepts_reservation_request.
    DATA(ls_request) = CORRESPONDING zif_reservation_gateway=>ty_request(
      allocation( ) ).
    ls_request-quantity = 5.

    cl_abap_unit_assert=>assert_true(
      zcl_allocation_persistence=>reservation_request_is_valid(
        ls_request ) ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_qty.
    DATA(ls_request) = CORRESPONDING zif_reservation_gateway=>ty_request(
      allocation( ) ).
    ls_request-quantity = '5.0001'.

    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>reservation_request_is_valid(
        ls_request ) ).
  ENDMETHOD.

  METHOD rejects_bad_reservation_rule.
    DATA(ls_request) = CORRESPONDING zif_reservation_gateway=>ty_request(
      allocation( ) ).
    ls_request-quantity = 5.
    ls_request-order_id = 'ORDER-1'.

    cl_abap_unit_assert=>assert_false(
      zcl_allocation_persistence=>reservation_request_is_valid(
        ls_request ) ).
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
