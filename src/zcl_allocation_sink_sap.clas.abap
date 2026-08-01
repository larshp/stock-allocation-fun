CLASS zcl_allocation_sink_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_read_authority  TYPE REF TO zif_allocation_read_authority OPTIONAL
        io_write_authority TYPE REF TO zif_allocation_write_authority OPTIONAL.
    INTERFACES zif_allocation_sink.
  PRIVATE SECTION.
    DATA mo_read_authority TYPE REF TO zif_allocation_read_authority.
    DATA mo_write_authority TYPE REF TO zif_allocation_write_authority.
    METHODS validate_demand
      IMPORTING
        is_demand         TYPE zif_stock_allocation=>ty_demand
        iv_require_run_id TYPE abap_bool OPTIONAL
      RAISING
        zcx_stock_allocation.
    METHODS validate_run_reference
      IMPORTING
        iv_run_id           TYPE zif_stock_allocation=>ty_run_id
        iv_material         TYPE zif_stock_allocation=>ty_material
        iv_plant            TYPE zif_stock_allocation=>ty_plant
        iv_storage_location TYPE zif_stock_allocation=>ty_storage_location
        iv_batch            TYPE zif_stock_allocation=>ty_batch
        iv_unit             TYPE zif_stock_allocation=>ty_unit
        iv_require_running  TYPE abap_bool OPTIONAL
      RAISING
        zcx_stock_allocation.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_allocation_sink_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_read_authority IS BOUND.
      mo_read_authority = io_read_authority.
    ELSE.
      CREATE OBJECT mo_read_authority TYPE zcl_allocation_read_authority_sap.
    ENDIF.
    IF io_write_authority IS BOUND.
      mo_write_authority = io_write_authority.
    ELSE.
      CREATE OBJECT mo_write_authority TYPE zcl_allocation_write_authority_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_sink~get_allocations.
    DATA lv_run_id TYPE zif_stock_allocation=>ty_run_id.
    DATA lv_allocation_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lt_reservation_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Allocation snapshot scope is incomplete' ).
    ENDIF.
    IF mo_read_authority IS BOUND.
      TRY.
          mo_read_authority->check_results( ).
        CATCH zcx_stock_allocation INTO DATA(lo_read_error).
          IF lo_read_error->message IS INITIAL.
            lo_read_error->message = 'Allocation result read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_read_error.
      ENDTRY.
    ENDIF.
    SELECT run_id AS allocation_run_id,
           allocation_unit,
           sales_document, sales_document_type, sales_item, schedule_line, order_unit,
           requested_on, order_id,
           requested, allocated, shortage, allocation_status,
           reservation_id,
           reservation_date, reservation_movement_type, reservation_unit
      FROM zstockalloc
      INTO TABLE @rt_demands
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND batch = @iv_batch.
    IF sy-subrc <> 0.
      CLEAR rt_demands.
    ENDIF.
    IF iv_unit IS NOT INITIAL.
      DELETE rt_demands WHERE allocation_unit <> iv_unit.
    ENDIF.
    SORT rt_demands BY allocation_unit order_id.
    LOOP AT rt_demands ASSIGNING <ls_demand>.
      validate_demand(
        is_demand         = <ls_demand>
        iv_require_run_id = abap_true ).
      validate_run_reference(
        iv_run_id           = <ls_demand>-allocation_run_id
        iv_material         = iv_material
        iv_plant            = iv_plant
        iv_storage_location = iv_storage_location
        iv_batch            = iv_batch
        iv_unit             = <ls_demand>-allocation_unit ).
      IF lv_allocation_unit IS INITIAL
          OR lv_allocation_unit <> <ls_demand>-allocation_unit.
        lv_allocation_unit = <ls_demand>-allocation_unit.
        lv_run_id = <ls_demand>-allocation_run_id.
    ELSEIF lv_run_id <> <ls_demand>-allocation_run_id.
        raise_error( iv_message = 'Allocation snapshot provenance is inconsistent' ).
      ENDIF.
      IF <ls_demand>-allocated > 0.
        INSERT <ls_demand>-reservation_id INTO TABLE lt_reservation_ids.
        IF sy-subrc <> 0.
          raise_error( iv_message = 'Allocation snapshot reservation correlation is duplicated' ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_allocation_sink~save_allocations.
    DATA ls_allocation TYPE zstockalloc.
    DATA lt_allocations TYPE STANDARD TABLE OF zstockalloc WITH EMPTY KEY.
    DATA lt_order_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    DATA lt_reservation_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_run_id IS INITIAL
        OR iv_unit IS INITIAL.
      raise_error( iv_message = 'Allocation snapshot input is incomplete' ).
    ENDIF.
    LOOP AT it_demands ASSIGNING <ls_demand>.
      validate_demand( is_demand = <ls_demand> ).
      INSERT <ls_demand>-order_id INTO TABLE lt_order_ids.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Allocation snapshot contains duplicate demand keys' ).
      ENDIF.
      IF <ls_demand>-allocated > 0.
        INSERT <ls_demand>-reservation_id INTO TABLE lt_reservation_ids.
        IF sy-subrc <> 0.
          raise_error( iv_message = 'Allocation snapshot reservation correlation is duplicated' ).
        ENDIF.
      ENDIF.
      CLEAR ls_allocation.
      ls_allocation-mandt = sy-mandt.
      ls_allocation-matnr = iv_material.
      ls_allocation-werks = iv_plant.
      ls_allocation-lgort = iv_storage_location.
      ls_allocation-batch = iv_batch.
      ls_allocation-run_id = iv_run_id.
      ls_allocation-allocation_unit = iv_unit.
      ls_allocation-sales_document = <ls_demand>-sales_document.
      ls_allocation-sales_document_type = <ls_demand>-sales_document_type.
      ls_allocation-sales_item = <ls_demand>-sales_item.
      ls_allocation-schedule_line = <ls_demand>-schedule_line.
      ls_allocation-order_unit = <ls_demand>-order_unit.
      ls_allocation-requested_on = <ls_demand>-requested_on.
      ls_allocation-order_id = <ls_demand>-order_id.
      ls_allocation-requested = <ls_demand>-requested.
      ls_allocation-allocated = <ls_demand>-allocated.
      ls_allocation-shortage = <ls_demand>-shortage.
      ls_allocation-allocation_status = <ls_demand>-allocation_status.
      ls_allocation-reservation_id = <ls_demand>-reservation_id.
      ls_allocation-reservation_date = <ls_demand>-reservation_date.
      ls_allocation-reservation_movement_type =
        <ls_demand>-reservation_movement_type.
      ls_allocation-reservation_unit = <ls_demand>-reservation_unit.
      APPEND ls_allocation TO lt_allocations.
    ENDLOOP.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_result_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Allocation result write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
      TRY.
          mo_write_authority->check_result_delete( ).
        CATCH zcx_stock_allocation INTO DATA(lo_delete_error).
          IF lo_delete_error->message IS INITIAL.
            lo_delete_error->message = 'Allocation result delete authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_delete_error.
      ENDTRY.
    ENDIF.

    validate_run_reference(
      iv_run_id           = iv_run_id
      iv_material         = iv_material
      iv_plant            = iv_plant
      iv_storage_location = iv_storage_location
      iv_batch            = iv_batch
      iv_unit             = iv_unit
      iv_require_running  = abap_true ).

    DELETE FROM zstockalloc
      WHERE mandt = @sy-mandt
        AND matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND batch = @iv_batch
        AND allocation_unit = @iv_unit.
    IF lt_allocations IS NOT INITIAL.
      MODIFY zstockalloc FROM TABLE @lt_allocations.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Allocation snapshot persistence failed' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_demand.
    IF is_demand-order_id IS INITIAL
        OR ( iv_require_run_id = abap_true
          AND is_demand-allocation_run_id IS INITIAL )
        OR is_demand-requested <= 0
        OR is_demand-allocated < 0
        OR is_demand-shortage < 0
        OR is_demand-allocated > is_demand-requested
        OR is_demand-shortage <> is_demand-requested
          - is_demand-allocated.
      raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
    ENDIF.
    IF is_demand-allocation_status <> 'F'
        AND is_demand-allocation_status <> 'P'
        AND is_demand-allocation_status <> 'U'.
      raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
    ENDIF.
    IF ( is_demand-allocation_status = 'F'
          AND ( is_demand-allocated <> is_demand-requested
            OR is_demand-shortage <> 0 ) )
        OR ( is_demand-allocation_status = 'P'
          AND ( is_demand-allocated <= 0
            OR is_demand-allocated >= is_demand-requested
            OR is_demand-shortage <= 0 ) )
        OR ( is_demand-allocation_status = 'U'
          AND ( is_demand-allocated <> 0
            OR is_demand-shortage <> is_demand-requested ) )
        OR ( is_demand-allocated > 0
          AND ( is_demand-reservation_id IS INITIAL
            OR is_demand-reservation_date IS INITIAL
            OR is_demand-reservation_movement_type IS INITIAL
            OR is_demand-reservation_unit IS INITIAL
            OR ( is_demand-allocation_unit IS NOT INITIAL
              AND is_demand-reservation_unit <> is_demand-allocation_unit ) ) )
        OR ( is_demand-allocated = 0
          AND ( is_demand-reservation_id IS NOT INITIAL
            OR is_demand-reservation_date IS NOT INITIAL
            OR is_demand-reservation_movement_type IS NOT INITIAL
            OR is_demand-reservation_unit IS NOT INITIAL ) ).
      raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_run_reference.
    DATA lv_run_material TYPE zstockalloc_run-matnr.
    DATA lv_run_plant TYPE zstockalloc_run-werks.
    DATA lv_run_storage_location TYPE zstockalloc_run-lgort.
    DATA lv_run_batch TYPE zstockalloc_run-batch.
    DATA lv_run_unit TYPE zstockalloc_run-unit.
    DATA lv_run_status TYPE zstockalloc_run-status.

    SELECT SINGLE matnr, werks, lgort, batch, unit, status
      FROM zstockalloc_run
      INTO (@lv_run_material, @lv_run_plant, @lv_run_storage_location,
            @lv_run_batch, @lv_run_unit, @lv_run_status)
      WHERE mandt = @sy-mandt
        AND run_id = @iv_run_id.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Allocation snapshot run was not found' ).
    ENDIF.
    IF lv_run_material <> iv_material
        OR lv_run_plant <> iv_plant
        OR lv_run_storage_location <> iv_storage_location
        OR lv_run_batch <> iv_batch
        OR lv_run_unit <> iv_unit.
      raise_error( iv_message = 'Allocation snapshot run scope is inconsistent' ).
    ENDIF.
    IF lv_run_status <> 'R'
        AND lv_run_status <> 'S'
        AND lv_run_status <> 'P'
        AND lv_run_status <> 'E'.
      raise_error( iv_message = 'Allocation snapshot run status is invalid' ).
    ENDIF.
    IF iv_require_running = abap_true
        AND lv_run_status <> 'R'.
      raise_error( iv_message = 'Allocation snapshot run is not active' ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
