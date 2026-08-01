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
      CREATE OBJECT mo_read_authority TYPE zcl_allocation_read_auth_sap.
    ENDIF.
    IF io_write_authority IS BOUND.
      mo_write_authority = io_write_authority.
    ELSE.
      CREATE OBJECT mo_write_authority TYPE zcl_allocation_write_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_sink~get_allocations.
    TYPES:
      BEGIN OF ty_coverage_line,
        coverage        TYPE zif_allocation_audit=>ty_coverage,
        shortage        TYPE zif_stock_allocation=>ty_quantity,
        requested_on    TYPE d,
        allocation_unit TYPE zif_stock_allocation=>ty_unit,
        priority        TYPE zif_stock_allocation=>ty_priority,
        order_id        TYPE zif_stock_allocation=>ty_order_id,
        demand          TYPE zif_stock_allocation=>ty_demand,
      END OF ty_coverage_line.
    DATA lv_run_id TYPE zif_stock_allocation=>ty_run_id.
    DATA lv_allocation_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_limit_start TYPE i.
    DATA lt_coverage_filtered TYPE zif_stock_allocation=>tt_demands.
    DATA lt_coverage_sorted TYPE STANDARD TABLE OF ty_coverage_line
      WITH EMPTY KEY.
    DATA lt_reservation_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Allocation snapshot scope is incomplete' ).
    ENDIF.
    IF iv_max_rows < 0.
      raise_error( iv_message = 'Allocation result row limit is invalid' ).
    ENDIF.
    IF iv_reserved_only = abap_true
        AND iv_unreserved_only = abap_true.
      raise_error(
        iv_message = 'Allocation result reservation filters conflict' ).
    ENDIF.
    IF iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to.
      raise_error( iv_message = 'Allocation result date range is invalid' ).
    ENDIF.
    IF iv_reservation_date_from IS NOT INITIAL
        AND iv_reservation_date_to IS NOT INITIAL
        AND iv_reservation_date_from > iv_reservation_date_to.
      raise_error(
        iv_message = 'Allocation result reservation date range is invalid' ).
    ENDIF.
    IF iv_priority_from IS NOT INITIAL
        AND iv_priority_to IS NOT INITIAL
        AND iv_priority_from > iv_priority_to.
      raise_error( iv_message = 'Allocation result priority range is invalid' ).
    ENDIF.
    IF ( iv_shortage_from IS NOT INITIAL AND iv_shortage_from < 0 )
        OR ( iv_shortage_to IS NOT INITIAL AND iv_shortage_to < 0 ).
      raise_error( iv_message = 'Allocation result shortage range is invalid' ).
    ENDIF.
    IF iv_shortage_from IS NOT INITIAL
        AND iv_shortage_to IS NOT INITIAL
        AND iv_shortage_from > iv_shortage_to.
      raise_error( iv_message = 'Allocation result shortage range is invalid' ).
    ENDIF.
    IF ( iv_requested_quantity_from IS NOT INITIAL
          AND iv_requested_quantity_from < 0 )
        OR ( iv_requested_quantity_to IS NOT INITIAL
          AND iv_requested_quantity_to < 0 ).
      raise_error(
        iv_message = 'Allocation result requested quantity range is invalid' ).
    ENDIF.
    IF iv_requested_quantity_from IS NOT INITIAL
        AND iv_requested_quantity_to IS NOT INITIAL
        AND iv_requested_quantity_from > iv_requested_quantity_to.
      raise_error(
        iv_message = 'Allocation result requested quantity range is invalid' ).
    ENDIF.
    IF ( iv_allocated_quantity_from IS NOT INITIAL
          AND iv_allocated_quantity_from < 0 )
        OR ( iv_allocated_quantity_to IS NOT INITIAL
          AND iv_allocated_quantity_to < 0 ).
      raise_error(
        iv_message = 'Allocation result allocated quantity range is invalid' ).
    ENDIF.
    IF iv_allocated_quantity_from IS NOT INITIAL
        AND iv_allocated_quantity_to IS NOT INITIAL
        AND iv_allocated_quantity_from > iv_allocated_quantity_to.
      raise_error(
        iv_message = 'Allocation result allocated quantity range is invalid' ).
    ENDIF.
    IF ( iv_coverage_from IS NOT INITIAL
          AND ( iv_coverage_from < 0 OR iv_coverage_from > 100 ) )
        OR ( iv_coverage_to IS NOT INITIAL
          AND ( iv_coverage_to < 0 OR iv_coverage_to > 100 ) ).
      raise_error(
        iv_message = 'Allocation result coverage range is invalid' ).
    ENDIF.
    IF iv_coverage_from IS NOT INITIAL
        AND iv_coverage_to IS NOT INITIAL
        AND iv_coverage_from > iv_coverage_to.
      raise_error(
        iv_message = 'Allocation result coverage range is invalid' ).
    ENDIF.
    IF iv_status IS NOT INITIAL
        AND iv_status <> 'F'
        AND iv_status <> 'P'
        AND iv_status <> 'U'.
      raise_error( iv_message = 'Allocation snapshot status is invalid' ).
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
           requested_on, order_id, priority,
           requested, allocated, shortage, allocation_status,
           reservation_id,
           reservation_date, reservation_movement_type, reservation_unit
      FROM zstockalloc
      INTO CORRESPONDING FIELDS OF TABLE @rt_demands
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND batch = @iv_batch.
    IF sy-subrc <> 0.
      CLEAR rt_demands.
    ENDIF.
    IF iv_unit IS NOT INITIAL.
      DELETE rt_demands WHERE allocation_unit <> iv_unit.
    ENDIF.
    IF iv_run_id IS NOT INITIAL.
      DELETE rt_demands WHERE allocation_run_id <> iv_run_id.
    ENDIF.
    IF iv_status IS NOT INITIAL.
      DELETE rt_demands WHERE allocation_status <> iv_status.
    ENDIF.
    IF iv_sales_document IS NOT INITIAL.
      DELETE rt_demands WHERE sales_document <> iv_sales_document.
    ENDIF.
    IF iv_sales_document_type IS NOT INITIAL.
      DELETE rt_demands
        WHERE sales_document_type <> iv_sales_document_type.
    ENDIF.
    IF iv_sales_item IS NOT INITIAL.
      DELETE rt_demands WHERE sales_item <> iv_sales_item.
    ENDIF.
    IF iv_schedule_line IS NOT INITIAL.
      DELETE rt_demands WHERE schedule_line <> iv_schedule_line.
    ENDIF.
    IF iv_order_unit IS NOT INITIAL.
      DELETE rt_demands WHERE order_unit <> iv_order_unit.
    ENDIF.
    IF iv_order_id IS NOT INITIAL.
      DELETE rt_demands WHERE order_id <> iv_order_id.
    ENDIF.
    IF iv_reservation_id IS NOT INITIAL.
      DELETE rt_demands WHERE reservation_id <> iv_reservation_id.
    ENDIF.
    IF iv_movement_type IS NOT INITIAL.
      DELETE rt_demands
        WHERE reservation_movement_type <> iv_movement_type.
    ENDIF.
    IF iv_reservation_unit IS NOT INITIAL.
      DELETE rt_demands WHERE reservation_unit <> iv_reservation_unit.
    ENDIF.
    IF iv_reserved_only = abap_true.
      DELETE rt_demands WHERE reservation_id IS INITIAL.
    ENDIF.
    IF iv_unreserved_only = abap_true.
      DELETE rt_demands WHERE reservation_id IS NOT INITIAL.
    ENDIF.
    IF iv_shortage_only = abap_true.
      DELETE rt_demands WHERE shortage <= 0.
    ENDIF.
    IF iv_overdue_only = abap_true.
      DELETE rt_demands WHERE requested_on IS INITIAL.
      DELETE rt_demands WHERE requested_on >= sy-datum.
    ENDIF.
    IF iv_reservation_date_from IS NOT INITIAL.
      DELETE rt_demands
        WHERE reservation_date < iv_reservation_date_from.
    ENDIF.
    IF iv_reservation_date_to IS NOT INITIAL.
      DELETE rt_demands
        WHERE reservation_date > iv_reservation_date_to.
    ENDIF.
    IF iv_requested_on_from IS NOT INITIAL.
      DELETE rt_demands WHERE requested_on < iv_requested_on_from.
    ENDIF.
    IF iv_requested_on_to IS NOT INITIAL.
      DELETE rt_demands WHERE requested_on > iv_requested_on_to.
    ENDIF.
    IF iv_priority_from IS NOT INITIAL.
      DELETE rt_demands WHERE priority < iv_priority_from.
    ENDIF.
    IF iv_priority_to IS NOT INITIAL.
      DELETE rt_demands WHERE priority > iv_priority_to.
    ENDIF.
    IF iv_shortage_from IS NOT INITIAL.
      DELETE rt_demands WHERE shortage < iv_shortage_from.
    ENDIF.
    IF iv_shortage_to IS NOT INITIAL.
      DELETE rt_demands WHERE shortage > iv_shortage_to.
    ENDIF.
    IF iv_requested_quantity_from IS NOT INITIAL.
      DELETE rt_demands WHERE requested < iv_requested_quantity_from.
    ENDIF.
    IF iv_requested_quantity_to IS NOT INITIAL.
      DELETE rt_demands WHERE requested > iv_requested_quantity_to.
    ENDIF.
    IF iv_allocated_quantity_from IS NOT INITIAL.
      DELETE rt_demands WHERE allocated < iv_allocated_quantity_from.
    ENDIF.
    IF iv_allocated_quantity_to IS NOT INITIAL.
      DELETE rt_demands WHERE allocated > iv_allocated_quantity_to.
    ENDIF.
    IF iv_coverage_from IS NOT INITIAL OR iv_coverage_to IS NOT INITIAL.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        IF <ls_demand>-requested > 0.
          lv_coverage = <ls_demand>-allocated * 100
            / <ls_demand>-requested.
          IF ( iv_coverage_from IS INITIAL
                OR lv_coverage >= iv_coverage_from )
              AND ( iv_coverage_to IS INITIAL
                OR lv_coverage <= iv_coverage_to ).
            APPEND <ls_demand> TO lt_coverage_filtered.
          ENDIF.
        ENDIF.
      ENDLOOP.
      rt_demands = lt_coverage_filtered.
    ENDIF.
    IF iv_sort_by_priority = abap_true.
      SORT rt_demands BY allocation_unit priority order_id.
    ELSEIF iv_sort_by_coverage = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        CLEAR lv_coverage.
        IF <ls_demand>-requested > 0.
          lv_coverage = <ls_demand>-allocated * 100
            / <ls_demand>-requested.
        ENDIF.
        APPEND VALUE #(
          coverage        = lv_coverage
          shortage        = <ls_demand>-shortage
          requested_on    = <ls_demand>-requested_on
          allocation_unit = <ls_demand>-allocation_unit
          priority        = <ls_demand>-priority
          order_id        = <ls_demand>-order_id
          demand          = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY coverage shortage DESCENDING requested_on
                                 allocation_unit priority order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_coverage_line>).
        APPEND <ls_coverage_line>-demand TO rt_demands.
      ENDLOOP.
    ELSEIF iv_sort_by_requested_quantity = abap_true.
      SORT rt_demands BY requested DESCENDING shortage DESCENDING requested_on
                         allocation_unit priority order_id.
    ELSEIF iv_sort_by_allocated_quantity = abap_true.
      SORT rt_demands BY allocated DESCENDING requested DESCENDING
                         shortage DESCENDING requested_on allocation_unit
                         priority order_id.
    ELSEIF iv_sort_by_requested_date = abap_true.
      SORT rt_demands BY requested_on allocation_unit priority order_id.
    ELSEIF iv_sort_by_reservation_date = abap_true.
      SORT rt_demands BY reservation_date allocation_unit priority order_id.
    ELSEIF iv_sort_by_shortage = abap_true.
      SORT rt_demands BY shortage DESCENDING requested_on
                         allocation_unit priority order_id.
    ELSE.
      SORT rt_demands BY allocation_unit order_id.
    ENDIF.
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
    IF iv_max_rows > 0 AND lines( rt_demands ) > iv_max_rows.
      lv_limit_start = iv_max_rows + 1.
      DELETE rt_demands FROM lv_limit_start.
    ENDIF.
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
      ls_allocation-priority = <ls_demand>-priority.
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
      WHERE matnr = @iv_material
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
      WHERE run_id = @iv_run_id.
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
