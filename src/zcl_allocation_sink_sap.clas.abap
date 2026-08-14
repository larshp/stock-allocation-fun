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
        iv_run_id                TYPE zif_stock_allocation=>ty_run_id
        iv_material              TYPE zif_stock_allocation=>ty_material
        iv_plant                 TYPE zif_stock_allocation=>ty_plant
        iv_storage_location      TYPE zif_stock_allocation=>ty_storage_location
        iv_batch                 TYPE zif_stock_allocation=>ty_batch
        iv_unit                  TYPE zif_stock_allocation=>ty_unit
        iv_strategy              TYPE zif_allocation_audit=>ty_strategy OPTIONAL
        iv_snapshot_date_from    TYPE d OPTIONAL
        iv_snapshot_date_to      TYPE d OPTIONAL
        iv_snapshot_date_present TYPE abap_bool OPTIONAL
        iv_require_running       TYPE abap_bool OPTIONAL
      RAISING
        zcx_stock_allocation.
    METHODS validate_date
      IMPORTING
        iv_date    TYPE d
        iv_message TYPE zif_allocation_audit=>ty_message
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
        status_rank            TYPE i,
        coverage               TYPE zif_allocation_audit=>ty_coverage,
        shortage_pct           TYPE zif_allocation_audit=>ty_coverage,
        demand_count           TYPE i,
        duration_seconds       TYPE i,
        shortage               TYPE zif_stock_allocation=>ty_quantity,
        deadline_age_available TYPE abap_bool,
        deadline_age_days      TYPE i,
        deadline_date          TYPE d,
        allocation_run_id      TYPE zif_stock_allocation=>ty_run_id,
        requested_on           TYPE d,
        allocation_unit        TYPE zif_stock_allocation=>ty_unit,
        priority               TYPE zif_stock_allocation=>ty_priority,
        order_id               TYPE zif_stock_allocation=>ty_order_id,
        demand                 TYPE zif_stock_allocation=>ty_demand,
      END OF ty_coverage_line.
    TYPES:
      BEGIN OF ty_strategy_run,
        run_id            TYPE zif_stock_allocation=>ty_run_id,
        strategy          TYPE c LENGTH 1,
        preview           TYPE abap_bool,
        movement_type     TYPE zif_stock_allocation=>ty_movement_type,
        min_shelf_life    TYPE i,
        safety_stock      TYPE zif_stock_allocation=>ty_quantity,
        demand_count      TYPE i,
        available         TYPE zif_stock_allocation=>ty_quantity,
        status            TYPE zif_allocation_audit=>ty_run_status,
        message           TYPE zif_allocation_audit=>ty_message,
        start_date        TYPE d,
        start_time        TYPE t,
        finish_date       TYPE d,
        finish_time       TYPE t,
        requested_on_from TYPE d,
        requested_on_to   TYPE d,
      END OF ty_strategy_run.
    TYPES:
      BEGIN OF ty_run_validation,
        run_id          TYPE zif_stock_allocation=>ty_run_id,
        allocation_unit TYPE zif_stock_allocation=>ty_unit,
        date_from       TYPE d,
        date_to         TYPE d,
        date_missing    TYPE abap_bool,
      END OF ty_run_validation.
    TYPES:
      BEGIN OF ty_unit_provenance,
        allocation_unit TYPE zif_stock_allocation=>ty_unit,
        run_id          TYPE zif_stock_allocation=>ty_run_id,
      END OF ty_unit_provenance.
    DATA lv_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_reservation_cutoff TYPE d.
    DATA lv_reservation_age_to_cutoff TYPE d.
    DATA lv_overdue_date TYPE d.
    DATA lv_run_deadline TYPE d.
    DATA lv_run_deadline_age_date TYPE d.
    DATA lv_run_deadline_age_days TYPE i.
    DATA lv_duration_seconds TYPE i.
    DATA lv_status_rank TYPE i.
    DATA lv_limit_start TYPE i.
    DATA lv_status TYPE zif_stock_allocation=>ty_allocation_status.
    DATA lv_run_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_preview_filter TYPE zif_allocation_audit=>ty_preview_filter.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_sales_document_type_filter
      TYPE zif_stock_allocation=>ty_sales_document_type.
    DATA lv_unit_filter TYPE zif_stock_allocation=>ty_unit.
    DATA lv_order_unit_filter TYPE zif_stock_allocation=>ty_unit.
    DATA lv_reservation_unit_filter TYPE zif_stock_allocation=>ty_unit.
    DATA lv_reservation_document_filter TYPE c LENGTH 10.
    DATA lt_coverage_filtered TYPE zif_stock_allocation=>tt_demands.
    DATA lt_strategy_runs TYPE SORTED TABLE OF ty_strategy_run
      WITH UNIQUE KEY run_id.
    DATA lt_run_validations TYPE SORTED TABLE OF ty_run_validation
      WITH UNIQUE KEY run_id allocation_unit.
    DATA ls_unit_provenance TYPE ty_unit_provenance.
    DATA lt_unit_provenance TYPE SORTED TABLE OF ty_unit_provenance
      WITH UNIQUE KEY allocation_unit.
    DATA lt_coverage_sorted TYPE STANDARD TABLE OF ty_coverage_line
      WITH EMPTY KEY.
    DATA lt_reservation_ids TYPE SORTED TABLE OF zif_stock_allocation=>ty_order_id
      WITH UNIQUE KEY table_line.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_strategy_run> TYPE ty_strategy_run.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Allocation snapshot scope is incomplete' ).
    ENDIF.
    lv_status = to_upper( iv_status ).
    lv_run_status = to_upper( iv_run_status ).
    lv_preview_filter = to_upper( iv_preview_filter ).
    lv_overdue_date = sy-datum.
    IF iv_overdue_date IS NOT INITIAL.
      lv_overdue_date = iv_overdue_date.
    ENDIF.
    lv_run_deadline_age_date = sy-datum.
    IF iv_run_deadline_age_date IS NOT INITIAL.
      lv_run_deadline_age_date = iv_run_deadline_age_date.
    ENDIF.
    validate_date(
      iv_date    = iv_overdue_date
      iv_message = 'Allocation result overdue date is invalid' ).
    validate_date(
      iv_date    = iv_run_deadline_age_date
      iv_message = 'Allocation result deadline age date is invalid' ).
    validate_date(
      iv_date    = iv_run_start_date_from
      iv_message = 'Allocation result audit start date range is invalid' ).
    validate_date(
      iv_date    = iv_run_start_date_to
      iv_message = 'Allocation result audit start date range is invalid' ).
    validate_date(
      iv_date    = iv_run_finish_date_from
      iv_message = 'Allocation result audit finish date range is invalid' ).
    validate_date(
      iv_date    = iv_run_finish_date_to
      iv_message = 'Allocation result audit finish date range is invalid' ).
    IF iv_run_finish_date_from IS NOT INITIAL
        AND iv_run_finish_date_to IS NOT INITIAL
        AND iv_run_finish_date_from > iv_run_finish_date_to.
      raise_error(
        iv_message = 'Allocation result audit finish date range is invalid' ).
    ENDIF.
    validate_date(
      iv_date    = iv_requested_on_from
      iv_message = 'Allocation result date range is invalid' ).
    validate_date(
      iv_date    = iv_requested_on_to
      iv_message = 'Allocation result date range is invalid' ).
    validate_date(
      iv_date    = iv_run_requested_on_from
      iv_message = 'Allocation result requested horizon range is invalid' ).
    validate_date(
      iv_date    = iv_run_requested_on_to
      iv_message = 'Allocation result requested horizon range is invalid' ).
    validate_date(
      iv_date    = iv_run_deadline_from
      iv_message = 'Allocation result requested deadline range is invalid' ).
    validate_date(
      iv_date    = iv_run_deadline_to
      iv_message = 'Allocation result requested deadline range is invalid' ).
    validate_date(
      iv_date    = iv_reservation_date_from
      iv_message = 'Allocation result reservation date range is invalid' ).
    validate_date(
      iv_date    = iv_reservation_date_to
      iv_message = 'Allocation result reservation date range is invalid' ).
    lv_strategy = to_upper( iv_strategy ).
    lv_sales_document_type_filter = to_upper( iv_sales_document_type ).
    lv_unit_filter = to_upper( iv_unit ).
    lv_order_unit_filter = to_upper( iv_order_unit ).
    lv_reservation_unit_filter = to_upper( iv_reservation_unit ).
    lv_reservation_document_filter = iv_reservation_id.
    IF iv_sales_document IS NOT INITIAL
        AND ( strlen( iv_sales_document )
              <> zif_stock_allocation=>c_sap_document_length
          OR iv_sales_document CN '0123456789'
          OR iv_sales_document = '0000000000' ).
      raise_error( iv_message = 'Allocation result sales document filter is invalid' ).
    ENDIF.
    IF iv_reservation_id IS NOT INITIAL
        AND ( strlen( iv_reservation_id )
              <> zif_stock_allocation=>c_sap_document_length
          OR iv_reservation_id CN '0123456789 '
          OR lv_reservation_document_filter CN '0123456789'
          OR lv_reservation_document_filter = '0000000000' ).
      raise_error(
        iv_message = 'Allocation result reservation document filter is invalid' ).
    ENDIF.
    IF iv_max_rows < 0.
      raise_error( iv_message = 'Allocation result row limit is invalid' ).
    ENDIF.
    IF iv_offset < 0.
      raise_error( iv_message = 'Allocation result row offset is invalid' ).
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
    IF iv_run_requested_on_from IS NOT INITIAL
        AND iv_run_requested_on_to IS NOT INITIAL
        AND iv_run_requested_on_from > iv_run_requested_on_to.
      raise_error(
        iv_message = 'Allocation result requested horizon range is invalid' ).
    ENDIF.
    IF iv_run_start_date_from IS NOT INITIAL
        AND iv_run_start_date_to IS NOT INITIAL
        AND iv_run_start_date_from > iv_run_start_date_to.
      raise_error(
        iv_message = 'Allocation result audit start date range is invalid' ).
    ENDIF.
    IF iv_run_demand_from IS NOT INITIAL
        AND iv_run_demand_from < 0
        OR iv_run_demand_to IS NOT INITIAL
        AND iv_run_demand_to < 0.
      raise_error(
        iv_message = 'Allocation result demand-count range is invalid' ).
    ENDIF.
    IF iv_run_demand_from IS NOT INITIAL
        AND iv_run_demand_to IS NOT INITIAL
        AND iv_run_demand_from > iv_run_demand_to.
      raise_error(
        iv_message = 'Allocation result demand-count range is invalid' ).
    ENDIF.
    IF ( iv_run_available_from IS NOT INITIAL
          AND iv_run_available_from < 0 )
        OR ( iv_run_available_to IS NOT INITIAL
          AND iv_run_available_to < 0 ).
      raise_error(
        iv_message = 'Allocation result available-stock range is invalid' ).
    ENDIF.
    IF iv_run_available_from IS NOT INITIAL
        AND iv_run_available_to IS NOT INITIAL
        AND iv_run_available_from > iv_run_available_to.
      raise_error(
        iv_message = 'Allocation result available-stock range is invalid' ).
    ENDIF.
    IF ( iv_run_duration_from IS NOT INITIAL
          AND iv_run_duration_from < 0 )
        OR ( iv_run_duration_to IS NOT INITIAL
          AND iv_run_duration_to < 0 ).
      raise_error(
        iv_message = 'Allocation result audit-duration range is invalid' ).
    ENDIF.
    IF iv_run_duration_from IS NOT INITIAL
        AND iv_run_duration_to IS NOT INITIAL
        AND iv_run_duration_from > iv_run_duration_to.
      raise_error(
        iv_message = 'Allocation result audit-duration range is invalid' ).
    ENDIF.
    IF iv_run_deadline_from IS NOT INITIAL
        AND iv_run_deadline_to IS NOT INITIAL
        AND iv_run_deadline_from > iv_run_deadline_to.
      raise_error(
        iv_message = 'Allocation result requested deadline range is invalid' ).
    ENDIF.
    IF iv_run_deadline_age_from IS NOT INITIAL
        AND iv_run_deadline_age_to IS NOT INITIAL
        AND iv_run_deadline_age_from > iv_run_deadline_age_to.
      raise_error(
        iv_message = 'Allocation result deadline age range is invalid' ).
    ENDIF.
    IF iv_run_deadline_age_date IS NOT INITIAL
        AND iv_run_deadline_age_from IS INITIAL
        AND iv_run_deadline_age_to IS INITIAL.
      raise_error(
        iv_message = 'Allocation result deadline age date requires an age range' ).
    ENDIF.
    IF iv_reservation_date_from IS NOT INITIAL
        AND iv_reservation_date_to IS NOT INITIAL
        AND iv_reservation_date_from > iv_reservation_date_to.
      raise_error(
        iv_message = 'Allocation result reservation date range is invalid' ).
    ENDIF.
    IF iv_reservation_age_from < 0.
      raise_error(
        iv_message = 'Allocation result reservation age is invalid' ).
    ENDIF.
    IF iv_reservation_age_to < 0.
      raise_error(
        iv_message = 'Allocation result reservation age is invalid' ).
    ENDIF.
    IF iv_reservation_age_from IS NOT INITIAL
        AND iv_reservation_age_to IS NOT INITIAL
        AND iv_reservation_age_from > iv_reservation_age_to.
      raise_error(
        iv_message = 'Allocation result reservation age range is invalid' ).
    ENDIF.
    IF ( iv_priority_from IS NOT INITIAL
          AND ( iv_priority_from < 0
            OR iv_priority_from > zif_stock_allocation=>c_max_priority ) )
        OR ( iv_priority_to IS NOT INITIAL
          AND ( iv_priority_to < 0
            OR iv_priority_to > zif_stock_allocation=>c_max_priority ) ).
      raise_error( iv_message = 'Allocation result priority range is invalid' ).
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
    IF ( iv_shortage_pct_from IS NOT INITIAL
          AND ( iv_shortage_pct_from < 0 OR iv_shortage_pct_from > 100 ) )
        OR ( iv_shortage_pct_to IS NOT INITIAL
          AND ( iv_shortage_pct_to < 0 OR iv_shortage_pct_to > 100 ) ).
      raise_error(
        iv_message = 'Allocation result shortage percentage range is invalid' ).
    ENDIF.
    IF iv_shortage_pct_from IS NOT INITIAL
        AND iv_shortage_pct_to IS NOT INITIAL
        AND iv_shortage_pct_from > iv_shortage_pct_to.
      raise_error(
        iv_message = 'Allocation result shortage percentage range is invalid' ).
    ENDIF.
    IF lv_status IS NOT INITIAL
        AND lv_status <> 'F'
        AND lv_status <> 'P'
        AND lv_status <> 'U'.
      raise_error( iv_message = 'Allocation snapshot status is invalid' ).
    ENDIF.
    IF lv_run_status IS NOT INITIAL
        AND lv_run_status <> 'R'
        AND lv_run_status <> 'S'
        AND lv_run_status <> 'P'
        AND lv_run_status <> 'E'.
      raise_error( iv_message = 'Allocation audit status is invalid' ).
    ENDIF.
    IF lv_preview_filter IS NOT INITIAL
        AND lv_preview_filter <> 'P'
        AND lv_preview_filter <> 'O'.
      raise_error( iv_message = 'Allocation audit preview filter is invalid' ).
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
      raise_error( iv_message = 'Allocation snapshot strategy is invalid' ).
    ENDIF.
    IF lv_strategy IS NOT INITIAL
        AND iv_legacy_strategy = abap_true.
      raise_error(
        iv_message = 'Allocation result strategy filters conflict' ).
    ENDIF.
    IF ( iv_allocation_movement_type IS NOT INITIAL
          AND ( strlen( iv_allocation_movement_type )
                <> zif_stock_allocation=>c_movement_type_length
            OR iv_allocation_movement_type CN '0123456789'
            OR iv_allocation_movement_type = zif_stock_allocation=>c_zero_movement_type ) )
        OR ( iv_movement_type IS NOT INITIAL
          AND ( strlen( iv_movement_type )
                <> zif_stock_allocation=>c_movement_type_length
            OR iv_movement_type CN '0123456789'
            OR iv_movement_type = zif_stock_allocation=>c_zero_movement_type ) ).
      raise_error( iv_message = 'Allocation result movement type is invalid' ).
    ENDIF.
    IF iv_min_shelf_life < 0.
      raise_error(
        iv_message = 'Allocation result minimum shelf-life is invalid' ).
    ENDIF.
    IF iv_safety_filter = abap_true
        AND ( iv_safety_from < 0 OR iv_safety_to < 0
          OR iv_safety_from > iv_safety_to ).
      raise_error(
        iv_message = 'Allocation result safety-stock range is invalid' ).
    ENDIF.
    IF iv_safety_filter = abap_false
        AND ( iv_safety_from IS NOT INITIAL
          OR iv_safety_to IS NOT INITIAL ).
      raise_error(
        iv_message = 'Allocation result safety-stock filter switch is required' ).
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
    IF iv_run_id IS INITIAL.
      SELECT run_id AS allocation_run_id,
             allocation_unit,
             sales_document, sales_document_type, sales_item, schedule_line, order_unit,
             requested_on, order_id, priority,
             requested, allocated, shortage, allocation_status,
             reservation_id,
             reservation_date, reservation_movement_type, reservation_unit
        FROM zstockalloc

        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch INTO CORRESPONDING FIELDS OF TABLE @rt_demands.
    ELSE.
      SELECT run_id AS allocation_run_id,
             allocation_unit,
             sales_document, sales_document_type, sales_item, schedule_line, order_unit,
             requested_on, order_id, priority,
             requested, allocated, shortage, allocation_status,
             reservation_id,
             reservation_date, reservation_movement_type, reservation_unit
        FROM zstockalloc

        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND run_id = @iv_run_id INTO CORRESPONDING FIELDS OF TABLE @rt_demands.
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rt_demands.
    ENDIF.
    LOOP AT rt_demands ASSIGNING <ls_demand>.
      <ls_demand>-allocation_status =
        to_upper( <ls_demand>-allocation_status ).
      <ls_demand>-sales_document_type =
        to_upper( <ls_demand>-sales_document_type ).
      <ls_demand>-allocation_unit =
        to_upper( <ls_demand>-allocation_unit ).
      <ls_demand>-order_unit = to_upper( <ls_demand>-order_unit ).
      <ls_demand>-reservation_unit =
        to_upper( <ls_demand>-reservation_unit ).
    ENDLOOP.
    IF lv_unit_filter IS NOT INITIAL.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        IF to_upper( <ls_demand>-allocation_unit ) <> lv_unit_filter.
          DELETE rt_demands.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_run_id IS NOT INITIAL.
      DELETE rt_demands WHERE allocation_run_id <> iv_run_id.
    ENDIF.
    IF iv_run_id_contains IS NOT INITIAL.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        IF to_upper( <ls_demand>-allocation_run_id )
            NS to_upper( iv_run_id_contains ).
          DELETE rt_demands.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF lines( rt_demands ) > 0.
      IF lv_strategy IS NOT INITIAL.
           SELECT run_id, strategy, preview, movement_type, min_shelf_life, safety_stock,
               demand_count,
               available,
               status, message,
               start_date, start_time, finish_date, finish_time,
               requested_on_from, requested_on_to
          FROM zstockalloc_run

          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch INTO TABLE @lt_strategy_runs.
      ELSEIF iv_legacy_strategy = abap_true.
           SELECT run_id, strategy, preview, movement_type, min_shelf_life, safety_stock,
               demand_count,
               available,
               status, message,
               start_date, start_time, finish_date, finish_time,
               requested_on_from, requested_on_to
          FROM zstockalloc_run

          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND strategy = @space INTO TABLE @lt_strategy_runs.
      ELSE.
           SELECT run_id, strategy, preview, movement_type, min_shelf_life, safety_stock,
               demand_count,
               available,
               status, message,
               start_date, start_time, finish_date, finish_time,
               requested_on_from, requested_on_to
          FROM zstockalloc_run

          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch INTO TABLE @lt_strategy_runs.
      ENDIF.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        READ TABLE lt_strategy_runs ASSIGNING <ls_strategy_run>
          WITH TABLE KEY run_id = <ls_demand>-allocation_run_id.
        IF sy-subrc <> 0.
           IF lv_strategy IS NOT INITIAL
              OR iv_legacy_strategy = abap_true
              OR iv_run_status IS NOT INITIAL
              OR iv_preview_filter IS NOT INITIAL
              OR iv_run_message_contains IS NOT INITIAL
              OR iv_run_message_only = abap_true
              OR iv_allocation_movement_type IS NOT INITIAL
              OR iv_min_shelf_life IS NOT INITIAL
              OR iv_safety_filter = abap_true
              OR iv_run_demand_from IS NOT INITIAL
              OR iv_run_demand_to IS NOT INITIAL
              OR iv_run_available_from IS NOT INITIAL
              OR iv_run_available_to IS NOT INITIAL
              OR iv_run_duration_from IS NOT INITIAL
              OR iv_run_duration_to IS NOT INITIAL
              OR iv_deadline_only = abap_true
              OR iv_run_requested_on_from IS NOT INITIAL
              OR iv_run_requested_on_to IS NOT INITIAL
              OR iv_run_deadline_from IS NOT INITIAL
              OR iv_run_deadline_to IS NOT INITIAL
              OR iv_run_deadline_age_from IS NOT INITIAL
              OR iv_run_deadline_age_to IS NOT INITIAL
              OR iv_run_deadline_age_date IS NOT INITIAL
              OR iv_run_start_date_from IS NOT INITIAL
              OR iv_run_start_date_to IS NOT INITIAL
              OR iv_run_finish_date_from IS NOT INITIAL
              OR iv_run_finish_date_to IS NOT INITIAL.
            DELETE rt_demands.
          ENDIF.
        ELSE.
           <ls_strategy_run>-strategy =
             to_upper( <ls_strategy_run>-strategy ).
           <ls_strategy_run>-status =
             to_upper( <ls_strategy_run>-status ).
           IF <ls_strategy_run>-status <> 'R'
               AND <ls_strategy_run>-status <> 'S'
               AND <ls_strategy_run>-status <> 'P'
               AND <ls_strategy_run>-status <> 'E'.
             raise_error(
               iv_message = 'Allocation snapshot run status is invalid' ).
           ENDIF.
           IF <ls_strategy_run>-start_date IS INITIAL
               OR <ls_strategy_run>-start_time IS INITIAL
               OR zcl_allocation_date_sap=>is_valid_or_initial(
                 <ls_strategy_run>-start_date ) <> abap_true
               OR zcl_allocation_time_sap=>is_valid_or_initial(
                 <ls_strategy_run>-start_time ) <> abap_true
               OR zcl_allocation_date_sap=>is_valid_or_initial(
                 <ls_strategy_run>-finish_date ) <> abap_true
               OR zcl_allocation_time_sap=>is_valid_or_initial(
                 <ls_strategy_run>-finish_time ) <> abap_true
               OR ( <ls_strategy_run>-finish_date IS INITIAL
                 AND <ls_strategy_run>-finish_time IS NOT INITIAL )
               OR ( <ls_strategy_run>-finish_date IS NOT INITIAL
                 AND <ls_strategy_run>-finish_time IS INITIAL )
               OR ( <ls_strategy_run>-status <> 'R'
                 AND ( <ls_strategy_run>-finish_date IS INITIAL
                   OR <ls_strategy_run>-finish_time IS INITIAL ) )
               OR ( <ls_strategy_run>-finish_date IS NOT INITIAL
                 AND ( <ls_strategy_run>-finish_date
                       < <ls_strategy_run>-start_date
                   OR ( <ls_strategy_run>-finish_date
                         = <ls_strategy_run>-start_date
                     AND <ls_strategy_run>-finish_time
                         < <ls_strategy_run>-start_time ) ) )
               OR ( <ls_strategy_run>-requested_on_from IS NOT INITIAL
                 AND zcl_allocation_date_sap=>is_valid_or_initial(
                   <ls_strategy_run>-requested_on_from ) <> abap_true )
               OR ( <ls_strategy_run>-requested_on_to IS NOT INITIAL
                 AND zcl_allocation_date_sap=>is_valid_or_initial(
                   <ls_strategy_run>-requested_on_to ) <> abap_true )
               OR ( <ls_strategy_run>-requested_on_from IS NOT INITIAL
                 AND <ls_strategy_run>-requested_on_to IS NOT INITIAL
                 AND <ls_strategy_run>-requested_on_from
                   > <ls_strategy_run>-requested_on_to ).
             raise_error(
               iv_message = 'Allocation result audit run is invalid' ).
           ENDIF.
           IF iv_run_message_contains IS NOT INITIAL
               AND to_upper( <ls_strategy_run>-message )
                 NS to_upper( iv_run_message_contains ).
             DELETE rt_demands.
             CONTINUE.
           ENDIF.
           IF iv_run_message_only = abap_true
               AND <ls_strategy_run>-message IS INITIAL.
             DELETE rt_demands.
             CONTINUE.
           ENDIF.
           IF ( lv_strategy IS NOT INITIAL
                AND <ls_strategy_run>-strategy <> lv_strategy )
              OR ( iv_legacy_strategy = abap_true
                AND <ls_strategy_run>-strategy IS NOT INITIAL ).
             DELETE rt_demands.
             CONTINUE.
           ENDIF.
           IF lv_run_status IS NOT INITIAL
               AND <ls_strategy_run>-status <> lv_run_status.
             DELETE rt_demands.
           ELSEIF lv_preview_filter = 'P'
               AND <ls_strategy_run>-preview <> abap_true.
             DELETE rt_demands.
           ELSEIF lv_preview_filter = 'O'
               AND <ls_strategy_run>-preview = abap_true.
             DELETE rt_demands.
           ELSEIF ( iv_run_demand_from IS NOT INITIAL
                 AND <ls_strategy_run>-demand_count < iv_run_demand_from )
               OR ( iv_run_demand_to IS NOT INITIAL
                 AND <ls_strategy_run>-demand_count > iv_run_demand_to ).
             DELETE rt_demands.
           ELSEIF ( iv_run_available_from IS NOT INITIAL
                 AND <ls_strategy_run>-available < iv_run_available_from )
               OR ( iv_run_available_to IS NOT INITIAL
                 AND <ls_strategy_run>-available > iv_run_available_to ).
             DELETE rt_demands.
           ELSEIF iv_run_duration_from IS NOT INITIAL
               OR iv_run_duration_to IS NOT INITIAL.
             CLEAR lv_duration_seconds.
             IF <ls_strategy_run>-finish_date IS INITIAL.
               DELETE rt_demands.
             ELSE.
               cl_abap_tstmp=>td_subtract(
                 EXPORTING
                   date1    = <ls_strategy_run>-finish_date
                   time1    = <ls_strategy_run>-finish_time
                   date2    = <ls_strategy_run>-start_date
                   time2    = <ls_strategy_run>-start_time
                 IMPORTING
                   res_secs = lv_duration_seconds ).
               IF ( iv_run_duration_from IS NOT INITIAL
                     AND lv_duration_seconds < iv_run_duration_from )
                   OR ( iv_run_duration_to IS NOT INITIAL
                     AND lv_duration_seconds > iv_run_duration_to ).
                 DELETE rt_demands.
               ENDIF.
             ENDIF.
           ELSEIF iv_allocation_movement_type IS NOT INITIAL
              AND <ls_strategy_run>-movement_type
                <> iv_allocation_movement_type.
            DELETE rt_demands.
          ELSEIF iv_min_shelf_life IS NOT INITIAL
              AND <ls_strategy_run>-min_shelf_life <> iv_min_shelf_life.
            DELETE rt_demands.
          ELSEIF iv_safety_filter = abap_true
              AND ( <ls_strategy_run>-safety_stock < iv_safety_from
                OR <ls_strategy_run>-safety_stock > iv_safety_to ).
            DELETE rt_demands.
          ELSEIF iv_deadline_only = abap_true
              AND <ls_strategy_run>-requested_on_from IS INITIAL
              AND <ls_strategy_run>-requested_on_to IS INITIAL.
            DELETE rt_demands.
          ELSEIF ( iv_run_requested_on_from IS NOT INITIAL
                AND <ls_strategy_run>-requested_on_from
                  <> iv_run_requested_on_from )
              OR ( iv_run_requested_on_to IS NOT INITIAL
                AND <ls_strategy_run>-requested_on_to
                  <> iv_run_requested_on_to ).
            DELETE rt_demands.
          ELSEIF ( iv_run_start_date_from IS NOT INITIAL
                AND <ls_strategy_run>-start_date < iv_run_start_date_from )
              OR ( iv_run_start_date_to IS NOT INITIAL
                AND <ls_strategy_run>-start_date > iv_run_start_date_to ).
            DELETE rt_demands.
          ELSEIF ( iv_run_finish_date_from IS NOT INITIAL
                AND ( <ls_strategy_run>-finish_date IS INITIAL
                  OR <ls_strategy_run>-finish_date < iv_run_finish_date_from ) )
              OR ( iv_run_finish_date_to IS NOT INITIAL
                AND ( <ls_strategy_run>-finish_date IS INITIAL
                  OR <ls_strategy_run>-finish_date > iv_run_finish_date_to ) ).
            DELETE rt_demands.
          ELSE.
            IF <ls_strategy_run>-requested_on_to IS INITIAL.
              lv_run_deadline = <ls_strategy_run>-requested_on_from.
            ELSE.
              lv_run_deadline = <ls_strategy_run>-requested_on_to.
            ENDIF.
            IF ( iv_run_deadline_from IS NOT INITIAL
                  AND ( lv_run_deadline IS INITIAL
                    OR lv_run_deadline < iv_run_deadline_from ) )
                OR ( iv_run_deadline_to IS NOT INITIAL
                  AND ( lv_run_deadline IS INITIAL
                    OR lv_run_deadline > iv_run_deadline_to ) ).
              DELETE rt_demands.
            ELSEIF iv_run_deadline_age_from IS NOT INITIAL
                OR iv_run_deadline_age_to IS NOT INITIAL.
              IF lv_run_deadline IS INITIAL.
                DELETE rt_demands.
              ELSE.
                lv_run_deadline_age_days = lv_run_deadline_age_date
                  - lv_run_deadline.
                IF ( iv_run_deadline_age_from IS NOT INITIAL
                      AND lv_run_deadline_age_days
                        < iv_run_deadline_age_from )
                    OR ( iv_run_deadline_age_to IS NOT INITIAL
                      AND lv_run_deadline_age_days
                        > iv_run_deadline_age_to ).
                  DELETE rt_demands.
                ELSE.
                  <ls_demand>-allocation_strategy = <ls_strategy_run>-strategy.
                ENDIF.
              ENDIF.
            ELSE.
              <ls_demand>-allocation_strategy = <ls_strategy_run>-strategy.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF lv_status IS NOT INITIAL.
      DELETE rt_demands WHERE allocation_status <> lv_status.
    ENDIF.
    IF iv_sales_document IS NOT INITIAL.
      DELETE rt_demands WHERE sales_document <> iv_sales_document.
    ENDIF.
    IF lv_sales_document_type_filter IS NOT INITIAL.
      DELETE rt_demands
        WHERE sales_document_type <> lv_sales_document_type_filter.
    ENDIF.
    IF iv_sales_item IS NOT INITIAL.
      DELETE rt_demands WHERE sales_item <> iv_sales_item.
    ENDIF.
    IF iv_schedule_line IS NOT INITIAL.
      DELETE rt_demands WHERE schedule_line <> iv_schedule_line.
    ENDIF.
    IF lv_order_unit_filter IS NOT INITIAL.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        IF to_upper( <ls_demand>-order_unit ) <> lv_order_unit_filter.
          DELETE rt_demands.
        ENDIF.
      ENDLOOP.
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
    IF lv_reservation_unit_filter IS NOT INITIAL.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        IF to_upper( <ls_demand>-reservation_unit )
            <> lv_reservation_unit_filter.
          DELETE rt_demands.
        ENDIF.
      ENDLOOP.
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
      DELETE rt_demands WHERE requested_on >= lv_overdue_date.
    ENDIF.
    IF iv_reservation_date_from IS NOT INITIAL.
      DELETE rt_demands
        WHERE reservation_date < iv_reservation_date_from.
    ENDIF.
    IF iv_reservation_date_to IS NOT INITIAL.
      DELETE rt_demands
        WHERE reservation_date > iv_reservation_date_to.
    ENDIF.
    IF iv_reservation_age_from IS NOT INITIAL.
      lv_reservation_cutoff = sy-datum - iv_reservation_age_from.
      DELETE rt_demands WHERE reservation_date IS INITIAL.
      DELETE rt_demands WHERE reservation_date > lv_reservation_cutoff.
    ENDIF.
    IF iv_reservation_age_to IS NOT INITIAL.
      lv_reservation_age_to_cutoff = sy-datum - iv_reservation_age_to.
      DELETE rt_demands WHERE reservation_date IS INITIAL.
      DELETE rt_demands WHERE reservation_date < lv_reservation_age_to_cutoff.
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
      CLEAR lt_coverage_filtered.
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
    IF iv_shortage_pct_from IS NOT INITIAL
        OR iv_shortage_pct_to IS NOT INITIAL.
      CLEAR lt_coverage_filtered.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        IF <ls_demand>-requested > 0.
          lv_shortage_pct = <ls_demand>-shortage * 100
            / <ls_demand>-requested.
          IF ( iv_shortage_pct_from IS INITIAL
                OR lv_shortage_pct >= iv_shortage_pct_from )
              AND ( iv_shortage_pct_to IS INITIAL
                OR lv_shortage_pct <= iv_shortage_pct_to ).
            APPEND <ls_demand> TO lt_coverage_filtered.
          ENDIF.
        ENDIF.
      ENDLOOP.
      rt_demands = lt_coverage_filtered.
    ENDIF.
    IF iv_sort_by_priority = abap_true.
      SORT rt_demands BY allocation_unit priority order_id.
    ELSEIF iv_sort_by_status = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        CASE <ls_demand>-allocation_status.
          WHEN 'U'.
            lv_status_rank = 1.
          WHEN 'P'.
            lv_status_rank = 2.
          WHEN OTHERS.
            lv_status_rank = 3.
        ENDCASE.
        APPEND VALUE #(
          status_rank     = lv_status_rank
          shortage        = <ls_demand>-shortage
          requested_on    = <ls_demand>-requested_on
          allocation_unit = <ls_demand>-allocation_unit
          priority        = <ls_demand>-priority
          order_id        = <ls_demand>-order_id
          demand          = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY status_rank shortage DESCENDING requested_on
                                 allocation_unit priority order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_status_line>).
        APPEND <ls_status_line>-demand TO rt_demands.
      ENDLOOP.
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
    ELSEIF iv_sort_by_shrt_pct = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        CLEAR lv_shortage_pct.
        IF <ls_demand>-requested > 0.
          lv_shortage_pct = <ls_demand>-shortage * 100
            / <ls_demand>-requested.
        ENDIF.
        APPEND VALUE #(
          shortage_pct    = lv_shortage_pct
          shortage        = <ls_demand>-shortage
          requested_on    = <ls_demand>-requested_on
          allocation_unit = <ls_demand>-allocation_unit
          priority        = <ls_demand>-priority
          order_id        = <ls_demand>-order_id
          demand          = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY shortage_pct DESCENDING shortage DESCENDING
                                 requested_on allocation_unit priority order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_shortage_pct_line>).
        APPEND <ls_shortage_pct_line>-demand TO rt_demands.
      ENDLOOP.
    ELSEIF iv_sort_by_demand_count = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        READ TABLE lt_strategy_runs ASSIGNING <ls_strategy_run>
          WITH TABLE KEY run_id = <ls_demand>-allocation_run_id.
        APPEND VALUE #(
          demand_count      = COND i(
            WHEN sy-subrc = 0 THEN <ls_strategy_run>-demand_count
            ELSE 0 )
          shortage          = <ls_demand>-shortage
          requested_on      = <ls_demand>-requested_on
          allocation_unit   = <ls_demand>-allocation_unit
          priority          = <ls_demand>-priority
          allocation_run_id = <ls_demand>-allocation_run_id
          order_id          = <ls_demand>-order_id
          demand            = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY demand_count DESCENDING
                                 shortage DESCENDING requested_on
                                 allocation_unit priority allocation_run_id
                                 order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_demand_count_line>).
        APPEND <ls_demand_count_line>-demand TO rt_demands.
      ENDLOOP.
    ELSEIF iv_sort_by_deadline_age = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        CLEAR: lv_run_deadline, lv_run_deadline_age_days.
        READ TABLE lt_strategy_runs ASSIGNING <ls_strategy_run>
          WITH TABLE KEY run_id = <ls_demand>-allocation_run_id.
        IF sy-subrc = 0.
          IF <ls_strategy_run>-requested_on_to IS INITIAL.
            lv_run_deadline = <ls_strategy_run>-requested_on_from.
          ELSE.
            lv_run_deadline = <ls_strategy_run>-requested_on_to.
          ENDIF.
          IF lv_run_deadline IS NOT INITIAL.
            lv_run_deadline_age_days = lv_run_deadline_age_date
              - lv_run_deadline.
          ENDIF.
        ENDIF.
        APPEND VALUE #(
          deadline_age_available = xsdbool( lv_run_deadline IS NOT INITIAL )
          deadline_age_days      = lv_run_deadline_age_days
          deadline_date          = lv_run_deadline
          allocation_run_id      = <ls_demand>-allocation_run_id
          shortage               = <ls_demand>-shortage
          requested_on           = <ls_demand>-requested_on
          allocation_unit        = <ls_demand>-allocation_unit
          priority               = <ls_demand>-priority
          order_id               = <ls_demand>-order_id
          demand                 = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY deadline_age_available DESCENDING
                                 deadline_age_days DESCENDING
                                 deadline_date ASCENDING
                                 shortage DESCENDING
                                 requested_on ASCENDING allocation_unit
                                 priority allocation_run_id order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_deadline_age_line>).
        APPEND <ls_deadline_age_line>-demand TO rt_demands.
      ENDLOOP.
    ELSEIF iv_sort_by_requested_deadline = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        CLEAR lv_run_deadline.
        READ TABLE lt_strategy_runs ASSIGNING <ls_strategy_run>
          WITH TABLE KEY run_id = <ls_demand>-allocation_run_id.
        IF sy-subrc = 0.
          IF <ls_strategy_run>-requested_on_to IS INITIAL.
            lv_run_deadline = <ls_strategy_run>-requested_on_from.
          ELSE.
            lv_run_deadline = <ls_strategy_run>-requested_on_to.
          ENDIF.
        ENDIF.
        APPEND VALUE #(
          deadline_age_available = xsdbool( lv_run_deadline IS NOT INITIAL )
          deadline_date          = lv_run_deadline
          shortage               = <ls_demand>-shortage
          requested_on           = <ls_demand>-requested_on
          allocation_unit        = <ls_demand>-allocation_unit
          priority               = <ls_demand>-priority
          allocation_run_id      = <ls_demand>-allocation_run_id
          order_id               = <ls_demand>-order_id
          demand                 = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY deadline_age_available DESCENDING
                                 deadline_date ASCENDING
                                 shortage DESCENDING requested_on ASCENDING
                                 allocation_unit priority allocation_run_id
                                 order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_deadline_line>).
        APPEND <ls_deadline_line>-demand TO rt_demands.
      ENDLOOP.
    ELSEIF iv_sort_by_audit_duration = abap_true.
      LOOP AT rt_demands ASSIGNING <ls_demand>.
        CLEAR lv_duration_seconds.
        READ TABLE lt_strategy_runs ASSIGNING <ls_strategy_run>
          WITH TABLE KEY run_id = <ls_demand>-allocation_run_id.
        IF sy-subrc <> 0 OR <ls_strategy_run>-finish_date IS INITIAL.
          lv_duration_seconds = -1.
        ELSE.
          cl_abap_tstmp=>td_subtract(
            EXPORTING
              date1    = <ls_strategy_run>-finish_date
              time1    = <ls_strategy_run>-finish_time
              date2    = <ls_strategy_run>-start_date
              time2    = <ls_strategy_run>-start_time
            IMPORTING
              res_secs = lv_duration_seconds ).
        ENDIF.
        APPEND VALUE #(
          duration_seconds  = lv_duration_seconds
          shortage          = <ls_demand>-shortage
          requested_on      = <ls_demand>-requested_on
          allocation_unit   = <ls_demand>-allocation_unit
          priority          = <ls_demand>-priority
          allocation_run_id = <ls_demand>-allocation_run_id
          order_id          = <ls_demand>-order_id
          demand            = <ls_demand> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY duration_seconds DESCENDING
                                 shortage DESCENDING requested_on
                                 allocation_unit priority allocation_run_id
                                 order_id.
      CLEAR rt_demands.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_duration_line>).
        APPEND <ls_duration_line>-demand TO rt_demands.
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
      READ TABLE lt_run_validations ASSIGNING FIELD-SYMBOL(<ls_run_validation>)
        WITH TABLE KEY run_id = <ls_demand>-allocation_run_id
                       allocation_unit = <ls_demand>-allocation_unit.
      IF sy-subrc <> 0.
        INSERT VALUE #(
          run_id          = <ls_demand>-allocation_run_id
          allocation_unit = <ls_demand>-allocation_unit
          date_from       = <ls_demand>-requested_on
          date_to         = <ls_demand>-requested_on
          date_missing    = xsdbool( <ls_demand>-requested_on IS INITIAL ) )
          INTO TABLE lt_run_validations.
      ELSEIF <ls_demand>-requested_on IS INITIAL.
        <ls_run_validation>-date_missing = abap_true.
        CLEAR: <ls_run_validation>-date_from,
               <ls_run_validation>-date_to.
      ELSEIF <ls_run_validation>-date_missing = abap_false.
        IF <ls_run_validation>-date_from IS INITIAL
            OR <ls_demand>-requested_on < <ls_run_validation>-date_from.
          <ls_run_validation>-date_from = <ls_demand>-requested_on.
        ENDIF.
        IF <ls_run_validation>-date_to IS INITIAL
            OR <ls_demand>-requested_on > <ls_run_validation>-date_to.
          <ls_run_validation>-date_to = <ls_demand>-requested_on.
        ENDIF.
      ENDIF.
    ENDLOOP.
    LOOP AT lt_run_validations ASSIGNING <ls_run_validation>.
      validate_run_reference(
        iv_run_id                = <ls_run_validation>-run_id
        iv_material              = iv_material
        iv_plant                 = iv_plant
        iv_storage_location      = iv_storage_location
        iv_batch                 = iv_batch
        iv_unit                  = <ls_run_validation>-allocation_unit
        iv_snapshot_date_from    = <ls_run_validation>-date_from
        iv_snapshot_date_to      = <ls_run_validation>-date_to
        iv_snapshot_date_present = abap_true ).
    ENDLOOP.
    LOOP AT rt_demands ASSIGNING <ls_demand>.
      READ TABLE lt_unit_provenance INTO ls_unit_provenance
        WITH TABLE KEY allocation_unit = <ls_demand>-allocation_unit.
      IF sy-subrc <> 0.
        ls_unit_provenance-allocation_unit =
          <ls_demand>-allocation_unit.
        ls_unit_provenance-run_id = <ls_demand>-allocation_run_id.
        INSERT ls_unit_provenance INTO TABLE lt_unit_provenance.
      ELSEIF ls_unit_provenance-run_id <> <ls_demand>-allocation_run_id.
        raise_error( iv_message = 'Allocation snapshot provenance is inconsistent' ).
      ENDIF.
      IF <ls_demand>-allocated > 0.
        INSERT <ls_demand>-reservation_id INTO TABLE lt_reservation_ids.
        IF sy-subrc <> 0.
          raise_error( iv_message = 'Allocation snapshot reservation correlation is duplicated' ).
        ENDIF.
      ENDIF.
    ENDLOOP.
    ev_total_rows = lines( rt_demands ).
    IF iv_offset > 0.
      IF iv_offset >= lines( rt_demands ).
        CLEAR rt_demands.
      ELSE.
        DELETE rt_demands FROM 1 TO iv_offset.
      ENDIF.
    ENDIF.
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
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_requested_on_min TYPE d.
    DATA lv_requested_on_max TYPE d.
    DATA lv_requested_on_missing TYPE abap_bool.
    DATA ls_demand TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    lv_unit = to_upper( iv_unit ).
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_run_id IS INITIAL
        OR lv_unit IS INITIAL.
      raise_error( iv_message = 'Allocation snapshot input is incomplete' ).
    ENDIF.
    LOOP AT it_demands ASSIGNING <ls_demand>.
      ls_demand = <ls_demand>.
      ls_demand-allocation_strategy = to_upper( ls_demand-allocation_strategy ).
      ls_demand-allocation_status = to_upper( ls_demand-allocation_status ).
      ls_demand-sales_document_type =
        to_upper( ls_demand-sales_document_type ).
      ls_demand-allocation_unit = to_upper( ls_demand-allocation_unit ).
      ls_demand-order_unit = to_upper( ls_demand-order_unit ).
      ls_demand-reservation_unit = to_upper( ls_demand-reservation_unit ).
      IF ls_demand-allocation_unit IS NOT INITIAL
          AND ls_demand-allocation_unit <> lv_unit.
        raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
      ENDIF.
      IF ls_demand-allocation_run_id IS NOT INITIAL
          AND ls_demand-allocation_run_id <> iv_run_id.
        raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
      ENDIF.
      IF ls_demand-allocation_strategy IS NOT INITIAL.
        IF lv_strategy IS INITIAL.
          lv_strategy = ls_demand-allocation_strategy.
        ELSEIF lv_strategy <> ls_demand-allocation_strategy.
          raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
        ENDIF.
      ENDIF.
      IF ls_demand-requested_on IS INITIAL.
        lv_requested_on_missing = abap_true.
        CLEAR: lv_requested_on_min, lv_requested_on_max.
      ELSEIF lv_requested_on_missing = abap_false.
        IF lv_requested_on_min IS INITIAL
            OR ls_demand-requested_on < lv_requested_on_min.
          lv_requested_on_min = ls_demand-requested_on.
        ENDIF.
        IF lv_requested_on_max IS INITIAL
            OR ls_demand-requested_on > lv_requested_on_max.
          lv_requested_on_max = ls_demand-requested_on.
        ENDIF.
      ENDIF.
      ls_demand-allocation_unit = lv_unit.
      ls_demand-allocation_run_id = iv_run_id.
      validate_demand( is_demand = ls_demand ).
      INSERT ls_demand-order_id INTO TABLE lt_order_ids.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Allocation snapshot contains duplicate demand keys' ).
      ENDIF.
      IF ls_demand-allocated > 0.
        INSERT ls_demand-reservation_id INTO TABLE lt_reservation_ids.
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
      ls_allocation-allocation_unit = lv_unit.
      ls_allocation-sales_document = ls_demand-sales_document.
      ls_allocation-sales_document_type = ls_demand-sales_document_type.
      ls_allocation-sales_item = ls_demand-sales_item.
      ls_allocation-schedule_line = ls_demand-schedule_line.
      ls_allocation-order_unit = ls_demand-order_unit.
      ls_allocation-requested_on = ls_demand-requested_on.
      ls_allocation-order_id = ls_demand-order_id.
      ls_allocation-priority = ls_demand-priority.
      ls_allocation-requested = ls_demand-requested.
      ls_allocation-allocated = ls_demand-allocated.
      ls_allocation-shortage = ls_demand-shortage.
      ls_allocation-allocation_status = ls_demand-allocation_status.
      ls_allocation-reservation_id = ls_demand-reservation_id.
      ls_allocation-reservation_date = ls_demand-reservation_date.
      ls_allocation-reservation_movement_type =
        ls_demand-reservation_movement_type.
      ls_allocation-reservation_unit = ls_demand-reservation_unit.
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
      iv_run_id                = iv_run_id
      iv_material              = iv_material
      iv_plant                 = iv_plant
      iv_storage_location      = iv_storage_location
      iv_batch                 = iv_batch
      iv_unit                  = lv_unit
      iv_strategy              = lv_strategy
      iv_snapshot_date_from    = lv_requested_on_min
      iv_snapshot_date_to      = lv_requested_on_max
      iv_snapshot_date_present = xsdbool( lines( lt_allocations ) > 0 )
      iv_require_running       = abap_true ).

    DELETE FROM zstockalloc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND batch = @iv_batch
        AND allocation_unit = @lv_unit.
    IF lt_allocations IS NOT INITIAL.
      MODIFY zstockalloc FROM TABLE @lt_allocations.
      IF sy-subrc <> 0.
        raise_error( iv_message = 'Allocation snapshot persistence failed' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_demand.
    DATA lv_reservation_document TYPE c LENGTH 10.

    lv_reservation_document = is_demand-reservation_id.
    IF is_demand-allocation_unit IS INITIAL
        OR is_demand-order_id IS INITIAL
        OR ( is_demand-sales_document IS NOT INITIAL
          AND strlen( is_demand-sales_document )
              <> zif_stock_allocation=>c_sap_document_length )
        OR ( is_demand-sales_document IS NOT INITIAL
          AND is_demand-sales_document CN '0123456789' )
        OR is_demand-sales_document = '0000000000'
        OR ( is_demand-reservation_id IS NOT INITIAL
          AND strlen( is_demand-reservation_id )
              <> zif_stock_allocation=>c_sap_document_length )
        OR ( is_demand-reservation_id IS NOT INITIAL
          AND is_demand-reservation_id CN '0123456789 ' )
        OR ( is_demand-reservation_id IS NOT INITIAL
          AND ( lv_reservation_document CN '0123456789'
            OR lv_reservation_document = '0000000000' ) )
        OR ( ( is_demand-sales_document IS NOT INITIAL
            OR is_demand-sales_document_type IS NOT INITIAL
            OR is_demand-sales_item IS NOT INITIAL
            OR is_demand-schedule_line IS NOT INITIAL )
          AND ( is_demand-sales_document IS INITIAL
            OR is_demand-sales_document_type IS INITIAL
            OR is_demand-sales_item IS INITIAL
            OR is_demand-schedule_line IS INITIAL ) )
        OR ( iv_require_run_id = abap_true
          AND is_demand-allocation_run_id IS INITIAL )
        OR is_demand-priority < 0
        OR is_demand-priority > zif_stock_allocation=>c_max_priority
        OR is_demand-requested <= 0
        OR is_demand-allocated < 0
        OR is_demand-shortage < 0
        OR is_demand-allocated > is_demand-requested
        OR is_demand-shortage <> is_demand-requested
          - is_demand-allocated
        OR zcl_allocation_date_sap=>is_valid_or_initial(
          is_demand-requested_on ) <> abap_true
        OR zcl_allocation_date_sap=>is_valid_or_initial(
          is_demand-reservation_date ) <> abap_true.
      raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
    ENDIF.
    IF is_demand-allocation_status <> 'F'
        AND is_demand-allocation_status <> 'P'
        AND is_demand-allocation_status <> 'U'.
      raise_error( iv_message = 'Allocation snapshot demand is invalid' ).
    ENDIF.
    IF is_demand-reservation_movement_type IS NOT INITIAL
        AND ( strlen( is_demand-reservation_movement_type )
              <> zif_stock_allocation=>c_movement_type_length
          OR is_demand-reservation_movement_type CN '0123456789'
          OR is_demand-reservation_movement_type = zif_stock_allocation=>c_zero_movement_type ).
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
            OR is_demand-reservation_id = '0000000000'
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
    DATA lv_run_strategy TYPE zstockalloc_run-strategy.
    DATA lv_run_movement_type TYPE zstockalloc_run-movement_type.
    DATA lv_run_min_shelf_life TYPE zstockalloc_run-min_shelf_life.
    DATA lv_run_safety_stock TYPE zstockalloc_run-safety_stock.
    DATA lv_run_requested_on_from TYPE zstockalloc_run-requested_on_from.
    DATA lv_run_requested_on_to TYPE zstockalloc_run-requested_on_to.
    DATA lv_run_status TYPE zstockalloc_run-status.

    SELECT SINGLE matnr, werks, lgort, batch, unit, strategy,
                  movement_type, min_shelf_life, safety_stock,
                  requested_on_from, requested_on_to, status
      FROM zstockalloc_run
      WHERE run_id = @iv_run_id
        INTO ( @lv_run_material, @lv_run_plant, @lv_run_storage_location,
               @lv_run_batch, @lv_run_unit, @lv_run_strategy,
               @lv_run_movement_type, @lv_run_min_shelf_life,
               @lv_run_safety_stock,
               @lv_run_requested_on_from, @lv_run_requested_on_to,
               @lv_run_status ).
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Allocation snapshot run was not found' ).
    ENDIF.
    lv_run_unit = to_upper( lv_run_unit ).
    lv_run_strategy = to_upper( lv_run_strategy ).
    lv_run_status = to_upper( lv_run_status ).
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
    IF lv_run_strategy IS NOT INITIAL
        AND lv_run_strategy <> 'P'
        AND lv_run_strategy <> 'F'
        AND lv_run_strategy <> 'N'
        AND lv_run_strategy <> 'S'
        AND lv_run_strategy <> 'L'
        AND lv_run_strategy <> 'B'
        AND lv_run_strategy <> 'E'
        AND lv_run_strategy <> 'A'
        AND lv_run_strategy <> 'W'.
      raise_error( iv_message = 'Allocation snapshot run strategy is invalid' ).
    ENDIF.
    IF lv_run_movement_type IS NOT INITIAL
        AND ( strlen( lv_run_movement_type )
              <> zif_stock_allocation=>c_movement_type_length
          OR lv_run_movement_type CN '0123456789'
          OR lv_run_movement_type = zif_stock_allocation=>c_zero_movement_type ).
      raise_error(
        iv_message = 'Allocation snapshot run movement type is invalid' ).
    ENDIF.
    IF lv_run_min_shelf_life < 0 OR lv_run_safety_stock < 0.
      raise_error(
        iv_message = 'Allocation snapshot run policy is invalid' ).
    ENDIF.
    IF ( lv_run_requested_on_from IS NOT INITIAL
          AND zcl_allocation_date_sap=>is_valid_or_initial(
            lv_run_requested_on_from ) <> abap_true )
        OR ( lv_run_requested_on_to IS NOT INITIAL
          AND zcl_allocation_date_sap=>is_valid_or_initial(
            lv_run_requested_on_to ) <> abap_true )
        OR ( lv_run_requested_on_from IS NOT INITIAL
        AND lv_run_requested_on_to IS NOT INITIAL
        AND lv_run_requested_on_from > lv_run_requested_on_to ).
      raise_error(
        iv_message = 'Allocation snapshot run requested horizon is invalid' ).
    ENDIF.
    IF iv_strategy IS NOT INITIAL
        AND lv_run_strategy <> iv_strategy.
      raise_error( iv_message = 'Allocation snapshot run strategy is inconsistent' ).
    ENDIF.
    IF iv_snapshot_date_present = abap_true
        AND ( ( lv_run_requested_on_from IS NOT INITIAL
              AND ( iv_snapshot_date_from IS INITIAL
                OR iv_snapshot_date_from < lv_run_requested_on_from ) )
          OR ( lv_run_requested_on_to IS NOT INITIAL
              AND ( iv_snapshot_date_to IS INITIAL
                OR iv_snapshot_date_to > lv_run_requested_on_to ) ) ).
      raise_error( iv_message = 'Allocation snapshot requested date is inconsistent' ).
    ENDIF.
    IF iv_require_running = abap_true
        AND lv_run_status <> 'R'.
      raise_error( iv_message = 'Allocation snapshot run is not active' ).
    ENDIF.
  ENDMETHOD.

  METHOD validate_date.
    IF iv_date IS NOT INITIAL
        AND zcl_allocation_date_sap=>is_valid_or_initial(
          iv_date ) <> abap_true.
      raise_error( iv_message = iv_message ).
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
