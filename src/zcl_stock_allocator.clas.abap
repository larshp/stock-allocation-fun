CLASS zcl_stock_allocator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_request_id       TYPE c LENGTH 32.
    TYPES ty_material         TYPE c LENGTH 40.
    TYPES ty_plant            TYPE c LENGTH 4.
    TYPES ty_storage_location TYPE c LENGTH 4.
    TYPES ty_movement_type    TYPE c LENGTH 3.
    TYPES ty_quantity         TYPE decfloat34.
    TYPES ty_status           TYPE c LENGTH 12.
    TYPES ty_posting_status   TYPE c LENGTH 12.
    TYPES ty_document_id      TYPE c LENGTH 10.
    TYPES ty_strategy         TYPE c LENGTH 20.

    CONSTANTS gc_status_allocated TYPE ty_status VALUE 'ALLOCATED'.
    CONSTANTS gc_status_partial   TYPE ty_status VALUE 'PARTIAL'.
    CONSTANTS gc_status_rejected  TYPE ty_status VALUE 'REJECTED'.
    CONSTANTS gc_status_invalid   TYPE ty_status VALUE 'INVALID'.
    CONSTANTS gc_status_config_error TYPE ty_status VALUE 'CONFIG_ERROR'.
    CONSTANTS gc_posting_pending  TYPE ty_posting_status VALUE 'PENDING'.
    CONSTANTS gc_posting_posted   TYPE ty_posting_status VALUE 'POSTED'.
    CONSTANTS gc_posting_failed   TYPE ty_posting_status VALUE 'FAILED'.
    CONSTANTS gc_posting_simulated TYPE ty_posting_status VALUE 'SIMULATED'.
    CONSTANTS gc_posting_not_required TYPE ty_posting_status VALUE 'NOT_REQUIRED'.
    CONSTANTS gc_strategy_priority_due TYPE ty_strategy VALUE 'PRIORITY_DUE'.
    CONSTANTS gc_strategy_due_priority TYPE ty_strategy VALUE 'DUE_PRIORITY'.
    CONSTANTS gc_strategy_priority_id  TYPE ty_strategy VALUE 'PRIORITY_ID'.

    TYPES:
      BEGIN OF ty_request,
        request_id       TYPE ty_request_id,
        material         TYPE ty_material,
        plant            TYPE ty_plant,
        storage_location TYPE ty_storage_location,
        movement_type    TYPE ty_movement_type,
        requirement_date TYPE d,
        requested_qty    TYPE ty_quantity,
        minimum_fill_pct TYPE ty_quantity,
        priority         TYPE i,
        allow_partial    TYPE abap_bool,
      END OF ty_request.
    TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_stock_balance,
        material         TYPE ty_material,
        plant            TYPE ty_plant,
        storage_location TYPE ty_storage_location,
        unrestricted_qty TYPE ty_quantity,
        safety_stock_qty TYPE ty_quantity,
      END OF ty_stock_balance.
    TYPES ty_stock_balances TYPE SORTED TABLE OF ty_stock_balance
      WITH UNIQUE KEY material plant storage_location.

    TYPES:
      BEGIN OF ty_allocation,
        request_id       TYPE ty_request_id,
        material         TYPE ty_material,
        plant            TYPE ty_plant,
        storage_location TYPE ty_storage_location,
        movement_type    TYPE ty_movement_type,
        requirement_date TYPE d,
        requested_qty    TYPE ty_quantity,
        allocated_qty    TYPE ty_quantity,
        shortfall_qty    TYPE ty_quantity,
        status           TYPE ty_status,
        posting_status   TYPE ty_posting_status,
        document_id      TYPE ty_document_id,
        posting_message  TYPE string,
      END OF ty_allocation.
    TYPES ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

    METHODS allocate
      IMPORTING
        it_requests           TYPE ty_requests
        it_stock_balances     TYPE ty_stock_balances
        iv_strategy           TYPE ty_strategy DEFAULT gc_strategy_priority_due
      RETURNING
        VALUE(rt_allocations) TYPE ty_allocations.

  PRIVATE SECTION.
    TYPES ty_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    METHODS calculate_available
      IMPORTING
        is_stock            TYPE ty_stock_balance
      RETURNING
        VALUE(rv_available) TYPE ty_quantity.

    METHODS create_allocation
      IMPORTING
        is_request           TYPE ty_request
        iv_available         TYPE ty_quantity
      RETURNING
        VALUE(rs_allocation) TYPE ty_allocation.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    DATA lt_requests TYPE ty_requests.
    DATA lt_stock_balances TYPE ty_stock_balances.
    DATA lt_seen_request_ids TYPE ty_seen_request_ids.

    lt_requests = it_requests.
    lt_stock_balances = it_stock_balances.
    CASE iv_strategy.
      WHEN gc_strategy_priority_due.
        SORT lt_requests BY priority ASCENDING
                            requirement_date ASCENDING
                            request_id ASCENDING.
      WHEN gc_strategy_due_priority.
        SORT lt_requests BY requirement_date ASCENDING
                            priority ASCENDING
                            request_id ASCENDING.
      WHEN gc_strategy_priority_id.
        SORT lt_requests BY priority ASCENDING
                            request_id ASCENDING.
      WHEN OTHERS.
        LOOP AT lt_requests INTO DATA(ls_invalid_strategy_request).
          APPEND VALUE #(
            request_id       = ls_invalid_strategy_request-request_id
            material         = ls_invalid_strategy_request-material
            plant            = ls_invalid_strategy_request-plant
            storage_location = ls_invalid_strategy_request-storage_location
            movement_type    = ls_invalid_strategy_request-movement_type
            requirement_date = ls_invalid_strategy_request-requirement_date
            requested_qty    = ls_invalid_strategy_request-requested_qty
            shortfall_qty    = ls_invalid_strategy_request-requested_qty
            status           = gc_status_config_error
            posting_status   = gc_posting_not_required
            posting_message  = 'Unsupported allocation strategy' )
            TO rt_allocations.
        ENDLOOP.
        RETURN.
    ENDCASE.

    LOOP AT lt_requests INTO DATA(ls_request).
      IF ls_request-requested_qty <= 0
          OR ls_request-minimum_fill_pct < 0
          OR ls_request-minimum_fill_pct > 100
          OR ls_request-request_id IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-storage_location IS INITIAL
          OR ls_request-movement_type IS INITIAL
          OR ls_request-requirement_date IS INITIAL
          OR line_exists( lt_seen_request_ids[ table_line = ls_request-request_id ] ).
        APPEND VALUE #(
          request_id       = ls_request-request_id
          material         = ls_request-material
          plant            = ls_request-plant
          storage_location = ls_request-storage_location
          movement_type    = ls_request-movement_type
          requirement_date = ls_request-requirement_date
          requested_qty    = ls_request-requested_qty
          shortfall_qty    = ls_request-requested_qty
          status           = gc_status_invalid
          posting_status   = gc_posting_not_required ) TO rt_allocations.
        CONTINUE.
      ENDIF.

      INSERT ls_request-request_id INTO TABLE lt_seen_request_ids.

      READ TABLE lt_stock_balances ASSIGNING FIELD-SYMBOL(<ls_stock>)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant
                       storage_location = ls_request-storage_location.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          request_id       = ls_request-request_id
          material         = ls_request-material
          plant            = ls_request-plant
          storage_location = ls_request-storage_location
          movement_type    = ls_request-movement_type
          requirement_date = ls_request-requirement_date
          requested_qty    = ls_request-requested_qty
          shortfall_qty    = ls_request-requested_qty
          status           = gc_status_rejected
          posting_status   = gc_posting_not_required ) TO rt_allocations.
        CONTINUE.
      ENDIF.

      DATA(lv_available) = calculate_available( <ls_stock> ).
      DATA(ls_allocation) = create_allocation(
        is_request   = ls_request
        iv_available = lv_available ).
      APPEND ls_allocation TO rt_allocations.
      <ls_stock>-unrestricted_qty =
        <ls_stock>-unrestricted_qty - ls_allocation-allocated_qty.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculate_available.
    rv_available = is_stock-unrestricted_qty - is_stock-safety_stock_qty.
    IF rv_available < 0.
      rv_available = 0.
    ENDIF.
  ENDMETHOD.

  METHOD create_allocation.
    rs_allocation-request_id = is_request-request_id.
    rs_allocation-material = is_request-material.
    rs_allocation-plant = is_request-plant.
    rs_allocation-storage_location = is_request-storage_location.
    rs_allocation-movement_type = is_request-movement_type.
    rs_allocation-requirement_date = is_request-requirement_date.
    rs_allocation-requested_qty = is_request-requested_qty.
    DATA(lv_available_pct) =
      iv_available * 100 / is_request-requested_qty.

    IF iv_available >= is_request-requested_qty.
      rs_allocation-allocated_qty = is_request-requested_qty.
      rs_allocation-status = gc_status_allocated.
      rs_allocation-posting_status = gc_posting_pending.
    ELSEIF is_request-allow_partial = abap_true
        AND iv_available > 0
        AND lv_available_pct >= is_request-minimum_fill_pct.
      rs_allocation-allocated_qty = iv_available.
      rs_allocation-status = gc_status_partial.
      rs_allocation-posting_status = gc_posting_pending.
    ELSE.
      rs_allocation-status = gc_status_rejected.
      rs_allocation-posting_status = gc_posting_not_required.
    ENDIF.

    rs_allocation-shortfall_qty =
      is_request-requested_qty - rs_allocation-allocated_qty.
  ENDMETHOD.
ENDCLASS.
