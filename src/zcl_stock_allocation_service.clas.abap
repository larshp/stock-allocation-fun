CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_source    TYPE REF TO zif_stock_source
        io_order_source    TYPE REF TO zif_order_source
        io_sink            TYPE REF TO zif_allocation_sink OPTIONAL
        io_allocator       TYPE REF TO zif_stock_allocation
        io_reservation     TYPE REF TO zif_stock_reservation OPTIONAL
        io_unit_converter  TYPE REF TO zif_unit_conversion OPTIONAL
        io_lock            TYPE REF TO zif_stock_allocation_lock OPTIONAL
        io_authority       TYPE REF TO zif_stock_allocation_authority OPTIONAL
        io_write_authority TYPE REF TO zif_allocation_write_authority OPTIONAL
        io_transaction     TYPE REF TO zif_allocation_transaction OPTIONAL
        io_audit           TYPE REF TO zif_allocation_audit.
    METHODS allocate
      IMPORTING
        iv_material          TYPE zif_stock_allocation=>ty_material
        iv_plant             TYPE zif_stock_allocation=>ty_plant
        iv_storage_location  TYPE zif_stock_allocation=>ty_storage_location
        iv_movement_type     TYPE zif_stock_allocation=>ty_movement_type
        iv_unit              TYPE zif_stock_allocation=>ty_unit
        iv_batch             TYPE zif_stock_allocation=>ty_batch OPTIONAL
        iv_requested_on_from TYPE d OPTIONAL
        iv_requested_on_to   TYPE d OPTIONAL
        iv_preview           TYPE abap_bool OPTIONAL
        iv_min_shelf_life    TYPE i OPTIONAL
        iv_safety_stock      TYPE zif_stock_allocation=>ty_quantity OPTIONAL
        iv_strategy          TYPE zif_allocation_audit=>ty_strategy OPTIONAL
      EXPORTING
        ev_run_id            TYPE zif_allocation_audit=>ty_run_id
      RETURNING
        VALUE(rv_remaining)  TYPE zif_stock_allocation=>ty_quantity
      RAISING
        zcx_stock_allocation.
  PRIVATE SECTION.
    DATA mo_stock_source TYPE REF TO zif_stock_source.
    DATA mo_order_source TYPE REF TO zif_order_source.
    DATA mo_sink TYPE REF TO zif_allocation_sink.
    DATA mo_allocator TYPE REF TO zif_stock_allocation.
    DATA mo_reservation TYPE REF TO zif_stock_reservation.
    DATA mo_unit_converter TYPE REF TO zif_unit_conversion.
    DATA mo_lock TYPE REF TO zif_stock_allocation_lock.
    DATA mo_authority TYPE REF TO zif_stock_allocation_authority.
    DATA mo_write_authority TYPE REF TO zif_allocation_write_authority.
    DATA mo_transaction TYPE REF TO zif_allocation_transaction.
    DATA mo_audit TYPE REF TO zif_allocation_audit.
    DATA mv_requested_on_from TYPE d.
    DATA mv_requested_on_to TYPE d.
    DATA mv_movement_type TYPE zif_stock_allocation=>ty_movement_type.
    DATA mv_min_shelf_life TYPE i.
    DATA mv_safety_stock TYPE zif_stock_allocation=>ty_quantity.
    METHODS finish_audit
      IMPORTING
        iv_run_id            TYPE zif_allocation_audit=>ty_run_id
        iv_status            TYPE zif_allocation_audit=>ty_run_status
        iv_available         TYPE zif_stock_allocation=>ty_quantity
        iv_allocated         TYPE zif_stock_allocation=>ty_quantity
        iv_shortage          TYPE zif_stock_allocation=>ty_quantity
        iv_full_count        TYPE i
        iv_partial_count     TYPE i
        iv_unallocated_count TYPE i
        iv_message           TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
    METHODS record_rejection
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
        iv_batch            TYPE zif_stock_allocation=>ty_batch
        iv_unit             TYPE zif_stock_allocation=>ty_unit
        iv_available        TYPE zif_stock_allocation=>ty_quantity
        iv_message          TYPE zif_allocation_audit=>ty_message.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_source = io_stock_source.
    mo_order_source = io_order_source.
    IF io_sink IS BOUND.
      mo_sink = io_sink.
    ELSE.
      CREATE OBJECT mo_sink TYPE zcl_allocation_sink_sap.
    ENDIF.
    mo_allocator = io_allocator.
    IF io_reservation IS BOUND.
      mo_reservation = io_reservation.
    ELSE.
      CREATE OBJECT mo_reservation TYPE zcl_stock_reservation_sap.
    ENDIF.
    IF io_unit_converter IS BOUND.
      mo_unit_converter = io_unit_converter.
    ELSE.
      CREATE OBJECT mo_unit_converter TYPE zcl_unit_conversion_sap.
    ENDIF.
    IF io_lock IS BOUND.
      mo_lock = io_lock.
    ELSE.
      CREATE OBJECT mo_lock TYPE zcl_stock_allocation_lock_sap.
    ENDIF.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_stock_alloc_auth_sap.
    ENDIF.
    IF io_write_authority IS BOUND.
      mo_write_authority = io_write_authority.
    ELSE.
      CREATE OBJECT mo_write_authority TYPE zcl_allocation_write_auth_sap.
    ENDIF.
    IF io_transaction IS BOUND.
      mo_transaction = io_transaction.
    ELSE.
      CREATE OBJECT mo_transaction TYPE zcl_allocation_transaction_sap.
    ENDIF.
    mo_audit = io_audit.
  ENDMETHOD.

  METHOD allocate.
    DATA lv_available TYPE zif_stock_allocation=>ty_quantity.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_required_date TYPE d.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_full_count TYPE i.
    DATA lv_partial_count TYPE i.
    DATA lv_unallocated_count TYPE i.
    DATA lv_demand_count TYPE i.
    DATA lv_result_count TYPE i.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_cleanup_failed TYPE abap_bool.
    DATA lv_reservation_failed TYPE abap_bool.
    DATA lv_failure_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_cleanup_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_persistence_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_rollback_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_release_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_audit_failure_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_reserved_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_converted_quantity TYPE zif_stock_allocation=>ty_quantity.
    DATA lo_cleanup_error TYPE REF TO zcx_stock_allocation.
    DATA lo_persistence_error TYPE REF TO zcx_stock_allocation.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    DATA lv_lock_acquired TYPE abap_bool.
    DATA lv_min_shelf_life_date TYPE d.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_original_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_demand_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lt_result_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lt_existing TYPE zif_stock_allocation=>tt_demands.
    DATA lt_reservations TYPE STANDARD TABLE OF zif_stock_allocation=>ty_order_id
      WITH EMPTY KEY.
    DATA lt_reused TYPE STANDARD TABLE OF zif_stock_allocation=>ty_order_id
      WITH EMPTY KEY.
    DATA lt_existing_reservation_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lt_cancel_movement_types TYPE SORTED TABLE OF zif_stock_allocation=>ty_movement_type
      WITH UNIQUE KEY table_line.
    DATA lt_existing_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lv_existing_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_existing_run_id TYPE zif_stock_allocation=>ty_run_id.
    DATA lv_reservation_document TYPE c LENGTH 10.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_original> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_existing> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <lv_reservation> TYPE zif_stock_allocation=>ty_order_id.

    CLEAR ev_run_id.
    mv_requested_on_from = iv_requested_on_from.
    mv_requested_on_to = iv_requested_on_to.
    mv_movement_type = iv_movement_type.
    mv_min_shelf_life = iv_min_shelf_life.
    mv_safety_stock = iv_safety_stock.
    lv_strategy = to_upper( iv_strategy ).
    lv_unit = to_upper( iv_unit ).

    IF ( iv_requested_on_from IS NOT INITIAL
          AND zcl_allocation_date_sap=>is_valid_or_initial(
            iv_requested_on_from ) <> abap_true )
        OR ( iv_requested_on_to IS NOT INITIAL
          AND zcl_allocation_date_sap=>is_valid_or_initial(
            iv_requested_on_to ) <> abap_true )
        OR ( iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to ).
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Requested delivery date range is invalid' ).
      ENDIF.
      raise_error( iv_message = 'Requested delivery date range is invalid' ).
    ENDIF.

    IF lv_strategy IS NOT INITIAL
        AND lv_strategy <> 'P'
        AND lv_strategy <> 'F'
        AND lv_strategy <> 'N'
        AND lv_strategy <> 'S'
        AND lv_strategy <> 'L'
        AND lv_strategy <> 'B'
        AND lv_strategy <> 'E'
        AND lv_strategy <> 'A'
        AND lv_strategy <> 'W'.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Invalid allocation strategy' ).
      ENDIF.
      raise_error( iv_message = 'Invalid allocation strategy' ).
    ENDIF.

    IF iv_preview IS NOT INITIAL AND iv_preview <> abap_true.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Invalid preview flag' ).
      ENDIF.
      raise_error( iv_message = 'Invalid preview flag' ).
    ENDIF.

    IF iv_movement_type IS NOT INITIAL
        AND ( strlen( iv_movement_type ) <> zif_stock_allocation=>c_movement_type_length
          OR iv_movement_type CN '0123456789'
          OR iv_movement_type = zif_stock_allocation=>c_zero_movement_type ).
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Invalid movement type' ).
      ENDIF.
      raise_error( iv_message = 'Invalid movement type' ).
    ENDIF.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_movement_type IS INITIAL
        OR lv_unit IS INITIAL.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Invalid allocation input' ).
      ENDIF.
      raise_error( iv_message = 'Invalid allocation input' ).
    ENDIF.
    IF iv_min_shelf_life < 0.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Invalid minimum shelf life' ).
      ENDIF.
      raise_error( iv_message = 'Invalid minimum shelf life' ).
    ENDIF.
    IF iv_safety_stock < 0.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Invalid safety stock' ).
      ENDIF.
      raise_error( iv_message = 'Invalid safety stock' ).
    ENDIF.
    IF mo_stock_source IS NOT BOUND
        OR mo_order_source IS NOT BOUND
        OR mo_allocator IS NOT BOUND
        OR mo_audit IS NOT BOUND
        OR ( iv_preview <> abap_true AND mo_sink IS NOT BOUND )
        OR ( iv_preview <> abap_true AND mo_reservation IS NOT BOUND ).
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Allocation dependency missing' ).
      ENDIF.
      raise_error( iv_message = 'Allocation dependency missing' ).
    ENDIF.

    IF mo_write_authority IS BOUND AND iv_preview <> abap_true.
      TRY.
          mo_write_authority->check_result_write( ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Allocation result write authorization failed'.
          ENDIF.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = 0
            iv_message          = lo_error->message ).
          RAISE EXCEPTION lo_error.
      ENDTRY.
      TRY.
          mo_write_authority->check_result_delete( ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Allocation result delete authorization failed'.
          ENDIF.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = 0
            iv_message          = lo_error->message ).
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.

    IF mo_authority IS BOUND AND iv_preview <> abap_true.
      TRY.
          mo_authority->check(
            iv_plant         = iv_plant
            iv_movement_type = iv_movement_type ).
          mo_authority->check_cancel(
            iv_plant         = iv_plant
            iv_movement_type = iv_movement_type ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = 0
              iv_message          = 'Movement authorization failed' ).
          ELSE.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = 0
              iv_message          = lo_error->message ).
          ENDIF.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Movement authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.

    IF mo_lock IS BOUND.
      TRY.
          mo_lock->acquire(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = 0
              iv_message          = 'Allocation lock acquisition failed' ).
          ELSE.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = 0
              iv_message          = lo_error->message ).
          ENDIF.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Allocation lock acquisition failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
      lv_lock_acquired = abap_true.
    ENDIF.
    TRY.
      TRY.
          ls_available = mo_stock_source->get_available(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = 0
              iv_message          = 'Available stock read failed' ).
          ELSE.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = 0
              iv_message          = lo_error->message ).
          ENDIF.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Available stock read failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ls_available-unit = to_upper( ls_available-unit ).
    IF ( ls_available-material_found <> abap_true
          AND ls_available-material_found <> abap_false )
        OR ( ls_available-batch_managed <> abap_true
          AND ls_available-batch_managed <> abap_false )
        OR ( ls_available-batch_found <> abap_true
          AND ls_available-batch_found <> abap_false )
        OR ( ls_available-batch_restricted <> abap_true
          AND ls_available-batch_restricted <> abap_false ).
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = 0
        iv_message          = 'Available stock result is invalid' ).
      raise_error( iv_message = 'Available stock result is invalid' ).
    ENDIF.
    IF ls_available-material_found <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = 0
        iv_message          = 'Material does not exist' ).
      raise_error( iv_message = 'Material does not exist' ).
    ENDIF.
    IF ls_available-unit IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = 0
        iv_message          = 'Material base unit is missing' ).
      raise_error( iv_message = 'Material base unit is missing' ).
    ENDIF.
    IF ls_available-quantity < 0.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = 0
        iv_message          = 'Stock quantity is invalid' ).
      raise_error( iv_message = 'Stock quantity is invalid' ).
    ENDIF.
    IF zcl_allocation_date_sap=>is_valid_or_initial(
         ls_available-batch_expiration_date ) <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = 0
        iv_message          = 'Batch expiration date is invalid' ).
      raise_error( iv_message = 'Batch expiration date is invalid' ).
    ENDIF.
    IF iv_batch IS INITIAL
        AND ( ls_available-batch_found = abap_true
          OR ls_available-batch_restricted = abap_true
          OR ls_available-batch_expiration_date IS NOT INITIAL ).
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = ls_available-quantity
        iv_message          = 'Available stock result is invalid' ).
      raise_error( iv_message = 'Available stock result is invalid' ).
    ENDIF.
    lv_available = ls_available-quantity.
    IF ls_available-batch_managed = abap_true
        AND iv_batch IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Batch is required' ).
      raise_error( iv_message = 'Batch is required' ).
    ENDIF.
    IF iv_batch IS NOT INITIAL
        AND ls_available-batch_managed <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Material is not batch managed' ).
      raise_error( iv_message = 'Material is not batch managed' ).
    ENDIF.
    IF iv_batch IS NOT INITIAL
        AND ls_available-batch_found <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Batch does not exist in storage location' ).
      raise_error( iv_message = 'Batch does not exist in storage location' ).
    ENDIF.
    IF iv_batch IS NOT INITIAL
        AND ls_available-batch_expiration_date IS NOT INITIAL
        AND ls_available-batch_expiration_date < sy-datum.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Batch is expired' ).
      raise_error( iv_message = 'Batch is expired' ).
    ENDIF.
    IF iv_min_shelf_life > 0
        AND iv_batch IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Minimum shelf life requires a batch' ).
      raise_error( iv_message = 'Minimum shelf life requires a batch' ).
    ENDIF.
    IF iv_min_shelf_life > 0
        AND ls_available-batch_expiration_date IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Batch expiration date is required for shelf-life policy' ).
      raise_error( iv_message = 'Batch expiration date is required for shelf-life policy' ).
    ENDIF.
    IF iv_min_shelf_life > 0.
      lv_min_shelf_life_date = sy-datum + iv_min_shelf_life.
      IF ls_available-batch_expiration_date < lv_min_shelf_life_date.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Batch does not meet minimum shelf life' ).
        raise_error( iv_message = 'Batch does not meet minimum shelf life' ).
      ENDIF.
    ENDIF.
    IF ls_available-batch_restricted = abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Batch is restricted' ).
      raise_error( iv_message = 'Batch is restricted' ).
    ENDIF.
    IF lv_available > 0
        AND ls_available-unit <> lv_unit.
      IF mo_unit_converter IS NOT BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Stock unit conversion failed' ).
        raise_error( iv_message = 'Stock unit conversion failed' ).
      ENDIF.
      TRY.
          lv_available = mo_unit_converter->convert(
            iv_material  = iv_material
            iv_quantity  = lv_available
            iv_unit_from = ls_available-unit
            iv_unit_to   = lv_unit ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = lv_available
              iv_message          = 'Stock unit conversion failed' ).
          ELSE.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = lv_available
              iv_message          = lo_error->message ).
          ENDIF.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Stock unit conversion failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
      IF lv_available <= 0.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = 0
          iv_message          = 'Stock unit conversion produced invalid quantity' ).
        raise_error( iv_message = 'Stock unit conversion produced invalid quantity' ).
      ENDIF.
    ENDIF.
    TRY.
        lt_demands = mo_order_source->get_open_demands(
          iv_material          = iv_material
          iv_plant             = iv_plant
          iv_requested_on_from = iv_requested_on_from
          iv_requested_on_to   = iv_requested_on_to ).
      CATCH zcx_stock_allocation INTO lo_error.
        IF lo_error->message IS INITIAL.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Open demand validation failed' ).
        ELSE.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = lo_error->message ).
        ENDIF.
        IF lo_error->message IS INITIAL.
          lo_error->message = 'Open demand validation failed'.
        ENDIF.
        RAISE EXCEPTION lo_error.
    ENDTRY.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      <ls_demand>-order_unit = to_upper( <ls_demand>-order_unit ).
      <ls_demand>-sales_document_type =
        to_upper( <ls_demand>-sales_document_type ).
      IF <ls_demand>-order_id IS INITIAL
          OR ( <ls_demand>-sales_document IS NOT INITIAL
            AND strlen( <ls_demand>-sales_document )
                <> zif_stock_allocation=>c_sap_document_length )
          OR ( <ls_demand>-sales_document IS NOT INITIAL
            AND <ls_demand>-sales_document CN '0123456789' )
          OR <ls_demand>-sales_document = '0000000000'
          OR <ls_demand>-requested <= 0.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Open demand quantity or key is invalid' ).
        raise_error( iv_message = 'Open demand quantity or key is invalid' ).
    ENDIF.
    IF <ls_demand>-requested > 0
        AND <ls_demand>-order_unit IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Open demand unit is missing' ).
      raise_error( iv_message = 'Open demand unit is missing' ).
    ENDIF.
    IF <ls_demand>-requested > 0
        AND <ls_demand>-requested_on IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Open demand requested date is missing' ).
      raise_error( iv_message = 'Open demand requested date is missing' ).
    ENDIF.
    IF <ls_demand>-requested > 0
        AND zcl_allocation_date_sap=>is_valid_or_initial(
          <ls_demand>-requested_on ) <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Open demand requested date is invalid' ).
      raise_error( iv_message = 'Open demand requested date is invalid' ).
    ENDIF.
    IF <ls_demand>-requested > 0
        AND ( <ls_demand>-sales_document IS NOT INITIAL
          OR <ls_demand>-sales_document_type IS NOT INITIAL
          OR <ls_demand>-sales_item IS NOT INITIAL
          OR <ls_demand>-schedule_line IS NOT INITIAL )
        AND ( <ls_demand>-sales_document_type IS INITIAL
          OR <ls_demand>-sales_item IS INITIAL
          OR <ls_demand>-schedule_line IS INITIAL ).
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Open demand source identity is incomplete' ).
      raise_error( iv_message = 'Open demand source identity is incomplete' ).
    ENDIF.
    IF <ls_demand>-priority < 0
          OR <ls_demand>-priority > zif_stock_allocation=>c_max_priority.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Open demand priority is invalid' ).
        raise_error( iv_message = 'Open demand priority is invalid' ).
      ENDIF.
      INSERT <ls_demand>-order_id INTO TABLE lt_demand_order_ids.
      IF sy-subrc <> 0.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Open demand key is duplicated' ).
        raise_error( iv_message = 'Open demand key is duplicated' ).
      ENDIF.
    ENDLOOP.
    DESCRIBE TABLE lt_demands LINES lv_demand_count.
    IF ls_available-batch_expiration_date IS NOT INITIAL.
      LOOP AT lt_demands ASSIGNING <ls_demand>.
        IF <ls_demand>-requested_on IS NOT INITIAL
            AND <ls_demand>-requested_on
              > ls_available-batch_expiration_date.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Batch expires before delivery date' ).
          raise_error( iv_message = 'Batch expires before delivery date' ).
        ENDIF.
      ENDLOOP.
    ENDIF.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_unit IS NOT INITIAL
          AND <ls_demand>-order_unit <> lv_unit.
        IF mo_unit_converter IS NOT BOUND.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Demand unit conversion failed' ).
          raise_error( iv_message = 'Demand unit conversion failed' ).
        ENDIF.
        TRY.
            <ls_demand>-requested = mo_unit_converter->convert(
              iv_material  = iv_material
              iv_quantity  = <ls_demand>-requested
              iv_unit_from = <ls_demand>-order_unit
              iv_unit_to   = lv_unit ).
          CATCH zcx_stock_allocation INTO lo_error.
            IF lo_error->message IS INITIAL.
              record_rejection(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch
                iv_unit             = lv_unit
                iv_available        = lv_available
                iv_message          = 'Demand unit conversion failed' ).
            ELSE.
              record_rejection(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch
                iv_unit             = lv_unit
                iv_available        = lv_available
                iv_message          = lo_error->message ).
            ENDIF.
            IF lo_error->message IS INITIAL.
              lo_error->message = 'Demand unit conversion failed'.
            ENDIF.
            RAISE EXCEPTION lo_error.
          ENDTRY.
          IF <ls_demand>-requested <= 0.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = lv_available
              iv_message          = 'Demand unit conversion produced invalid quantity' ).
            raise_error( iv_message = 'Demand unit conversion produced invalid quantity' ).
          ENDIF.
        ENDIF.
    ENDLOOP.
    IF iv_preview <> abap_true.
      TRY.
          lt_existing = mo_sink->get_allocations(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = lv_available
              iv_message          = 'Allocation snapshot read failed' ).
          ELSE.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = lv_available
              iv_message          = lo_error->message ).
          ENDIF.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Allocation snapshot read failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
      LOOP AT lt_existing ASSIGNING <ls_existing>.
        <ls_existing>-allocation_unit =
          to_upper( <ls_existing>-allocation_unit ).
        <ls_existing>-allocation_strategy =
          to_upper( <ls_existing>-allocation_strategy ).
        <ls_existing>-allocation_status =
          to_upper( <ls_existing>-allocation_status ).
        <ls_existing>-sales_document_type =
          to_upper( <ls_existing>-sales_document_type ).
        <ls_existing>-order_unit = to_upper( <ls_existing>-order_unit ).
        <ls_existing>-reservation_unit =
          to_upper( <ls_existing>-reservation_unit ).
      ENDLOOP.
      SORT lt_existing BY allocation_unit order_id.
      LOOP AT lt_existing ASSIGNING <ls_existing>.
        CLEAR lv_reservation_document.
        lv_reservation_document = <ls_existing>-reservation_id.
        IF <ls_existing>-allocation_run_id IS INITIAL
            OR <ls_existing>-order_id IS INITIAL
            OR <ls_existing>-allocation_unit IS INITIAL
            OR ( ( <ls_existing>-sales_document IS NOT INITIAL
                OR <ls_existing>-sales_document_type IS NOT INITIAL
                OR <ls_existing>-sales_item IS NOT INITIAL
                OR <ls_existing>-schedule_line IS NOT INITIAL )
              AND ( <ls_existing>-sales_document IS INITIAL
                OR <ls_existing>-sales_document_type IS INITIAL
                OR <ls_existing>-sales_item IS INITIAL
                OR <ls_existing>-schedule_line IS INITIAL ) )
            OR ( <ls_existing>-sales_document IS NOT INITIAL
              AND strlen( <ls_existing>-sales_document )
                  <> zif_stock_allocation=>c_sap_document_length )
            OR ( <ls_existing>-sales_document IS NOT INITIAL
              AND <ls_existing>-sales_document CN '0123456789' )
            OR <ls_existing>-sales_document = '0000000000'
            OR ( <ls_existing>-reservation_id IS NOT INITIAL
              AND strlen( <ls_existing>-reservation_id )
                  <> zif_stock_allocation=>c_sap_document_length )
            OR ( <ls_existing>-reservation_id IS NOT INITIAL
              AND <ls_existing>-reservation_id CN '0123456789 ' )
            OR ( <ls_existing>-reservation_id IS NOT INITIAL
              AND ( lv_reservation_document CN '0123456789'
                OR lv_reservation_document = '0000000000' ) )
            OR <ls_existing>-priority < 0
            OR <ls_existing>-priority > zif_stock_allocation=>c_max_priority
            OR ( <ls_existing>-allocation_strategy IS NOT INITIAL
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'P'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'F'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'N'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'S'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'L'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'B'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'E'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'A'
              AND to_upper( <ls_existing>-allocation_strategy ) <> 'W' )
            OR ( <ls_existing>-reservation_movement_type IS NOT INITIAL
              AND ( strlen( <ls_existing>-reservation_movement_type )
                    <> zif_stock_allocation=>c_movement_type_length
                OR <ls_existing>-reservation_movement_type CN '0123456789'
                OR <ls_existing>-reservation_movement_type = zif_stock_allocation=>c_zero_movement_type ) )
            OR ( <ls_existing>-allocated > 0
              AND ( <ls_existing>-reservation_id IS INITIAL
                OR <ls_existing>-reservation_id = '0000000000'
                OR <ls_existing>-reservation_date IS INITIAL
                OR <ls_existing>-reservation_movement_type IS INITIAL
                OR <ls_existing>-reservation_unit IS INITIAL
                OR ( <ls_existing>-allocation_unit IS NOT INITIAL
                  AND <ls_existing>-reservation_unit
                    <> <ls_existing>-allocation_unit ) ) )
            OR zcl_allocation_date_sap=>is_valid_or_initial(
              <ls_existing>-requested_on ) <> abap_true
            OR zcl_allocation_date_sap=>is_valid_or_initial(
              <ls_existing>-reservation_date ) <> abap_true
            OR <ls_existing>-requested <= 0
            OR <ls_existing>-allocated < 0
            OR <ls_existing>-shortage < 0
            OR <ls_existing>-allocated > <ls_existing>-requested
            OR <ls_existing>-shortage <> <ls_existing>-requested
              - <ls_existing>-allocated
            OR ( <ls_existing>-allocated > 0
              AND <ls_existing>-reservation_unit IS NOT INITIAL
              AND <ls_existing>-reservation_unit <> <ls_existing>-allocation_unit )
            OR ( <ls_existing>-allocated = 0
              AND ( <ls_existing>-reservation_id IS NOT INITIAL
                OR <ls_existing>-reservation_date IS NOT INITIAL
                OR <ls_existing>-reservation_movement_type IS NOT INITIAL
                OR <ls_existing>-reservation_unit IS NOT INITIAL ) ).
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation snapshot read returned invalid data' ).
          raise_error( iv_message = 'Allocation snapshot read returned invalid data' ).
        ENDIF.
        IF lv_existing_unit IS INITIAL
            OR lv_existing_unit <> <ls_existing>-allocation_unit.
          lv_existing_unit = <ls_existing>-allocation_unit.
          lv_existing_run_id = <ls_existing>-allocation_run_id.
          CLEAR lt_existing_order_ids.
        ELSEIF lv_existing_run_id <> <ls_existing>-allocation_run_id.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation snapshot read returned inconsistent provenance' ).
          raise_error( iv_message = 'Allocation snapshot read returned inconsistent provenance' ).
        ENDIF.
        INSERT <ls_existing>-order_id INTO TABLE lt_existing_order_ids.
        IF sy-subrc <> 0.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation snapshot read returned duplicated demand key' ).
          raise_error( iv_message = 'Allocation snapshot read returned duplicated demand key' ).
        ENDIF.
        IF <ls_existing>-allocated > 0.
          INSERT <ls_existing>-reservation_id INTO TABLE lt_existing_reservation_ids.
          IF sy-subrc <> 0.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = lv_unit
              iv_available        = lv_available
              iv_message          = 'Allocation snapshot read returned duplicated reservation correlation' ).
            raise_error( iv_message = 'Allocation snapshot read returned duplicated reservation correlation' ).
          ENDIF.
        ENDIF.
        IF <ls_existing>-allocation_status <> 'F'
            AND <ls_existing>-allocation_status <> 'P'
            AND <ls_existing>-allocation_status <> 'U'.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation snapshot read returned invalid data' ).
          raise_error( iv_message = 'Allocation snapshot read returned invalid data' ).
        ENDIF.
        IF ( <ls_existing>-allocation_status = 'F'
              AND ( <ls_existing>-allocated <> <ls_existing>-requested
                OR <ls_existing>-shortage <> 0 ) )
            OR ( <ls_existing>-allocation_status = 'P'
              AND ( <ls_existing>-allocated <= 0
                OR <ls_existing>-allocated >= <ls_existing>-requested
                OR <ls_existing>-shortage <= 0 ) )
            OR ( <ls_existing>-allocation_status = 'U'
              AND ( <ls_existing>-allocated <> 0
                OR <ls_existing>-shortage <> <ls_existing>-requested ) )
            OR ( <ls_existing>-allocated > 0
              AND ( <ls_existing>-reservation_id IS INITIAL
                OR <ls_existing>-reservation_date IS INITIAL
                OR <ls_existing>-reservation_movement_type IS INITIAL
                OR <ls_existing>-reservation_unit IS INITIAL ) ).
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation snapshot read returned invalid data' ).
          raise_error( iv_message = 'Allocation snapshot read returned invalid data' ).
      ENDIF.
      ENDLOOP.
      LOOP AT lt_existing ASSIGNING <ls_existing>.
        IF <ls_existing>-allocation_unit = lv_unit
            AND <ls_existing>-allocated > 0
            AND <ls_existing>-reservation_movement_type <> iv_movement_type.
          INSERT <ls_existing>-reservation_movement_type
            INTO TABLE lt_cancel_movement_types.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_cancel_movement_types INTO DATA(lv_cancel_movement_type).
        TRY.
            mo_authority->check_cancel(
              iv_plant         = iv_plant
              iv_movement_type = lv_cancel_movement_type ).
          CATCH zcx_stock_allocation INTO lo_error.
            IF lo_error->message IS INITIAL.
              record_rejection(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch
                iv_unit             = lv_unit
                iv_available        = lv_available
                iv_message          = 'Reservation cancellation authorization failed' ).
              lo_error->message = 'Reservation cancellation authorization failed'.
            ELSE.
              record_rejection(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch
                iv_unit             = lv_unit
                iv_available        = lv_available
                iv_message          = lo_error->message ).
            ENDIF.
            RAISE EXCEPTION lo_error.
        ENDTRY.
      ENDLOOP.
      LOOP AT lt_existing ASSIGNING <ls_existing>.
        IF <ls_existing>-allocation_unit IS INITIAL
            OR <ls_existing>-allocation_unit = lv_unit
            OR <ls_existing>-allocated <= 0
            OR <ls_existing>-reservation_id IS INITIAL.
          CONTINUE.
        ENDIF.
        IF mo_unit_converter IS NOT BOUND.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Existing allocation unit conversion failed' ).
          raise_error( iv_message = 'Existing allocation unit conversion failed' ).
        ENDIF.
        TRY.
            lv_converted_quantity = mo_unit_converter->convert(
              iv_material  = iv_material
              iv_quantity  = <ls_existing>-allocated
              iv_unit_from = <ls_existing>-allocation_unit
              iv_unit_to   = lv_unit ).
          CATCH zcx_stock_allocation INTO lo_error.
            IF lo_error->message IS INITIAL.
              record_rejection(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch
                iv_unit             = lv_unit
                iv_available        = lv_available
                iv_message          = 'Existing allocation unit conversion failed' ).
            ELSE.
              record_rejection(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch
                iv_unit             = lv_unit
                iv_available        = lv_available
                iv_message          = lo_error->message ).
            ENDIF.
            IF lo_error->message IS INITIAL.
              lo_error->message = 'Existing allocation unit conversion failed'.
            ENDIF.
            RAISE EXCEPTION lo_error.
        ENDTRY.
        IF lv_converted_quantity <= 0.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Existing allocation unit conversion produced invalid quantity' ).
          raise_error( iv_message = 'Existing allocation unit conversion produced invalid quantity' ).
        ENDIF.
        IF lv_reserved_quantity >= lv_available
            OR lv_converted_quantity >= lv_available - lv_reserved_quantity.
          " Once reservations cover available stock, larger totals are not
          " needed and could overflow the packed quantity accumulator.
          lv_reserved_quantity = lv_available.
        ELSE.
          lv_reserved_quantity = lv_reserved_quantity + lv_converted_quantity.
        ENDIF.
      ENDLOOP.
      IF lv_available > 0.
        IF lv_reserved_quantity >= lv_available.
          CLEAR lv_available.
        ELSE.
          lv_available = lv_available - lv_reserved_quantity.
        ENDIF.
      ENDIF.
    ENDIF.
    IF iv_safety_stock > 0.
      IF lv_available <= iv_safety_stock.
        CLEAR lv_available.
      ELSE.
        lv_available = lv_available - iv_safety_stock.
      ENDIF.
    ENDIF.
    lt_original_demands = lt_demands.
    TRY.
        rv_remaining = mo_allocator->allocate(
          EXPORTING
            iv_available = lv_available
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation INTO lo_error.
        IF lo_error->message IS INITIAL.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation calculation failed' ).
        ELSE.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = lv_unit
            iv_available        = lv_available
            iv_message          = lo_error->message ).
        ENDIF.
        IF lo_error->message IS INITIAL.
          lo_error->message = 'Allocation calculation failed'.
        ENDIF.
        RAISE EXCEPTION lo_error.
    ENDTRY.
    DESCRIBE TABLE lt_demands LINES lv_result_count.
    IF lv_result_count <> lv_demand_count.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Allocation result is invalid' ).
      raise_error( iv_message = 'Allocation result is invalid' ).
    ENDIF.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_id IS INITIAL
          OR <ls_demand>-requested <= 0
          OR <ls_demand>-allocated < 0
          OR <ls_demand>-shortage < 0
          OR <ls_demand>-allocated > <ls_demand>-requested
          OR <ls_demand>-shortage <> <ls_demand>-requested
            - <ls_demand>-allocated.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      READ TABLE lt_demand_order_ids
        WITH TABLE KEY table_line = <ls_demand>-order_id
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      READ TABLE lt_original_demands ASSIGNING <ls_original>
        WITH KEY order_id = <ls_demand>-order_id.
      IF sy-subrc <> 0
          OR <ls_demand>-sales_document <> <ls_original>-sales_document
          OR <ls_demand>-sales_document_type <> <ls_original>-sales_document_type
          OR <ls_demand>-sales_item <> <ls_original>-sales_item
          OR <ls_demand>-schedule_line <> <ls_original>-schedule_line
          OR <ls_demand>-order_unit <> <ls_original>-order_unit
          OR <ls_demand>-priority <> <ls_original>-priority
          OR <ls_demand>-requested_on <> <ls_original>-requested_on
          OR <ls_demand>-requested <> <ls_original>-requested.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      IF <ls_demand>-allocation_run_id IS NOT INITIAL
          OR <ls_demand>-allocation_strategy IS NOT INITIAL
          OR <ls_demand>-allocation_unit IS NOT INITIAL.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      INSERT <ls_demand>-order_id INTO TABLE lt_result_order_ids.
      IF sy-subrc <> 0.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      IF <ls_demand>-allocation_status <> 'F'
          AND <ls_demand>-allocation_status <> 'P'
          AND <ls_demand>-allocation_status <> 'U'.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      IF ( <ls_demand>-allocation_status = 'F'
            AND ( <ls_demand>-allocated <> <ls_demand>-requested
              OR <ls_demand>-shortage <> 0 ) )
          OR ( <ls_demand>-allocation_status = 'P'
            AND ( <ls_demand>-allocated <= 0
              OR <ls_demand>-allocated >= <ls_demand>-requested
              OR <ls_demand>-shortage <= 0 ) )
          OR ( <ls_demand>-allocation_status = 'U'
            AND ( <ls_demand>-allocated <> 0
              OR <ls_demand>-shortage <> <ls_demand>-requested ) ).
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      IF ( <ls_demand>-reservation_id IS NOT INITIAL
            OR <ls_demand>-reservation_date IS NOT INITIAL
            OR <ls_demand>-reservation_movement_type IS NOT INITIAL
            OR <ls_demand>-reservation_unit IS NOT INITIAL ).
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = lv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation result is invalid' ).
        raise_error( iv_message = 'Allocation result is invalid' ).
      ENDIF.
      lv_allocated = lv_allocated + <ls_demand>-allocated.
      lv_shortage = lv_shortage + <ls_demand>-shortage.
      IF <ls_demand>-allocation_status = 'F'.
        lv_full_count = lv_full_count + 1.
      ELSEIF <ls_demand>-allocation_status = 'P'.
        lv_partial_count = lv_partial_count + 1.
      ELSEIF <ls_demand>-allocation_status = 'U'.
        lv_unallocated_count = lv_unallocated_count + 1.
      ENDIF.
    ENDLOOP.
    IF rv_remaining < 0
        OR rv_remaining + lv_allocated <> lv_available.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = lv_unit
        iv_available        = lv_available
        iv_message          = 'Allocation result is invalid' ).
      raise_error( iv_message = 'Allocation result is invalid' ).
    ENDIF.
    TRY.
        lv_run_id = mo_audit->start_run(
          iv_material          = iv_material
          iv_plant             = iv_plant
          iv_storage_location  = iv_storage_location
          iv_available         = lv_available
          iv_demand_count      = lv_demand_count
          iv_batch             = iv_batch
          iv_movement_type     = iv_movement_type
          iv_min_shelf_life    = iv_min_shelf_life
          iv_safety_stock      = iv_safety_stock
          iv_requested_on_from = iv_requested_on_from
          iv_requested_on_to   = iv_requested_on_to
          iv_unit              = lv_unit
          iv_strategy          = lv_strategy ).
      CATCH zcx_stock_allocation INTO lo_error.
        IF lo_error->message IS INITIAL.
          lo_error->message = 'Audit run start failed'.
        ENDIF.
        RAISE EXCEPTION lo_error.
    ENDTRY.
    IF lv_run_id IS INITIAL.
      raise_error( iv_message = 'Audit run ID was not returned' ).
    ENDIF.
    ev_run_id = lv_run_id.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_start_transaction_error).
          IF lo_start_transaction_error->message IS INITIAL.
            lo_start_transaction_error->message = 'Audit run start commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_start_transaction_error.
      ENDTRY.
    ENDIF.
    IF iv_preview = abap_true.
      IF lv_shortage > 0.
        lv_status = 'P'.
      ELSE.
        lv_status = 'S'.
      ENDIF.
      lv_message = 'Preview only; no reservations or snapshot were written'.
    ELSE.
      lv_cleanup_failed = abap_false.
      lv_reservation_failed = abap_false.
      TRY.
        LOOP AT lt_demands ASSIGNING <ls_demand>.
          IF <ls_demand>-requested_on IS INITIAL.
            lv_required_date = sy-datum.
          ELSE.
            lv_required_date = <ls_demand>-requested_on.
          ENDIF.
            IF <ls_demand>-allocated > 0.
              READ TABLE lt_existing ASSIGNING <ls_existing>
                WITH KEY order_id       = <ls_demand>-order_id
                         allocation_unit = lv_unit.
            IF sy-subrc = 0
                AND <ls_existing>-allocated = <ls_demand>-allocated
                AND <ls_existing>-reservation_id IS NOT INITIAL
                AND <ls_existing>-reservation_date = lv_required_date
                AND <ls_existing>-reservation_movement_type = iv_movement_type
                AND <ls_existing>-reservation_unit = lv_unit.
              <ls_demand>-reservation_id = <ls_existing>-reservation_id.
              <ls_demand>-reservation_date = lv_required_date.
              <ls_demand>-reservation_movement_type = iv_movement_type.
              <ls_demand>-reservation_unit = lv_unit.
              APPEND <ls_existing>-reservation_id TO lt_reused.
              CONTINUE.
            ENDIF.
            TRY.
                <ls_demand>-reservation_id = mo_reservation->reserve(
                  iv_material         = iv_material
                  iv_plant            = iv_plant
                  iv_storage_location = iv_storage_location
                  iv_movement_type    = iv_movement_type
                  iv_quantity         = <ls_demand>-allocated
                  iv_unit             = lv_unit
                  iv_required_date    = lv_required_date
                  iv_batch            = iv_batch ).
            CATCH zcx_stock_allocation INTO DATA(lo_reservation_error).
                lv_reservation_failed = abap_true.
                lv_failure_message = lo_reservation_error->message.
                RAISE EXCEPTION TYPE zcx_stock_allocation.
            ENDTRY.
            IF <ls_demand>-reservation_id IS INITIAL.
              lv_reservation_failed = abap_true.
              lv_failure_message = 'Reservation document was not returned'.
              RAISE EXCEPTION TYPE zcx_stock_allocation.
            ENDIF.
            lv_reservation_document = <ls_demand>-reservation_id.
            IF strlen( <ls_demand>-reservation_id )
                  <> zif_stock_allocation=>c_sap_document_length
                OR lv_reservation_document CN '0123456789'
                OR lv_reservation_document = '0000000000'.
              lv_reservation_failed = abap_true.
              lv_failure_message = 'Reservation document is invalid'.
              RAISE EXCEPTION TYPE zcx_stock_allocation.
            ENDIF.
            <ls_demand>-reservation_date = lv_required_date.
            <ls_demand>-reservation_movement_type = iv_movement_type.
            <ls_demand>-reservation_unit = lv_unit.
            APPEND <ls_demand>-reservation_id TO lt_reservations.
          ENDIF.
        ENDLOOP.
      CATCH zcx_stock_allocation.
        LOOP AT lt_reservations ASSIGNING <lv_reservation>.
          TRY.
              mo_reservation->cancel(
                iv_document      = <lv_reservation>
                iv_plant         = iv_plant
                iv_movement_type = iv_movement_type ).
            CATCH zcx_stock_allocation INTO lo_cleanup_error.
              lv_cleanup_failed = abap_true.
              IF lv_cleanup_message IS INITIAL.
                lv_cleanup_message = lo_cleanup_error->message.
              ENDIF.
              CONTINUE.
          ENDTRY.
        ENDLOOP.
        IF lv_cleanup_failed = abap_true.
          lv_status = 'P'.
          IF lv_failure_message IS NOT INITIAL
              AND lv_cleanup_message IS NOT INITIAL.
            CONCATENATE 'Reservation failed:' lv_failure_message
              '; reservation cleanup incomplete:' lv_cleanup_message
              INTO lv_message SEPARATED BY space.
          ELSEIF lv_failure_message IS NOT INITIAL.
            CONCATENATE 'Reservation failed:' lv_failure_message
              '; reservation cleanup incomplete'
              INTO lv_message SEPARATED BY space.
          ELSEIF lv_cleanup_message IS INITIAL.
            lv_message = 'Reservation cleanup incomplete'.
          ELSE.
            CONCATENATE 'Reservation cleanup incomplete:' lv_cleanup_message
              INTO lv_message SEPARATED BY space.
          ENDIF.
        ELSE.
          lv_status = 'E'.
          IF lv_reservation_failed = abap_true.
            IF lv_failure_message IS INITIAL.
              lv_message = 'Reservation failed'.
            ELSE.
              lv_message = lv_failure_message.
            ENDIF.
          ELSE.
            lv_message = 'Allocation failed'.
          ENDIF.
        ENDIF.
        TRY.
            finish_audit(
              iv_run_id            = lv_run_id
              iv_status            = lv_status
              iv_available         = lv_available
              iv_allocated         = lv_allocated
              iv_shortage          = lv_shortage
              iv_full_count        = lv_full_count
              iv_partial_count     = lv_partial_count
              iv_unallocated_count = lv_unallocated_count
              iv_message           = lv_message ).
          CATCH zcx_stock_allocation INTO DATA(lo_reservation_audit_error).
            IF lo_reservation_audit_error->message IS INITIAL
                OR lo_reservation_audit_error->message = 'Audit finalization failed'.
              lv_audit_failure_message = 'Audit finalization failed'.
            ELSE.
              CONCATENATE 'Audit finalization failed:'
                lo_reservation_audit_error->message
                INTO lv_audit_failure_message SEPARATED BY space.
            ENDIF.
            IF lv_message IS INITIAL.
              lv_message = lv_audit_failure_message.
            ELSE.
              CONCATENATE lv_message lv_audit_failure_message
                INTO lv_message SEPARATED BY '; '.
            ENDIF.
        ENDTRY.
        IF lv_lock_acquired = abap_true.
          TRY.
              mo_lock->release(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch ).
              CLEAR lv_lock_acquired.
            CATCH zcx_stock_allocation INTO DATA(lo_reservation_release_error).
              IF lo_reservation_release_error->message IS INITIAL.
                lv_release_message = 'Allocation lock release failed'.
              ELSE.
                CONCATENATE 'Allocation lock release failed:'
                  lo_reservation_release_error->message
                  INTO lv_release_message SEPARATED BY space.
              ENDIF.
              IF lv_message IS INITIAL.
                lv_message = lv_release_message.
              ELSE.
                CONCATENATE lv_message lv_release_message
                  INTO lv_message SEPARATED BY '; '.
              ENDIF.
              CLEAR lv_lock_acquired.
          ENDTRY.
        ENDIF.
        CLEAR lo_error.
        CREATE OBJECT lo_error.
        lo_error->message = lv_message.
        RAISE EXCEPTION lo_error.
      ENDTRY.
      TRY.
        mo_sink->save_allocations(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_run_id           = lv_run_id
          iv_unit             = lv_unit
          it_demands          = lt_demands ).
        IF mo_transaction IS BOUND.
          mo_transaction->commit( ).
        ENDIF.
      CATCH zcx_stock_allocation INTO lo_persistence_error.
        lv_persistence_message = lo_persistence_error->message.
        IF mo_transaction IS BOUND.
          TRY.
              mo_transaction->rollback( ).
            CATCH zcx_stock_allocation INTO DATA(lo_rollback_error).
              IF lo_rollback_error->message IS INITIAL.
                lv_rollback_message = 'Allocation transaction rollback failed'.
              ELSE.
                CONCATENATE 'Allocation transaction rollback failed:'
                  lo_rollback_error->message
                  INTO lv_rollback_message SEPARATED BY space.
              ENDIF.
              IF lv_persistence_message IS INITIAL.
                lv_persistence_message = lv_rollback_message.
              ELSE.
                CONCATENATE lv_persistence_message lv_rollback_message
                  INTO lv_persistence_message SEPARATED BY '; ' .
              ENDIF.
          ENDTRY.
        ENDIF.
        LOOP AT lt_reservations ASSIGNING <lv_reservation>.
          TRY.
              mo_reservation->cancel(
                iv_document      = <lv_reservation>
                iv_plant         = iv_plant
                iv_movement_type = iv_movement_type ).
            CATCH zcx_stock_allocation INTO lo_cleanup_error.
              lv_cleanup_failed = abap_true.
              IF lv_cleanup_message IS INITIAL.
                lv_cleanup_message = lo_cleanup_error->message.
              ENDIF.
              CONTINUE.
          ENDTRY.
        ENDLOOP.
        IF lv_cleanup_failed = abap_true.
          lv_status = 'P'.
          IF lv_persistence_message IS INITIAL AND lv_cleanup_message IS INITIAL.
            lv_message = 'Allocation result was not persisted; reservation cleanup incomplete'.
          ELSEIF lv_persistence_message IS INITIAL.
            CONCATENATE 'Allocation result was not persisted; reservation cleanup incomplete:'
              lv_cleanup_message INTO lv_message SEPARATED BY space.
          ELSEIF lv_cleanup_message IS INITIAL.
            CONCATENATE 'Allocation result was not persisted:' lv_persistence_message
              INTO lv_message SEPARATED BY space.
          ELSE.
            CONCATENATE 'Allocation result was not persisted:' lv_persistence_message
              '; reservation cleanup incomplete:' lv_cleanup_message
              INTO lv_message SEPARATED BY space.
          ENDIF.
        ELSE.
          lv_status = 'E'.
          IF lv_persistence_message IS INITIAL.
            lv_message = 'Allocation result was not persisted'.
          ELSE.
            CONCATENATE 'Allocation result was not persisted:' lv_persistence_message
              INTO lv_message SEPARATED BY space.
          ENDIF.
        ENDIF.
        TRY.
            finish_audit(
              iv_run_id            = lv_run_id
              iv_status            = lv_status
              iv_available         = lv_available
              iv_allocated         = lv_allocated
              iv_shortage          = lv_shortage
              iv_full_count        = lv_full_count
              iv_partial_count     = lv_partial_count
              iv_unallocated_count = lv_unallocated_count
              iv_message           = lv_message ).
          CATCH zcx_stock_allocation INTO DATA(lo_persistence_audit_error).
            IF lo_persistence_audit_error->message IS INITIAL
                OR lo_persistence_audit_error->message = 'Audit finalization failed'.
              lv_audit_failure_message = 'Audit finalization failed'.
            ELSE.
              CONCATENATE 'Audit finalization failed:'
                lo_persistence_audit_error->message
                INTO lv_audit_failure_message SEPARATED BY space.
            ENDIF.
            IF lv_message IS INITIAL.
              lv_message = lv_audit_failure_message.
            ELSE.
              CONCATENATE lv_message lv_audit_failure_message
                INTO lv_message SEPARATED BY '; '.
            ENDIF.
        ENDTRY.
        IF lv_lock_acquired = abap_true.
          TRY.
              mo_lock->release(
                iv_material         = iv_material
                iv_plant            = iv_plant
                iv_storage_location = iv_storage_location
                iv_batch            = iv_batch ).
              CLEAR lv_lock_acquired.
            CATCH zcx_stock_allocation INTO DATA(lo_persistence_release_error).
              IF lo_persistence_release_error->message IS INITIAL.
                lv_release_message = 'Allocation lock release failed'.
              ELSE.
                CONCATENATE 'Allocation lock release failed:'
                  lo_persistence_release_error->message
                  INTO lv_release_message SEPARATED BY space.
              ENDIF.
              IF lv_message IS INITIAL.
                lv_message = lv_release_message.
              ELSE.
                CONCATENATE lv_message lv_release_message
                  INTO lv_message SEPARATED BY '; '.
              ENDIF.
              CLEAR lv_lock_acquired.
          ENDTRY.
        ENDIF.
        CLEAR lo_error.
        CREATE OBJECT lo_error.
        lo_error->message = lv_message.
        RAISE EXCEPTION lo_error.
      ENDTRY.
      LOOP AT lt_existing ASSIGNING <ls_existing>.
        IF <ls_existing>-allocation_unit = lv_unit
            AND <ls_existing>-reservation_id IS NOT INITIAL.
          READ TABLE lt_reused
            WITH KEY table_line = <ls_existing>-reservation_id
            TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            TRY.
                mo_reservation->cancel(
                  iv_document      = <ls_existing>-reservation_id
                  iv_plant         = iv_plant
                  iv_movement_type = <ls_existing>-reservation_movement_type ).
              CATCH zcx_stock_allocation INTO lo_cleanup_error.
                lv_cleanup_failed = abap_true.
                IF lv_cleanup_message IS INITIAL.
                  lv_cleanup_message = lo_cleanup_error->message.
                ENDIF.
                CONTINUE.
            ENDTRY.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF lv_cleanup_failed = abap_true.
        lv_status = 'P'.
        IF lv_cleanup_message IS INITIAL.
          lv_message = 'Allocation completed; reservation cleanup incomplete'.
        ELSE.
          CONCATENATE 'Allocation completed; reservation cleanup incomplete:'
            lv_cleanup_message INTO lv_message SEPARATED BY space.
        ENDIF.
      ELSEIF lv_shortage > 0.
        lv_status = 'P'.
        lv_message = 'Allocation completed with shortage'.
      ELSE.
        lv_status = 'S'.
        lv_message = 'Allocation completed'.
      ENDIF.
    ENDIF.
    CATCH zcx_stock_allocation INTO lo_error.
      IF lv_lock_acquired = abap_true.
        TRY.
            mo_lock->release(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch ).
          CATCH zcx_stock_allocation INTO DATA(lo_release_error).
            IF lo_release_error->message IS INITIAL.
              lv_release_message = 'Allocation lock release failed'.
            ELSE.
              CONCATENATE 'Allocation lock release failed:' lo_release_error->message
                INTO lv_release_message SEPARATED BY space.
            ENDIF.
            IF lo_error->message IS INITIAL.
              lo_error->message = lv_release_message.
            ELSE.
              CONCATENATE lo_error->message lv_release_message
                INTO lo_error->message SEPARATED BY '; '.
            ENDIF.
            CLEAR lv_lock_acquired.
        ENDTRY.
      ENDIF.
      RAISE EXCEPTION lo_error.
    ENDTRY.
    IF lv_lock_acquired = abap_true.
      TRY.
          mo_lock->release(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch ).
          CLEAR lv_lock_acquired.
          CATCH zcx_stock_allocation INTO lo_error.
            IF lo_error->message IS INITIAL.
              lv_release_message = 'Allocation lock release failed'.
          ELSE.
            CONCATENATE 'Allocation lock release failed:' lo_error->message
                INTO lv_release_message SEPARATED BY space.
            ENDIF.
            IF lv_cleanup_failed = abap_true.
              IF lv_message IS INITIAL.
                lv_message = lv_release_message.
              ELSE.
                CONCATENATE lv_message lv_release_message
                  INTO lv_message SEPARATED BY '; '.
              ENDIF.
              lv_release_message = lv_message.
            ENDIF.
            TRY.
                finish_audit(
                iv_run_id            = lv_run_id
                iv_status            = 'P'
                iv_available         = lv_available
                iv_allocated         = lv_allocated
                iv_shortage          = lv_shortage
                iv_full_count        = lv_full_count
                iv_partial_count     = lv_partial_count
                iv_unallocated_count = lv_unallocated_count
                iv_message           = lv_release_message ).
            CATCH zcx_stock_allocation INTO DATA(lo_audit_release_error).
              IF lv_release_message IS INITIAL.
                lv_release_message = lo_audit_release_error->message.
              ENDIF.
          ENDTRY.
          lo_error->message = lv_release_message.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.
    TRY.
        finish_audit(
          iv_run_id            = lv_run_id
          iv_status            = lv_status
          iv_available         = lv_available
          iv_allocated         = lv_allocated
          iv_shortage          = lv_shortage
          iv_full_count        = lv_full_count
          iv_partial_count     = lv_partial_count
          iv_unallocated_count = lv_unallocated_count
          iv_message           = lv_message ).
      CATCH zcx_stock_allocation INTO lo_error.
        IF lv_cleanup_failed = abap_true.
          IF lo_error->message IS INITIAL
              OR lo_error->message = 'Audit finalization failed'.
            lv_audit_failure_message = 'Audit finalization failed'.
          ELSE.
            CONCATENATE 'Audit finalization failed:'
              lo_error->message INTO lv_audit_failure_message SEPARATED BY space.
          ENDIF.
          CONCATENATE lv_message lv_audit_failure_message
            INTO lv_message SEPARATED BY '; '.
          lo_error->message = lv_message.
        ENDIF.
        RAISE EXCEPTION lo_error.
    ENDTRY.
    IF lv_cleanup_failed = abap_true.
      CLEAR lo_error.
      CREATE OBJECT lo_error.
      lo_error->message = lv_message.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.

  METHOD finish_audit.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.

    lv_message = iv_message.
    IF to_upper( iv_status ) = 'S'.
      CLEAR lv_message.
    ENDIF.
    TRY.
        mo_audit->finish_run(
          iv_run_id            = iv_run_id
          iv_status            = iv_status
          iv_available         = iv_available
          iv_allocated         = iv_allocated
          iv_shortage          = iv_shortage
          iv_full_count        = iv_full_count
          iv_partial_count     = iv_partial_count
          iv_unallocated_count = iv_unallocated_count
          iv_message           = lv_message ).
      CATCH zcx_stock_allocation INTO lo_error.
        IF lo_error->message IS INITIAL.
          lo_error->message = 'Audit finalization failed'.
        ENDIF.
        RAISE EXCEPTION lo_error.
    ENDTRY.
  ENDMETHOD.

  METHOD record_rejection.
    DATA lv_movement_type TYPE zif_stock_allocation=>ty_movement_type.

    lv_movement_type = mv_movement_type.
    IF lv_movement_type IS NOT INITIAL
        AND ( strlen( lv_movement_type ) <> zif_stock_allocation=>c_movement_type_length
          OR lv_movement_type CN '0123456789'
          OR lv_movement_type = zif_stock_allocation=>c_zero_movement_type ).
      CLEAR lv_movement_type.
    ENDIF.
    TRY.
        mo_audit->record_rejection(
          iv_material          = iv_material
          iv_plant             = iv_plant
          iv_storage_location  = iv_storage_location
          iv_batch             = iv_batch
          iv_movement_type     = lv_movement_type
          iv_min_shelf_life    = mv_min_shelf_life
          iv_safety_stock      = mv_safety_stock
          iv_unit              = iv_unit
          iv_requested_on_from = mv_requested_on_from
          iv_requested_on_to   = mv_requested_on_to
          iv_available         = iv_available
          iv_message           = iv_message ).
      CATCH zcx_stock_allocation.
        RETURN.
    ENDTRY.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
