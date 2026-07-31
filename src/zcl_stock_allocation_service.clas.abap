CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_source   TYPE REF TO zif_stock_source
        io_order_source   TYPE REF TO zif_order_source
        io_sink           TYPE REF TO zif_allocation_sink OPTIONAL
        io_allocator      TYPE REF TO zif_stock_allocation
        io_reservation    TYPE REF TO zif_stock_reservation OPTIONAL
        io_unit_converter TYPE REF TO zif_unit_conversion OPTIONAL
        io_lock           TYPE REF TO zif_stock_allocation_lock OPTIONAL
        io_authority      TYPE REF TO zif_stock_allocation_authority OPTIONAL
        io_audit          TYPE REF TO zif_allocation_audit.
    METHODS allocate
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
        iv_movement_type    TYPE zif_stock_allocation=>ty_movement_type
        iv_unit             TYPE zif_stock_allocation=>ty_unit
        iv_batch            TYPE zif_stock_allocation=>ty_batch OPTIONAL
        iv_preview          TYPE abap_bool OPTIONAL
        iv_min_shelf_life   TYPE i OPTIONAL
      RETURNING
        VALUE(rv_remaining) TYPE zif_stock_allocation=>ty_quantity
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
    DATA mo_audit TYPE REF TO zif_allocation_audit.
    METHODS finish_audit
      IMPORTING
        iv_run_id    TYPE zif_allocation_audit=>ty_run_id
        iv_status    TYPE zif_allocation_audit=>ty_run_status
        iv_available TYPE zif_stock_allocation=>ty_quantity
        iv_allocated TYPE zif_stock_allocation=>ty_quantity
        iv_shortage  TYPE zif_stock_allocation=>ty_quantity
        iv_message   TYPE zif_allocation_audit=>ty_message
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
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_source = io_stock_source.
    mo_order_source = io_order_source.
    mo_sink = io_sink.
    mo_allocator = io_allocator.
    mo_reservation = io_reservation.
    mo_unit_converter = io_unit_converter.
    mo_lock = io_lock.
    mo_authority = io_authority.
    mo_audit = io_audit.
  ENDMETHOD.

  METHOD allocate.
    DATA lv_available TYPE zif_stock_allocation=>ty_quantity.
    DATA ls_available TYPE zif_stock_allocation=>ty_available.
    DATA lv_required_date TYPE d.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_demand_count TYPE i.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_cleanup_failed TYPE abap_bool.
    DATA lv_reservation_failed TYPE abap_bool.
    DATA lv_failure_message TYPE zif_allocation_audit=>ty_message.
    DATA lv_lock_acquired TYPE abap_bool.
    DATA lv_min_shelf_life_date TYPE d.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lt_existing TYPE zif_stock_allocation=>tt_demands.
    DATA lt_reservations TYPE STANDARD TABLE OF zif_stock_allocation=>ty_order_id
      WITH EMPTY KEY.
    DATA lt_reused TYPE STANDARD TABLE OF zif_stock_allocation=>ty_order_id
      WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_existing> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <lv_reservation> TYPE zif_stock_allocation=>ty_order_id.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_movement_type IS INITIAL
        OR iv_unit IS INITIAL.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = 0
          iv_message          = 'Invalid allocation input' ).
      ENDIF.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_min_shelf_life < 0.
      IF mo_audit IS BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = 0
          iv_message          = 'Invalid minimum shelf life' ).
      ENDIF.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
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
          iv_unit             = iv_unit
          iv_available        = 0
          iv_message          = 'Allocation dependency missing' ).
      ENDIF.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    IF mo_authority IS BOUND AND iv_preview <> abap_true.
      TRY.
          mo_authority->check( iv_movement_type = iv_movement_type ).
        CATCH zcx_stock_allocation.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit
            iv_available        = 0
            iv_message          = 'Movement authorization failed' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDTRY.
    ENDIF.

    IF mo_lock IS BOUND.
      TRY.
          mo_lock->acquire(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch ).
        CATCH zcx_stock_allocation.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit
            iv_available        = 0
            iv_message          = 'Allocation lock acquisition failed' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
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
        CATCH zcx_stock_allocation.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit
            iv_available        = 0
            iv_message          = 'Available stock read failed' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDTRY.
    IF ls_available-material_found <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = 0
        iv_message          = 'Material does not exist' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF ls_available-unit IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = 0
        iv_message          = 'Material base unit is missing' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    lv_available = ls_available-quantity.
    IF ls_available-batch_managed = abap_true
        AND iv_batch IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Batch is required' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_batch IS NOT INITIAL
        AND ls_available-batch_managed <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Material is not batch managed' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_batch IS NOT INITIAL
        AND ls_available-batch_found <> abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Batch does not exist in storage location' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_batch IS NOT INITIAL
        AND ls_available-batch_expiration_date IS NOT INITIAL
        AND ls_available-batch_expiration_date < sy-datum.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Batch is expired' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_min_shelf_life > 0
        AND iv_batch IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Minimum shelf life requires a batch' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_min_shelf_life > 0
        AND ls_available-batch_expiration_date IS INITIAL.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Batch expiration date is required for shelf-life policy' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF iv_min_shelf_life > 0.
      lv_min_shelf_life_date = sy-datum + iv_min_shelf_life.
      IF ls_available-batch_expiration_date < lv_min_shelf_life_date.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = lv_available
          iv_message          = 'Batch does not meet minimum shelf life' ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
    ENDIF.
    IF ls_available-batch_restricted = abap_true.
      record_rejection(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = iv_unit
        iv_available        = lv_available
        iv_message          = 'Batch is restricted' ).
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF lv_available > 0
        AND ls_available-unit <> iv_unit.
      IF mo_unit_converter IS NOT BOUND.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = lv_available
          iv_message          = 'Stock unit conversion failed' ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
      TRY.
          lv_available = mo_unit_converter->convert(
            iv_material  = iv_material
            iv_quantity  = lv_available
            iv_unit_from = ls_available-unit
            iv_unit_to   = iv_unit ).
        CATCH zcx_stock_allocation.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit
            iv_available        = lv_available
            iv_message          = 'Stock unit conversion failed' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDTRY.
    ENDIF.
    TRY.
        lt_demands = mo_order_source->get_open_demands(
          iv_material = iv_material
          iv_plant    = iv_plant ).
      CATCH zcx_stock_allocation.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = lv_available
          iv_message          = 'Open demand validation failed' ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDTRY.
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
            iv_unit             = iv_unit
            iv_available        = lv_available
            iv_message          = 'Batch expires before delivery date' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
        ENDIF.
      ENDLOOP.
    ENDIF.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_unit IS NOT INITIAL
          AND <ls_demand>-order_unit <> iv_unit.
        IF mo_unit_converter IS NOT BOUND.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit
            iv_available        = lv_available
            iv_message          = 'Demand unit conversion failed' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
        ENDIF.
        TRY.
            <ls_demand>-requested = mo_unit_converter->convert(
              iv_material  = iv_material
              iv_quantity  = <ls_demand>-requested
              iv_unit_from = <ls_demand>-order_unit
              iv_unit_to   = iv_unit ).
          CATCH zcx_stock_allocation.
            record_rejection(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch
              iv_unit             = iv_unit
              iv_available        = lv_available
              iv_message          = 'Demand unit conversion failed' ).
            RAISE EXCEPTION TYPE zcx_stock_allocation.
        ENDTRY.
      ENDIF.
    ENDLOOP.
    IF iv_preview <> abap_true.
      TRY.
          lt_existing = mo_sink->get_allocations(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit ).
        CATCH zcx_stock_allocation.
          record_rejection(
            iv_material         = iv_material
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_batch            = iv_batch
            iv_unit             = iv_unit
            iv_available        = lv_available
            iv_message          = 'Allocation snapshot read failed' ).
          RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDTRY.
    ENDIF.
    TRY.
        rv_remaining = mo_allocator->allocate(
          EXPORTING
            iv_available = lv_available
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation.
        record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = lv_available
          iv_message          = 'Allocation calculation failed' ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDTRY.
    DESCRIBE TABLE lt_demands LINES lv_demand_count.
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      lv_allocated = lv_allocated + <ls_demand>-allocated.
      lv_shortage = lv_shortage + <ls_demand>-shortage.
    ENDLOOP.
    lv_run_id = mo_audit->start_run(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_available        = lv_available
      iv_demand_count     = lv_demand_count
      iv_batch            = iv_batch
      iv_unit             = iv_unit ).
    IF iv_preview = abap_true.
      IF lv_shortage > 0.
        lv_status = 'P'.
      ELSE.
        lv_status = 'S'.
      ENDIF.
      finish_audit(
        iv_run_id    = lv_run_id
        iv_status    = lv_status
        iv_available = lv_available
        iv_allocated = lv_allocated
        iv_shortage  = lv_shortage
        iv_message   = 'Preview only; no reservations or snapshot were written' ).
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
              WITH KEY order_id = <ls_demand>-order_id.
            IF sy-subrc = 0
                AND <ls_existing>-allocated = <ls_demand>-allocated
                AND <ls_existing>-reservation_id IS NOT INITIAL
                AND <ls_existing>-reservation_date = lv_required_date
                AND <ls_existing>-reservation_movement_type = iv_movement_type
                AND <ls_existing>-reservation_unit = iv_unit.
              <ls_demand>-reservation_id = <ls_existing>-reservation_id.
              <ls_demand>-reservation_date = lv_required_date.
              <ls_demand>-reservation_movement_type = iv_movement_type.
              <ls_demand>-reservation_unit = iv_unit.
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
                  iv_unit             = iv_unit
                  iv_required_date    = lv_required_date
                  iv_batch            = iv_batch ).
              CATCH zcx_stock_allocation INTO DATA(lo_reservation_error).
                lv_reservation_failed = abap_true.
                lv_failure_message = lo_reservation_error->message.
                RAISE EXCEPTION TYPE zcx_stock_allocation.
            ENDTRY.
            <ls_demand>-reservation_date = lv_required_date.
            <ls_demand>-reservation_movement_type = iv_movement_type.
            <ls_demand>-reservation_unit = iv_unit.
            APPEND <ls_demand>-reservation_id TO lt_reservations.
          ENDIF.
        ENDLOOP.
        LOOP AT lt_existing ASSIGNING <ls_existing>.
          IF <ls_existing>-reservation_id IS NOT INITIAL.
            READ TABLE lt_reused
              WITH TABLE KEY table_line = <ls_existing>-reservation_id
              TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              TRY.
                  mo_reservation->cancel(
                    iv_document = <ls_existing>-reservation_id ).
                CATCH zcx_stock_allocation.
                  lv_cleanup_failed = abap_true.
                  RAISE EXCEPTION TYPE zcx_stock_allocation.
              ENDTRY.
            ENDIF.
          ENDIF.
        ENDLOOP.
      CATCH zcx_stock_allocation.
        LOOP AT lt_reservations ASSIGNING <lv_reservation>.
          TRY.
              mo_reservation->cancel( iv_document = <lv_reservation> ).
            CATCH zcx_stock_allocation.
              lv_cleanup_failed = abap_true.
              CONTINUE.
          ENDTRY.
        ENDLOOP.
        IF lv_cleanup_failed = abap_true.
          lv_status = 'P'.
          lv_message = 'Reservation cleanup incomplete'.
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
        finish_audit(
          iv_run_id    = lv_run_id
          iv_status    = lv_status
          iv_available = lv_available
          iv_allocated = lv_allocated
          iv_shortage  = lv_shortage
          iv_message   = lv_message ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDTRY.
      TRY.
        mo_sink->save_allocations(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_run_id           = lv_run_id
          iv_unit             = iv_unit
          it_demands          = lt_demands ).
      CATCH zcx_stock_allocation.
        LOOP AT lt_reservations ASSIGNING <lv_reservation>.
          TRY.
              mo_reservation->cancel( iv_document = <lv_reservation> ).
            CATCH zcx_stock_allocation.
              lv_cleanup_failed = abap_true.
              CONTINUE.
          ENDTRY.
        ENDLOOP.
        IF lv_cleanup_failed = abap_true.
          lv_status = 'P'.
          lv_message = 'Allocation result was not persisted; reservation cleanup incomplete'.
        ELSE.
          lv_status = 'E'.
          lv_message = 'Allocation result was not persisted'.
        ENDIF.
        finish_audit(
          iv_run_id    = lv_run_id
          iv_status    = lv_status
          iv_available = lv_available
          iv_allocated = lv_allocated
          iv_shortage  = lv_shortage
          iv_message   = lv_message ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDTRY.
      IF lv_shortage > 0.
      lv_status = 'P'.
      lv_message = 'Allocation completed with shortage'.
    ELSE.
      lv_status = 'S'.
      lv_message = 'Allocation completed'.
    ENDIF.
      finish_audit(
        iv_run_id    = lv_run_id
        iv_status    = lv_status
        iv_available = lv_available
        iv_allocated = lv_allocated
        iv_shortage  = lv_shortage
        iv_message   = lv_message ).
    ENDIF.
    CATCH zcx_stock_allocation.
      IF lv_lock_acquired = abap_true.
        TRY.
            mo_lock->release(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_batch            = iv_batch ).
          CATCH zcx_stock_allocation.
            CLEAR lv_lock_acquired.
        ENDTRY.
      ENDIF.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDTRY.
    IF lv_lock_acquired = abap_true.
      mo_lock->release(
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch ).
    ENDIF.
  ENDMETHOD.

  METHOD finish_audit.
    mo_audit->finish_run(
      iv_run_id    = iv_run_id
      iv_status    = iv_status
      iv_available = iv_available
      iv_allocated = iv_allocated
      iv_shortage  = iv_shortage
      iv_message   = iv_message ).
  ENDMETHOD.

  METHOD record_rejection.
    TRY.
        mo_audit->record_rejection(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
          iv_batch            = iv_batch
          iv_unit             = iv_unit
          iv_available        = iv_available
          iv_message          = iv_message ).
      CATCH zcx_stock_allocation.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
