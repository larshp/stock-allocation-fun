CLASS zcl_allocation_audit_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_read_authority      TYPE REF TO zif_allocation_read_authority OPTIONAL
        io_write_authority     TYPE REF TO zif_allocation_write_authority OPTIONAL
        io_retention_authority TYPE REF TO zif_alloc_retention_auth OPTIONAL
        io_transaction         TYPE REF TO zif_allocation_transaction OPTIONAL.
    INTERFACES zif_allocation_audit.
  PRIVATE SECTION.
    DATA mo_read_authority TYPE REF TO zif_allocation_read_authority.
    DATA mo_write_authority TYPE REF TO zif_allocation_write_authority.
    DATA mo_retention_authority TYPE REF TO zif_alloc_retention_auth.
    DATA mo_transaction TYPE REF TO zif_allocation_transaction.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
    METHODS validate_run
      IMPORTING
        is_run TYPE zif_allocation_audit=>ty_run
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_allocation_audit_sap IMPLEMENTATION.
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
    IF io_retention_authority IS BOUND.
      mo_retention_authority = io_retention_authority.
    ELSE.
      CREATE OBJECT mo_retention_authority TYPE zcl_alloc_retention_auth_sap.
    ENDIF.
    IF io_transaction IS BOUND.
      mo_transaction = io_transaction.
    ELSE.
      CREATE OBJECT mo_transaction TYPE zcl_allocation_transaction_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_running_age.
    DATA lv_seconds TYPE i.
    DATA lv_now_date TYPE d.
    DATA lv_now_time TYPE t.

    CLEAR rs_age.
    lv_now_date = sy-datum.
    lv_now_time = sy-uzeit.
    IF iv_now_date IS NOT INITIAL.
      lv_now_date = iv_now_date.
    ENDIF.
    IF iv_now_time IS NOT INITIAL.
      lv_now_time = iv_now_time.
    ENDIF.
    IF to_upper( is_run-status ) <> 'R'
        OR is_run-finish_date IS NOT INITIAL
        OR is_run-start_date IS INITIAL
        OR is_run-start_time IS INITIAL.
      RETURN.
    ENDIF.

    cl_abap_tstmp=>td_subtract(
      EXPORTING
        date1    = lv_now_date
        time1    = lv_now_time
        date2    = is_run-start_date
        time2    = is_run-start_time
      IMPORTING
        res_secs = lv_seconds ).
    IF lv_seconds < 0.
      RETURN.
    ENDIF.

    rs_age-available = abap_true.
    rs_age-seconds = lv_seconds.
  ENDMETHOD.

  METHOD zif_allocation_audit~purge_runs_before.
    TYPES:
      BEGIN OF ty_purge_candidate,
        run_id            TYPE zif_allocation_audit=>ty_run_id,
        start_date        TYPE d,
        finish_date       TYPE d,
        movement_type     TYPE zif_stock_allocation=>ty_movement_type,
        min_shelf_life    TYPE i,
        unit              TYPE zif_stock_allocation=>ty_unit,
        requested_on_from TYPE d,
        requested_on_to   TYPE d,
        status            TYPE zif_allocation_audit=>ty_run_status,
        strategy          TYPE zif_allocation_audit=>ty_strategy,
        message           TYPE zif_allocation_audit=>ty_message,
      END OF ty_purge_candidate.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_overdue_date TYPE d.
    DATA lv_requested_deadline TYPE d.
    DATA lv_deadline_age_date TYPE d.
    DATA lv_deadline_age_days TYPE i.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Audit purge scope is incomplete' ).
    ENDIF.
    lv_status = to_upper( iv_status ).
    lv_strategy = to_upper( iv_strategy ).
    lv_unit = to_upper( iv_unit ).
    lv_overdue_date = sy-datum.
    IF iv_overdue_date IS NOT INITIAL.
      lv_overdue_date = iv_overdue_date.
    ENDIF.
    lv_deadline_age_date = sy-datum.
    IF iv_deadline_age_date IS NOT INITIAL.
      lv_deadline_age_date = iv_deadline_age_date.
    ENDIF.
    IF iv_movement_type IS NOT INITIAL
        AND iv_movement_type CN '0123456789'.
      raise_error( iv_message = 'Audit movement type is invalid' ).
    ENDIF.
    IF iv_before_date IS INITIAL.
      raise_error( iv_message = 'Audit purge date is required' ).
    ENDIF.
    IF iv_before_date > sy-datum.
      raise_error( iv_message = 'Audit purge date cannot be in the future' ).
    ENDIF.
    IF iv_start_date_from IS NOT INITIAL
        AND iv_start_date_from >= iv_before_date.
      raise_error(
        iv_message = 'Audit purge start date must be before the cutoff date' ).
    ENDIF.
    IF iv_finish_date_from IS NOT INITIAL
        AND iv_finish_date_to IS NOT INITIAL
        AND iv_finish_date_from > iv_finish_date_to.
      raise_error( iv_message = 'Audit purge finish date range is invalid' ).
    ENDIF.
    IF iv_min_shelf_life < 0.
      raise_error( iv_message = 'Audit purge minimum shelf-life filter is invalid' ).
    ENDIF.
    IF iv_overdue_date IS NOT INITIAL
        AND iv_overdue_only = abap_false.
      raise_error(
        iv_message = 'Audit overdue as-of date requires overdue-only filtering' ).
    ENDIF.
    IF iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to.
      raise_error( iv_message = 'Audit requested date range is invalid' ).
    ENDIF.
    IF iv_deadline_from IS NOT INITIAL
        AND iv_deadline_to IS NOT INITIAL
        AND iv_deadline_from > iv_deadline_to.
      raise_error( iv_message = 'Audit requested deadline range is invalid' ).
    ENDIF.
    IF iv_deadline_age_from IS NOT INITIAL
        AND iv_deadline_age_to IS NOT INITIAL
        AND iv_deadline_age_from > iv_deadline_age_to.
      raise_error( iv_message = 'Audit deadline age range is invalid' ).
    ENDIF.
    IF iv_deadline_age_date IS NOT INITIAL
        AND iv_deadline_age_from IS INITIAL
        AND iv_deadline_age_to IS INITIAL.
      raise_error(
        iv_message = 'Audit deadline age date requires an age range' ).
    ENDIF.
    IF lv_status IS NOT INITIAL
        AND lv_status <> 'S'
        AND lv_status <> 'P'
        AND lv_status <> 'E'.
      raise_error( iv_message = 'Audit purge status filter is invalid' ).
    ENDIF.
    IF lv_strategy IS NOT INITIAL
        AND lv_strategy <> 'P'
        AND lv_strategy <> 'F'
        AND lv_strategy <> 'N'
        AND lv_strategy <> 'S'
        AND lv_strategy <> 'L'
        AND lv_strategy <> 'B'.
      raise_error( iv_message = 'Audit strategy is invalid' ).
    ENDIF.
    IF iv_legacy_strategy = abap_true
        AND lv_strategy IS NOT INITIAL.
      raise_error( iv_message = 'Audit strategy filters conflict' ).
    ENDIF.
    IF mo_retention_authority IS BOUND.
      TRY.
          mo_retention_authority->check( ).
        CATCH zcx_stock_allocation INTO DATA(lo_retention_error).
          IF lo_retention_error->message IS INITIAL.
            lo_retention_error->message = 'Audit retention authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_retention_error.
      ENDTRY.
    ENDIF.
    DATA lt_run_ids TYPE SORTED TABLE OF zif_allocation_audit=>ty_run_id
      WITH UNIQUE KEY table_line.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_deleted_snapshots TYPE i.
    DATA lv_deleted_success TYPE i.
    DATA lv_deleted_partial TYPE i.
    DATA lv_deleted_error TYPE i.
    DATA lv_protected_running TYPE i.
    DATA lv_protected_unknown TYPE i.
    DATA lt_candidates TYPE STANDARD TABLE OF ty_purge_candidate WITH EMPTY KEY.
    DATA ls_candidate TYPE ty_purge_candidate.
    IF iv_run_id IS INITIAL.
      IF iv_start_date_from IS INITIAL.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND start_date < @iv_before_date
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ELSE.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND start_date < @iv_before_date
            AND start_date >= @iv_start_date_from
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ENDIF.
    ELSE.
      IF iv_start_date_from IS INITIAL.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND run_id = @iv_run_id
            AND start_date < @iv_before_date
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ELSE.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND run_id = @iv_run_id
            AND start_date < @iv_before_date
            AND start_date >= @iv_start_date_from
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ENDIF.
    ENDIF.
    LOOP AT lt_candidates INTO ls_candidate.
      ls_candidate-unit = to_upper( ls_candidate-unit ).
      ls_candidate-status = to_upper( ls_candidate-status ).
      ls_candidate-strategy = to_upper( ls_candidate-strategy ).
      IF iv_legacy_strategy = abap_true
          AND ls_candidate-strategy IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      IF iv_start_date_from IS NOT INITIAL
          AND ls_candidate-start_date < iv_start_date_from.
        CONTINUE.
      ENDIF.
      IF iv_finish_date_from IS NOT INITIAL
          AND ( ls_candidate-finish_date IS INITIAL
            OR ls_candidate-finish_date < iv_finish_date_from ).
        CONTINUE.
      ENDIF.
      IF iv_finish_date_to IS NOT INITIAL
          AND ( ls_candidate-finish_date IS INITIAL
            OR ls_candidate-finish_date > iv_finish_date_to ).
        CONTINUE.
      ENDIF.
      IF iv_message_contains IS NOT INITIAL
          AND to_upper( ls_candidate-message )
            NS to_upper( iv_message_contains ).
        CONTINUE.
      ENDIF.
      IF iv_message_only = abap_true
          AND ls_candidate-message IS INITIAL.
        CONTINUE.
      ENDIF.
      IF iv_run_id_contains IS NOT INITIAL
          AND to_upper( ls_candidate-run_id )
            NS to_upper( iv_run_id_contains ).
        CONTINUE.
      ENDIF.
      IF ls_candidate-requested_on_to IS INITIAL.
        lv_requested_deadline = ls_candidate-requested_on_from.
      ELSE.
        lv_requested_deadline = ls_candidate-requested_on_to.
      ENDIF.
      IF iv_overdue_only = abap_true
          AND ( lv_requested_deadline IS INITIAL
            OR lv_requested_deadline >= lv_overdue_date ).
        CONTINUE.
      ENDIF.
      IF ( iv_deadline_from IS NOT INITIAL
            AND ( lv_requested_deadline IS INITIAL
              OR lv_requested_deadline < iv_deadline_from ) )
          OR ( iv_deadline_to IS NOT INITIAL
            AND ( lv_requested_deadline IS INITIAL
              OR lv_requested_deadline > iv_deadline_to ) ).
        CONTINUE.
      ENDIF.
      IF iv_deadline_age_from IS NOT INITIAL
          OR iv_deadline_age_to IS NOT INITIAL.
        IF lv_requested_deadline IS INITIAL.
          CONTINUE.
        ENDIF.
        lv_deadline_age_days = lv_deadline_age_date
          - lv_requested_deadline.
        IF ( iv_deadline_age_from IS NOT INITIAL
              AND lv_deadline_age_days < iv_deadline_age_from )
            OR ( iv_deadline_age_to IS NOT INITIAL
              AND lv_deadline_age_days > iv_deadline_age_to ).
          CONTINUE.
        ENDIF.
      ENDIF.
      IF ( iv_unit IS INITIAL OR ls_candidate-unit = lv_unit )
          AND ( iv_movement_type IS INITIAL
            OR ls_candidate-movement_type = iv_movement_type )
          AND ( iv_run_id IS INITIAL OR ls_candidate-run_id = iv_run_id )
          AND ( iv_min_shelf_life IS INITIAL
            OR ls_candidate-min_shelf_life = iv_min_shelf_life )
          AND ( lv_status IS INITIAL OR ls_candidate-status = lv_status )
          AND ( lv_strategy IS INITIAL
            OR ls_candidate-strategy = lv_strategy )
          AND ( iv_requested_on_from IS INITIAL
            OR ls_candidate-requested_on_from = iv_requested_on_from )
          AND ( iv_requested_on_to IS INITIAL
            OR ls_candidate-requested_on_to = iv_requested_on_to ).
        CASE ls_candidate-status.
          WHEN 'S'.
            INSERT ls_candidate-run_id INTO TABLE lt_run_ids.
            lv_deleted_success = lv_deleted_success + 1.
          WHEN 'P'.
            INSERT ls_candidate-run_id INTO TABLE lt_run_ids.
            lv_deleted_partial = lv_deleted_partial + 1.
          WHEN 'E'.
            INSERT ls_candidate-run_id INTO TABLE lt_run_ids.
            lv_deleted_error = lv_deleted_error + 1.
          WHEN 'R'.
            lv_protected_running = lv_protected_running + 1.
          WHEN OTHERS.
            lv_protected_unknown = lv_protected_unknown + 1.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    LOOP AT lt_run_ids INTO lv_run_id.
      DELETE FROM zstockalloc
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND run_id = @lv_run_id.
      lv_deleted_snapshots = lv_deleted_snapshots + sy-dbcnt.
    ENDLOOP.
    CLEAR rv_deleted.
    LOOP AT lt_run_ids INTO lv_run_id.
      DELETE FROM zstockalloc_run
        WHERE run_id = @lv_run_id.
      rv_deleted = rv_deleted + sy-dbcnt.
    ENDLOOP.
    ev_deleted_snapshots = lv_deleted_snapshots.
    ev_deleted_success = lv_deleted_success.
    ev_deleted_partial = lv_deleted_partial.
    ev_deleted_error = lv_deleted_error.
    ev_protected_running = lv_protected_running.
    ev_protected_unknown = lv_protected_unknown.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_transaction_error).
          IF lo_transaction_error->message IS INITIAL.
            lo_transaction_error->message = 'Audit purge commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_transaction_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_purge_preview.
    TYPES:
      BEGIN OF ty_purge_candidate,
        run_id            TYPE zif_allocation_audit=>ty_run_id,
        start_date        TYPE d,
        finish_date       TYPE d,
        movement_type     TYPE zif_stock_allocation=>ty_movement_type,
        min_shelf_life    TYPE i,
        unit              TYPE zif_stock_allocation=>ty_unit,
        requested_on_from TYPE d,
        requested_on_to   TYPE d,
        status            TYPE zif_allocation_audit=>ty_run_status,
        strategy          TYPE zif_allocation_audit=>ty_strategy,
        message           TYPE zif_allocation_audit=>ty_message,
      END OF ty_purge_candidate.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_overdue_date TYPE d.
    DATA lv_requested_deadline TYPE d.
    DATA lv_deadline_age_date TYPE d.
    DATA lv_deadline_age_days TYPE i.
    DATA lt_candidates TYPE STANDARD TABLE OF ty_purge_candidate WITH EMPTY KEY.
    DATA lt_run_ids TYPE SORTED TABLE OF zif_allocation_audit=>ty_run_id
      WITH UNIQUE KEY table_line.
    DATA ls_candidate TYPE ty_purge_candidate.
    DATA lv_run_id TYPE zif_allocation_audit=>ty_run_id.
    DATA lv_snapshot_count TYPE i.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Audit purge scope is incomplete' ).
    ENDIF.
    lv_status = to_upper( iv_status ).
    lv_strategy = to_upper( iv_strategy ).
    lv_unit = to_upper( iv_unit ).
    lv_overdue_date = sy-datum.
    IF iv_overdue_date IS NOT INITIAL.
      lv_overdue_date = iv_overdue_date.
    ENDIF.
    lv_deadline_age_date = sy-datum.
    IF iv_deadline_age_date IS NOT INITIAL.
      lv_deadline_age_date = iv_deadline_age_date.
    ENDIF.
    IF iv_movement_type IS NOT INITIAL
        AND iv_movement_type CN '0123456789'.
      raise_error( iv_message = 'Audit movement type is invalid' ).
    ENDIF.
    IF iv_before_date IS INITIAL.
      raise_error( iv_message = 'Audit purge date is required' ).
    ENDIF.
    IF iv_before_date > sy-datum.
      raise_error( iv_message = 'Audit purge date cannot be in the future' ).
    ENDIF.
    IF iv_start_date_from IS NOT INITIAL
        AND iv_start_date_from >= iv_before_date.
      raise_error(
        iv_message = 'Audit purge start date must be before the cutoff date' ).
    ENDIF.
    IF iv_finish_date_from IS NOT INITIAL
        AND iv_finish_date_to IS NOT INITIAL
        AND iv_finish_date_from > iv_finish_date_to.
      raise_error( iv_message = 'Audit purge finish date range is invalid' ).
    ENDIF.
    IF iv_min_shelf_life < 0.
      raise_error( iv_message = 'Audit purge minimum shelf-life filter is invalid' ).
    ENDIF.
    IF iv_overdue_date IS NOT INITIAL
        AND iv_overdue_only = abap_false.
      raise_error(
        iv_message = 'Audit overdue as-of date requires overdue-only filtering' ).
    ENDIF.
    IF iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to.
      raise_error( iv_message = 'Audit requested date range is invalid' ).
    ENDIF.
    IF iv_deadline_from IS NOT INITIAL
        AND iv_deadline_to IS NOT INITIAL
        AND iv_deadline_from > iv_deadline_to.
      raise_error( iv_message = 'Audit requested deadline range is invalid' ).
    ENDIF.
    IF iv_deadline_age_from IS NOT INITIAL
        AND iv_deadline_age_to IS NOT INITIAL
        AND iv_deadline_age_from > iv_deadline_age_to.
      raise_error( iv_message = 'Audit deadline age range is invalid' ).
    ENDIF.
    IF iv_deadline_age_date IS NOT INITIAL
        AND iv_deadline_age_from IS INITIAL
        AND iv_deadline_age_to IS INITIAL.
      raise_error(
        iv_message = 'Audit deadline age date requires an age range' ).
    ENDIF.
    IF lv_status IS NOT INITIAL
        AND lv_status <> 'S'
        AND lv_status <> 'P'
        AND lv_status <> 'E'.
      raise_error( iv_message = 'Audit purge status filter is invalid' ).
    ENDIF.
    IF lv_strategy IS NOT INITIAL
        AND lv_strategy <> 'P'
        AND lv_strategy <> 'F'
        AND lv_strategy <> 'N'
        AND lv_strategy <> 'S'
        AND lv_strategy <> 'L'
        AND lv_strategy <> 'B'.
      raise_error( iv_message = 'Audit strategy is invalid' ).
    ENDIF.
    IF iv_legacy_strategy = abap_true
        AND lv_strategy IS NOT INITIAL.
      raise_error( iv_message = 'Audit strategy filters conflict' ).
    ENDIF.
    IF mo_retention_authority IS BOUND.
      TRY.
          mo_retention_authority->check( ).
        CATCH zcx_stock_allocation INTO DATA(lo_retention_error).
          IF lo_retention_error->message IS INITIAL.
            lo_retention_error->message = 'Audit retention authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_retention_error.
      ENDTRY.
    ENDIF.
    IF iv_run_id IS INITIAL.
      IF iv_start_date_from IS INITIAL.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND start_date < @iv_before_date
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ELSE.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND start_date < @iv_before_date
            AND start_date >= @iv_start_date_from
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ENDIF.
    ELSE.
      IF iv_start_date_from IS INITIAL.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND run_id = @iv_run_id
            AND start_date < @iv_before_date
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ELSE.
        SELECT run_id,
               start_date,
               finish_date,
               movement_type,
               min_shelf_life,
               unit,
               requested_on_from,
               requested_on_to,
               status,
               strategy,
               message
          FROM zstockalloc_run
          INTO CORRESPONDING FIELDS OF TABLE @lt_candidates
          WHERE matnr = @iv_material
            AND werks = @iv_plant
            AND lgort = @iv_storage_location
            AND batch = @iv_batch
            AND run_id = @iv_run_id
            AND start_date < @iv_before_date
            AND start_date >= @iv_start_date_from
            AND ( @iv_deadline_only = @abap_false
              OR requested_on_from <> '00000000'
              OR requested_on_to <> '00000000' ).
      ENDIF.
    ENDIF.
    LOOP AT lt_candidates INTO ls_candidate.
      ls_candidate-unit = to_upper( ls_candidate-unit ).
      ls_candidate-status = to_upper( ls_candidate-status ).
      ls_candidate-strategy = to_upper( ls_candidate-strategy ).
      IF iv_legacy_strategy = abap_true
          AND ls_candidate-strategy IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      IF iv_start_date_from IS NOT INITIAL
          AND ls_candidate-start_date < iv_start_date_from.
        CONTINUE.
      ENDIF.
      IF iv_finish_date_from IS NOT INITIAL
          AND ( ls_candidate-finish_date IS INITIAL
            OR ls_candidate-finish_date < iv_finish_date_from ).
        CONTINUE.
      ENDIF.
      IF iv_finish_date_to IS NOT INITIAL
          AND ( ls_candidate-finish_date IS INITIAL
            OR ls_candidate-finish_date > iv_finish_date_to ).
        CONTINUE.
      ENDIF.
      IF iv_message_contains IS NOT INITIAL
          AND to_upper( ls_candidate-message )
            NS to_upper( iv_message_contains ).
        CONTINUE.
      ENDIF.
      IF iv_message_only = abap_true
          AND ls_candidate-message IS INITIAL.
        CONTINUE.
      ENDIF.
      IF iv_run_id_contains IS NOT INITIAL
          AND to_upper( ls_candidate-run_id )
            NS to_upper( iv_run_id_contains ).
        CONTINUE.
      ENDIF.
      IF ls_candidate-requested_on_to IS INITIAL.
        lv_requested_deadline = ls_candidate-requested_on_from.
      ELSE.
        lv_requested_deadline = ls_candidate-requested_on_to.
      ENDIF.
      IF iv_overdue_only = abap_true
          AND ( lv_requested_deadline IS INITIAL
            OR lv_requested_deadline >= lv_overdue_date ).
        CONTINUE.
      ENDIF.
      IF ( iv_deadline_from IS NOT INITIAL
            AND ( lv_requested_deadline IS INITIAL
              OR lv_requested_deadline < iv_deadline_from ) )
          OR ( iv_deadline_to IS NOT INITIAL
            AND ( lv_requested_deadline IS INITIAL
              OR lv_requested_deadline > iv_deadline_to ) ).
        CONTINUE.
      ENDIF.
      IF iv_deadline_age_from IS NOT INITIAL
          OR iv_deadline_age_to IS NOT INITIAL.
        IF lv_requested_deadline IS INITIAL.
          CONTINUE.
        ENDIF.
        lv_deadline_age_days = lv_deadline_age_date
          - lv_requested_deadline.
        IF ( iv_deadline_age_from IS NOT INITIAL
              AND lv_deadline_age_days < iv_deadline_age_from )
            OR ( iv_deadline_age_to IS NOT INITIAL
              AND lv_deadline_age_days > iv_deadline_age_to ).
          CONTINUE.
        ENDIF.
      ENDIF.
      IF ( iv_unit IS INITIAL OR ls_candidate-unit = lv_unit )
          AND ( iv_movement_type IS INITIAL
            OR ls_candidate-movement_type = iv_movement_type )
          AND ( iv_run_id IS INITIAL OR ls_candidate-run_id = iv_run_id )
          AND ( iv_min_shelf_life IS INITIAL
            OR ls_candidate-min_shelf_life = iv_min_shelf_life )
          AND ( lv_status IS INITIAL OR ls_candidate-status = lv_status )
          AND ( lv_strategy IS INITIAL
            OR ls_candidate-strategy = lv_strategy )
          AND ( iv_requested_on_from IS INITIAL
            OR ls_candidate-requested_on_from = iv_requested_on_from )
          AND ( iv_requested_on_to IS INITIAL
            OR ls_candidate-requested_on_to = iv_requested_on_to ).
        CASE ls_candidate-status.
          WHEN 'S'.
            INSERT ls_candidate-run_id INTO TABLE lt_run_ids.
            rs_preview-success_count = rs_preview-success_count + 1.
          WHEN 'P'.
            INSERT ls_candidate-run_id INTO TABLE lt_run_ids.
            rs_preview-partial_count = rs_preview-partial_count + 1.
          WHEN 'E'.
            INSERT ls_candidate-run_id INTO TABLE lt_run_ids.
            rs_preview-error_count = rs_preview-error_count + 1.
          WHEN 'R'.
            rs_preview-running_count = rs_preview-running_count + 1.
          WHEN OTHERS.
            rs_preview-unknown_count = rs_preview-unknown_count + 1.
        ENDCASE.
      ENDIF.
    ENDLOOP.
    rs_preview-audit_count = lines( lt_run_ids ).
    LOOP AT lt_run_ids INTO lv_run_id.
      SELECT COUNT( * )
        FROM zstockalloc
        INTO @lv_snapshot_count
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND run_id = @lv_run_id.
      rs_preview-snapshot_count =
        rs_preview-snapshot_count + lv_snapshot_count.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_summary.
    DATA lt_runs TYPE zif_allocation_audit=>tt_runs.
    DATA lv_summary_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_last_duration_seconds TYPE i.
    DATA lv_duration_seconds TYPE i.
    DATA lv_duration_total TYPE p LENGTH 12 DECIMALS 2.
    DATA lv_duration_count TYPE i.
    DATA lv_running_age_seconds TYPE i.
    DATA lv_running_age_count TYPE i.
    DATA lv_policy_initialized TYPE abap_bool.
    DATA lv_policy_mixed TYPE abap_bool.
    DATA lv_policy_movement_type TYPE zif_stock_allocation=>ty_movement_type.
    DATA lv_policy_min_shelf_life TYPE i.
    DATA lv_deadline_age_reference_date TYPE d.
    DATA ls_running_age TYPE zif_allocation_audit=>ty_running_age.
    FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

    lv_deadline_age_reference_date = sy-datum.
    IF iv_deadline_age_date IS NOT INITIAL.
      lv_deadline_age_reference_date = iv_deadline_age_date.
    ENDIF.
    rs_summary-deadline_age_reference_date =
      lv_deadline_age_reference_date.

    lt_runs = zif_allocation_audit~get_runs(
      iv_material          = iv_material
      iv_plant             = iv_plant
      iv_storage_location  = iv_storage_location
      iv_batch             = iv_batch
      iv_run_id            = iv_run_id
      iv_run_id_contains   = iv_run_id_contains
      iv_movement_type     = iv_movement_type
      iv_min_shelf_life    = iv_min_shelf_life
      iv_requested_on_from = iv_requested_on_from
      iv_requested_on_to   = iv_requested_on_to
      iv_requested_overdue = iv_requested_overdue
      iv_overdue_date      = iv_overdue_date
      iv_deadline_only     = iv_deadline_only
      iv_deadline_from     = iv_deadline_from
      iv_deadline_to       = iv_deadline_to
      iv_deadline_age_from = iv_deadline_age_from
      iv_deadline_age_to   = iv_deadline_age_to
      iv_deadline_age_date = iv_deadline_age_date
      iv_start_date_from   = iv_start_date_from
      iv_start_date_to     = iv_start_date_to
      iv_finish_date_from  = iv_finish_date_from
      iv_finish_date_to    = iv_finish_date_to
      iv_duration_from     = iv_duration_from
      iv_duration_to       = iv_duration_to
      iv_coverage_from     = iv_coverage_from
      iv_coverage_to       = iv_coverage_to
      iv_shortage_pct_from = iv_shortage_pct_from
      iv_shortage_pct_to   = iv_shortage_pct_to
      iv_shortage_from     = iv_shortage_from
      iv_shortage_to       = iv_shortage_to
      iv_allocated_from    = iv_allocated_from
      iv_allocated_to      = iv_allocated_to
      iv_available_from    = iv_available_from
      iv_available_to      = iv_available_to
      iv_requested_from    = iv_requested_from
      iv_requested_to      = iv_requested_to
      iv_demand_from       = iv_demand_from
      iv_demand_to         = iv_demand_to
      iv_stale_seconds     = iv_stale_seconds
      iv_running_age_to    = iv_running_age_to
      iv_unit              = iv_unit
      iv_status            = iv_status
      iv_strategy          = iv_strategy
      iv_legacy_strategy   = iv_legacy_strategy
      iv_message_contains  = iv_message_contains
      iv_message_only      = iv_message_only ).
    IF iv_unit IS NOT INITIAL.
      rs_summary-unit = to_upper( iv_unit ).
    ENDIF.
    LOOP AT lt_runs ASSIGNING <ls_run>.
      rs_summary-total_runs = rs_summary-total_runs + 1.
      rs_summary-demand_count = rs_summary-demand_count
        + <ls_run>-demand_count.
      IF <ls_run>-requested_deadline IS NOT INITIAL.
        rs_summary-deadline_count = rs_summary-deadline_count + 1.
      ENDIF.
      CASE <ls_run>-strategy.
        WHEN 'P'.
          rs_summary-priority_runs = rs_summary-priority_runs + 1.
        WHEN 'F'.
          rs_summary-fifo_runs = rs_summary-fifo_runs + 1.
        WHEN 'N'.
          rs_summary-full_only_runs = rs_summary-full_only_runs + 1.
        WHEN 'S'.
          rs_summary-smallest_runs = rs_summary-smallest_runs + 1.
        WHEN 'L'.
          rs_summary-largest_runs = rs_summary-largest_runs + 1.
        WHEN 'B'.
          rs_summary-best_runs = rs_summary-best_runs + 1.
        WHEN OTHERS.
          rs_summary-legacy_strategy_runs =
            rs_summary-legacy_strategy_runs + 1.
      ENDCASE.
      IF lv_summary_unit IS INITIAL.
        lv_summary_unit = <ls_run>-unit.
      ELSEIF lv_summary_unit <> <ls_run>-unit.
        rs_summary-mixed_units = abap_true.
      ENDIF.
      IF lv_policy_initialized = abap_false.
        lv_policy_initialized = abap_true.
        lv_policy_movement_type = <ls_run>-movement_type.
        lv_policy_min_shelf_life = <ls_run>-min_shelf_life.
      ELSEIF lv_policy_movement_type <> <ls_run>-movement_type
          OR lv_policy_min_shelf_life <> <ls_run>-min_shelf_life.
        lv_policy_mixed = abap_true.
      ENDIF.
      IF <ls_run>-requested_deadline IS NOT INITIAL.
        IF rs_summary-earliest_requested_deadline IS INITIAL
            OR <ls_run>-requested_deadline
               < rs_summary-earliest_requested_deadline.
          rs_summary-earliest_requested_deadline =
            <ls_run>-requested_deadline.
        ENDIF.
        IF rs_summary-latest_requested_deadline IS INITIAL
            OR <ls_run>-requested_deadline
               > rs_summary-latest_requested_deadline.
          rs_summary-latest_requested_deadline =
            <ls_run>-requested_deadline.
        ENDIF.
      ENDIF.
      IF rs_summary-mixed_units <> abap_true.
        rs_summary-allocated = rs_summary-allocated + <ls_run>-allocated.
        rs_summary-shortage = rs_summary-shortage + <ls_run>-shortage.
        rs_summary-requested = rs_summary-requested
          + <ls_run>-allocated + <ls_run>-shortage.
        CASE <ls_run>-strategy.
          WHEN 'P'.
            rs_summary-priority_allocated =
              rs_summary-priority_allocated + <ls_run>-allocated.
            rs_summary-priority_shortage =
              rs_summary-priority_shortage + <ls_run>-shortage.
            rs_summary-priority_requested =
              rs_summary-priority_requested + <ls_run>-allocated
              + <ls_run>-shortage.
          WHEN 'F'.
            rs_summary-fifo_allocated =
              rs_summary-fifo_allocated + <ls_run>-allocated.
            rs_summary-fifo_shortage =
              rs_summary-fifo_shortage + <ls_run>-shortage.
            rs_summary-fifo_requested =
              rs_summary-fifo_requested + <ls_run>-allocated
              + <ls_run>-shortage.
          WHEN 'N'.
            rs_summary-full_only_allocated =
              rs_summary-full_only_allocated + <ls_run>-allocated.
            rs_summary-full_only_shortage =
              rs_summary-full_only_shortage + <ls_run>-shortage.
            rs_summary-full_only_requested =
              rs_summary-full_only_requested + <ls_run>-allocated
              + <ls_run>-shortage.
          WHEN 'S'.
            rs_summary-smallest_allocated =
              rs_summary-smallest_allocated + <ls_run>-allocated.
            rs_summary-smallest_shortage =
              rs_summary-smallest_shortage + <ls_run>-shortage.
            rs_summary-smallest_requested =
              rs_summary-smallest_requested + <ls_run>-allocated
              + <ls_run>-shortage.
          WHEN 'L'.
            rs_summary-largest_allocated =
              rs_summary-largest_allocated + <ls_run>-allocated.
            rs_summary-largest_shortage =
              rs_summary-largest_shortage + <ls_run>-shortage.
            rs_summary-largest_requested =
              rs_summary-largest_requested + <ls_run>-allocated
              + <ls_run>-shortage.
          WHEN 'B'.
            rs_summary-best_allocated =
              rs_summary-best_allocated + <ls_run>-allocated.
            rs_summary-best_shortage =
              rs_summary-best_shortage + <ls_run>-shortage.
            rs_summary-best_requested =
              rs_summary-best_requested + <ls_run>-allocated
              + <ls_run>-shortage.
          WHEN OTHERS.
            rs_summary-legacy_allocated =
              rs_summary-legacy_allocated + <ls_run>-allocated.
            rs_summary-legacy_shortage =
              rs_summary-legacy_shortage + <ls_run>-shortage.
            rs_summary-legacy_requested =
              rs_summary-legacy_requested + <ls_run>-allocated
              + <ls_run>-shortage.
        ENDCASE.
      ENDIF.
      rs_summary-full_count = rs_summary-full_count + <ls_run>-full_count.
      rs_summary-partial_count = rs_summary-partial_count + <ls_run>-partial_count.
      rs_summary-unallocated_count =
        rs_summary-unallocated_count + <ls_run>-unallocated_count.
      IF <ls_run>-status = 'R'.
        rs_summary-running_runs = rs_summary-running_runs + 1.
        ls_running_age = zif_allocation_audit~get_running_age(
          is_run = <ls_run> ).
        IF ls_running_age-available = abap_true.
          lv_running_age_seconds = ls_running_age-seconds.
          lv_running_age_count = lv_running_age_count + 1.
          IF lv_running_age_count = 1
              OR lv_running_age_seconds
                 > rs_summary-oldest_running_age_seconds.
            rs_summary-oldest_running_age_seconds =
              lv_running_age_seconds.
            rs_summary-oldest_running_run_id = <ls_run>-run_id.
          ENDIF.
          IF lv_running_age_count = 1
              OR lv_running_age_seconds
                 < rs_summary-newest_running_age_seconds.
            rs_summary-newest_running_age_seconds =
              lv_running_age_seconds.
            rs_summary-newest_running_run_id = <ls_run>-run_id.
          ENDIF.
        ENDIF.
      ELSEIF <ls_run>-status = 'S'.
        rs_summary-success_runs = rs_summary-success_runs + 1.
      ELSEIF <ls_run>-status = 'P'.
        rs_summary-partial_runs = rs_summary-partial_runs + 1.
      ELSEIF <ls_run>-status = 'E'.
        rs_summary-error_runs = rs_summary-error_runs + 1.
      ENDIF.
      IF <ls_run>-finish_date IS NOT INITIAL.
        CLEAR lv_duration_seconds.
        cl_abap_tstmp=>td_subtract(
          EXPORTING
            date1    = <ls_run>-finish_date
            time1    = <ls_run>-finish_time
            date2    = <ls_run>-start_date
            time2    = <ls_run>-start_time
        IMPORTING
            res_secs = lv_duration_seconds ).
        lv_duration_total = lv_duration_total + lv_duration_seconds.
        IF lv_duration_count = 0
            OR lv_duration_seconds < rs_summary-minimum_duration_seconds.
          rs_summary-minimum_duration_seconds = lv_duration_seconds.
        ENDIF.
        IF lv_duration_count = 0
            OR lv_duration_seconds > rs_summary-maximum_duration_seconds.
          rs_summary-maximum_duration_seconds = lv_duration_seconds.
        ENDIF.
        lv_duration_count = lv_duration_count + 1.
      ENDIF.
      IF <ls_run>-start_date > rs_summary-last_start_date
          OR ( <ls_run>-start_date = rs_summary-last_start_date
            AND <ls_run>-start_time > rs_summary-last_start_time )
          OR ( <ls_run>-start_date = rs_summary-last_start_date
            AND <ls_run>-start_time = rs_summary-last_start_time
            AND <ls_run>-run_id > rs_summary-last_run_id ).
        rs_summary-last_run_id = <ls_run>-run_id.
        rs_summary-last_start_date = <ls_run>-start_date.
        rs_summary-last_start_time = <ls_run>-start_time.
        rs_summary-last_requested_on_from = <ls_run>-requested_on_from.
        rs_summary-last_requested_on_to = <ls_run>-requested_on_to.
        rs_summary-last_requested_deadline = <ls_run>-requested_deadline.
        rs_summary-last_strategy = <ls_run>-strategy.
        rs_summary-last_finish_date = <ls_run>-finish_date.
        rs_summary-last_finish_time = <ls_run>-finish_time.
        CLEAR lv_last_duration_seconds.
        IF <ls_run>-finish_date IS NOT INITIAL.
          cl_abap_tstmp=>td_subtract(
            EXPORTING
              date1    = <ls_run>-finish_date
              time1    = <ls_run>-finish_time
              date2    = <ls_run>-start_date
              time2    = <ls_run>-start_time
            IMPORTING
              res_secs = lv_last_duration_seconds ).
        ENDIF.
        rs_summary-last_duration_seconds = lv_last_duration_seconds.
        rs_summary-last_status = <ls_run>-status.
        rs_summary-last_message = <ls_run>-message.
      ENDIF.
    ENDLOOP.
    IF lv_duration_count > 0.
      rs_summary-average_duration_seconds = lv_duration_total
        / lv_duration_count.
    ENDIF.
    rs_summary-completed_duration_runs = lv_duration_count.
    IF rs_summary-total_runs > 0.
      rs_summary-completion_pct =
        ( rs_summary-success_runs + rs_summary-partial_runs
          + rs_summary-error_runs ) * 100 / rs_summary-total_runs.
    ENDIF.
    IF rs_summary-success_runs + rs_summary-partial_runs
        + rs_summary-error_runs > 0.
      rs_summary-success_rate_pct = rs_summary-success_runs * 100
        / ( rs_summary-success_runs + rs_summary-partial_runs
          + rs_summary-error_runs ).
      rs_summary-partial_rate_pct = rs_summary-partial_runs * 100
        / ( rs_summary-success_runs + rs_summary-partial_runs
          + rs_summary-error_runs ).
      rs_summary-error_rate_pct = rs_summary-error_runs * 100
        / ( rs_summary-success_runs + rs_summary-partial_runs
          + rs_summary-error_runs ).
    ENDIF.
    IF rs_summary-mixed_units = abap_true.
      CLEAR: rs_summary-allocated,
             rs_summary-shortage,
             rs_summary-requested,
             rs_summary-coverage,
             rs_summary-shortage_pct,
             rs_summary-priority_allocated,
             rs_summary-priority_shortage,
             rs_summary-priority_requested,
             rs_summary-fifo_allocated,
             rs_summary-fifo_shortage,
             rs_summary-fifo_requested,
             rs_summary-full_only_allocated,
             rs_summary-full_only_shortage,
             rs_summary-full_only_requested,
             rs_summary-smallest_allocated,
             rs_summary-smallest_shortage,
             rs_summary-smallest_requested,
             rs_summary-largest_allocated,
             rs_summary-largest_shortage,
             rs_summary-largest_requested,
             rs_summary-best_allocated,
             rs_summary-best_shortage,
             rs_summary-best_requested,
             rs_summary-legacy_allocated,
             rs_summary-legacy_shortage,
             rs_summary-legacy_requested,
             rs_summary-unit.
    ELSEIF iv_unit IS INITIAL.
      rs_summary-unit = lv_summary_unit.
    ENDIF.
    IF rs_summary-mixed_units = abap_false.
      IF rs_summary-requested > 0.
        rs_summary-coverage = rs_summary-allocated * 100
          / rs_summary-requested.
        rs_summary-shortage_pct = rs_summary-shortage * 100
          / rs_summary-requested.
      ENDIF.
      IF rs_summary-priority_requested > 0.
        rs_summary-priority_coverage =
          rs_summary-priority_allocated * 100
          / rs_summary-priority_requested.
      ENDIF.
      IF rs_summary-fifo_requested > 0.
        rs_summary-fifo_coverage =
          rs_summary-fifo_allocated * 100
          / rs_summary-fifo_requested.
      ENDIF.
      IF rs_summary-full_only_requested > 0.
        rs_summary-full_only_coverage =
          rs_summary-full_only_allocated * 100
          / rs_summary-full_only_requested.
      ENDIF.
      IF rs_summary-smallest_requested > 0.
        rs_summary-smallest_coverage =
          rs_summary-smallest_allocated * 100
          / rs_summary-smallest_requested.
      ENDIF.
      IF rs_summary-largest_requested > 0.
        rs_summary-largest_coverage =
          rs_summary-largest_allocated * 100
          / rs_summary-largest_requested.
      ENDIF.
      IF rs_summary-best_requested > 0.
        rs_summary-best_coverage =
          rs_summary-best_allocated * 100
          / rs_summary-best_requested.
      ENDIF.
      IF rs_summary-legacy_requested > 0.
        rs_summary-legacy_coverage =
          rs_summary-legacy_allocated * 100
          / rs_summary-legacy_requested.
      ENDIF.
    ELSE.
      CLEAR: rs_summary-coverage,
             rs_summary-shortage_pct,
             rs_summary-priority_coverage,
             rs_summary-fifo_coverage,
             rs_summary-full_only_coverage,
             rs_summary-smallest_coverage,
             rs_summary-largest_coverage,
             rs_summary-best_coverage,
             rs_summary-legacy_coverage.
    ENDIF.
    IF lv_policy_initialized = abap_false.
      rs_summary-movement_type_context = 'n/a'.
      CLEAR rs_summary-min_shelf_life_context.
      rs_summary-policy_context_available = abap_false.
      rs_summary-mixed_policies = abap_false.
    ELSEIF lv_policy_mixed = abap_true.
      rs_summary-movement_type_context = 'mixed'.
      CLEAR rs_summary-min_shelf_life_context.
      rs_summary-policy_context_available = abap_true.
      rs_summary-mixed_policies = abap_true.
    ELSE.
      rs_summary-movement_type_context = lv_policy_movement_type.
      rs_summary-min_shelf_life_context = lv_policy_min_shelf_life.
      rs_summary-policy_context_available = abap_true.
      rs_summary-mixed_policies = abap_false.
    ENDIF.
    IF rs_summary-last_requested_deadline IS NOT INITIAL.
      rs_summary-last_deadline_age_days = lv_deadline_age_reference_date
        - rs_summary-last_requested_deadline.
    ENDIF.
    IF rs_summary-earliest_requested_deadline IS NOT INITIAL.
      rs_summary-oldest_deadline_age_days = lv_deadline_age_reference_date
        - rs_summary-earliest_requested_deadline.
    ENDIF.
    IF rs_summary-latest_requested_deadline IS NOT INITIAL.
      rs_summary-newest_deadline_age_days = lv_deadline_age_reference_date
        - rs_summary-latest_requested_deadline.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~record_rejection.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.

    lv_unit = to_upper( iv_unit ).
    IF iv_message IS INITIAL.
      raise_error( iv_message = 'Audit rejection message is required' ).
    ENDIF.
    IF iv_movement_type IS NOT INITIAL
        AND iv_movement_type CN '0123456789'.
      raise_error( iv_message = 'Audit movement type is invalid' ).
    ENDIF.
    IF iv_available < 0.
      raise_error( iv_message = 'Audit rejection metrics are invalid' ).
    ENDIF.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_audit_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Audit write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
    ENDIF.
    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        raise_error( iv_message = 'Audit run ID generation failed' ).
    ENDTRY.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = rv_run_id.
    ls_run-matnr = iv_material.
    ls_run-werks = iv_plant.
    ls_run-lgort = iv_storage_location.
    ls_run-batch = iv_batch.
    ls_run-movement_type = iv_movement_type.
    ls_run-min_shelf_life = iv_min_shelf_life.
    ls_run-requested_on_from = iv_requested_on_from.
    ls_run-requested_on_to = iv_requested_on_to.
    ls_run-unit = lv_unit.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-finish_date = sy-datum.
    ls_run-finish_time = sy-uzeit.
    ls_run-status = 'E'.
    ls_run-available = iv_available.
    ls_run-message = iv_message.
    MODIFY zstockalloc_run FROM @ls_run.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit rejection persistence failed' ).
    ENDIF.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_transaction_error).
          IF lo_transaction_error->message IS INITIAL.
            lo_transaction_error->message = 'Audit rejection commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_transaction_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~get_runs.
    TYPES:
      BEGIN OF ty_coverage_run,
        coverage               TYPE zif_allocation_audit=>ty_coverage,
        shortage_pct           TYPE zif_allocation_audit=>ty_coverage,
        demand_count           TYPE i,
        shortage               TYPE zif_stock_allocation=>ty_quantity,
        deadline_age_available TYPE abap_bool,
        deadline_age_days      TYPE i,
        deadline_date          TYPE d,
        horizon                TYPE abap_bool,
        requested_from         TYPE d,
        requested_to           TYPE d,
        sort_date              TYPE d,
        start_date             TYPE d,
        start_time             TYPE t,
        run_id                 TYPE zif_allocation_audit=>ty_run_id,
        status_rank            TYPE i,
        duration_seconds       TYPE i,
        run                    TYPE zif_allocation_audit=>ty_run,
      END OF ty_coverage_run.
    DATA lt_filtered TYPE zif_allocation_audit=>tt_runs.
    DATA lv_coverage TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_shortage_pct TYPE zif_allocation_audit=>ty_coverage.
    DATA lv_requested_deadline TYPE d.
    DATA lv_overdue_date TYPE d.
    DATA lv_deadline_age_date TYPE d.
    DATA lv_deadline_age_days TYPE i.
    DATA lv_sort_date TYPE d.
    DATA lv_status_rank TYPE i.
    DATA lv_duration_seconds TYPE i.
    DATA lv_running_age_seconds TYPE i.
    DATA lv_limit_start TYPE i.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lt_coverage_sorted TYPE STANDARD TABLE OF ty_coverage_run
      WITH EMPTY KEY.
    DATA lt_duration_sorted TYPE STANDARD TABLE OF ty_coverage_run
      WITH EMPTY KEY.
    FIELD-SYMBOLS <ls_run> TYPE zif_allocation_audit=>ty_run.

    lv_overdue_date = sy-datum.
    IF iv_overdue_date IS NOT INITIAL.
      lv_overdue_date = iv_overdue_date.
    ENDIF.
    lv_deadline_age_date = sy-datum.
    IF iv_deadline_age_date IS NOT INITIAL.
      lv_deadline_age_date = iv_deadline_age_date.
    ENDIF.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL.
      raise_error( iv_message = 'Audit read scope is incomplete' ).
    ENDIF.
    lv_status = to_upper( iv_status ).
    lv_strategy = to_upper( iv_strategy ).
    lv_unit = to_upper( iv_unit ).
    IF iv_movement_type IS NOT INITIAL
        AND iv_movement_type CN '0123456789'.
      raise_error( iv_message = 'Audit movement type is invalid' ).
    ENDIF.
    IF iv_max_rows < 0.
      raise_error( iv_message = 'Audit history row limit is invalid' ).
    ENDIF.
    IF iv_offset < 0.
      raise_error( iv_message = 'Audit history row offset is invalid' ).
    ENDIF.
    IF iv_start_date_from IS NOT INITIAL
        AND iv_start_date_to IS NOT INITIAL
        AND iv_start_date_from > iv_start_date_to.
      raise_error( iv_message = 'Audit date range is invalid' ).
    ENDIF.
    IF iv_finish_date_from IS NOT INITIAL
        AND iv_finish_date_to IS NOT INITIAL
        AND iv_finish_date_from > iv_finish_date_to.
      raise_error( iv_message = 'Audit finish date range is invalid' ).
    ENDIF.
    IF ( iv_shortage_from IS NOT INITIAL AND iv_shortage_from < 0 )
        OR ( iv_shortage_to IS NOT INITIAL AND iv_shortage_to < 0 ).
      raise_error( iv_message = 'Audit shortage range is invalid' ).
    ENDIF.
    IF iv_shortage_from IS NOT INITIAL
        AND iv_shortage_to IS NOT INITIAL
        AND iv_shortage_from > iv_shortage_to.
      raise_error( iv_message = 'Audit shortage range is invalid' ).
    ENDIF.
    IF ( iv_allocated_from IS NOT INITIAL AND iv_allocated_from < 0 )
        OR ( iv_allocated_to IS NOT INITIAL AND iv_allocated_to < 0 ).
      raise_error( iv_message = 'Audit allocated range is invalid' ).
    ENDIF.
    IF iv_allocated_from IS NOT INITIAL
        AND iv_allocated_to IS NOT INITIAL
        AND iv_allocated_from > iv_allocated_to.
      raise_error( iv_message = 'Audit allocated range is invalid' ).
    ENDIF.
    IF ( iv_available_from IS NOT INITIAL AND iv_available_from < 0 )
        OR ( iv_available_to IS NOT INITIAL AND iv_available_to < 0 ).
      raise_error( iv_message = 'Audit available range is invalid' ).
    ENDIF.
    IF iv_available_from IS NOT INITIAL
        AND iv_available_to IS NOT INITIAL
        AND iv_available_from > iv_available_to.
      raise_error( iv_message = 'Audit available range is invalid' ).
    ENDIF.
    IF ( iv_requested_from IS NOT INITIAL AND iv_requested_from < 0 )
        OR ( iv_requested_to IS NOT INITIAL AND iv_requested_to < 0 ).
      raise_error( iv_message = 'Audit requested quantity range is invalid' ).
    ENDIF.
    IF iv_requested_from IS NOT INITIAL
        AND iv_requested_to IS NOT INITIAL
        AND iv_requested_from > iv_requested_to.
      raise_error( iv_message = 'Audit requested quantity range is invalid' ).
    ENDIF.
    IF iv_demand_from IS NOT INITIAL AND iv_demand_from < 0
        OR iv_demand_to IS NOT INITIAL AND iv_demand_to < 0.
      raise_error( iv_message = 'Audit demand count range is invalid' ).
    ENDIF.
    IF iv_demand_from IS NOT INITIAL
        AND iv_demand_to IS NOT INITIAL
        AND iv_demand_from > iv_demand_to.
      raise_error( iv_message = 'Audit demand count range is invalid' ).
    ENDIF.
    IF ( iv_duration_from IS NOT INITIAL AND iv_duration_from < 0 )
        OR ( iv_duration_to IS NOT INITIAL AND iv_duration_to < 0 ).
      raise_error( iv_message = 'Audit duration range is invalid' ).
    ENDIF.
    IF iv_duration_from IS NOT INITIAL
        AND iv_duration_to IS NOT INITIAL
        AND iv_duration_from > iv_duration_to.
      raise_error( iv_message = 'Audit duration range is invalid' ).
    ENDIF.
    IF iv_stale_seconds < 0.
      raise_error( iv_message = 'Audit stale-running threshold is invalid' ).
    ENDIF.
    IF iv_running_age_to < 0.
      raise_error( iv_message = 'Audit maximum running age is invalid' ).
    ENDIF.
    IF iv_stale_seconds IS NOT INITIAL
        AND iv_running_age_to IS NOT INITIAL
        AND iv_running_age_to < iv_stale_seconds.
      raise_error( iv_message = 'Audit running age bounds are invalid' ).
    ENDIF.
    IF ( iv_coverage_from IS NOT INITIAL
          AND ( iv_coverage_from < 0 OR iv_coverage_from > 100 ) )
        OR ( iv_coverage_to IS NOT INITIAL
          AND ( iv_coverage_to < 0 OR iv_coverage_to > 100 ) ).
      raise_error( iv_message = 'Audit coverage range is invalid' ).
    ENDIF.
    IF iv_coverage_from IS NOT INITIAL
        AND iv_coverage_to IS NOT INITIAL
        AND iv_coverage_from > iv_coverage_to.
      raise_error( iv_message = 'Audit coverage range is invalid' ).
    ENDIF.
    IF ( iv_shortage_pct_from IS NOT INITIAL
          AND ( iv_shortage_pct_from < 0 OR iv_shortage_pct_from > 100 ) )
        OR ( iv_shortage_pct_to IS NOT INITIAL
          AND ( iv_shortage_pct_to < 0 OR iv_shortage_pct_to > 100 ) ).
      raise_error( iv_message = 'Audit shortage percentage range is invalid' ).
    ENDIF.
    IF iv_shortage_pct_from IS NOT INITIAL
        AND iv_shortage_pct_to IS NOT INITIAL
        AND iv_shortage_pct_from > iv_shortage_pct_to.
      raise_error( iv_message = 'Audit shortage percentage range is invalid' ).
    ENDIF.
    IF iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to.
      raise_error( iv_message = 'Audit requested date range is invalid' ).
    ENDIF.
    IF iv_deadline_from IS NOT INITIAL
        AND iv_deadline_to IS NOT INITIAL
        AND iv_deadline_from > iv_deadline_to.
      raise_error( iv_message = 'Audit requested deadline range is invalid' ).
    ENDIF.
    IF iv_deadline_age_from IS NOT INITIAL
        AND iv_deadline_age_to IS NOT INITIAL
        AND iv_deadline_age_from > iv_deadline_age_to.
      raise_error( iv_message = 'Audit deadline age range is invalid' ).
    ENDIF.
    IF iv_deadline_age_date IS NOT INITIAL
        AND iv_deadline_age_from IS INITIAL
        AND iv_deadline_age_to IS INITIAL.
      raise_error(
        iv_message = 'Audit deadline age date requires an age range' ).
    ENDIF.
    IF iv_min_shelf_life < 0.
      raise_error( iv_message = 'Audit minimum shelf-life filter is invalid' ).
    ENDIF.
    IF lv_status IS NOT INITIAL
        AND lv_status <> 'R'
        AND lv_status <> 'S'
        AND lv_status <> 'P'
        AND lv_status <> 'E'.
      raise_error( iv_message = 'Audit status is invalid' ).
    ENDIF.
    IF lv_strategy IS NOT INITIAL
        AND lv_strategy <> 'P'
        AND lv_strategy <> 'F'
        AND lv_strategy <> 'N'
        AND lv_strategy <> 'S'
        AND lv_strategy <> 'L'
        AND lv_strategy <> 'B'.
      raise_error( iv_message = 'Audit strategy is invalid' ).
    ENDIF.
    IF iv_legacy_strategy = abap_true
        AND lv_strategy IS NOT INITIAL.
      raise_error( iv_message = 'Audit strategy filters conflict' ).
    ENDIF.
    IF mo_read_authority IS BOUND.
      TRY.
          mo_read_authority->check_audit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_read_error).
          IF lo_read_error->message IS INITIAL.
            lo_read_error->message = 'Audit read authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_read_error.
      ENDTRY.
    ENDIF.

    IF iv_run_id IS INITIAL.
      SELECT run_id,
             matnr AS material,
             werks AS plant,
             lgort AS storage_location,
             batch,
             movement_type,
             min_shelf_life,
             unit,
             strategy,
             start_date,
             start_time,
              finish_date,
              finish_time,
              status,
              available,
             demand_count,
             requested_on_from,
             requested_on_to,
              full_count,
             partial_count,
             unallocated_count,
             allocated,
             shortage,
             message
        FROM zstockalloc_run
        INTO CORRESPONDING FIELDS OF TABLE @rt_runs
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch.
    ELSE.
      SELECT run_id,
             matnr AS material,
             werks AS plant,
             lgort AS storage_location,
             batch,
             movement_type,
             min_shelf_life,
             unit,
             strategy,
             start_date,
             start_time,
              finish_date,
              finish_time,
              status,
              available,
             demand_count,
             requested_on_from,
             requested_on_to,
              full_count,
             partial_count,
             unallocated_count,
             allocated,
             shortage,
             message
        FROM zstockalloc_run
        INTO CORRESPONDING FIELDS OF TABLE @rt_runs
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
          AND batch = @iv_batch
          AND run_id = @iv_run_id.
    ENDIF.
    IF sy-subrc <> 0.
      CLEAR rt_runs.
    ENDIF.
    LOOP AT rt_runs ASSIGNING <ls_run>.
      <ls_run>-unit = to_upper( <ls_run>-unit ).
      <ls_run>-status = to_upper( <ls_run>-status ).
      <ls_run>-strategy = to_upper( <ls_run>-strategy ).
      validate_run( is_run = <ls_run> ).
      <ls_run>-requested = <ls_run>-allocated + <ls_run>-shortage.
      IF <ls_run>-requested_on_to IS INITIAL.
        <ls_run>-requested_deadline = <ls_run>-requested_on_from.
      ELSE.
        <ls_run>-requested_deadline = <ls_run>-requested_on_to.
      ENDIF.
    ENDLOOP.
    IF iv_run_id_contains IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF to_upper( <ls_run>-run_id ) NS to_upper( iv_run_id_contains ).
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF lv_strategy IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-strategy <> lv_strategy.
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_legacy_strategy = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-strategy IS NOT INITIAL.
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_requested_overdue = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-requested_on_to IS INITIAL.
          lv_requested_deadline = <ls_run>-requested_on_from.
        ELSE.
          lv_requested_deadline = <ls_run>-requested_on_to.
        ENDIF.
        IF lv_requested_deadline IS INITIAL
            OR lv_requested_deadline >= lv_overdue_date.
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_deadline_only = abap_true.
      DELETE rt_runs WHERE requested_deadline IS INITIAL.
    ENDIF.
    IF iv_deadline_from IS NOT INITIAL OR iv_deadline_to IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-requested_deadline IS INITIAL
            OR ( iv_deadline_from IS NOT INITIAL
              AND <ls_run>-requested_deadline < iv_deadline_from )
            OR ( iv_deadline_to IS NOT INITIAL
              AND <ls_run>-requested_deadline > iv_deadline_to ).
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_deadline_age_from IS NOT INITIAL
        OR iv_deadline_age_to IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-requested_deadline IS INITIAL.
          DELETE rt_runs.
        ELSE.
          lv_deadline_age_days = lv_deadline_age_date
            - <ls_run>-requested_deadline.
          IF ( iv_deadline_age_from IS NOT INITIAL
                AND lv_deadline_age_days < iv_deadline_age_from )
              OR ( iv_deadline_age_to IS NOT INITIAL
                AND lv_deadline_age_days > iv_deadline_age_to ).
            DELETE rt_runs.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_movement_type IS NOT INITIAL OR iv_min_shelf_life IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF ( iv_movement_type IS NOT INITIAL
              AND <ls_run>-movement_type <> iv_movement_type )
            OR ( iv_min_shelf_life IS NOT INITIAL
              AND <ls_run>-min_shelf_life <> iv_min_shelf_life ).
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_run_id IS NOT INITIAL
        OR iv_requested_on_from IS NOT INITIAL
        OR iv_requested_on_to IS NOT INITIAL
        OR lv_unit IS NOT INITIAL
        OR iv_start_date_from IS NOT INITIAL
        OR iv_start_date_to IS NOT INITIAL
        OR iv_finish_date_from IS NOT INITIAL
        OR iv_finish_date_to IS NOT INITIAL
        OR iv_shortage_from IS NOT INITIAL
        OR iv_shortage_to IS NOT INITIAL
        OR iv_allocated_from IS NOT INITIAL
        OR iv_allocated_to IS NOT INITIAL
        OR iv_available_from IS NOT INITIAL
        OR iv_available_to IS NOT INITIAL
        OR iv_requested_from IS NOT INITIAL
        OR iv_requested_to IS NOT INITIAL
        OR iv_demand_from IS NOT INITIAL
        OR iv_demand_to IS NOT INITIAL
        OR iv_coverage_from IS NOT INITIAL
        OR iv_coverage_to IS NOT INITIAL
        OR lv_status IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF iv_run_id IS INITIAL OR <ls_run>-run_id = iv_run_id.
          IF iv_requested_on_from IS INITIAL
              OR <ls_run>-requested_on_from = iv_requested_on_from.
            IF iv_requested_on_to IS INITIAL
                OR <ls_run>-requested_on_to = iv_requested_on_to.
              IF lv_status IS INITIAL OR <ls_run>-status = lv_status.
                IF lv_unit IS INITIAL
                    OR to_upper( <ls_run>-unit ) = lv_unit.
                  IF iv_start_date_from IS INITIAL
                      OR <ls_run>-start_date >= iv_start_date_from.
                    IF iv_start_date_to IS INITIAL
                        OR <ls_run>-start_date <= iv_start_date_to.
                      IF ( iv_finish_date_from IS INITIAL
                            AND iv_finish_date_to IS INITIAL )
                          OR ( <ls_run>-finish_date IS NOT INITIAL
                            AND ( iv_finish_date_from IS INITIAL
                              OR <ls_run>-finish_date >= iv_finish_date_from )
                            AND ( iv_finish_date_to IS INITIAL
                              OR <ls_run>-finish_date <= iv_finish_date_to ) ).
                        IF ( iv_shortage_from IS INITIAL
                              AND iv_shortage_to IS INITIAL )
                            OR ( ( iv_shortage_from IS INITIAL
                              OR <ls_run>-shortage >= iv_shortage_from )
                              AND ( iv_shortage_to IS INITIAL
                                OR <ls_run>-shortage <= iv_shortage_to ) ).
                          IF ( iv_allocated_from IS INITIAL
                                AND iv_allocated_to IS INITIAL )
                              OR ( ( iv_allocated_from IS INITIAL
                                OR <ls_run>-allocated >= iv_allocated_from )
                                AND ( iv_allocated_to IS INITIAL
                                  OR <ls_run>-allocated <= iv_allocated_to ) ).
                            IF ( iv_available_from IS INITIAL
                                  AND iv_available_to IS INITIAL )
                                OR ( ( iv_available_from IS INITIAL
                                  OR <ls_run>-available >= iv_available_from )
                                  AND ( iv_available_to IS INITIAL
                                    OR <ls_run>-available <= iv_available_to ) ).
                              IF ( iv_requested_from IS INITIAL
                                    AND iv_requested_to IS INITIAL )
                                  OR ( ( iv_requested_from IS INITIAL
                                    OR <ls_run>-allocated + <ls_run>-shortage
                                      >= iv_requested_from )
                                    AND ( iv_requested_to IS INITIAL
                                      OR <ls_run>-allocated + <ls_run>-shortage
                                        <= iv_requested_to ) ).
                                IF ( iv_demand_from IS INITIAL
                                      AND iv_demand_to IS INITIAL )
                                    OR ( ( iv_demand_from IS INITIAL
                                      OR <ls_run>-demand_count >= iv_demand_from )
                                      AND ( iv_demand_to IS INITIAL
                                        OR <ls_run>-demand_count <= iv_demand_to ) ).
                                  IF ( iv_coverage_from IS INITIAL
                                        AND iv_coverage_to IS INITIAL ).
                                    APPEND <ls_run> TO lt_filtered.
                                  ELSE.
                                    CLEAR lv_coverage.
                                    IF <ls_run>-allocated + <ls_run>-shortage > 0.
                                      lv_coverage = <ls_run>-allocated * 100
                                        / ( <ls_run>-allocated + <ls_run>-shortage ).
                                      IF ( iv_coverage_from IS INITIAL
                                            OR lv_coverage >= iv_coverage_from )
                                          AND ( iv_coverage_to IS INITIAL
                                            OR lv_coverage <= iv_coverage_to ).
                                        APPEND <ls_run> TO lt_filtered.
                                      ENDIF.
                                    ENDIF.
                                  ENDIF.
                                ENDIF.
                              ENDIF.
                            ENDIF.
                          ENDIF.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      rt_runs = lt_filtered.
    ENDIF.
    IF iv_shortage_pct_from IS NOT INITIAL
        OR iv_shortage_pct_to IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-allocated + <ls_run>-shortage > 0.
          lv_shortage_pct = <ls_run>-shortage * 100
            / ( <ls_run>-allocated + <ls_run>-shortage ).
          IF ( iv_shortage_pct_from IS INITIAL
                OR lv_shortage_pct >= iv_shortage_pct_from )
              AND ( iv_shortage_pct_to IS INITIAL
                OR lv_shortage_pct <= iv_shortage_pct_to ).
            CONTINUE.
          ENDIF.
        ENDIF.
        DELETE rt_runs.
      ENDLOOP.
    ENDIF.
    IF iv_duration_from IS NOT INITIAL OR iv_duration_to IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-finish_date IS INITIAL.
          DELETE rt_runs.
        ELSE.
          cl_abap_tstmp=>td_subtract(
            EXPORTING
              date1    = <ls_run>-finish_date
              time1    = <ls_run>-finish_time
              date2    = <ls_run>-start_date
              time2    = <ls_run>-start_time
            IMPORTING
              res_secs = lv_duration_seconds ).
          IF ( iv_duration_from IS NOT INITIAL
                AND lv_duration_seconds < iv_duration_from )
              OR ( iv_duration_to IS NOT INITIAL
                AND lv_duration_seconds > iv_duration_to ).
            DELETE rt_runs.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_message_contains IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF to_upper( <ls_run>-message ) NS to_upper( iv_message_contains ).
          DELETE rt_runs.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_message_only = abap_true.
      DELETE rt_runs WHERE message IS INITIAL.
    ENDIF.
    IF iv_stale_seconds IS NOT INITIAL OR iv_running_age_to IS NOT INITIAL.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-status <> 'R'.
          DELETE rt_runs.
        ELSE.
          cl_abap_tstmp=>td_subtract(
            EXPORTING
              date1    = sy-datum
              time1    = sy-uzeit
              date2    = <ls_run>-start_date
              time2    = <ls_run>-start_time
            IMPORTING
              res_secs = lv_running_age_seconds ).
          IF lv_running_age_seconds < iv_stale_seconds
              OR ( iv_running_age_to IS NOT INITIAL
                AND lv_running_age_seconds > iv_running_age_to ).
            DELETE rt_runs.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF iv_sort_by_coverage = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        CLEAR lv_coverage.
        IF <ls_run>-allocated + <ls_run>-shortage > 0.
          lv_coverage = <ls_run>-allocated * 100
            / ( <ls_run>-allocated + <ls_run>-shortage ).
        ENDIF.
        APPEND VALUE #(
          coverage   = lv_coverage
          shortage   = <ls_run>-shortage
          start_date = <ls_run>-start_date
          start_time = <ls_run>-start_time
          run_id     = <ls_run>-run_id
          run        = <ls_run> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY coverage shortage DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_coverage_run>).
        APPEND <ls_coverage_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_shrt_pct = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        CLEAR lv_shortage_pct.
        IF <ls_run>-allocated + <ls_run>-shortage > 0.
          lv_shortage_pct = <ls_run>-shortage * 100
            / ( <ls_run>-allocated + <ls_run>-shortage ).
        ENDIF.
        APPEND VALUE #(
          shortage_pct = lv_shortage_pct
          shortage     = <ls_run>-shortage
          start_date   = <ls_run>-start_date
          start_time   = <ls_run>-start_time
          run_id       = <ls_run>-run_id
          run          = <ls_run> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY shortage_pct DESCENDING shortage DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_shortage_pct_run>).
        APPEND <ls_shortage_pct_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_demand_count = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        APPEND VALUE #(
          demand_count = <ls_run>-demand_count
          shortage     = <ls_run>-shortage
          start_date   = <ls_run>-start_date
          start_time   = <ls_run>-start_time
          run_id       = <ls_run>-run_id
          run          = <ls_run> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY demand_count DESCENDING
                                 shortage DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_demand_count_run>).
        APPEND <ls_demand_count_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_deadline_age = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        CLEAR lv_deadline_age_days.
        IF <ls_run>-requested_deadline IS NOT INITIAL.
          lv_deadline_age_days = lv_deadline_age_date
            - <ls_run>-requested_deadline.
        ENDIF.
        APPEND VALUE #(
          deadline_age_available = xsdbool(
            <ls_run>-requested_deadline IS NOT INITIAL )
          deadline_age_days      = lv_deadline_age_days
          deadline_date          = <ls_run>-requested_deadline
          shortage               = <ls_run>-shortage
          start_date             = <ls_run>-start_date
          start_time             = <ls_run>-start_time
          run_id                 = <ls_run>-run_id
          run                    = <ls_run> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY deadline_age_available DESCENDING
                                 deadline_age_days DESCENDING
                                 deadline_date ASCENDING
                                 shortage DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_deadline_age_run>).
        APPEND <ls_deadline_age_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_due = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-requested_on_from IS INITIAL.
          lv_sort_date = <ls_run>-requested_on_to.
        ELSE.
          lv_sort_date = <ls_run>-requested_on_from.
        ENDIF.
        APPEND VALUE #(
          horizon        = xsdbool( lv_sort_date IS NOT INITIAL )
          requested_from = <ls_run>-requested_on_from
          requested_to   = <ls_run>-requested_on_to
          sort_date      = lv_sort_date
          shortage       = <ls_run>-shortage
          start_date     = <ls_run>-start_date
          start_time     = <ls_run>-start_time
          run_id         = <ls_run>-run_id
          run            = <ls_run> ) TO lt_coverage_sorted.
      ENDLOOP.
      SORT lt_coverage_sorted BY horizon DESCENDING
                                 sort_date ASCENDING
                                 requested_to ASCENDING shortage DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_coverage_sorted ASSIGNING FIELD-SYMBOL(<ls_requested_run>).
        APPEND <ls_requested_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_status = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        CASE <ls_run>-status.
          WHEN 'E'.
            lv_status_rank = 1.
          WHEN 'P'.
            lv_status_rank = 2.
          WHEN 'R'.
            lv_status_rank = 3.
          WHEN OTHERS.
            lv_status_rank = 4.
        ENDCASE.
        APPEND VALUE #(
          status_rank = lv_status_rank
          shortage    = <ls_run>-shortage
          start_date  = <ls_run>-start_date
          start_time  = <ls_run>-start_time
          run_id      = <ls_run>-run_id
          run         = <ls_run> ) TO lt_duration_sorted.
      ENDLOOP.
      SORT lt_duration_sorted BY status_rank
                                 shortage DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_duration_sorted ASSIGNING FIELD-SYMBOL(<ls_status_run>).
        APPEND <ls_status_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_duration = abap_true.
      LOOP AT rt_runs ASSIGNING <ls_run>.
        IF <ls_run>-finish_date IS INITIAL.
          lv_duration_seconds = -1.
        ELSE.
          cl_abap_tstmp=>td_subtract(
            EXPORTING
              date1    = <ls_run>-finish_date
              time1    = <ls_run>-finish_time
              date2    = <ls_run>-start_date
              time2    = <ls_run>-start_time
            IMPORTING
              res_secs = lv_duration_seconds ).
        ENDIF.
        APPEND VALUE #(
          coverage         = 0
          shortage         = <ls_run>-shortage
          start_date       = <ls_run>-start_date
          start_time       = <ls_run>-start_time
          run_id           = <ls_run>-run_id
          duration_seconds = lv_duration_seconds
          run              = <ls_run> ) TO lt_duration_sorted.
      ENDLOOP.
      SORT lt_duration_sorted BY duration_seconds DESCENDING
                                 start_date DESCENDING start_time DESCENDING
                                 run_id DESCENDING.
      CLEAR rt_runs.
      LOOP AT lt_duration_sorted ASSIGNING FIELD-SYMBOL(<ls_duration_run>).
        APPEND <ls_duration_run>-run TO rt_runs.
      ENDLOOP.
    ELSEIF iv_sort_by_shortage = abap_true.
      SORT rt_runs BY shortage DESCENDING
                      start_date DESCENDING
                      start_time DESCENDING
                      run_id DESCENDING.
    ELSE.
      SORT rt_runs BY start_date DESCENDING
                      start_time DESCENDING
                      run_id DESCENDING.
    ENDIF.
    ev_total_rows = lines( rt_runs ).
    IF iv_offset > 0.
      IF iv_offset >= lines( rt_runs ).
        CLEAR rt_runs.
      ELSE.
        DELETE rt_runs FROM 1 TO iv_offset.
      ENDIF.
    ENDIF.
    IF iv_max_rows > 0 AND lines( rt_runs ) > iv_max_rows.
      lv_limit_start = iv_max_rows + 1.
      DELETE rt_runs FROM lv_limit_start.
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~start_run.
    DATA ls_run TYPE zstockalloc_run.
    DATA lv_strategy TYPE zif_allocation_audit=>ty_strategy.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.

    lv_strategy = to_upper( iv_strategy ).
    lv_unit = to_upper( iv_unit ).

    IF iv_requested_on_from IS NOT INITIAL
        AND iv_requested_on_to IS NOT INITIAL
        AND iv_requested_on_from > iv_requested_on_to.
      raise_error( iv_message = 'Audit requested date range is invalid' ).
    ENDIF.
    IF iv_min_shelf_life < 0.
      raise_error( iv_message = 'Audit minimum shelf life is invalid' ).
    ENDIF.
    IF iv_movement_type IS NOT INITIAL
        AND iv_movement_type CN '0123456789'.
      raise_error( iv_message = 'Audit movement type is invalid' ).
    ENDIF.
    IF lv_strategy IS NOT INITIAL
        AND lv_strategy <> 'P'
        AND lv_strategy <> 'F'
        AND lv_strategy <> 'N'
        AND lv_strategy <> 'S'
        AND lv_strategy <> 'L'
        AND lv_strategy <> 'B'.
      raise_error( iv_message = 'Audit strategy is invalid' ).
    ENDIF.
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR lv_unit IS INITIAL.
      raise_error( iv_message = 'Audit run scope is incomplete' ).
    ENDIF.
    IF iv_available < 0 OR iv_demand_count < 0.
      raise_error( iv_message = 'Audit run inputs are invalid' ).
    ENDIF.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_audit_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Audit write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
    ENDIF.
    TRY.
        rv_run_id = cl_system_uuid=>create_uuid_c32_static( ).
      CATCH cx_uuid_error.
        raise_error( iv_message = 'Audit run ID generation failed' ).
    ENDTRY.
    ls_run-mandt = sy-mandt.
    ls_run-run_id = rv_run_id.
    ls_run-matnr = iv_material.
    ls_run-werks = iv_plant.
    ls_run-lgort = iv_storage_location.
    ls_run-batch = iv_batch.
    ls_run-movement_type = iv_movement_type.
    ls_run-min_shelf_life = iv_min_shelf_life.
    ls_run-requested_on_from = iv_requested_on_from.
    ls_run-requested_on_to = iv_requested_on_to.
    ls_run-unit = lv_unit.
    ls_run-strategy = lv_strategy.
    ls_run-start_date = sy-datum.
    ls_run-start_time = sy-uzeit.
    ls_run-status = 'R'.
    ls_run-available = iv_available.
    ls_run-demand_count = iv_demand_count.
    MODIFY zstockalloc_run FROM @ls_run.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit run persistence failed' ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_allocation_audit~finish_run.
    DATA lv_current_status TYPE zif_allocation_audit=>ty_run_status.
    DATA lv_current_available TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_status TYPE zif_allocation_audit=>ty_run_status.

    lv_status = to_upper( iv_status ).

    IF iv_run_id IS INITIAL.
      raise_error( iv_message = 'Audit run ID is required' ).
    ENDIF.
    IF lv_status <> 'S'
        AND lv_status <> 'P'
        AND lv_status <> 'E'.
      raise_error( iv_message = 'Audit final status is invalid' ).
    ENDIF.
    IF ( lv_status = 'P' OR lv_status = 'E' )
        AND iv_message IS INITIAL.
      raise_error( iv_message = 'Audit final message is required' ).
    ENDIF.
    IF iv_available < 0
        OR iv_allocated < 0
        OR iv_shortage < 0
        OR iv_full_count < 0
        OR iv_partial_count < 0
        OR iv_unallocated_count < 0.
      raise_error( iv_message = 'Audit final metrics are invalid' ).
    ENDIF.
    IF mo_write_authority IS BOUND.
      TRY.
          mo_write_authority->check_audit_write( ).
        CATCH zcx_stock_allocation INTO DATA(lo_write_error).
          IF lo_write_error->message IS INITIAL.
            lo_write_error->message = 'Audit write authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_write_error.
      ENDTRY.
    ENDIF.
    SELECT SINGLE status, available
      FROM zstockalloc_run
      INTO (@lv_current_status, @lv_current_available)
      WHERE run_id = @iv_run_id.
    IF sy-subrc <> 0.
      raise_error( iv_message = 'Audit run was not found' ).
    ENDIF.
    IF lv_current_status <> 'R'.
      raise_error( iv_message = 'Audit run is already finalized' ).
    ENDIF.
    IF iv_available <> lv_current_available
        OR iv_allocated > lv_current_available
        OR ( lv_status = 'S' AND iv_shortage <> 0 )
        OR ( lv_status = 'P' AND iv_shortage <= 0 ).
      raise_error( iv_message = 'Audit final metrics are invalid' ).
    ENDIF.
    UPDATE zstockalloc_run
      SET finish_date = @sy-datum,
          finish_time = @sy-uzeit,
           status      = @lv_status,
           available   = @iv_available,
           allocated   = @iv_allocated,
           shortage    = @iv_shortage,
           message     = @iv_message,
           full_count  = @iv_full_count,
           partial_count = @iv_partial_count,
           unallocated_count = @iv_unallocated_count
      WHERE run_id = @iv_run_id
        AND status = 'R'.
    IF sy-subrc <> 0 OR sy-dbcnt <> 1.
      raise_error( iv_message = 'Audit finalization persistence failed' ).
    ENDIF.
    IF mo_transaction IS BOUND.
      TRY.
          mo_transaction->commit( ).
        CATCH zcx_stock_allocation INTO DATA(lo_transaction_error).
          IF lo_transaction_error->message IS INITIAL.
            lo_transaction_error->message = 'Audit finalization commit failed'.
          ENDIF.
          RAISE EXCEPTION lo_transaction_error.
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.

  METHOD validate_run.
    IF is_run-requested_on_from IS NOT INITIAL
        AND is_run-requested_on_to IS NOT INITIAL
        AND is_run-requested_on_from > is_run-requested_on_to.
      raise_error( iv_message = 'Audit run requested date range is invalid' ).
    ENDIF.
    IF is_run-run_id IS INITIAL
        OR is_run-material IS INITIAL
        OR is_run-plant IS INITIAL
        OR is_run-storage_location IS INITIAL
        OR is_run-unit IS INITIAL
        OR is_run-start_date IS INITIAL
        OR is_run-start_time IS INITIAL
        OR is_run-available < 0
        OR is_run-demand_count < 0
        OR is_run-full_count < 0
        OR is_run-partial_count < 0
        OR is_run-unallocated_count < 0
        OR is_run-allocated < 0
        OR is_run-shortage < 0
        OR is_run-allocated > is_run-available.
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
    IF is_run-movement_type IS NOT INITIAL
        AND is_run-movement_type CN '0123456789'.
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
    IF is_run-status <> 'R'
        AND is_run-status <> 'S'
        AND is_run-status <> 'P'
        AND is_run-status <> 'E'.
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
    IF is_run-strategy IS NOT INITIAL
        AND is_run-strategy <> 'P'
        AND is_run-strategy <> 'F'
        AND is_run-strategy <> 'N'
        AND is_run-strategy <> 'S'
        AND is_run-strategy <> 'L'
        AND is_run-strategy <> 'B'.
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
    IF ( is_run-status = 'R'
          AND ( is_run-finish_date IS NOT INITIAL
            OR is_run-finish_time IS NOT INITIAL
            OR is_run-allocated <> 0
            OR is_run-shortage <> 0
            OR is_run-full_count <> 0
            OR is_run-partial_count <> 0
            OR is_run-unallocated_count <> 0
            OR is_run-message IS NOT INITIAL ) )
        OR ( is_run-status <> 'R'
          AND ( is_run-finish_date IS INITIAL
            OR is_run-finish_time IS INITIAL ) )
        OR ( is_run-status = 'S'
          AND ( is_run-shortage <> 0
            OR is_run-message IS NOT INITIAL ) )
        OR ( is_run-status = 'P'
          AND is_run-shortage <= 0 )
        OR ( ( is_run-status = 'P' OR is_run-status = 'E' )
          AND is_run-message IS INITIAL )
        OR ( is_run-status <> 'R'
          AND ( is_run-finish_date < is_run-start_date
            OR ( is_run-finish_date = is_run-start_date
              AND is_run-finish_time < is_run-start_time ) ) ).
      raise_error( iv_message = 'Audit run data is invalid' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
