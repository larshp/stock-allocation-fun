INTERFACE zif_idempotency_store PUBLIC.
  TYPES:
    BEGIN OF ty_record,
      is_found             TYPE abap_bool,
      payload_version      TYPE zcl_stock_allocator=>ty_payload_version,
      request_id           TYPE zcl_stock_allocator=>ty_request_id,
      material             TYPE zcl_stock_allocator=>ty_material,
      plant                TYPE zcl_stock_allocator=>ty_plant,
      storage_location     TYPE zcl_stock_allocator=>ty_storage_location,
      movement_type        TYPE zcl_stock_allocator=>ty_movement_type,
      cost_center          TYPE zcl_stock_allocator=>ty_cost_center,
      order_id             TYPE zcl_stock_allocator=>ty_order_id,
      wbs_element          TYPE zcl_stock_allocator=>ty_wbs_element,
      sales_order          TYPE zcl_stock_allocator=>ty_sales_order,
      sales_order_item     TYPE zcl_stock_allocator=>ty_sales_order_item,
      asset_number         TYPE zcl_stock_allocator=>ty_asset_number,
      asset_subnumber      TYPE zcl_stock_allocator=>ty_asset_subnumber,
      network_id           TYPE zcl_stock_allocator=>ty_network_id,
      network_activity     TYPE zcl_stock_allocator=>ty_network_activity,
      requirement_date     TYPE d,
      source_requested_qty TYPE zcl_stock_allocator=>ty_quantity,
      source_unit          TYPE zcl_stock_allocator=>ty_unit,
      minimum_fill_pct     TYPE zcl_stock_allocator=>ty_quantity,
      priority             TYPE i,
      allow_partial        TYPE abap_bool,
      requested_qty        TYPE zcl_stock_allocator=>ty_quantity,
      allocated_qty        TYPE zcl_stock_allocator=>ty_quantity,
      unit_of_measure      TYPE zcl_stock_allocator=>ty_unit,
      document_id          TYPE zcl_stock_allocator=>ty_document_id,
    END OF ty_record.

  METHODS find
    IMPORTING
      iv_request_id    TYPE zcl_stock_allocator=>ty_request_id
    RETURNING
      VALUE(rs_record) TYPE ty_record.

  METHODS claim
    IMPORTING
      is_allocation      TYPE zcl_stock_allocator=>ty_allocation
    RETURNING
      VALUE(rv_acquired) TYPE abap_bool.

  METHODS set_document
    IMPORTING
      iv_request_id     TYPE zcl_stock_allocator=>ty_request_id
      iv_document_id    TYPE zcl_stock_allocator=>ty_document_id
    RETURNING
      VALUE(rv_updated) TYPE abap_bool.
ENDINTERFACE.
