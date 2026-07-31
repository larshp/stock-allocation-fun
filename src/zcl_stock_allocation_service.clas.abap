CLASS zcl_stock_allocation_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock_source TYPE REF TO zif_stock_source
        io_order_source TYPE REF TO zif_order_source
        io_sink         TYPE REF TO zif_allocation_sink
        io_allocator    TYPE REF TO zif_stock_allocation
        io_reservation  TYPE REF TO zif_stock_reservation
        io_audit        TYPE REF TO zif_allocation_audit.
    METHODS allocate
      IMPORTING
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
        iv_movement_type    TYPE zif_stock_allocation=>ty_movement_type
        iv_unit             TYPE zif_stock_allocation=>ty_unit
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
    DATA mo_audit TYPE REF TO zif_allocation_audit.
    METHODS finish_audit
      IMPORTING
        iv_run_id    TYPE zif_allocation_audit=>ty_run_id
        iv_status    TYPE zif_allocation_audit=>ty_run_status
        iv_available TYPE zif_stock_allocation=>ty_quantity
        iv_allocated TYPE zif_stock_allocation=>ty_quantity
        iv_shortage  TYPE zif_stock_allocation=>ty_quantity
        iv_message   TYPE zif_allocation_audit=>ty_message.
ENDCLASS.

CLASS zcl_stock_allocation_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock_source = io_stock_source.
    mo_order_source = io_order_source.
    mo_sink = io_sink.
    mo_allocator = io_allocator.
    mo_reservation = io_reservation.
    mo_audit = io_audit.
  ENDMETHOD.

  METHOD allocate.
    DATA lv_available TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_required_date TYPE d.
    DATA lv_allocated TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_shortage TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_demand_count TYPE i.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_cleanup_failed TYPE abap_bool.
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
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    IF mo_stock_source IS NOT BOUND
        OR mo_order_source IS NOT BOUND
        OR mo_sink IS NOT BOUND
        OR mo_allocator IS NOT BOUND
        OR mo_reservation IS NOT BOUND
        OR mo_audit IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    lv_available = mo_stock_source->get_available(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    lt_demands = mo_order_source->get_open_demands(
      iv_material = iv_material
      iv_plant    = iv_plant ).
    LOOP AT lt_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_unit IS NOT INITIAL
          AND <ls_demand>-order_unit <> iv_unit.
        RAISE EXCEPTION TYPE zcx_stock_allocation.
      ENDIF.
    ENDLOOP.
    lt_existing = mo_sink->get_allocations(
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location ).
    rv_remaining = mo_allocator->allocate(
      EXPORTING
        iv_available = lv_available
      CHANGING
        ct_demands   = lt_demands ).
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
      iv_demand_count     = lv_demand_count ).
    lv_cleanup_failed = abap_false.
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
            <ls_demand>-reservation_id = mo_reservation->reserve(
              iv_material         = iv_material
              iv_plant            = iv_plant
              iv_storage_location = iv_storage_location
              iv_movement_type    = iv_movement_type
              iv_quantity         = <ls_demand>-allocated
              iv_unit             = iv_unit
              iv_required_date    = lv_required_date ).
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
        ELSE.
          lv_status = 'E'.
        ENDIF.
        finish_audit(
          iv_run_id    = lv_run_id
          iv_status    = lv_status
          iv_available = lv_available
          iv_allocated = lv_allocated
          iv_shortage  = lv_shortage
          iv_message   = 'Allocation failed' ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDTRY.
    TRY.
        mo_sink->save_allocations(
          iv_material         = iv_material
          iv_plant            = iv_plant
          iv_storage_location = iv_storage_location
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
        ELSE.
          lv_status = 'E'.
        ENDIF.
        finish_audit(
          iv_run_id    = lv_run_id
          iv_status    = lv_status
          iv_available = lv_available
          iv_allocated = lv_allocated
          iv_shortage  = lv_shortage
          iv_message   = 'Allocation result was not persisted' ).
        RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDTRY.
    finish_audit(
      iv_run_id    = lv_run_id
      iv_status    = 'S'
      iv_available = lv_available
      iv_allocated = lv_allocated
      iv_shortage  = lv_shortage
      iv_message   = '' ).
  ENDMETHOD.

  METHOD finish_audit.
    TRY.
        mo_audit->finish_run(
          iv_run_id    = iv_run_id
          iv_status    = iv_status
          iv_available = iv_available
          iv_allocated = iv_allocated
          iv_shortage  = iv_shortage
          iv_message   = iv_message ).
      CATCH zcx_stock_allocation.
        RETURN.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
